#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Apply pending GeoPackage schema migrations to a target .gpkg file.

Strict sequential semantics: reads ``current_schema_version`` from the target,
then applies every ``sql/migrations/gpkg/vX.Y.Z.sql`` whose version is greater,
in semver order, each in its own transaction. Each successful migration records
itself in the ``schema_migrations`` table.

Usage:
    scripts/migrate_gpkg.py [options] <gpkg-file>

Options:
    --dry-run               Show the plan, do not apply.
    --target vX.Y.Z         Stop after this version.
    --crs EPSG:NNNN         Also reproject all spatial columns to this CRS.
"""
from __future__ import annotations

import argparse
import getpass
import hashlib
import pathlib
import re
import sqlite3
import sys
from typing import List, Tuple

ROOT = pathlib.Path(__file__).resolve().parent.parent
MIGRATIONS_DIR = ROOT / "sql" / "migrations" / "gpkg"

SEMVER_RE = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")


def parse_version(s: str) -> Tuple[int, int, int]:
    """Parse a ``vX.Y.Z`` string into a ``(major, minor, patch)`` tuple.

    Args:
        s: Semver label, e.g. ``"v0.2.0"``.

    Returns:
        Three-element tuple of integers ``(major, minor, patch)``.

    Raises:
        ValueError: If ``s`` is not a valid ``vX.Y.Z`` label.
    """
    m = SEMVER_RE.match(s)
    if not m:
        raise ValueError(f"Not a vX.Y.Z version: {s!r}")
    return tuple(int(x) for x in m.groups())  # type: ignore[return-value]


def discover_migrations() -> List[Tuple[Tuple[int, int, int], str, pathlib.Path]]:
    """Discover available GPKG migration files.

    Returns:
        A list of ``(semver_tuple, "vX.Y.Z", path)`` entries sorted ascending
        by semver. Empty if the migrations directory does not exist.
    """
    out: List[Tuple[Tuple[int, int, int], str, pathlib.Path]] = []
    if not MIGRATIONS_DIR.is_dir():
        return out
    for f in MIGRATIONS_DIR.iterdir():
        if not f.is_file() or not f.suffix == ".sql":
            continue
        if not SEMVER_RE.match(f.stem):
            continue
        out.append((parse_version(f.stem), f.stem, f))
    out.sort()
    return out


def read_current_version(conn: sqlite3.Connection) -> Tuple[Tuple[int, int, int], str]:
    """Read the highest applied version from the target GPKG.

    Args:
        conn: Open SQLite connection to the target ``.gpkg`` file.

    Returns:
        A tuple of ``((major, minor, patch), "vX.Y.Z")``.

    Raises:
        RuntimeError: If the target has no ``current_schema_version`` row.
    """
    cur = conn.execute(
        "SELECT version, major, minor, patch FROM current_schema_version"
    )
    row = cur.fetchone()
    if row is None:
        raise RuntimeError("Target GPKG has no rows in current_schema_version.")
    return ((row[1], row[2], row[3]), row[0])


def reproject_geometries(conn: sqlite3.Connection, target_srid: int) -> None:
    """Reproject every spatial column in the target GPKG to a given SRID.

    Args:
        conn: Open SQLite connection to the target ``.gpkg`` file.
        target_srid: EPSG identifier to reproject every spatial column to.

    Raises:
        NotImplementedError: Always — GPKG in-place reprojection requires
            SpatiaLite extensions that are not assumed to be available.
            Rebuild via ``scripts/build_gpkg.sh --crs`` instead.
    """
    del conn, target_srid  # arguments preserved for the eventual implementation
    raise NotImplementedError(
        "GPKG in-place reprojection requires SpatiaLite extensions or an external "
        "ogr2ogr pass. Rebuild the GPKG via 'scripts/build_gpkg.sh --crs ...' instead."
    )


def apply_migration(
    conn: sqlite3.Connection,
    version: str,
    semver: Tuple[int, int, int],
    sql_path: pathlib.Path,
    applied_by: str,
) -> None:
    """Apply one migration SQL file inside a transaction.

    Args:
        conn: Open SQLite connection to the target ``.gpkg`` file.
        version: Semver label, e.g. ``"v0.2.0"``.
        semver: Parsed ``(major, minor, patch)`` tuple matching ``version``.
        sql_path: Path to the migration SQL file to apply.
        applied_by: String stored in ``schema_migrations.applied_by``.

    Raises:
        Exception: Any exception raised by SQLite is re-raised after rolling
            the transaction back.
    """
    sql_text = sql_path.read_text(encoding="utf-8")
    checksum = hashlib.sha256(sql_text.encode("utf-8")).hexdigest()
    major, minor, patch = semver
    try:
        conn.execute("BEGIN")
        conn.executescript(sql_text)
        conn.execute(
            """
            INSERT INTO schema_migrations
                (version, major, minor, patch, applied_by, checksum, is_baseline, notes)
            VALUES (?, ?, ?, ?, ?, ?, 0, NULL)
            ON CONFLICT(version) DO NOTHING
            """,
            (version, major, minor, patch, applied_by, checksum),
        )
        conn.execute("COMMIT")
    except Exception:
        conn.execute("ROLLBACK")
        raise


def main() -> int:
    """Run the migrator end-to-end against a target GPKG file.

    Returns:
        0 on success, 2 on bad arguments.
    """
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n", maxsplit=1)[0])
    ap.add_argument("gpkg", type=pathlib.Path, help="Path to target .gpkg file")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--target", metavar="vX.Y.Z", default=None)
    ap.add_argument("--crs", metavar="EPSG:NNNN", default=None)
    args = ap.parse_args()

    if not args.gpkg.is_file():
        print(f"ERROR: {args.gpkg} does not exist.", file=sys.stderr)
        return 2

    target_semver = None
    if args.target:
        target_semver = parse_version(args.target)

    conn = sqlite3.connect(str(args.gpkg))
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        current_semver, current_label = read_current_version(conn)
        print(f">> Current schema version on {args.gpkg}: {current_label}")

        all_migs = discover_migrations()
        pending = [
            (sv, label, path)
            for (sv, label, path) in all_migs
            if sv > current_semver and (target_semver is None or sv <= target_semver)
        ]

        if not pending:
            print(">> Already at the requested version. Nothing to do.")
            return 0

        print(f">> Will apply {len(pending)} migration(s) in order:")
        for _, label, _ in pending:
            print(f"   {label}")

        if args.dry_run:
            print(">> --dry-run; no changes applied.")
            return 0

        applied_by = f"{getpass.getuser()}@migrate_gpkg.py"
        for sv, label, path in pending:
            print(f">> Applying {label} ({path})...")
            apply_migration(conn, label, sv, path, applied_by)

        if args.crs:
            srid_str = (
                args.crs.removeprefix("EPSG:")
                if args.crs.startswith("EPSG:")
                else args.crs
            )
            srid = int(srid_str)
            if srid == 4326:
                print(
                    "⚠️  WARNING: EPSG:4326 is geographic; ~2 m accuracy.",
                    file=sys.stderr,
                )
            reproject_geometries(conn, srid)

        final_label = read_current_version(conn)[1]
        print(f">> Done. Current schema version on {args.gpkg}: {final_label}")
        return 0
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
