<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Release Process

A release in Infrastructure Mapper is a *schema* release: it freezes the
current `UNRELEASED.sql` migration into a versioned `vX.Y.Z.sql`, bumps
`VERSION`, tags `main`, and publishes built artifacts.

## `scripts/release.sh` &mdash; two-step cutover

`main` is protected (PRs + status checks required), so the release
flow is two steps:

```bash
# Step 1: prepare the release branch + PR.
nix run .#release -- --bump patch --commit
# (or --bump minor / --bump major)

# After the PR has merged into main:
git checkout main && git pull --ff-only

# Step 2: tag the merged release commit.
nix run .#release -- --tag
```

**Step 1 (`--commit`)** does the following on a fresh branch
`release/vX.Y.Z`:

1. **Validate**: refuses to run unless you're on a clean main that
   matches `origin/main`. Refuses if either `UNRELEASED.sql` is empty
   (no point bumping for no schema change) &mdash; pass `--empty` to
   override (e.g. for a docs-only patch bump).
2. **Bump `VERSION`**: reads the current semver, applies the requested
   bump, writes `MAJOR.MINOR.PATCH` back to the file.
3. **Rename**: `sql/migrations/pg/UNRELEASED.sql` →
   `sql/migrations/pg/vX.Y.Z.sql`, and the same for `gpkg/`. Creates
   fresh empty `UNRELEASED.sql` files for the next cycle.
4. **Regenerate** the per-domain schema reference docs under
   `docs/data-model/` (best-effort &mdash; needs Postgres reachable).
5. **Commit + push**: a single `Release vX.Y.Z` commit on
   `release/vX.Y.Z`, pushed to origin.
6. **Open PR**: via `gh pr create`, base `main`, head `release/vX.Y.Z`.

**Step 2 (`--tag`)** runs on main *after* the PR has merged. It:

1. Verifies you're on `main` and at `origin/main`.
2. Reads `VERSION` (which the merged PR has set to `X.Y.Z`).
3. Creates an annotated tag `vX.Y.Z` at `main` HEAD.
4. Pushes the tag.

Pushing the tag triggers `.github/workflows/Release.yml`, which builds
and publishes the artifacts.

Why two steps: branch protection blocks direct pushes to `main`, so the
release commit has to land via PR. The tag is just a pointer to the
already-merged commit and doesn't go through branch protection, so it
can be pushed directly. The `--tag` step also gives you a sanity gate
between "PR is merged" and "Release.yml fires" &mdash; you can pause
between the two if needed.

## The Release GitHub Action

Pushing a `vX.Y.Z` tag triggers `.github/workflows/Release.yml`. It
runs `scripts/build_artifacts.sh` and `scripts/schema_diff.py`, then
attaches the full asset set to the GitHub release:

| Asset | What's in it |
|---|---|
| `pg-schema-vX.Y.Z.sql` (+ `pg-schema-latest.sql`) | Composite SQL: extensions + meta + every domain + fixtures. |
| `KartozaInfrastructureMapper-vX.Y.Z.gpkg` (+ `-latest.gpkg`) | Composite GeoPackage with every domain. |
| `pg-schema-NN-name-vX.Y.Z.sql` (×13, + `-latest`) | Per-domain SQL slice. |
| `KartozaInfrastructureMapper-NN-name-vX.Y.Z.gpkg` (×13, + `-latest`) | Per-domain GeoPackage. |
| `pg-fixtures-vX.Y.Z.sql` (+ `-latest`) | Data-only dump of lookup tables. |
| `pg-migrations-vX.Y.Z.tar.gz` (+ `-latest`) | Forward migration files + runner script. |
| `gpkg-migrations-vX.Y.Z.tar.gz` (+ `-latest`) | Same, for GeoPackage. |
| `schema-diff-vX.Y.Z.sql` (+ `-latest`) | `migra`-generated ALTER diff vs the previous release. |
| `MANIFEST.json` | Byte sizes + per-domain table lists for every artifact. |

Every asset is published twice: once with the version embedded (for
reproducibility / archival) and once with `-latest` (so
`https://github.com/kartoza/InfrastructureMapper/releases/latest/download/<name>`
stable URLs resolve to the always-current file).

## Consuming a release

For most users:

```bash
# Composite GeoPackage (everything, latest):
curl -LO https://github.com/kartoza/InfrastructureMapper/releases/latest/download/KartozaInfrastructureMapper-latest.gpkg

# Composite SQL (everything, latest):
curl -LO https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-schema-latest.sql
psql -d my_db -v ON_ERROR_STOP=1 -f pg-schema-latest.sql

# Just one domain (example: fencing):
curl -LO https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-schema-07-fencing-latest.sql
curl -LO https://github.com/kartoza/InfrastructureMapper/releases/latest/download/KartozaInfrastructureMapper-07-fencing-latest.gpkg
```

`scripts/migrate_pg.sh` and `scripts/migrate_gpkg.py` can apply the
forward migrations from `pg-migrations-latest.tar.gz` /
`gpkg-migrations-latest.tar.gz` on top of an existing earlier-version
database.

## Why semver and not date-based versions

A tempting alternative is date-stamped releases (`2026.06.10`). Semver
won because the project's contract is *schema compatibility*, not
"when was it cut":

- `0.x.y` → `0.x.(y+1)`: tooling can upgrade silently.
- `0.x.y` → `0.(x+1).0`: tooling should review migration notes but can upgrade.
- `0.x.y` → `(x+1).0.0`: tooling must adapt &mdash; old code may break.

The `schema_migrations.major`/`minor`/`patch` columns let consumers check
compatibility programmatically without parsing a date.
