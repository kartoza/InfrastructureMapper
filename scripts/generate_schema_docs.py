#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Regenerate per-component schema reference sections in sql/N-component.md.

The hand-written narrative, mermaid diagrams, and prompts at the top of each
.md file are left untouched. This script manages only a delimited "Schema
Reference" section appended to each file, replacing it on every run:

    <!-- SCHEMA-REFERENCE-START - auto-generated, do not edit by hand -->
    ## Schema Reference
    ...
    <!-- SCHEMA-REFERENCE-END -->

The content reflects the materialized current state - baseline plus every
frozen migration applied - introspected from a fresh reference Postgres DB
built and torn down on each run.

Usage:
    scripts/generate_schema_docs.py [--keep-db]
"""
from __future__ import annotations

import argparse
import os
import pathlib
import re
import subprocess
import sys
from typing import Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent

_HOSTNAME_RE = re.compile(r"\A[A-Za-z0-9._-]{1,253}\Z")
_DBNAME_RE = re.compile(r"\A[A-Za-z0-9_][A-Za-z0-9_-]{0,62}\Z")
_PORT_RE = re.compile(r"\A[0-9]{1,5}\Z")


def _validated_pghost(raw: str) -> str:
    """Validate a PGHOST value before letting it reach a subprocess.

    Args:
        raw: Candidate host string, either an absolute path to a Unix socket
            directory or a DNS/IP literal.

    Returns:
        The same ``raw`` value if it is acceptable.

    Raises:
        RuntimeError: If ``raw`` is neither an existing directory nor a safe
            hostname/IP literal.
    """
    if raw.startswith("/"):
        if pathlib.Path(raw).is_dir():
            return raw
        raise RuntimeError(f"PGHOST {raw!r} is not an existing directory.")
    if _HOSTNAME_RE.match(raw):
        return raw
    raise RuntimeError(f"PGHOST {raw!r} is not a valid host or socket directory.")


def _validated_pgport(raw: str) -> str:
    """Validate a PGPORT value.

    Args:
        raw: Candidate port string.

    Returns:
        The same ``raw`` value if it is an integer between 1 and 65535.

    Raises:
        RuntimeError: If ``raw`` does not parse as a valid TCP port number.
    """
    if not _PORT_RE.match(raw) or not 1 <= int(raw) <= 65535:
        raise RuntimeError(f"PGPORT {raw!r} is not a valid port number.")
    return raw


def _validated_dbname(raw: str) -> str:
    """Validate a database name.

    Args:
        raw: Candidate database name.

    Returns:
        The same ``raw`` value if it matches Postgres's safe identifier shape.

    Raises:
        RuntimeError: If ``raw`` contains characters outside the allowlist.
    """
    if not _DBNAME_RE.match(raw):
        raise RuntimeError(f"Database name {raw!r} contains invalid characters.")
    return raw


PGHOST = _validated_pghost(os.environ.get("PGHOST", str(ROOT / "pgdata")))
PGPORT = _validated_pgport(os.environ.get("PGPORT", "5432"))
DB_NAME = _validated_dbname(os.environ.get("DOC_DB", "im_docs_build"))

START_MARK = "<!-- SCHEMA-REFERENCE-START - auto-generated, do not edit by hand -->"
END_MARK = "<!-- SCHEMA-REFERENCE-END -->"

CREATE_TABLE_RE = re.compile(
    r"CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+(\w+)\s*\(",
    re.IGNORECASE,
)

CONSTRAINT_LABEL = {
    "p": "PRIMARY KEY",
    "u": "UNIQUE",
    "f": "FOREIGN KEY",
    "c": "CHECK",
    "x": "EXCLUSION",
}


def _psql_argv(db: str) -> List[str]:
    """Build the static psql invocation prefix from already-validated values.

    Args:
        db: Target database name.

    Returns:
        A list of command-line tokens ready to be passed to ``subprocess``.
    """
    return ["psql", "-h", PGHOST, "-p", PGPORT, "-d", _validated_dbname(db)]


def psql(sql: str, db: str = DB_NAME) -> str:
    """Run a SQL statement against the reference DB and return stdout.

    Args:
        sql: The SQL statement to execute via ``psql -c``.
        db: Target database name. Defaults to the module-level ``DB_NAME``.

    Returns:
        The captured stdout as a pipe-separated UTF-8 string.
    """
    # bearer:disable=python_lang_os_command_injection
    return subprocess.check_output(  # noqa: S603 - list-form, all args validated
        _psql_argv(db) + ["-At", "-F", "|", "-c", sql],
        text=True,
    )


def psql_file(file_path: pathlib.Path, db: str = DB_NAME) -> None:
    """Apply a SQL file against the reference DB via ``psql -f``.

    Args:
        file_path: Path to the SQL file to execute.
        db: Target database name. Defaults to the module-level ``DB_NAME``.
    """
    # bearer:disable=python_lang_os_command_injection
    subprocess.run(  # noqa: S603 - list-form, all args validated
        _psql_argv(db) + ["-v", "ON_ERROR_STOP=1", "-q", "-f", str(file_path)],
        check=True,
    )


def build_reference_db() -> None:
    """Drop and re-create the reference DB, apply baseline + migrations.

    The reference DB ends up at the schema version recorded in the repo's
    ``VERSION`` file plus any frozen ``sql/migrations/pg/v*.sql`` files.
    """
    subprocess.run(
        ["dropdb", "-h", PGHOST, "-p", PGPORT, "--if-exists", DB_NAME],
        check=True,
    )
    subprocess.run(["createdb", "-h", PGHOST, "-p", PGPORT, DB_NAME], check=True)

    psql_file(ROOT / "sql" / "extensions.sql")
    psql_file(ROOT / "sql" / "0-meta.sql")
    for f in _component_files():
        psql_file(f)
    psql_file(ROOT / "sql" / "fixtures.sql")

    # Stamp baseline so current_schema_version works.
    version = (ROOT / "VERSION").read_text().strip()
    maj, minor, patch = version.split(".")
    psql(
        f"""
        INSERT INTO schema_migrations
            (version, major, minor, patch, applied_by, checksum, is_baseline, notes)
        VALUES ('v{version}', {maj}, {minor}, {patch}, 'generate_schema_docs',
                'doc-gen', TRUE, 'Reference build')
        ON CONFLICT DO NOTHING;
        """
    )

    # Apply frozen migrations on top.
    for mig in sorted((ROOT / "sql" / "migrations" / "pg").glob("v*.sql")):
        psql_file(mig)


def drop_reference_db() -> None:
    """Drop the reference DB if it exists. Best-effort; ignores failures."""
    subprocess.run(
        ["dropdb", "-h", PGHOST, "-p", PGPORT, "--if-exists", DB_NAME],
        check=False,
    )


def _component_files() -> List[pathlib.Path]:
    """Return top-level numbered component SQL files in numeric order.

    Returns:
        A list of ``sql/N-domain.sql`` paths sorted ascending by leading
        integer (so ``2-`` precedes ``10-``).
    """
    candidates = list((ROOT / "sql").glob("[1-9]*.sql"))
    files: List[pathlib.Path] = []
    for p in candidates:
        m = re.match(r"^(\d+)-", p.name)
        if m:
            files.append(p)
    files.sort(key=lambda p: int(p.name.split("-")[0]))
    return files


def extract_table_names(sql_path: pathlib.Path) -> List[str]:
    """Extract table names declared by ``CREATE TABLE`` statements.

    Args:
        sql_path: Path to a SQL file.

    Returns:
        The names of every table the file declares, in source order.
    """
    text = sql_path.read_text(encoding="utf-8")
    return [m.group(1) for m in CREATE_TABLE_RE.finditer(text)]


def introspect_table(name: str) -> Dict:
    """Inspect a table's columns and constraints via Postgres introspection.

    Args:
        name: Unqualified table name in the ``public`` schema.

    Returns:
        A dictionary with keys ``name``, ``comment``, ``columns`` and
        ``constraints`` describing the table's current shape.
    """
    table_comment = psql(
        f"SELECT COALESCE(obj_description('public.{name}'::regclass, 'pg_class'), '');"
    ).strip()

    cols_raw = psql(
        f"""
        SELECT column_name, data_type, is_nullable, COALESCE(column_default, ''),
               COALESCE(col_description('public.{name}'::regclass, ordinal_position), '')
        FROM information_schema.columns
        WHERE table_schema='public' AND table_name='{name}'
        ORDER BY ordinal_position;
    """
    )
    columns = []
    for line in cols_raw.strip().split("\n"):
        if not line:
            continue
        parts = line.split("|")
        # Pad in case of trailing-empty truncation
        while len(parts) < 5:
            parts.append("")
        columns.append(
            {
                "name": parts[0],
                "type": parts[1],
                "nullable": parts[2] == "YES",
                "default": parts[3],
                "comment": parts[4],
            }
        )

    cons_raw = psql(
        f"""
        SELECT conname, contype, pg_get_constraintdef(oid)
        FROM pg_constraint
        WHERE conrelid = 'public.{name}'::regclass
        ORDER BY CASE contype WHEN 'p' THEN 0 WHEN 'u' THEN 1 WHEN 'f' THEN 2 WHEN 'c' THEN 3 ELSE 9 END,
                 conname;
    """
    )
    constraints = []
    for line in cons_raw.strip().split("\n"):
        if not line:
            continue
        parts = line.split("|", 2)
        while len(parts) < 3:
            parts.append("")
        constraints.append({"name": parts[0], "type": parts[1], "def": parts[2]})

    return {
        "name": name,
        "comment": table_comment,
        "columns": columns,
        "constraints": constraints,
    }


def render_table_md(t: Dict) -> str:
    """Render a single table's reference markdown.

    Args:
        t: A dictionary as returned by ``introspect_table``.

    Returns:
        A markdown fragment with a heading, optional description, a column
        table, and a constraints list.
    """
    lines = [f"### `{t['name']}`", ""]
    if t["comment"]:
        lines += [t["comment"], ""]
    lines += [
        "| Column | Type | Nullable | Default | Description |",
        "|---|---|---|---|---|",
    ]
    for c in t["columns"]:
        comment = c["comment"].replace("|", "\\|").replace("\n", " ")
        default = (
            c["default"].replace("|", "\\|").replace("\n", " ") if c["default"] else ""
        )
        nullable = "yes" if c["nullable"] else "no"
        default_md = f"`{default}`" if default else ""
        lines.append(
            f"| `{c['name']}` | `{c['type']}` | {nullable} | {default_md} | {comment} |"
        )
    if t["constraints"]:
        lines += ["", "**Constraints:**", ""]
        for ct in t["constraints"]:
            label = CONSTRAINT_LABEL.get(ct["type"], ct["type"])
            lines.append(f"- {label} `{ct['name']}`: `{ct['def']}`")
    return "\n".join(lines)


def render_component_section(sql_path: pathlib.Path, version: str) -> str:
    """Render the full Schema Reference section for one component.

    Args:
        sql_path: Path to the baseline component SQL file.
        version: Materialised schema version label, e.g. ``v0.1.0``.

    Returns:
        A complete delimited markdown section ready to insert into the .md
        file.
    """
    tables = extract_table_names(sql_path)
    if not tables:
        body = f"_No tables found in `{sql_path.name}`._"
    else:
        chunks = [
            f"_Materialized at **{version}** - baseline plus every applied PG migration._",
            f"_Source: `{sql_path.name}`. {len(tables)} table(s)._",
        ]
        chunks.extend(render_table_md(introspect_table(tn)) for tn in tables)
        body = "\n\n".join(chunks)

    return f"{START_MARK}\n## Schema Reference\n\n{body}\n{END_MARK}"


def upsert_section(md_path: pathlib.Path, new_section: str) -> bool:
    """Insert or replace the delimited Schema Reference block in ``md_path``.

    Args:
        md_path: Path to the per-component .md file.
        new_section: Pre-rendered delimited markdown block.

    Returns:
        ``True`` if the file's contents changed (and were written),
        ``False`` if the new section was already present byte-for-byte.
    """
    current = md_path.read_text(encoding="utf-8") if md_path.exists() else ""
    pattern = re.compile(
        re.escape(START_MARK) + r".*?" + re.escape(END_MARK),
        re.DOTALL,
    )
    if pattern.search(current):
        replaced = pattern.sub(new_section, current)
    else:
        head = current.rstrip() + "\n\n" if current.strip() else ""
        replaced = head + new_section + "\n"
    if replaced != current:
        md_path.write_text(replaced, encoding="utf-8")
        return True
    return False


def main() -> int:
    """Run the doc generator end-to-end.

    Returns:
        0 on success, 2 if required tooling is missing.
    """
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument(
        "--keep-db",
        action="store_true",
        help="Don't drop the reference DB after generating (for inspection).",
    )
    args = ap.parse_args()

    for cmd in ("psql", "createdb", "dropdb"):
        if subprocess.run(["which", cmd], capture_output=True).returncode != 0:
            print(f"ERROR: '{cmd}' not on PATH (need nix develop).", file=sys.stderr)
            return 2

    print(">> Building reference Postgres DB...")
    build_reference_db()
    try:
        version = psql("SELECT version FROM current_schema_version;").strip()
        print(f">> Reference DB at {version}")

        for sql_file in _component_files():
            md_file = sql_file.with_suffix(".md")
            changed = upsert_section(
                md_file, render_component_section(sql_file, version)
            )
            status = "updated" if changed else "no change"
            print(f">> {md_file.name}: {status}")
    finally:
        if not args.keep_db:
            drop_reference_db()
    return 0


if __name__ == "__main__":
    sys.exit(main())
