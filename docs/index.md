---
hide:
  - navigation
  - toc
---
<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->

<div class="kz-hero" markdown>

<span class="kz-eyebrow">KARTOZA · INFRASTRUCTURE MAPPER</span>

# A versioned spatial schema for site infrastructure

Capture in Postgres, snapshot to GeoPackage, sync from the field &mdash; one source of truth.

<div class="kz-cta" markdown>
[:material-rocket-launch: Get Started](getting-started/index.md){ .kz-cta__primary }
[:material-database-eye: Data model](data-model/index.md){ .kz-cta__secondary }
[:simple-github: GitHub](https://github.com/kartoza/InfrastructureMapper){ .kz-cta__secondary }
</div>

</div>

![Infrastructure Mapper in action](assets/infrastructure-mapper.gif){ .kz-figure }

## What it is

Infrastructure Mapper is an opinionated PostgreSQL/PostGIS data model for capturing
buildings, roads, water, electricity, fences, vegetation, monitoring, points of
interest, land use, gates, poles, and culinary facilities &mdash; together with
every condition, material, and reading observed against them over time.

Ship the schema as a Postgres database. Snapshot it as a GeoPackage. Take it to the
field in QField or Mergin Maps. Migrate it forward with `vX.Y.Z` migrations. All from
the same source of truth.

## Download the latest release

Always-current direct links &mdash; no version pinning, no GitHub navigation:

<div class="grid cards" markdown>

-   :material-database-outline:{ .lg .middle } __GeoPackage__

    ---

    Single `.gpkg` with every domain. Drag onto a QGIS canvas.

    [:octicons-download-24: KartozaInfrastructureMapper-latest.gpkg](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/KartozaInfrastructureMapper-latest.gpkg)

-   :material-database:{ .lg .middle } __PostgreSQL schema__

    ---

    Self-contained SQL: extensions + meta + every domain + fixtures.

    [:octicons-download-24: pg-schema-latest.sql](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-schema-latest.sql)

-   :material-source-branch:{ .lg .middle } __Migrations__

    ---

    Forward migrations + runner scripts. Apply on top of an older DB.

    [:octicons-download-24: pg-migrations-latest.tar.gz](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-migrations-latest.tar.gz)
    &middot;
    [:octicons-download-24: gpkg-migrations-latest.tar.gz](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/gpkg-migrations-latest.tar.gz)

</div>

Want just one domain? Every release also ships 13 per-domain SQL + GeoPackage slices
(e.g. `pg-schema-07-fencing-latest.sql`,
`KartozaInfrastructureMapper-07-fencing-latest.gpkg`) &mdash; see
[Getting Started](getting-started/index.md) for the per-domain download patterns,
or [GitHub Releases](https://github.com/kartoza/InfrastructureMapper/releases/latest)
for the full asset list.

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
