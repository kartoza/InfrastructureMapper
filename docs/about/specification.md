<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Specification

This is the canonical technical specification for Infrastructure Mapper.
It captures *what the system must do and how it must behave*, such that
the project could be re-implemented from scratch in another language and
arrive at a homologous outcome.

It is updated whenever functionality is added, removed, or changed.

## 1. Purpose and scope

Infrastructure Mapper is a relational geospatial schema for capturing
physical infrastructure (buildings, fences, roads, water, electricity,
gates, poles, points of interest, vegetation, monitoring stations,
culinary facilities, and land-use areas) plus their conditions over time.

The schema is the deliverable. It is intended to be loaded into:

- A PostgreSQL/PostGIS database (the canonical, server-side store).
- A GeoPackage file (the offline, field-portable snapshot), opened in
  QGIS desktop or in QField / Mergin Maps for capture.

## 2. Architecture

```text
sql/                                 baseline schema (immutable once committed)
├── extensions.sql                   enable PostGIS
├── 0-meta.sql                       schema_migrations + current_schema_version
├── 1-infrastructure.sql … 13-roads.sql   capture domains
├── fixtures.sql                     lookup data
└── migrations/
    ├── pg/
    │   ├── UNRELEASED.sql           editable; consolidated into vX.Y.Z.sql at release
    │   └── vX.Y.Z.sql               frozen released migrations (PostgreSQL syntax)
    └── gpkg/
        ├── UNRELEASED.sql
        └── vX.Y.Z.sql               frozen released migrations (SQLite syntax)

scripts/
├── build_gpkg.sh                    PG → ogr2ogr → GPKG pipeline
├── migrate_pg.sh                    Apply pending PG migrations to a target DB
├── migrate_gpkg.py                  Apply pending GPKG migrations to a target file
├── generate_schema_docs.py          Refresh "Schema Reference" sections in docs/data-model/
├── release.sh                       Cut a release: rename UNRELEASED → vX.Y.Z, bump VERSION
└── check_schema_immutability.sh     Pre-commit / CI gate

.github/workflows/
├── ci.yml                           Pre-commit suite + tests on every PR
├── SchemaImmutability.yml           Pre-commit hook mirror for PRs and tag pushes
├── Release.yml                      On tag push, build and publish release artifacts
└── Docs.yml                         On push to main, rebuild and publish docs

VERSION                              Single line of plain semver, e.g. "0.1.0"
gpkg/KartozaInfrastructureMapper.gpkg  Latest local build of the GeoPackage
```

## 3. Versioning

### 3.1 Version stamp

- `VERSION` at repo root contains a single semver string (`MAJOR.MINOR.PATCH`).
- Every PG and GPKG database produced by the build process must include the
  `schema_migrations` table (defined in `sql/0-meta.sql`) with at least one
  row recording the baseline version.
- The `current_schema_version` view must return exactly one row representing
  the highest applied version.

### 3.2 Bump rule

Per the project's commit convention:

- Bugfix-only changes → patch bump.
- New features → minor bump.
- Breaking schema changes → major bump.

## 4. Schema immutability

### 4.1 Baseline files

Files under `sql/` at the top level (`extensions.sql`, `0-meta.sql`,
`<n>-<domain>.sql`, `fixtures.sql`) form the baseline. Once committed,
each is frozen. The pre-commit hook and the `SchemaImmutability`
GitHub Action reject any in-place modification.

New top-level files for **new capture domains** are permitted (e.g. a future
`sql/14-solar.sql`). They become immutable from the moment they are first
committed.

### 4.2 Released migrations

Files matching `sql/migrations/{pg,gpkg}/vX.Y.Z.sql` are frozen on commit
by the same gate.

### 4.3 UNRELEASED files

`sql/migrations/pg/UNRELEASED.sql` and `sql/migrations/gpkg/UNRELEASED.sql`
are the only freely-editable schema files. They are renamed to
`vX.Y.Z.sql` at release time.

### 4.4 Issue-NNN annotation

Every block appended to either `UNRELEASED.sql` must be preceded by an
annotation line of the form:

```sql
-- Issue #NNN: short description
```

referencing the GitHub issue that tracks the change. The hook rejects any
top-level DDL/DML keyword (`CREATE`, `ALTER`, `DROP`, `INSERT`, …) that
does not have a preceding `-- Issue #NNN:` line in the file.

## 5. Release process

### 5.1 Local release script

`scripts/release.sh --bump <major|minor|patch> [--commit]`:

1. Reads `VERSION`, computes the next version.
2. Requires that at least one of the two `UNRELEASED.sql` files contain a
   `-- Issue #` block (override with `--empty`).
3. `git mv` both `UNRELEASED.sql` → `vX.Y.Z.sql`.
4. Recreates empty `UNRELEASED.sql` files (header preserved).
5. Writes new version into `VERSION`.
6. Regenerates per-component schema reference docs.
7. With `--commit`, creates the release commit and the `vX.Y.Z` git tag.

### 5.2 Release pipeline

The `Release` GitHub Action triggers on `v*` tag push. It publishes the
following artifacts to the release:

| Artifact | Description |
|---|---|
| `pg-schema-vX.Y.Z.sql` | `pg_dump --schema-only` from a fresh reference PG |
| `pg-fixtures-vX.Y.Z.sql` | `pg_dump --data-only` of lookup tables |
| `KartozaInfrastructureMapper-vX.Y.Z.gpkg` | Blank GeoPackage built via `ogr2ogr` |
| `pg-migrations-vX.Y.Z.tar.gz` | Every `sql/migrations/pg/v*.sql` + `migrate_pg.sh` |
| `gpkg-migrations-vX.Y.Z.tar.gz` | Every `sql/migrations/gpkg/v*.sql` + `migrate_gpkg.py` |
| `RELEASE_NOTES.md` | Generated from filenames between previous and current tags |

The migration tarballs ship the full history; the runners skip migrations
already recorded in the target's `schema_migrations` table, so one tarball
serves any prior version.

## 6. Migration application

### 6.1 Runners

- `scripts/migrate_pg.sh <dbname>` for PostgreSQL.
- `scripts/migrate_gpkg.py <file.gpkg>` for GeoPackage.

### 6.2 Strict sequential semantics

Both runners:

1. Read the target's `current_schema_version`.
2. List all locally-available `vX.Y.Z.sql` files sorted in semver order.
3. Apply every file whose semver is greater than the target's current
   version, in order, each in its own transaction.
4. Record successful application in `schema_migrations` with checksum and
   `applied_by`.
5. Are idempotent: re-running on an up-to-date DB is a no-op.
6. Support `--dry-run` (print plan only) and `--target vX.Y.Z` (stop at).

If the local file set has a gap (e.g. `v1.1.sql` and `v1.3.sql` present,
`v1.2.sql` missing), the runner reports which file is missing rather
than silently skipping.

## 7. Coordinate reference systems

### 7.1 Schema baseline

Every spatial column in the baseline declares `EPSG:4326`.

### 7.2 Build-time reprojection

`scripts/build_gpkg.sh --crs EPSG:NNNN` reprojects every spatial column
during build. The reprojection runs as
`ALTER TABLE … ALTER COLUMN geometry TYPE GEOMETRY(<type>, <srid>) USING ST_Transform(geometry, <srid>)`
on the throwaway PG, so the declared type and the stored geometry stay
consistent.

### 7.3 Geographic-CRS warning

When `--crs` is omitted or set to EPSG:4326, the build script emits a
warning explaining that geographic CRSes are only accurate to ~2 m.

### 7.4 Runtime reprojection

`migrate_pg.sh --crs EPSG:NNNN` may reproject after applying migrations.
For GPKG, in-place reprojection requires SpatiaLite extensions or an
external ogr2ogr pass; the runner refuses with a clear message rather
than silently producing wrong geometries.

### 7.5 PG-GPKG CRS coupling

The system assumes a paired prod PG and prod GPKG share the same CRS at
sync time. CRS mismatch is not silently reconciled.

## 8. Field sync model

The GPKG is a versioned snapshot. The sync workflow (GPKG → PG) is not yet
implemented but the schema supports it: every table has a `uuid` (stable
across both stores) and a `last_update` timestamp. A future
`scripts/sync_gpkg_to_pg.py` will merge by UUID, with the conflict policy
to be decided.

## 9. Generated documentation

`scripts/generate_schema_docs.py` regenerates the "Schema Reference" section
inside each `docs/data-model/NN-<domain>.md`. The section is delimited by:

```html
<!-- SCHEMA-REFERENCE-START - auto-generated, do not edit by hand -->
…
<!-- SCHEMA-REFERENCE-END -->
```

Content outside those markers is hand-curated narrative and must not be
touched by the generator.

The generated content reflects the materialised current state of the
schema &mdash; baseline plus every applied PG migration &mdash; and
includes per table: description, columns (name, type, nullability,
default, description), and constraints (PK, UNIQUE, FK, CHECK).

## 10. Built-in metadata

`sql/0-meta.sql` defines:

- `schema_migrations(version, major, minor, patch, applied_at, applied_by,
  checksum, is_baseline, notes)` &mdash; append-only history of applied
  versions; `is_baseline = TRUE` distinguishes the initial build from
  applied migrations.
- `current_schema_version` view &mdash; single-row introspection helper.

These must be present in any environment claiming to be an
Infrastructure Mapper database.

## 11. Documentation site

The user-facing documentation is published as a [mkdocs-material] site at
<https://timlinux.github.io/InfrastructureMapper/>. It is built and
deployed by the `Docs.yml` GitHub workflow on every push to `main`.

The site sources live under `docs/` and use the Kartoza design system
([design.md](design.md)) for typography, palette, and component styling.
Per-component schema reference blocks are regenerated by
`scripts/generate_schema_docs.py` as part of the deploy workflow, so the
docs site is never stale relative to `main`.

[mkdocs-material]: https://squidfunk.github.io/mkdocs-material/
