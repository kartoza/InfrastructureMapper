<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Local Build

Five minutes from a fresh `nix develop` to a working GeoPackage open in
QGIS. This is the contributor / from-source path; end users typically
just download a release artefact &mdash; see
[Getting Started](../getting-started/index.md).

## 1. Start Postgres

```bash
nix run .#pg-start
```

Idempotent: on the first run it `initdb`s `./pgdata`, creates the `gis` database
and enables PostGIS. On subsequent runs it just brings the cluster up.

## 2. Build the canonical GeoPackage

```bash
nix run .#build-gpkg
```

`build-gpkg` auto-starts Postgres if it isn't already running, so step 1 is
optional &mdash; it's just useful to make the state explicit.

The build script:

1. Drops and recreates a throwaway PG database called `im_gpkg_build`.
2. Applies `sql/extensions.sql` + `sql/0-meta.sql` + every numbered baseline file +
   `sql/fixtures.sql` + any frozen `sql/migrations/pg/v*.sql` files.
3. Stamps the result with the current `VERSION` value in the `schema_migrations`
   table.
4. Runs `ogr2ogr -f GPKG ... PG:...` to export everything to
   `gpkg/KartozaInfrastructureMapper.gpkg`.
5. Drops the throwaway database.

!!! warning "EPSG:4326 is only accurate to ~2 m"
    Pass `--crs EPSG:NNNN` to reproject every spatial column to a metric CRS
    during the build &mdash; for example:

    ```bash
    nix run .#build-gpkg -- --crs EPSG:32735
    ```

    `EPSG:32735` is UTM Zone 35S, appropriate for most of southern Africa.
    Pick the UTM zone (or other metric CRS) that fits your survey area.

## 3. Open it in QGIS

```bash
nix run .#qgis
```

In QGIS, drag `gpkg/KartozaInfrastructureMapper.gpkg` into the canvas. Every
spatial layer is pre-registered with its SRS in `gpkg_contents` and
`gpkg_geometry_columns`, so QGIS picks them up automatically. The lookup
tables come along as aspatial entries.

## 4. Introspect the version

From psql:

```sql
SELECT * FROM current_schema_version;
--  version | major | minor | patch |        applied_at          | is_baseline
-- ---------+-------+-------+-------+----------------------------+-------------
--  v0.1.0  |     0 |     1 |     0 | 2026-06-08 09:39:20.951+00 | t
```

From sqlite3 against the GeoPackage:

```sql
SELECT version FROM current_schema_version;
-- v0.1.0
```

Both stores carry the same `schema_migrations` table baked into the baseline by
`sql/0-meta.sql`, so introspection works identically &mdash; from psql, QGIS,
ogrinfo, or any GPKG-aware tool.

## What next?

- Explore the [data model](../data-model/index.md) &mdash; each capture
  domain has hand-written narrative and an auto-generated schema reference.
- Read about the [schema lifecycle](../schema-lifecycle/index.md): how
  baseline, migrations, and releases fit together.
- Take the GeoPackage [into the field](../getting-started/field-workflow.md).
