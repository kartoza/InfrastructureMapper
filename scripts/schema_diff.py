#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Produce a structured schema diff between two SQL bundles using migra.

Used by Artifacts.yml on PRs and Release.yml on tags to compare the schema
as it exists in the branch being built against the schema at a base ref
(usually `main` for PRs or the previous tag for releases).

The script loads each side into a throwaway Postgres database, runs migra to
emit ALTER-style SQL, and writes:

- dist/schema-diff-<vtag>.sql      : the migra output (apply against the base
                                     to bring it to the head schema)
- dist/schema-diff-<vtag>.summary  : a short Markdown summary for PR comments
                                     (counts of tables added/dropped/altered,
                                     plus a header)

If the two schemas are identical, schema-diff-<vtag>.sql is empty and the
summary says "No schema changes". Migra exits 2 on differences, 0 on identity;
both are non-error from our perspective.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess  # nosec B404
import sys
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Echo + run a subprocess, aborting on non-zero exit.

    Args:
        cmd: Argv to execute, in list form (no shell).
        **kwargs: Extra keyword arguments forwarded to ``subprocess.run``.

    Returns:
        The completed process object.
    """
    print("$", " ".join(cmd), flush=True)
    return subprocess.run(cmd, check=True, **kwargs)  # nosec B603


def psql_load(database: str, sql_file: Path, conn_args: list[str], env: dict) -> None:
    """Apply a single SQL file to the given database, stopping on error.

    Args:
        database: Target database name.
        sql_file: SQL file to feed to psql via ``-f``.
        conn_args: Connection argv fragment (``-h -p -U``).
        env: Environment for the subprocess (usually carries PGPASSWORD).
    """
    cmd = [
        "psql",
        *conn_args,
        "-d",
        database,
        "-v",
        "ON_ERROR_STOP=1",
        "-q",
        "-f",
        str(sql_file),
    ]
    print("$", " ".join(cmd), flush=True)
    subprocess.run(cmd, check=True, env=env)  # nosec B603


def load_side(
    label: str, sql_files: list[Path], conn_args: list[str], env: dict, db_prefix: str
) -> str:
    """Create a temp DB, load the given SQL bundle into it, return its name.

    Args:
        label: Short identifier (``base`` or ``head``) used in the DB name.
        sql_files: Files to load in order. Missing entries are skipped.
        conn_args: Connection argv fragment (``-h -p -U``).
        env: Environment for the subprocesses.
        db_prefix: Prefix used to namespace temporary databases.

    Returns:
        The name of the newly-created database.
    """
    db = f"{db_prefix}_{label}_{os.getpid()}"
    run(["createdb", *conn_args, db], env=env)
    for f in sql_files:
        if f.exists():
            psql_load(db, f, conn_args, env)
        else:
            print(f"  (skip missing {f})", flush=True)
    return db


def drop_db(name: str, conn_args: list[str], env: dict) -> None:
    """Best-effort dropdb — used in ``finally`` blocks; never raises.

    Args:
        name: Database name to drop.
        conn_args: Connection argv fragment (``-h -p -U``).
        env: Environment for the subprocess.
    """
    subprocess.run(  # nosec B603
        ["dropdb", *conn_args, "--if-exists", name],
        check=False,
        env=env,
    )


def run_migra(base_db: str, head_db: str, conn_url_base: str) -> tuple[str, int]:
    """Invoke migra and return ``(sql_diff, exit_code)``.

    migra exits 0 if no differences, 2 if differences exist (both fine).
    Any other code is a real failure.

    Args:
        base_db: Database name on the BASE side.
        head_db: Database name on the HEAD side.
        conn_url_base: ``postgresql://user[:pass]@host:port`` prefix
            (without a database segment).

    Returns:
        Tuple of ``(sql_diff_text, migra_exit_code)``.

    Raises:
        SystemExit: When migra exits with a code other than 0 or 2.
    """
    cmd = [
        "migra",
        "--unsafe",
        f"{conn_url_base}/{base_db}",
        f"{conn_url_base}/{head_db}",
    ]
    print("$", " ".join(cmd), flush=True)
    # check=False: migra's exit 2 means "diffs exist", which is a valid outcome.
    result = subprocess.run(  # nosec B603
        cmd, capture_output=True, text=True, check=False
    )
    if result.returncode not in (0, 2):
        sys.stderr.write(result.stderr)
        raise SystemExit(f"migra failed with exit {result.returncode}")
    return result.stdout, result.returncode


# Statement classifiers — operate on the migra SQL output, which is a stream
# of single-line top-level statements separated by blank lines.
STMT_PATTERNS = [
    ("table_added", re.compile(r"^\s*create\s+table\b", re.IGNORECASE)),
    ("table_dropped", re.compile(r"^\s*drop\s+table\b", re.IGNORECASE)),
    ("table_altered", re.compile(r"^\s*alter\s+table\b", re.IGNORECASE)),
    (
        "view_changed",
        re.compile(r"^\s*(create|drop)\s+(or\s+replace\s+)?view\b", re.IGNORECASE),
    ),
    (
        "index_changed",
        re.compile(r"^\s*(create|drop)\s+(unique\s+)?index\b", re.IGNORECASE),
    ),
    (
        "function_changed",
        re.compile(r"^\s*(create|drop)\s+(or\s+replace\s+)?function\b", re.IGNORECASE),
    ),
    (
        "constraint_changed",
        re.compile(
            r"^\s*alter\s+table\b.*\b(add|drop)\s+constraint\b",
            re.IGNORECASE | re.DOTALL,
        ),
    ),
]


def summarise(diff_sql: str) -> dict:
    """Bucket migra's SQL statements into table/view/index/etc. counts.

    Args:
        diff_sql: Raw migra output (statements separated by semicolons).

    Returns:
        A dictionary of category counts (``table_added``, ``table_altered``,
        ``view_changed``, ``index_changed``, etc.) plus a ``statements``
        total.
    """
    counts = Counter()
    statements = [s.strip() for s in diff_sql.split(";") if s.strip()]
    counts["statements"] = len(statements)
    for stmt in statements:
        for label, pattern in STMT_PATTERNS:
            if pattern.search(stmt):
                counts[label] += 1
                break
    return dict(counts)


def render_summary(vtag: str, base_label: str, head_label: str, diff_sql: str) -> str:
    """Render the Markdown body posted in the PR comment / attached to releases.

    Args:
        vtag: Version tag (e.g. ``v0.2.0`` or ``pr-123-abc1234``).
        base_label: Human label for the BASE side (e.g. ``v0.1.0``).
        head_label: Human label for the HEAD side (e.g. ``v0.2.0``).
        diff_sql: Raw migra output (empty string means "no diff").

    Returns:
        A Markdown summary suitable for embedding in a GitHub comment.
    """
    counts = summarise(diff_sql)
    lines = [f"### Schema diff: `{base_label}` → `{head_label}` ({vtag})", ""]
    if not diff_sql.strip():
        lines.append("**No schema changes.**")
        return "\n".join(lines) + "\n"
    lines.append(f"- **{counts.get('statements', 0)}** total SQL statements")
    for key, label in [
        ("table_added", "tables added"),
        ("table_dropped", "tables dropped"),
        ("table_altered", "tables altered"),
        ("view_changed", "views changed"),
        ("index_changed", "indexes changed"),
        ("function_changed", "functions changed"),
        ("constraint_changed", "constraints changed"),
    ]:
        n = counts.get(key, 0)
        if n:
            lines.append(f"- {n} {label}")
    lines.append("")
    lines.append("Full diff in the workflow artifacts: `schema-diff-*.sql`.")
    return "\n".join(lines) + "\n"


def main() -> int:
    """CLI entry point — diff two composite SQL bundles and write outputs.

    Returns:
        Exit code (0 on success; the script otherwise raises).
    """
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n", maxsplit=1)[0])
    parser.add_argument(
        "--base-bundle",
        required=True,
        help="Path to the BASE composite SQL (e.g. dist-base/pg-schema-*.sql)",
    )
    parser.add_argument(
        "--head-bundle",
        required=True,
        help="Path to the HEAD composite SQL (e.g. dist/pg-schema-*.sql)",
    )
    parser.add_argument(
        "--version", required=True, help="Version tag used in output filenames"
    )
    parser.add_argument("--base-label", default="base", help="Label for the BASE side")
    parser.add_argument("--head-label", default="head", help="Label for the HEAD side")
    parser.add_argument("--out", default=str(REPO / "dist"))
    parser.add_argument("--pg-host", default=os.environ.get("PGHOST", "localhost"))
    parser.add_argument("--pg-port", default=os.environ.get("PGPORT", "5432"))
    parser.add_argument("--pg-user", default=os.environ.get("PGUSER", "postgres"))
    parser.add_argument("--pg-password", default=os.environ.get("PGPASSWORD", ""))
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    conn_args = [
        "-h",
        args.pg_host,
        "-p",
        str(args.pg_port),
        "-U",
        args.pg_user,
    ]
    env = os.environ.copy()
    if args.pg_password:
        env["PGPASSWORD"] = args.pg_password
    pw_segment = f":{args.pg_password}" if args.pg_password else ""
    conn_url_base = (
        f"postgresql://{args.pg_user}{pw_segment}" f"@{args.pg_host}:{args.pg_port}"
    )

    db_prefix = "im_diff"
    base_db = head_db = None
    try:
        print(f"== Loading BASE ({args.base_label}) from {args.base_bundle}")
        base_db = load_side(
            "base",
            [Path(args.base_bundle)],
            conn_args,
            env,
            db_prefix,
        )
        print(f"== Loading HEAD ({args.head_label}) from {args.head_bundle}")
        head_db = load_side(
            "head",
            [Path(args.head_bundle)],
            conn_args,
            env,
            db_prefix,
        )

        print("== Running migra")
        diff_sql, _migra_exit = run_migra(base_db, head_db, conn_url_base)

    finally:
        if base_db:
            drop_db(base_db, conn_args, env)
        if head_db:
            drop_db(head_db, conn_args, env)

    diff_path = out_dir / f"schema-diff-{args.version}.sql"
    header = (
        f"-- Schema diff for {args.version}\n"
        f"-- BASE: {args.base_label}  HEAD: {args.head_label}\n"
        "-- Generated by migra via scripts/schema_diff.py.\n"
        "-- Apply against a database matching BASE to bring it to HEAD.\n\n"
    )
    diff_path.write_text(header + diff_sql, encoding="utf-8")

    summary_path = out_dir / f"schema-diff-{args.version}.summary.md"
    summary_path.write_text(
        render_summary(args.version, args.base_label, args.head_label, diff_sql),
        encoding="utf-8",
    )

    print(f"\nWrote {diff_path}")
    print(f"Wrote {summary_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
