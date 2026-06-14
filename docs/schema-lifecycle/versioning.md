<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Versioning

## The version stamp

`VERSION` at the repo root holds a single semver string (`MAJOR.MINOR.PATCH`).
It's the canonical "what version is this project on right now" answer for the
codebase, and it's read by:

- `scripts/release.sh` to know the next tag and to rename
  `UNRELEASED.sql` → `vX.Y.Z.sql`.
- `scripts/build_gpkg.sh` to stamp a freshly-built PG/GeoPackage.
- The Release GitHub Action to tag the release.
- `scripts/check_schema_immutability.sh` (indirectly, via the migration files).

## Bump rule

Per the project's commit convention:

| Change type | Bump |
|---|---|
| Bugfix only | patch (`0.1.0` → `0.1.1`) |
| New feature, additive | minor (`0.1.0` → `0.2.0`) |
| Breaking schema change | major (`0.1.0` → `1.0.0`) |

`scripts/release.sh --bump patch|minor|major --commit` opens the release PR
(file rename, `VERSION` bump, docs regenerate, branch push, PR via `gh`). A
follow-up `scripts/release.sh --tag` on `main` after the PR merges creates
and pushes the tag, triggering `Release.yml`.

## The `schema_migrations` table

Every PG and GeoPackage database produced by the build process carries a
`schema_migrations` table defined in `sql/0-meta.sql`:

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
    version TEXT NOT NULL PRIMARY KEY,
    major INTEGER NOT NULL,
    minor INTEGER NOT NULL,
    patch INTEGER NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    applied_by TEXT NOT NULL,
    checksum TEXT NOT NULL,
    is_baseline BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT
);
```

Plus a convenience view:

```sql
CREATE OR REPLACE VIEW current_schema_version AS
SELECT version, major, minor, patch, applied_at, is_baseline
FROM schema_migrations
ORDER BY major DESC, minor DESC, patch DESC
LIMIT 1;
```

So you can introspect the version from psql, ogrinfo, QGIS, sqlite3 &mdash;
anywhere &mdash; without knowing the migration history. The major/minor/patch
columns are stored as integers (alongside the human-readable text `version`)
to sidestep lexical-vs-numeric sort bugs (otherwise `v1.10.0` would sort before
`v1.2.0`).

## Baseline vs migrated

The first row in `schema_migrations` always has `is_baseline = TRUE`. It's
written by the build script when the canonical baseline files are loaded.
Subsequent migration applications insert rows with `is_baseline = FALSE`. The
`current_schema_version` view doesn't distinguish &mdash; it returns the
highest applied version &mdash; but the column lets diagnostics tell "fresh
build at vX.Y.Z" apart from "migrated from older baseline to vX.Y.Z".

## What's not stored

`VERSION` itself isn't checked into the schema. The reasoning: the project
version drifts on every release, but the schema files are baseline + ordered
migrations. Mixing a moving project version into the immutable baseline
would tie them together unhelpfully. The build script reads `VERSION` at
build time and writes it to `schema_migrations.version`, which is exactly
where downstream tools should read it back.
