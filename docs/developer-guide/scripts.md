<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Scripts &amp; Apps

Every meaningful workflow has both a `scripts/<name>` entry point and a
`nix run .#<name>` wrapper. The wrapper guarantees the script runs inside
`nix develop`, so tool versions match CI even from a cold shell.

## Schema lifecycle

| `nix run` | Script | What it does |
|---|---|---|
| `.#build-gpkg` | `scripts/build_gpkg.sh` | Drops + recreates `im_gpkg_build` PG database, applies baseline + frozen migrations + `fixtures.sql`, stamps `schema_migrations`, exports to `gpkg/KartozaInfrastructureMapper.gpkg`. Accepts `--crs EPSG:NNNN` to reproject. |
| `.#build-artifacts` | `scripts/build_artifacts.sh` &rarr; `scripts/build_artifacts.py` | Produces the composite + 13 per-domain SQL files and GPKGs that ship with PRs and releases. Requires `--version <tag>`. Add `--skip-gpkg` for fast schema-only iteration. |
| `.#schema-diff` | `scripts/schema_diff.py` | Runs `migra` between two composite SQL bundles to produce a structured ALTER-style diff plus a Markdown summary. Used by the Artifacts and Release workflows. |
| `.#migrate-pg` | `scripts/migrate_pg.sh` | Applies any `sql/migrations/pg/vX.Y.Z.sql` newer than `current_schema_version` against a target PG database. Strict-sequential, refuses downgrades. |
| `.#migrate-gpkg` | `scripts/migrate_gpkg.py` | Same semantics as `migrate-pg`, but for an in-place GeoPackage. |
| `.#release` | `scripts/release.sh` | Bumps `VERSION`, renames `UNRELEASED.sql` → `vX.Y.Z.sql` for both PG and GPKG, commits, tags. Needs `--bump patch\|minor\|major` and `--commit` to actually mutate. |
| `.#docs` | `scripts/generate_schema_docs.py` | Regenerates the per-component schema reference Markdown from a fresh reference PG database. Output goes under `docs/data-model/`. |

## QGIS launchers

| `nix run` | What it does |
|---|---|
| `.#qgis` | Launches mainline QGIS with `--profile InfrastructureMapper` and the bundled Python extras (pyqtwebengine, jsonschema, debugpy, future, psutil). |
| `.#qgis-ltr` | Same, but QGIS LTR. |

## Documentation

| `nix run` | What it does |
|---|---|
| `.#docs-serve` | `mkdocs serve` &mdash; live-reloading preview at <http://127.0.0.1:8000>. |
| `.#docs-build` | `mkdocs build --strict` &mdash; fails on broken links or missing references. This is what the Docs CI workflow runs. |

## Postgres lifecycle

Every operation on the project-local cluster (`./pgdata`) is a `nix run`
app, so you never need to remember script paths. The welcome banner shows
live status on each `nix develop` entry.

| `nix run` | Script | What it does |
|---|---|---|
| `.#pg-start` | `scripts/start_pg.sh` | `initdb` on first run, `pg_ctl start` thereafter. Creates the `gis` DB and enables PostGIS once. Idempotent. |
| `.#pg-stop` | `scripts/stop_pg.sh` | `pg_ctl stop -m fast`. Idempotent &mdash; no-ops if already stopped. |
| `.#pg-status` | `scripts/status_pg.sh` | Reports RUNNING / STOPPED / NOT INITIALIZED + version + database list. |
| `.#pg-restart` | `scripts/restart_pg.sh` | Stop, then start. |
| `.#pg-psql` | `scripts/psql_pg.sh` | Drops you into `psql -d gis`. Extra args forward to psql (e.g. `nix run .#pg-psql -- -c 'SELECT version();'`). |
| `.#pg-logs` | `scripts/logs_pg.sh` | `tail -F` of `pgdata/postgres.log`. |
| `.#pg-reset` | `scripts/reset_pg.sh` | **Destructive.** Confirms first, then stops, deletes `./pgdata`, and reinitialises from scratch. |

A shared helper, `scripts/ensure_pg.sh`, is invoked by `build-gpkg` and
`docs` to auto-start the cluster if it isn't already serving &mdash; so
those commands "just work" from a cold shell.

## Maintenance and meta-tooling

The `scripts/` tree also contains:

| Script | Used by |
|---|---|
| `add_spdx_headers.sh` | One-shot to add SPDX headers across the tree. Idempotent &mdash; safe to re-run. |
| `check_schema_immutability.sh` | Pre-commit + CI; described in [CI & Pre-commit](../schema-lifecycle/ci.md). |
| `codebase_size_check.sh` | Reports LOC by directory, used to spot drift. |
| `commit_test_stats.py` | Writes `.test_stats.json` after a test run for trend tracking. |
| `create_presentations.sh` | Builds the marp slide decks under `presentations/`. |
| `docstrings_check.sh` | Pre-commit; flags missing module/function docstrings in Python scripts. |
| `encoding_check.sh` | Pre-commit; rejects non-UTF-8 files. |
| `gource.sh` | Renders a `gource` visualisation of the repo's history. |
| `license_check.sh` | Pre-commit; wraps `reuse lint`. |
| `load_schema.sh` | Loads the baseline into a *named* (not throwaway) PG database for hand-testing. |
| `vscode.sh` | Launches VS Code inside `nix develop` so its terminal inherits the dev shell. |
| `check.sh` | Runs the full pre-commit suite on all files. |

## "But I want to run the script directly"

Nothing stops you. From inside `nix develop`:

```bash
./scripts/build_gpkg.sh --crs EPSG:32735
./scripts/migrate_gpkg.py path/to/some.gpkg
./scripts/release.sh --bump minor --dry-run
```

The `nix run .#…` wrappers exist for **cold-shell** usage &mdash; running
from a directory you're not currently `cd`'d into, or from CI, or before
`nix develop` is active. The wrapper enters the shell for you, then execs
the script.

## Adding a new script

1. Drop the file under `scripts/`. Start it with `#!/usr/bin/env bash`
   (not `/bin/bash`).
2. `chmod +x scripts/your-script.sh`.
3. Add a SPDX header (the pre-commit hook will fail otherwise).
4. If it's a workflow developers should reach for routinely, register it
   in `flake.nix` under `apps.${system}` using `mkScriptApp` or
   `mkPythonApp`. The wrapper handles the `cd $ROOT && nix develop --command`
   dance so the script can assume a clean shell.
5. Add a line to the shellHook banner so people discover it.
