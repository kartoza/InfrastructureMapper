<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
<!-- cspell:ignore landuse mkdocs ogr2ogr -->

# 🌐 Infrastructure Mapper

![Kartoza · Open Source Geospatial Solutions](./docs/assets/brand/kartoza-logo-horizontal-color.png)

A versioned PostgreSQL/PostGIS schema (and matching GeoPackage build pipeline)
for capturing physical infrastructure &mdash; buildings, fences, roads, water,
electricity, gates, poles, points of interest, vegetation, monitoring
stations, culinary facilities, and land-use areas &mdash; plus their conditions
over time.

📚 **[Read the docs](https://kartoza.github.io/InfrastructureMapper/)** &mdash;
quick start, data model, schema lifecycle, contributor guide.

![Animation](./img/infrastructure-mapper.gif)

## Get the data

Stable download links &mdash; always resolve to the latest released version:

| Asset | Direct download |
|---|---|
| **GeoPackage** (everything, for QGIS / QField / Mergin Maps) | [`KartozaInfrastructureMapper-latest.gpkg`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/KartozaInfrastructureMapper-latest.gpkg) |
| **PostgreSQL schema** (composite, self-contained SQL) | [`pg-schema-latest.sql`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-schema-latest.sql) |
| **PostgreSQL fixtures** (data-only dump of lookup tables) | [`pg-fixtures-latest.sql`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-fixtures-latest.sql) |
| **PostgreSQL migrations** (forward migrations + runner) | [`pg-migrations-latest.tar.gz`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-migrations-latest.tar.gz) |
| **GeoPackage migrations** (forward migrations + runner) | [`gpkg-migrations-latest.tar.gz`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/gpkg-migrations-latest.tar.gz) |

Each release also publishes 13 **per-domain slices** (one self-contained
SQL + GeoPackage per capture domain) and a `migra`-generated schema
diff vs the previous release. Stable per-domain URLs follow the pattern
`pg-schema-NN-name-latest.sql` and `KartozaInfrastructureMapper-NN-name-latest.gpkg`
&mdash; e.g.
[`pg-schema-07-fencing-latest.sql`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/pg-schema-07-fencing-latest.sql),
[`KartozaInfrastructureMapper-07-fencing-latest.gpkg`](https://github.com/kartoza/InfrastructureMapper/releases/latest/download/KartozaInfrastructureMapper-07-fencing-latest.gpkg).
Full asset list on the
[GitHub Releases page](https://github.com/kartoza/InfrastructureMapper/releases/latest).

## Quick start

```bash
nix develop
nix run .#pg-start
nix run .#build-gpkg
nix run .#qgis
```

That gives you a fresh `gpkg/KartozaInfrastructureMapper.gpkg` open in QGIS.
For metric work, build with a UTM CRS:

```bash
nix run .#build-gpkg -- --crs EPSG:32735
```

Full instructions in
[Getting Started](https://kartoza.github.io/InfrastructureMapper/getting-started/).

## QA Status

[![📃 License Checks](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LicenseChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LicenseChecks.yml)
[![🏋🏽 PostGIS Load Test](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LoadSchema.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/LoadSchema.yml)
[![✏️ Markdown](https://github.com/kartoza/InfrastructureMapper/actions/workflows/MarkdownChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/MarkdownChecks.yml)
[![🐍 Python](https://github.com/kartoza/InfrastructureMapper/actions/workflows/PythonChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/PythonChecks.yml)
[![⚒️ QA](https://github.com/kartoza/InfrastructureMapper/actions/workflows/QAChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/QAChecks.yml)
[![👁️ Spelling](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SpellCheck.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SpellCheck.yml)
[![👨🏽 SQL](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SQLChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SQLChecks.yml)
[![🗜️ Yaml](https://github.com/kartoza/InfrastructureMapper/actions/workflows/YamlChecks.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/YamlChecks.yml)
[![🔒 Schema Immutability](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SchemaImmutability.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/SchemaImmutability.yml)
[![📚 Docs](https://github.com/kartoza/InfrastructureMapper/actions/workflows/Docs.yml/badge.svg)](https://github.com/kartoza/InfrastructureMapper/actions/workflows/Docs.yml)

## Documentation

The full documentation lives at
**<https://kartoza.github.io/InfrastructureMapper/>** &mdash; built with
mkdocs-material from `docs/`, regenerated on every push to `main`.

- [Getting Started](https://kartoza.github.io/InfrastructureMapper/getting-started/) &mdash; load the schema into Postgres, open the GeoPackage in QGIS, take it into the field.
- [Data Model](https://kartoza.github.io/InfrastructureMapper/data-model/) &mdash; every capture domain with hand-written narrative and auto-generated schema references.
- [Schema Lifecycle](https://kartoza.github.io/InfrastructureMapper/schema-lifecycle/) &mdash; versioning, migrations, releases, CI.
- [Developer Guide](https://kartoza.github.io/InfrastructureMapper/developer-guide/) &mdash; the Nix flake, scripts, contribution flow.
- [Specification](https://kartoza.github.io/InfrastructureMapper/about/specification/) &mdash; the canonical technical spec.

Preview the docs locally:

```bash
nix run .#docs-serve   # → http://127.0.0.1:8000
```

## License

MIT &mdash; see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branch/migration/PR flow, and
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards.

## Support this project

If Infrastructure Mapper is useful to you or your organisation, please
consider supporting continued development:

- 💖 [GitHub Sponsors](https://github.com/sponsors/timlinux)
- ☕ [Ko-fi](https://ko-fi.com/timlinux)
- 🏢 [Hire Kartoza](https://kartoza.com) for custom work

## Contributors

See the [contributors page](https://github.com/kartoza/InfrastructureMapper/graphs/contributors)
for everyone who has shipped to this project.

---

Made with 💗 by [Kartoza](https://kartoza.com) &middot;
[Donate](https://github.com/sponsors/timlinux) &middot;
[GitHub](https://github.com/kartoza/InfrastructureMapper)
