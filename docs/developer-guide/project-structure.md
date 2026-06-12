<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Project Structure

A quick map of what lives where and why.

```text
InfrastructureMapper/
├── VERSION                  # canonical semver, single line
├── flake.nix / flake.lock   # dev environment + nix run apps
├── README.md                # short pitch + pointer to these docs
├── SPECIFICATION.md         # full technical spec, kept in sync with the app
├── CONTRIBUTING.md          # contribution flow
├── CODE_OF_CONDUCT.md       # Contributor Covenant v2.1
├── LICENSE / LICENSES/      # MIT + SPDX-formatted license texts
├── cspell.config.yaml       # spell-check dictionary
├── mkdocs.yml               # docs site config (this site)
│
├── sql/                     # ◀── the schema
│   ├── extensions.sql       # CREATE EXTENSION postgis, …
│   ├── 0-meta.sql           # schema_migrations + current_schema_version
│   ├── 1-infrastructure.sql # ┐
│   ├── …                    # ├ one baseline per capture domain (immutable once shipped)
│   ├── 13-roads.sql         # ┘
│   ├── fixtures.sql         # lookup-table seed data
│   ├── 1-infrastructure.md  # ┐ legacy hand-written component docs
│   ├── …                    # │ (being superseded by docs/data-model/)
│   ├── 13-roads.md          # ┘
│   └── migrations/
│       ├── pg/
│       │   ├── UNRELEASED.sql    # in-progress migration
│       │   └── vX.Y.Z.sql        # frozen, immutable after release
│       └── gpkg/
│           ├── UNRELEASED.sql    # paired counterpart
│           └── vX.Y.Z.sql
│
├── scripts/                 # ◀── automation (see Scripts page)
│   ├── build_gpkg.sh
│   ├── migrate_pg.sh
│   ├── migrate_gpkg.py
│   ├── release.sh
│   ├── generate_schema_docs.py
│   ├── check_schema_immutability.sh
│   └── …
│
├── docs/                    # ◀── mkdocs source (this site)
│   ├── index.md
│   ├── getting-started/
│   ├── data-model/          # 13 hand-written + auto-augmented component pages
│   ├── schema-lifecycle/
│   ├── developer-guide/
│   ├── about/
│   ├── assets/              # logos, icons, GIFs
│   ├── stylesheets/extra.css
│   └── overrides/           # mkdocs-material template overrides
│
├── gpkg/                    # built GeoPackage(s)
│   └── KartozaInfrastructureMapper.gpkg
│
├── qgis_projects/           # ready-to-open .qgz projects
├── qml/                     # QGIS layer style files
├── img/                     # legacy image assets (mirrored into docs/assets)
├── diagrams/                # source files for diagrams
├── presentations/           # marp slide decks
└── pgdata/                  # `nix run .#pg-start`'s data dir (gitignored)
```

## Load order &mdash; the schema's golden path

`scripts/build_gpkg.sh` applies SQL files in a strict order:

```text
1. sql/extensions.sql        ← CREATE EXTENSION postgis;
2. sql/0-meta.sql            ← schema_migrations + current_schema_version
3. sql/1-infrastructure.sql  ┐
4. sql/2-electricity.sql     │
   …                         ├ baselines in numerical order
14. sql/13-roads.sql          ┘
15. sql/fixtures.sql         ← lookup seed data
16. sql/migrations/pg/v0.2.0.sql
17. sql/migrations/pg/v0.3.0.sql
    …                        ← migrations in semver order
```

Numeric prefixes are load-order, not topical priority. The dependency
direction is "later files may reference earlier tables, never the
reverse" &mdash; `4-vegetation.sql` can reference `9-landuse.sql`'s
land-use areas only because `landuse` exists by load time, not because
of any topical hierarchy.

## What is and isn't versioned

| Lives in `sql/` | Versioned how |
|---|---|
| `extensions.sql` | Baseline, immutable. |
| `0-meta.sql` | Baseline, immutable. |
| `N-domain.sql` × 13 | Baseline, immutable. |
| `fixtures.sql` | Baseline, immutable (additions go through migrations). |
| `migrations/{pg,gpkg}/vX.Y.Z.sql` | Frozen on release, immutable thereafter. |
| `migrations/{pg,gpkg}/UNRELEASED.sql` | The only schema file you *can* edit on a feature branch. |

The immutability hook (see [CI & Pre-commit](../schema-lifecycle/ci.md))
enforces this at commit time. The only way to "fix" a shipped baseline is
to write a corrective migration.

## What's gitignored, and why

- `pgdata/` &mdash; the project-local Postgres data directory created by
  `nix run .#pg-start`. Recreated freely (`nix run .#pg-reset` will wipe
  and reinitialise it), never committed.
- `.venv/` &mdash; if any tool slipped a virtualenv in. The project doesn't
  use one; everything is in the flake.
- `*.gpkg` in `gpkg/` &mdash; built artifacts. Released GeoPackages are
  attached to GitHub Release tags instead.
- `claude.out`, `.claude-ci/` &mdash; AI-assistant session artifacts. Local
  helper output, not project content.
- `PROMPT.log` &mdash; a per-project log of AI-assistant prompts, used as
  context for future sessions. Local only.

## docs vs sql/*.md

You'll notice both `sql/N-domain.md` and `docs/data-model/NN-domain.md` exist.
The `sql/*.md` files are the legacy hand-written component docs &mdash; they
predate this mkdocs site. The `docs/data-model/*.md` files are the live,
auto-regenerated docs. The legacy files will eventually be removed once the
auto-generation has stabilised; until then, *treat the docs/ versions as
canonical*.
