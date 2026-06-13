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

📚 **[Read the docs](https://timlinux.github.io/InfrastructureMapper/)** &mdash;
quick start, data model, schema lifecycle, contributor guide.

![Animation](./img/infrastructure-mapper.gif)

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
[Getting Started](https://timlinux.github.io/InfrastructureMapper/getting-started/).

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
**<https://timlinux.github.io/InfrastructureMapper/>** &mdash; built with
mkdocs-material from `docs/`, regenerated on every push to `main`.

- [Getting Started](https://timlinux.github.io/InfrastructureMapper/getting-started/) &mdash; install, build, take it into the field.
- [Data Model](https://timlinux.github.io/InfrastructureMapper/data-model/) &mdash; every capture domain with hand-written narrative and auto-generated schema references.
- [Schema Lifecycle](https://timlinux.github.io/InfrastructureMapper/schema-lifecycle/) &mdash; versioning, migrations, releases, CI.
- [Developer Guide](https://timlinux.github.io/InfrastructureMapper/developer-guide/) &mdash; the Nix flake, scripts, contribution flow.
- [Specification](https://timlinux.github.io/InfrastructureMapper/about/specification/) &mdash; the canonical technical spec.

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

See the [contributors page](https://github.com/timlinux/InfrastructureMapper/graphs/contributors)
for everyone who has shipped to this project.

---

Made with 💗 by [Kartoza](https://kartoza.com) &middot;
[Donate](https://github.com/sponsors/timlinux) &middot;
[GitHub](https://github.com/timlinux/InfrastructureMapper)
