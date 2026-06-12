<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Release Process

A release in Infrastructure Mapper is a *schema* release: it freezes the
current `UNRELEASED.sql` migration into a versioned `vX.Y.Z.sql`, bumps
`VERSION`, tags `main`, and publishes built artifacts.

## `scripts/release.sh` &mdash; the cutover

```bash
nix run .#release -- --bump patch --commit
nix run .#release -- --bump minor --commit
nix run .#release -- --bump major --commit
```

The script does five things, in order:

1. **Validate**: refuses to run with a dirty working tree, on a non-main
   branch, or if either `UNRELEASED.sql` is empty (no point bumping for
   no schema change).
2. **Bump `VERSION`**: reads the current semver, applies the requested
   bump, writes `MAJOR.MINOR.PATCH` back to the file.
3. **Rename**: `sql/migrations/pg/UNRELEASED.sql` →
   `sql/migrations/pg/vX.Y.Z.sql`, and the same for `gpkg/`. Creates
   fresh empty `UNRELEASED.sql` files for the next cycle.
4. **Commit**: a single commit titled
   `Release vX.Y.Z` containing the `VERSION` bump and the renames.
5. **Tag**: `git tag vX.Y.Z` on that commit.

`--dry-run` prints what would happen without touching anything.

`--commit` is required for the script to actually mutate state &mdash;
without it, the dry-run path is the default. This is intentional belt-and-
braces against accidental releases from a development shell.

## The Release GitHub Action

Pushing a `vX.Y.Z` tag to the remote triggers `.github/workflows/release.yml`,
which builds and publishes:

| Artifact | What's in it |
|---|---|
| `infrastructure-mapper-vX.Y.Z-schema.tar.gz` | The full `sql/` tree at the tag (baseline + all migrations through vX.Y.Z). |
| `infrastructure-mapper-vX.Y.Z.gpkg` | A canonical GeoPackage built fresh from the tag, in EPSG:4326. |
| `infrastructure-mapper-vX.Y.Z-utm35s.gpkg` | The same data reprojected to EPSG:32735 (UTM Zone 35S) for southern Africa metric work. |
| `CHANGELOG.md` extract | The release notes for `vX.Y.Z` parsed from `CHANGELOG.md`. |

Artifacts attach to the GitHub Release page automatically. Schema consumers
can `curl` the tarball, or download a ready-to-use GeoPackage for the
common metric CRS without rebuilding locally.

## Consuming a release

For most users, the recommended consumption path is:

```bash
# Download the canonical metric GeoPackage:
gh release download vX.Y.Z --pattern '*-utm35s.gpkg'

# Or, to apply the schema to an existing Postgres database:
gh release download vX.Y.Z --pattern '*-schema.tar.gz'
tar xf infrastructure-mapper-vX.Y.Z-schema.tar.gz
psql -d my_db -f sql/0-meta.sql
# … then the rest of the baseline + migrations in order.
```

`scripts/migrate_pg.py` and `scripts/migrate_gpkg.py` can also pull a
tarball directly &mdash; the runners just need access to the `sql/`
directory tree.

## Why semver and not date-based versions

A tempting alternative is date-stamped releases (`2026.06.10`). Semver
won because the project's contract is *schema compatibility*, not
"when was it cut":

- `0.x.y` → `0.x.(y+1)`: tooling can upgrade silently.
- `0.x.y` → `0.(x+1).0`: tooling should review migration notes but can upgrade.
- `0.x.y` → `(x+1).0.0`: tooling must adapt &mdash; old code may break.

The `schema_migrations.major`/`minor`/`patch` columns let consumers check
compatibility programmatically without parsing a date.
