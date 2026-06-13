<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Open the GeoPackage in QGIS

The simplest way to use Infrastructure Mapper is to download a single
GeoPackage file and open it in QGIS. Every capture domain is
pre-registered as a layer; lookup tables come along as aspatial
entries.

## 1. Download the GeoPackage

Every release publishes two GeoPackages on the
[GitHub Releases page]:

[GitHub Releases page]: https://github.com/kartoza/InfrastructureMapper/releases/latest

| File pattern | When to pick this one |
| --- | --- |
| `infrastructure-mapper-vX.Y.Z.gpkg` | Default. Geometries in **EPSG:4326** (longitude / latitude). Accurate to ~2&nbsp;m. |
| `infrastructure-mapper-vX.Y.Z-utm35s.gpkg` | Geometries reprojected to **EPSG:32735** (UTM Zone 35S). Use this for southern-African work where you need metres-accurate distances and areas. |

Click the link, scroll to **Assets**, download the file you want.

!!! tip "Which CRS should I pick?"
    If your work covers a small area and needs distance / area
    measurements in metres, pick the projected variant matching your
    region (UTM 35S ships by default; other zones can be built from
    source &mdash; see [Local Build]). If you are exchanging data
    globally or with web maps, the EPSG:4326 variant is the universal
    default.

[Local Build]: ../developer-guide/local-build.md

## 2. Open it in QGIS

You have three equally good options:

1. **Drag and drop** the `.gpkg` file onto an empty QGIS canvas. Every
   spatial layer registers automatically.
2. **Browser panel &rarr; GeoPackage** &rarr; right-click &rarr;
   *New Connection*, pick the file, expand it, double-click any layer
   to add it.
3. ***Layer &rarr; Add Layer &rarr; Add Vector Layer***, point at the
   `.gpkg`, and tick the layers you want.

Once the layers are on the canvas, QGIS reads the layer styles, joins
to lookup tables, and the integer-id / UUID column relationships
already declared in the schema.

## 3. Inspect the schema version

Every GeoPackage produced by this project carries its own provenance.
From the QGIS *DB Manager* (`Database &rarr; DB Manager`), connect to
the GeoPackage and run:

```sql
SELECT version FROM current_schema_version;
-- → v0.1.0
```

Or, from a terminal:

```bash
sqlite3 infrastructure-mapper-vX.Y.Z.gpkg \
  "SELECT version FROM current_schema_version;"
```

That version tells you which migrations are baked in, so you can
compare against a Postgres instance you may be syncing with.

## What next?

- Take the GeoPackage into the field &mdash; see
  [Field Workflow](field-workflow.md).
- Prefer a server-hosted setup? Use the same data in your own Postgres
  &mdash; see [Load the schema into Postgres](postgres.md).
- Curious about the schema? Browse the [Data Model](../data-model/index.md).
