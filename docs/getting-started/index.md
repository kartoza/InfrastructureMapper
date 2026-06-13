<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Getting Started

Pick the path that matches what you want to do. Each one assumes you
already have **the tool on the left-hand column** installed; no Nix,
no dev shell, no compilation.

<div class="grid cards" markdown>

-   :material-database-outline:{ .lg .middle } __Open the GeoPackage in QGIS__

    ---

    Download a single `.gpkg` file from the latest release. Drag it
    onto a QGIS canvas. Every capture domain registers automatically.
    Best for desktop GIS and one-machine workflows.

    [:octicons-arrow-right-24: GeoPackage in QGIS](geopackage.md)

-   :material-server-network:{ .lg .middle } __Load the schema into Postgres__

    ---

    Download the released SQL bundle and apply it to your own
    PostgreSQL + PostGIS database. Then connect from QGIS, web maps,
    or anything that speaks Postgres.

    [:octicons-arrow-right-24: Load into Postgres](postgres.md)

-   :material-map-marker-path:{ .lg .middle } __Take it to the field__

    ---

    The GeoPackage is field-portable in QField and Mergin Maps. UUIDs
    and `last_update` timestamps make a clean sync path back to the
    source Postgres after a capture trip.

    [:octicons-arrow-right-24: Field workflow](field-workflow.md)

</div>

## I want to&hellip;

| Goal | Path |
| --- | --- |
| Look at the data in QGIS on my laptop | [GeoPackage in QGIS](geopackage.md) |
| Run a server my team and tools can query | [Load into Postgres](postgres.md) |
| Wire QGIS to that server | [Connect QGIS to Postgres](postgres.md#5-connect-qgis-to-your-database) |
| Take data into the field on my phone or tablet | [Field workflow](field-workflow.md) |
| Browse what the schema actually captures | [Data Model](../data-model/index.md) |
| Work on the schema itself (not just use it) | [Developer Guide](../developer-guide/index.md) |

## Schema versions

The current schema version is on the
[GitHub Releases page](https://github.com/kartoza/InfrastructureMapper/releases/latest).
Every released GeoPackage and SQL tarball is tagged with a `vX.Y.Z`
semver and carries its own `current_schema_version` view so consumers
can read which migrations are baked in. See
[Schema Lifecycle](../schema-lifecycle/index.md) for what bumps a
major / minor / patch.

## Need help?

- Issue tracker: <https://github.com/kartoza/InfrastructureMapper/issues>
- Email: <info@kartoza.com>
