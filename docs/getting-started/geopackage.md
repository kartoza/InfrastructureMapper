<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Open the GeoPackage in QGIS

The simplest way to use Infrastructure Mapper is to download a single
GeoPackage file and open it in QGIS. Every capture domain is
pre-registered as a layer; lookup tables come along as aspatial
entries.

## 1. Download the GeoPackage

Every release on the [GitHub Releases page] publishes the full schema
as a single GeoPackage, plus per-domain slices for narrower workflows:

[GitHub Releases page]: https://github.com/kartoza/InfrastructureMapper/releases/latest

| File pattern | What it is |
| --- | --- |
| `KartozaInfrastructureMapper-vX.Y.Z.gpkg` | **Everything** &mdash; all 13 domains, every lookup table, all in one file. Default choice. |
| `KartozaInfrastructureMapper-NN-name-vX.Y.Z.gpkg` | **One domain only** &mdash; e.g. `KartozaInfrastructureMapper-07-fencing-vX.Y.Z.gpkg`. Pick this if you only care about fences, or roads, or any single domain. |

All GeoPackages ship with geometries in **EPSG:4326** (longitude /
latitude). If you need a metric CRS for distance / area measurements,
build your own &mdash; see [Local Build].

[Local Build]: ../developer-guide/local-build.md

```bash
# Whole schema:
gh release download --repo kartoza/InfrastructureMapper \
  --pattern 'KartozaInfrastructureMapper-v*.gpkg'

# Just one domain (example: fencing):
gh release download --repo kartoza/InfrastructureMapper \
  --pattern 'KartozaInfrastructureMapper-07-fencing-v*.gpkg'
```

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
sqlite3 KartozaInfrastructureMapper-vX.Y.Z.gpkg \
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
