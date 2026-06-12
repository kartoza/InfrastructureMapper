<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Migrations

Once a `vX.Y.Z` schema has shipped, the baseline files in `sql/` are
**immutable**. Every subsequent schema change lives as a paired migration:
one PostgreSQL file and one GeoPackage (SQLite) file, applied in strict
sequence on top of the baseline.

## Layout

```text
sql/migrations/
  pg/
    UNRELEASED.sql       ← work-in-progress, renamed at release time
    v0.2.0.sql
    v0.3.0.sql
  gpkg/
    UNRELEASED.sql
    v0.2.0.sql
    v0.3.0.sql
```

A migration is a *pair*: every PG migration **must** have a matching GeoPackage
migration with the same filename. The pre-commit hook
`scripts/check_migration_pairs.sh` refuses any commit that ships one without
the other.

## `UNRELEASED.sql`: the staging area

Active development always targets `UNRELEASED.sql` &mdash; never an existing
`vX.Y.Z.sql`. The rationale is the same as `CHANGELOG.md`'s
"Unreleased" section: the file that shipped at `v0.2.0` is frozen the moment
the tag goes out; anything you want next belongs in `UNRELEASED.sql`.

When `scripts/release.sh` cuts the next version, it renames
`UNRELEASED.sql` → `vX.Y.Z.sql` in *both* `pg/` and `gpkg/` and recreates
empty `UNRELEASED.sql` files for the next cycle.

## Issue-NNN annotations

Each statement (or logical group of statements) in a migration is prefixed
with the GitHub issue or PR it implements:

```sql
-- Issue-42: rename "rated_kva" to "rated_kva_total" on electricity poles.
ALTER TABLE electricity_poles RENAME COLUMN rated_kva TO rated_kva_total;

-- Issue-42 (cont.): backfill the new column where rated_kva was the per-phase rating.
UPDATE electricity_poles SET rated_kva_total = rated_kva_per_phase * 3
  WHERE rated_kva_per_phase IS NOT NULL;
```

This is enforced by `scripts/check_migration_annotations.sh` &mdash; every
non-comment, non-blank logical block must be preceded by an
`-- Issue-NNN:` (or `-- Issue-NNN (cont.):`) line. The hook fails the commit
otherwise.

The payoff: `git log -p sql/migrations/` plus `grep Issue-` gives an
auditable per-issue trail of every schema change ever shipped, without
needing a separate changelog table.

## Paired PG / GPKG dialects

The two SQL flavours diverge in small but real ways:

| Concern | PostgreSQL | GeoPackage (SQLite) |
|---|---|---|
| Add NOT NULL with default | `ALTER TABLE … ADD COLUMN … NOT NULL DEFAULT …` | Often a copy-table dance |
| Rename column | `ALTER TABLE … RENAME COLUMN` | `ALTER TABLE … RENAME COLUMN` (SQLite 3.25+) |
| Drop column | `ALTER TABLE … DROP COLUMN` | Copy-table dance pre-3.35 |
| Type change | `ALTER TABLE … ALTER COLUMN … TYPE …` | Copy-table dance |
| Spatial column | `ALTER TABLE … ADD COLUMN … geometry(POINT, 4326)` | Register in `gpkg_geometry_columns` + `gpkg_contents` |
| Lookup seeding | Plain `INSERT` | Plain `INSERT` (no geometry registration overhead) |

The same *semantic* change is expressed in both files, but the SQL is
different. The migration runners trust that the paired files express the
same intent &mdash; there's no automatic translation.

## Strict-sequential runners

Two scripts apply migrations:

- **`scripts/migrate_pg.py`** &mdash; `nix run .#migrate-pg`
- **`scripts/migrate_gpkg.py`** &mdash; `nix run .#migrate-gpkg`

Both behave identically:

1. Read `schema_migrations` to find the highest-version row already applied.
2. List `sql/migrations/{pg,gpkg}/v*.sql`, sorted by semver.
3. Refuse to run if any `vX.Y.Z` on disk has a version *older than* the
   highest applied version (that's a schema downgrade, never silently OK).
4. Apply every newer migration in semver order, inside a single transaction
   per migration file.
5. Insert a row into `schema_migrations` with `is_baseline = FALSE` for each
   one, including a SHA-256 checksum of the file as applied.

`UNRELEASED.sql` is **never** applied by the runners &mdash; it's
work-in-progress, not a shipping migration. To preview pending changes
locally, run `scripts/release.sh --bump patch --dry-run` to see what
filename it would get, then either re-cut a build or run the SQL by hand
in a throwaway database.

## When in doubt: rebuild

For local development, the fastest "is my migration correct?" loop is to
just re-run `nix run .#build-gpkg`. The build script applies the baseline
plus every frozen migration plus (optionally) `UNRELEASED.sql` from a
clean PG database, so a broken migration shows up immediately as a
build failure rather than a subtle state divergence.
