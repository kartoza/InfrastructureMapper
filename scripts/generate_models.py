#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Generate a CRS-templated mirror of the schema and its migrations.

Every spatial column in this project's baseline (``sql/*.sql``) and in its
migrations (``sql/migrations/{pg,gpkg}/*.sql``) is declared against the
literal token ``4326`` (WGS 84 lat/lon) — the one documented exception,
``32734`` on the original roads/intersection baseline, is corrected forward
by the ``v0.2.0`` migration and is never substituted. This script copies
every ``sql/**/*.sql`` file into ``build/models/sql/`` (mirroring the
source tree), replacing the literal ``4326`` token with the CRS a user
chooses for their own checkout.

The chosen CRS is remembered in ``.im-crs`` at the repo root (gitignored,
machine-local) so later runs — e.g. after ``git pull`` — don't need to
re-enter it. ``scripts/apply_pg.sh`` and ``scripts/build_gpkg.sh`` consume
the same file.

Usage:
    scripts/generate_models.py [options]

Options:
    --crs EPSG:NNNN   Use this CRS; also remembers it for next time.
    --reset-crs       Ignore the remembered CRS and prompt again.
    --out DIR         Output root (default: build/models/sql).
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Tuple

ROOT = Path(__file__).resolve().parent.parent
SQL_ROOT = ROOT / "sql"
CRS_STATE_FILE = ROOT / ".im-crs"
DEFAULT_OUT = ROOT / "build" / "models" / "sql"

SRID_TOKEN_RE = re.compile(r"\b4326\b")


def validate_crs(value: str) -> Tuple[str, str]:
    """Normalise a CRS string into ``(srid, "EPSG:<srid>")``.

    Args:
        value: Either ``"EPSG:<n>"`` or a bare ``"<n>"``.

    Returns:
        A ``(srid, epsg)`` pair, e.g. ``("32734", "EPSG:32734")``.

    Raises:
        SystemExit: If ``value`` is not a recognisable CRS.
    """
    if value.upper().startswith("EPSG:"):
        srid = value.split(":", 1)[1]
    else:
        srid = value
    if not srid.isdigit():
        print(
            f"ERROR: CRS must be like 'EPSG:3857' or just '3857', got '{value}'.",
            file=sys.stderr,
        )
        raise SystemExit(2)
    return srid, f"EPSG:{srid}"


def warn_if_geographic(srid: str) -> None:
    """Print the standard geographic-CRS accuracy warning for EPSG:4326.

    Args:
        srid: The resolved SRID, as a bare numeric string.
    """
    if srid == "4326":
        print(
            "⚠️  WARNING: EPSG:4326 is a geographic CRS — distances and areas "
            "computed in\n    it are only accurate to ~2 m. Pick a metric CRS "
            "(UTM zone, EPSG:3857)\n    for field work needing precise "
            "measurements.\n",
            file=sys.stderr,
        )


def resolve_crs(cli_crs: str | None, reset: bool) -> Tuple[str, str]:
    """Resolve the CRS to use: ``--crs`` flag > remembered file > prompt.

    Args:
        cli_crs: Value passed via ``--crs``, or ``None``.
        reset: If true, ignore any remembered value (still honours ``cli_crs``).

    Returns:
        A ``(srid, epsg)`` pair. The resolved value is persisted to
        ``CRS_STATE_FILE``.

    Raises:
        SystemExit: If no CRS is available and stdin is not a terminal.
    """
    value: str | None = cli_crs
    source = "--crs flag"

    if value is None and not reset and CRS_STATE_FILE.is_file():
        remembered = CRS_STATE_FILE.read_text(encoding="utf-8").strip()
        if remembered:
            value = remembered
            source = f"remembered in {CRS_STATE_FILE}"

    if value is None:
        if not sys.stdin.isatty():
            print(
                "ERROR: no CRS given, none remembered, and stdin is not a "
                "terminal.\n       Pass --crs EPSG:NNNN, or run interactively "
                "once to set it.",
                file=sys.stderr,
            )
            raise SystemExit(2)
        value = input(
            "Target CRS for this checkout (e.g. EPSG:4326, EPSG:32734): "
        ).strip()
        source = "interactive prompt"

    srid, epsg = validate_crs(value)
    warn_if_geographic(srid)
    CRS_STATE_FILE.write_text(epsg + "\n", encoding="utf-8")
    print(
        f">> Using CRS {epsg} ({source}); remembered in {CRS_STATE_FILE}",
        file=sys.stderr,
    )
    return srid, epsg


def template_sql(text: str, srid: str) -> str:
    """Replace every literal ``4326`` SRID token with ``srid``.

    Args:
        text: SQL file contents to template.
        srid: Target SRID, as a bare numeric string.

    Returns:
        ``text`` with every standalone ``4326`` token replaced by ``srid``.
    """
    return SRID_TOKEN_RE.sub(srid, text)


def generate(srid: str, out_root: Path) -> int:
    """Mirror every ``sql/**/*.sql`` file into ``out_root``, SRID-templated.

    Args:
        srid: Target SRID, as a bare numeric string.
        out_root: Directory to mirror ``sql/`` into.

    Returns:
        The number of files written.
    """
    sources = sorted(SQL_ROOT.glob("*.sql")) + sorted(
        SQL_ROOT.glob("migrations/*/*.sql")
    )
    count = 0
    for src in sources:
        rel = src.relative_to(SQL_ROOT)
        dest = out_root / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(
            template_sql(src.read_text(encoding="utf-8"), srid), encoding="utf-8"
        )
        count += 1
    return count


def main() -> int:
    """Run the generator end-to-end.

    Returns:
        0 on success, 2 on bad arguments.
    """
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n", maxsplit=1)[0])
    ap.add_argument("--crs", metavar="EPSG:NNNN", default=None)
    ap.add_argument("--reset-crs", action="store_true")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = ap.parse_args()

    srid, epsg = resolve_crs(args.crs, args.reset_crs)
    count = generate(srid, args.out)

    print(f">> Generated {count} SQL file(s) under {args.out} at {epsg}.")
    print(">> Next steps:")
    print("     nix run .#apply-pg -- <dbname>   # load/update a Postgres database")
    print(f"     nix run .#build-gpkg             # build a GeoPackage at {epsg}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
