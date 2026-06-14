#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Build the composite and per-domain release artifacts.

Composite (one per build):
- pg-schema-<VTAG>.sql      : extensions + meta + every domain + fixtures
- pg-fixtures-<VTAG>.sql    : data-only dump of the lookup tables
- KartozaInfrastructureMapper-<VTAG>.gpkg
- pg-migrations-<VTAG>.tar.gz
- gpkg-migrations-<VTAG>.tar.gz

Per-domain (one per domain, 13 of them):
- pg-schema-<NN-name>-<VTAG>.sql : extensions + meta + that domain + relevant fixtures
- KartozaInfrastructureMapper-<NN-name>-<VTAG>.gpkg

Also writes dist/MANIFEST.json with sizes + counts for the PR comment.

The script expects a Postgres database already loaded with the full schema +
fixtures (the CI workflow and scripts/release.sh both arrange this before
invoking the script). The composite GPKG is built from that DB via ogr2ogr;
per-domain GPKGs are sliced from the composite by table-name filter so we
don't re-load 13 times.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess  # nosec B404
import sys
import tarfile
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SQL_DIR = REPO / "sql"

# CREATE TABLE [IF NOT EXISTS] "name" ( ...  — name may be unquoted or quoted,
# may follow the keyword on the next line, may have arbitrary whitespace.
TABLE_RE = re.compile(
    r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?\"?([a-zA-Z_][a-zA-Z0-9_]*)\"?\s*\(",
    re.IGNORECASE,
)
# INSERT INTO target — used for fixture filtering.
INSERT_RE = re.compile(
    r"^\s*INSERT\s+INTO\s+\"?([a-zA-Z_][a-zA-Z0-9_]*)\"?", re.IGNORECASE
)


@dataclass
class Domain:
    """One capture domain (e.g. fencing, roads) — its file, slug, and tables."""

    number: int
    slug: str  # e.g. "fencing"
    label: str  # e.g. "07-fencing" for filenames
    sql_path: Path
    tables: list[str] = field(default_factory=list)


def discover_domains() -> list[Domain]:
    """Find sql/N-name.sql files, sorted by N, and parse their tables.

    Returns:
        The 13 capture domains in numeric order. Each carries the file
        path, slug, padded label (``07-fencing``), and the list of tables
        declared inside.
    """
    domains: list[Domain] = []
    pattern = re.compile(r"^(\d+)-([a-z0-9_]+)\.sql$")
    for entry in SQL_DIR.iterdir():
        match = pattern.match(entry.name)
        if not match:
            continue
        number = int(match.group(1))
        if number == 0:  # 0-meta.sql is the meta layer, not a domain.
            continue
        slug = match.group(2)
        label = f"{number:02d}-{slug}"
        text = entry.read_text(encoding="utf-8")
        tables = TABLE_RE.findall(text)
        domains.append(
            Domain(number=number, slug=slug, label=label, sql_path=entry, tables=tables)
        )
    domains.sort(key=lambda d: d.number)
    return domains


def filter_fixtures(fixtures_text: str, allowed_tables: set[str]) -> str:
    """Keep the INSERT blocks targeting allowed_tables, skip the rest.

    Fixtures are organised as ``INSERT INTO <table> VALUES (...);``
    statements interleaved with ``-- domain`` comment headers. We pass
    through every line that is part of an allowed INSERT statement (a
    statement spans from the INSERT keyword to the terminating semicolon)
    plus comment lines that appear immediately before such an insert.

    Args:
        fixtures_text: Full text of ``sql/fixtures.sql``.
        allowed_tables: Table names whose INSERTs should be kept.

    Returns:
        A filtered SQL string containing only the allowed INSERTs and
        their leading comment headers.
    """
    out_lines: list[str] = []
    pending_comments: list[str] = []
    in_allowed = False

    for line in fixtures_text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("--") or not stripped:
            if in_allowed:
                out_lines.append(line)
            else:
                pending_comments.append(line)
            continue

        match = INSERT_RE.match(line)
        if match:
            target = match.group(1)
            in_allowed = target in allowed_tables
            if in_allowed:
                out_lines.extend(pending_comments)
                pending_comments = []
                out_lines.append(line)
            # else: drop the line silently
        elif in_allowed:
            out_lines.append(line)

        if in_allowed and stripped.endswith(";"):
            in_allowed = False

    return "".join(out_lines)


SEPARATOR = "-- " + "=" * 60 + "\n"


def concat_sql(parts: list[Path], header: str) -> str:
    """Concatenate SQL files with a banner separating each.

    Args:
        parts: Files to concatenate, in load order.
        header: Block of comment text placed at the top of the bundle.

    Returns:
        The fully-assembled SQL bundle as a single string.
    """
    out = [header]
    for path in parts:
        out.append("\n" + SEPARATOR)
        out.append(f"-- {path.relative_to(REPO)}\n")
        out.append(SEPARATOR)
        out.append(path.read_text(encoding="utf-8"))
    return "".join(out)


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Run a subprocess, echoing the command, and abort on non-zero.

    Args:
        cmd: Argv to execute, in list form (no shell).
        **kwargs: Extra keyword arguments forwarded to ``subprocess.run``.

    Returns:
        The completed process object.
    """
    print("$", " ".join(cmd), flush=True)
    return subprocess.run(cmd, check=True, **kwargs)  # nosec B603


def pg_conn_args(args: argparse.Namespace) -> list[str]:
    """Build the standard ``-h -p -U -d`` argv slice for psql/pg_dump.

    Args:
        args: Parsed CLI namespace carrying host/port/user/database.

    Returns:
        Argv fragment ready to splice into a psql or pg_dump command.
    """
    return [
        "-h",
        args.pg_host,
        "-p",
        str(args.pg_port),
        "-U",
        args.pg_user,
        "-d",
        args.pg_database,
    ]


def pg_env(args: argparse.Namespace) -> dict[str, str]:
    """Environment copy with PGPASSWORD set when one was provided.

    Args:
        args: Parsed CLI namespace; only ``pg_password`` is consulted.

    Returns:
        A copy of ``os.environ`` with ``PGPASSWORD`` injected (if non-empty).
    """
    env = os.environ.copy()
    if args.pg_password:
        env["PGPASSWORD"] = args.pg_password
    return env


def build_composite_schema(out_dir: Path, vtag: str, domains: list[Domain]) -> Path:
    """Concat extensions + meta + every domain + fixtures into one SQL bundle.

    Args:
        out_dir: Directory to write the output file into.
        vtag: Version tag interpolated into the filename and header.
        domains: Domain list returned by ``discover_domains``.

    Returns:
        Path to the freshly-written ``pg-schema-<vtag>.sql``.
    """
    parts = [
        SQL_DIR / "extensions.sql",
        SQL_DIR / "0-meta.sql",
        *[d.sql_path for d in domains],
        SQL_DIR / "fixtures.sql",
    ]
    header = (
        f"-- Infrastructure Mapper composite schema {vtag}\n"
        "-- Generated by scripts/build_artifacts.py — do not edit by hand.\n"
        "-- Apply against an empty database to bootstrap the full schema + fixtures.\n"
    )
    out = out_dir / f"pg-schema-{vtag}.sql"
    out.write_text(concat_sql(parts, header), encoding="utf-8")
    return out


def build_domain_schema(
    out_dir: Path, vtag: str, domain: Domain, fixtures_text: str
) -> Path:
    """Write a self-contained SQL bundle for a single domain.

    The bundle includes the extensions layer, the meta layer, the
    domain's own SQL file, and the filtered fixtures targeting tables in
    that domain. Loading it into an empty database bootstraps the
    domain in isolation.

    Args:
        out_dir: Directory to write the output file into.
        vtag: Version tag interpolated into the filename and header.
        domain: The capture domain whose slice this is.
        fixtures_text: Full text of ``sql/fixtures.sql`` (filtered here).

    Returns:
        Path to the freshly-written per-domain SQL bundle.
    """
    domain_fixtures = filter_fixtures(fixtures_text, set(domain.tables))
    header = (
        f"-- Infrastructure Mapper — {domain.label} schema slice {vtag}\n"
        "-- Generated by scripts/build_artifacts.py — do not edit by hand.\n"
        "-- Apply against an empty database to bootstrap only this domain.\n"
    )
    body = concat_sql(
        [SQL_DIR / "extensions.sql", SQL_DIR / "0-meta.sql", domain.sql_path],
        header,
    )
    if domain_fixtures.strip():
        body += (
            "\n-- ============================================================\n"
            f"-- {domain.label} fixtures (filtered from sql/fixtures.sql)\n"
            "-- ============================================================\n"
        )
        body += domain_fixtures
    out = out_dir / f"pg-schema-{domain.label}-{vtag}.sql"
    out.write_text(body, encoding="utf-8")
    return out


def build_pg_fixtures_dump(args: argparse.Namespace, out_dir: Path, vtag: str) -> Path:
    """Write a data-only ``pg_dump`` of the lookup tables.

    The set of "lookup tables" is the same heuristic the previous
    Release.yml used: any table whose name ends ``_type``, ``_status``,
    ``_surface``, ``_condition``, or ``_category`` plus a handful of
    named singletons.

    Args:
        args: Parsed CLI namespace (host/port/user/db/password).
        out_dir: Directory to write the output file into.
        vtag: Version tag interpolated into the filename.

    Returns:
        Path to the freshly-written ``pg-fixtures-<vtag>.sql``.
    """
    sql_list = (
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema='public' AND ("
        "table_name ~ '_(type|status|surface|condition|category)$' "
        "OR table_name IN "
        "('condition','month','water_source','plant_usage','pole_material',"
        "'pole_function','facility_type'))"
    )  # nosec B608 — fixed-form schema introspection, no untrusted input.
    psql = ["psql", *pg_conn_args(args), "-At", "-c", sql_list]
    print("$", " ".join(psql), flush=True)
    result = subprocess.run(  # nosec B603
        psql, check=True, capture_output=True, text=True, env=pg_env(args)
    )
    tables = [t.strip() for t in result.stdout.splitlines() if t.strip()]
    out = out_dir / f"pg-fixtures-{vtag}.sql"
    cmd = ["pg_dump", *pg_conn_args(args), "--data-only"]
    for t in tables:
        cmd.extend(["-t", t])
    with out.open("w", encoding="utf-8") as fh:
        print("$", " ".join(cmd), flush=True)
        subprocess.run(cmd, check=True, stdout=fh, env=pg_env(args))  # nosec B603
    return out


def build_composite_gpkg(args: argparse.Namespace, out_dir: Path, vtag: str) -> Path:
    """Run ogr2ogr against PG -> GPKG and post-process the version view.

    Args:
        args: Parsed CLI namespace (host/port/user/db/password).
        out_dir: Directory to write the output file into.
        vtag: Version tag interpolated into the filename.

    Returns:
        Path to the freshly-written ``KartozaInfrastructureMapper-<vtag>.gpkg``.
    """
    out = out_dir / f"KartozaInfrastructureMapper-{vtag}.gpkg"
    if out.exists():
        out.unlink()
    pg_conn = (
        f"PG:host={args.pg_host} port={args.pg_port} "
        f"dbname={args.pg_database} user={args.pg_user}"
    )
    if args.pg_password:
        pg_conn += f" password={args.pg_password}"
    cmd = [
        "ogr2ogr",
        "-f",
        "GPKG",
        str(out),
        pg_conn,
        "-oo",
        "LIST_ALL_TABLES=YES",
    ]
    print("$", " ".join(cmd[:6] + ["<PG conn>"] + cmd[7:]), flush=True)
    subprocess.run(cmd, check=True, env=pg_env(args))  # nosec B603
    # current_schema_version is a view in PG; ogr2ogr materialises it as a
    # table. Recreate it as a view so the GPKG stays consistent.
    fix_sql = (
        "DROP TABLE IF EXISTS current_schema_version; "
        "DROP VIEW IF EXISTS current_schema_version; "
        "CREATE VIEW current_schema_version AS SELECT version, major, minor, "
        "patch, applied_at, is_baseline FROM schema_migrations "
        "ORDER BY major DESC, minor DESC, patch DESC LIMIT 1; "
        "DELETE FROM gpkg_contents WHERE table_name = 'current_schema_version';"
    )  # nosec B608 — fixed DDL, no user input.
    subprocess.run(["sqlite3", str(out), fix_sql], check=True)  # nosec B603
    return out


def build_domain_gpkg(
    composite_gpkg: Path, out_dir: Path, vtag: str, domain: Domain
) -> Path:
    """Slice the composite GPKG down to just one domain's tables.

    Copies the composite then DROPs every table whose name is not in the
    domain's allow-list (plus ``gpkg_*`` metadata tables,
    ``spatial_ref_sys``, and ``schema_migrations``, which every slice
    needs). This is faster than re-running ogr2ogr per domain and
    guarantees identical row content between composite and slice.

    Args:
        composite_gpkg: The already-built composite GeoPackage to slice from.
        out_dir: Directory to write the per-domain output into.
        vtag: Version tag interpolated into the filename.
        domain: The capture domain whose slice this is.

    Returns:
        Path to the freshly-written per-domain GeoPackage.
    """
    out = out_dir / f"KartozaInfrastructureMapper-{domain.label}-{vtag}.gpkg"
    if out.exists():
        out.unlink()
    shutil.copyfile(composite_gpkg, out)

    keep = set(domain.tables) | {
        "schema_migrations",
        "spatial_ref_sys",
    }
    # Discover all user-visible tables (the gpkg_* metadata tables are kept by
    # virtue of not being in gpkg_contents — we only drop tables that are
    # registered as data).
    list_sql = "SELECT table_name FROM gpkg_contents"
    result = subprocess.run(  # nosec B603
        ["sqlite3", str(out), list_sql],
        check=True,
        capture_output=True,
        text=True,
    )
    all_tables = [t.strip() for t in result.stdout.splitlines() if t.strip()]
    drop_targets = [t for t in all_tables if t not in keep]
    if drop_targets:
        script = _build_gpkg_drop_script(drop_targets)
        subprocess.run(["sqlite3", str(out), script], check=True)  # nosec B603
    return out


_GPKG_DROP_TEMPLATES = (
    # Single quotes around the table name: in SQLite double quotes denote
    # identifiers, so `WHERE table_name = "building"` would be parsed as
    # comparing against the *column* named building (which doesn't exist) and
    # fail with "no such column". Single quotes give us a string literal.
    # Domain table names never contain a single quote, so straight
    # interpolation is safe.
    "DELETE FROM gpkg_contents WHERE table_name = '{}';",
    "DELETE FROM gpkg_geometry_columns WHERE table_name = '{}';",
    # DROP TABLE uses double quotes — that's identifier-quoting, which is
    # what we want for the table name in this statement.
    'DROP TABLE IF EXISTS "{}";',
)


def _build_gpkg_drop_script(tables: list[str]) -> str:
    """Build the transactional sqlite script that drops the given tables.

    Identifiers come from ``gpkg_contents`` (we own the schema producing
    those tables), so interpolating them via ``.format()`` is safe —
    bandit's B608 alert on the templates above is a known false positive.

    Args:
        tables: Table names to drop, plus their metadata entries.

    Returns:
        A single sqlite script wrapped in BEGIN/COMMIT plus VACUUM.
    """
    parts = ["BEGIN;"]
    for t in tables:
        for tpl in _GPKG_DROP_TEMPLATES:
            parts.append(tpl.format(t))
    parts.extend(["COMMIT;", "VACUUM;"])
    return " ".join(parts)


def build_migration_archives(
    out_dir: Path, vtag: str
) -> tuple[Path | None, Path | None]:
    """Tar up the frozen PG + GPKG migrations alongside their runner scripts.

    Args:
        out_dir: Directory to write the tarballs into.
        vtag: Version tag interpolated into both filenames.

    Returns:
        Tuple of ``(pg_archive_path, gpkg_archive_path)``. Either may be
        ``None`` if the corresponding migration directory is empty.
    """
    pg_archive = None
    gpkg_archive = None
    pg_files = sorted((SQL_DIR / "migrations" / "pg").glob("v*.sql"))
    gpkg_files = sorted((SQL_DIR / "migrations" / "gpkg").glob("v*.sql"))
    if pg_files:
        pg_archive = out_dir / f"pg-migrations-{vtag}.tar.gz"
        with tarfile.open(pg_archive, "w:gz") as tar:
            for f in pg_files:
                tar.add(f, arcname=str(f.relative_to(REPO)))
            tar.add(REPO / "scripts/migrate_pg.sh", arcname="scripts/migrate_pg.sh")
    if gpkg_files:
        gpkg_archive = out_dir / f"gpkg-migrations-{vtag}.tar.gz"
        with tarfile.open(gpkg_archive, "w:gz") as tar:
            for f in gpkg_files:
                tar.add(f, arcname=str(f.relative_to(REPO)))
            tar.add(REPO / "scripts/migrate_gpkg.py", arcname="scripts/migrate_gpkg.py")
    return pg_archive, gpkg_archive


def write_manifest(out_dir: Path, vtag: str, domains: list[Domain]) -> Path:
    """Index every artifact in dist/ with byte size + per-domain table list.

    Args:
        out_dir: Directory containing the artifacts; manifest is written here too.
        vtag: Version tag recorded in the manifest body.
        domains: Domain list recorded in the manifest body.

    Returns:
        Path to the freshly-written ``MANIFEST.json``.
    """
    entries = []
    for path in sorted(out_dir.iterdir()):
        if path.name == "MANIFEST.json":
            continue
        if not path.is_file():
            continue
        entries.append({"name": path.name, "bytes": path.stat().st_size})
    manifest = {
        "version": vtag,
        "artifacts": entries,
        "domains": [
            {"number": d.number, "slug": d.slug, "label": d.label, "tables": d.tables}
            for d in domains
        ],
    }
    out = out_dir / "MANIFEST.json"
    out.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    return out


def main() -> int:
    """CLI entry point — parse args, build every artifact into ``--out``.

    Returns:
        Exit code (0 on success; the script otherwise raises rather than
        returning a non-zero value).
    """
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n", maxsplit=1)[0])
    parser.add_argument(
        "--version",
        required=True,
        help="Version tag for filenames, e.g. v0.2.0 or pr-123-abc1234",
    )
    parser.add_argument(
        "--out", default=str(REPO / "dist"), help="Output directory (default: ./dist)"
    )
    parser.add_argument("--pg-host", default=os.environ.get("PGHOST", "localhost"))
    parser.add_argument("--pg-port", default=os.environ.get("PGPORT", "5432"))
    parser.add_argument("--pg-user", default=os.environ.get("PGUSER", "postgres"))
    parser.add_argument("--pg-database", default=os.environ.get("PGDATABASE", "gis"))
    parser.add_argument("--pg-password", default=os.environ.get("PGPASSWORD", ""))
    parser.add_argument(
        "--skip-gpkg",
        action="store_true",
        help="Skip GPKG builds (useful for fast schema-only iteration)",
    )
    args = parser.parse_args()

    vtag = args.version
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    domains = discover_domains()
    print(f"Discovered {len(domains)} domains:")
    for d in domains:
        print(f"  {d.label}  ({len(d.tables)} tables)")
    fixtures_text = (SQL_DIR / "fixtures.sql").read_text(encoding="utf-8")

    print("\n== Composite schema ==")
    build_composite_schema(out_dir, vtag, domains)
    build_pg_fixtures_dump(args, out_dir, vtag)

    if not args.skip_gpkg:
        print("\n== Composite GPKG ==")
        composite_gpkg = build_composite_gpkg(args, out_dir, vtag)
    else:
        composite_gpkg = None

    print("\n== Per-domain schemas ==")
    for d in domains:
        build_domain_schema(out_dir, vtag, d, fixtures_text)

    if not args.skip_gpkg and composite_gpkg is not None:
        print("\n== Per-domain GPKGs ==")
        for d in domains:
            build_domain_gpkg(composite_gpkg, out_dir, vtag, d)

    print("\n== Migration archives ==")
    build_migration_archives(out_dir, vtag)

    print("\n== Manifest ==")
    manifest = write_manifest(out_dir, vtag, domains)
    print(f"Wrote {manifest}")

    print("\nAll artifacts:")
    for path in sorted(out_dir.iterdir()):
        if path.is_file():
            size_kb = path.stat().st_size / 1024
            print(f"  {path.name:55s}  {size_kb:>10.1f} KiB")

    return 0


if __name__ == "__main__":
    sys.exit(main())
