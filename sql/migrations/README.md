<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Schema migrations

The top-level files in `sql/` are the **baseline schema** — they describe what a fresh database
contains at the most recent release. They are immutable once committed; the pre-commit hook
and the CI workflow both reject in-place edits.

Every change to the schema after the baseline is captured here as a migration.

## Directory layout

```text
sql/migrations/
  pg/
    UNRELEASED.sql        # editable; release.sh renames this to vX.Y.Z.sql
    v0.2.0.sql            # frozen
    v0.3.0.sql            # frozen
  gpkg/
    UNRELEASED.sql        # editable; release.sh renames this to vX.Y.Z.sql
    v0.2.0.sql            # frozen
    v0.3.0.sql            # frozen
```

Migrations are paired across `pg/` and `gpkg/` — every change must land in both directories
under the same version number. The PG file uses PostgreSQL syntax; the GPKG file uses SQLite
syntax (frequently the SQLite 12-step recreate pattern for constraint changes).

## Appending a change

Every appended block must start with an `-- Issue #NNN:` header that references the GitHub
issue tracking the change:

```sql
-- Issue #142: Add solar_panel table for grid solar installations
CREATE TABLE solar_panel (
    ...
);
```

The pre-commit hook enforces this format. The header survives consolidation when
`UNRELEASED.sql` is renamed at release time, so PR-level provenance remains visible inside
the released migration file.

## Applying migrations

To a PostgreSQL database:

```bash
scripts/migrate_pg.sh <dbname>
```

To a GeoPackage file:

```bash
scripts/migrate_gpkg.py path/to/file.gpkg
```

Both runners:

1. Read the current version from the target's `current_schema_version` view.
2. Identify pending `vX.Y.Z.sql` files (semver-greater than current).
3. Refuse to start if there is a gap in the pending set (e.g. on v1.0, has v1.1 and v1.3
   locally but v1.2 is missing — report what is missing).
4. Apply each pending migration in semver order, each in its own transaction, recording
   success in `schema_migrations` before moving on.

Flags: `--dry-run` prints the plan without applying; `--target vX.Y.Z` stops at a specific
version instead of "everything available."
