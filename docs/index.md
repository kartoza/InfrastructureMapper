<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
---
hide:
  - navigation
  - toc
---

<div class="kz-hero" markdown>
<div class="kz-hero__text" markdown>

<span class="kz-eyebrow">KARTOZA · INFRASTRUCTURE MAPPER</span>

# A versioned spatial schema for every piece of infrastructure on your site

Infrastructure Mapper is an opinionated PostgreSQL/PostGIS data model for capturing
buildings, roads, water, electricity, fences, vegetation, monitoring, points of interest,
land use, gates, poles, and culinary facilities &mdash; together with every condition,
material, and reading observed against them over time.

Ship the schema as a Postgres database. Snapshot it as a GeoPackage. Take it to the
field in QField or Mergin Maps. Migrate it forward with `vX.Y.Z` migrations. All from
the same source of truth.

<div class="kz-cta" markdown>
[:material-rocket-launch: Get Started](getting-started/index.md){ .kz-cta__primary }
[:material-database-eye: Explore the data model](data-model/index.md){ .kz-cta__secondary }
[:simple-github: View on GitHub](https://github.com/kartoza/InfrastructureMapper){ .kz-cta__secondary }
</div>

</div>
<div class="kz-hero__visual">

![Kartoza · Open Source Geospatial Solutions](assets/brand/kartoza-logo-horizontal-color.png)

![Infrastructure Mapper in action](assets/infrastructure-mapper.gif)

</div>
</div>

## What's in the box

<div class="grid cards" markdown>

-   :material-database:{ .lg .middle } __Every capture domain__

    ---

    From sub-soil readings to gate hinge angles &mdash; everything you need
    to map a working site, modelled relationally with stable UUIDs across
    PG and GPKG.

    [:octicons-arrow-right-24: Explore the data model](data-model/index.md)

-   :material-source-branch:{ .lg .middle } __Versioned schema lifecycle__

    ---

    Immutable baseline plus paired PG and GPKG migration trails.
    Strict-sequential runners apply pending versions in semver order, each
    in its own transaction.

    [:octicons-arrow-right-24: Read the lifecycle](schema-lifecycle/index.md)

-   :material-map-marker-path:{ .lg .middle } __Field-ready GeoPackages__

    ---

    The same schema, snapshot to a single file for QField or Mergin Maps.
    UUIDs and `last_update` timestamps make a clean sync path back to the
    source PG.

    [:octicons-arrow-right-24: Field workflow](getting-started/field-workflow.md)

-   :material-package-down:{ .lg .middle } __One-tag releases__

    ---

    Each `vX.Y.Z` tag publishes a fresh PG schema dump, GPKG, fixtures, and
    migration tarballs as GitHub Release artifacts.

    [:octicons-arrow-right-24: Release process](schema-lifecycle/release.md)

-   :material-snowflake:{ .lg .middle } __Reproducible Nix dev shell__

    ---

    One flake provisions Postgres, PostGIS, QGIS, GDAL, sqlfluff, black,
    markdownlint, mkdocs &mdash; everything CI uses, ready locally with
    `nix develop`.

    [:octicons-arrow-right-24: The Nix flake](developer-guide/nix-flake.md)

-   :material-shield-check:{ .lg .middle } __CI that knows the schema__

    ---

    Pre-commit + GitHub Action enforce baseline immutability and the
    `-- Issue-NNN:` annotation convention. The schema cannot drift silently.

    [:octicons-arrow-right-24: CI &amp; pre-commit](schema-lifecycle/ci.md)

</div>

## QA status

[![📃 License Checks](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LicenseChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LicenseChecks.yml)
[![🏋🏽 PostGIS Load](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LoadSchema.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LoadSchema.yml)
[![✏️ Markdown](https://github.com/kartoza/InfrastructureMapper/actions/workflows/MarkdownChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/MarkdownChecks.yml)
[![🐍 Python](https://github.com/kartoza/InfrastructureMapper/actions/workflows/PythonChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/PythonChecks.yml)
[![⚒️ QA](https://github.com/kartoza/InfrastructureMapper/actions/workflows/QAChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/QAChecks.yml)
[![👁️ Spelling](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SpellCheck.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SpellCheck.yml)
[![👨🏽 SQL](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SQLChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SQLChecks.yml)
[![🔒 Schema Immutability](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SchemaImmutability.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SchemaImmutability.yml)
[![🗜️ YAML](https://github.com/kartoza/InfrastructureMapper/actions/workflows/YamlChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/YamlChecks.yml)

<div class="kz-footer-credits" markdown>
Made with 💗 by [Kartoza](https://kartoza.com) &middot;
[Sponsor on GitHub](https://github.com/sponsors/kartoza) &middot;
[Repository](https://github.com/kartoza/InfrastructureMapper)
</div>
