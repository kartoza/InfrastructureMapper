<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# The Nix Flake

`flake.nix` is the single source of truth for *every tool the project needs*:
Postgres + PostGIS, QGIS, the SQL linters, the Python packages, mkdocs and
its plugins, the GDAL/`ogr2ogr` binaries, and the formatters. Open the
project, `cd` into it, type `nix develop`, and you have an environment that
matches CI bit-for-bit.

## The contract

> Anything a developer or CI needs to build, lint, test, or document
> Infrastructure Mapper is provided by `nix develop`. No `pip install`, no
> `apt install`, no `brew install`.

That's an enforced project rule. `requirements.txt` doesn't exist; CI does
not add packages on top of the Nix shell. Adding a new Python or CLI
dependency means editing `flake.nix`.

## What's inside

The shell exposes (see `flake.nix` for the live list):

| Category | What you get |
|---|---|
| **Postgres** | `postgresql.withPackages [ postgis ]` &mdash; PG + PostGIS in one binary path. |
| **QGIS** | From `geospatial-nix` (provided by `imincik/geospatial-nix.repo`), with pyqtwebengine, jsonschema, debugpy, future, psutil already wired into the embedded interpreter. LTR is also packaged as `qgis-ltr`. |
| **GDAL / ogr2ogr** | Pulled in through the QGIS dependency tree. |
| **Python** | `pkgs.python3.withPackages (ps: [...])` with: `mkdocs`, `mkdocs-material`, `mkdocs-material-extensions`, `mkdocs-glightbox`, `mkdocs-git-revision-date-localized-plugin`, `mkdocs-mermaid2-plugin`, `pymdown-extensions`, plus the deps used by `scripts/*.py`. |
| **SQL tooling** | `sqlfluff` (Postgres + SQLite profiles), `pre-commit`. |
| **Python tooling** | `black`, `ruff` (via the dev shell). |
| **Markdown / spell** | `markdownlint-cli`, `cspell`. |
| **License compliance** | `reuse` for SPDX header checking. |
| **Docs** | `marp-cli` for slide rendering, `glow` for terminal markdown previews. |
| **Visualisation** | `gource`, `chafa`, `ffmpeg`. |
| **Editing** | `vim`, `neovim` (via your own config), `vscode`. |

Everything else (`gum`, `gdb`, `jq`, `shellcheck`, `shfmt`, `yamllint`,
`yamlfmt`, `nixfmt-rfc-style`) is there because the pre-commit suite needs
it, or because it's a frequent enough developer aid that it's worth pinning.

## Why this is non-negotiable

The project's primary product is a *database schema*. Schema reproducibility
hinges on tool reproducibility:

- `sqlfluff` 2.x and 3.x disagree on Postgres-keyword handling.
- `black` formatting shifts year to year.
- `mkdocs-material` plugins gain and lose features.
- `ogr2ogr` flags drift between GDAL versions.

If CI runs `sqlfluff 3.0.0` and you run `sqlfluff 2.3.5` locally, your
green commit becomes a red PR. The flake closes that gap: `flake.lock`
pins every transitive dependency to a content-addressed Nix store path.
`nix develop` is the same environment for everyone, all the time.

## Adding a dependency

1. Open `flake.nix`.
2. If it's a Python package available in nixpkgs, add it to the
   `python3.withPackages` list. If it's a CLI tool, add it to the
   `devShells.${system}.default.packages` list.
3. Run `nix flake update` if you need newer nixpkgs &mdash; otherwise leave
   the lock file alone.
4. Run `nix develop --command bash -c 'which <new-tool>'` to confirm it's
   present.
5. Commit `flake.nix` and `flake.lock` together.

> **Don't** pip-install a Python package "just to try it." If the experiment
> is worth keeping, it's worth adding to the flake. If it isn't, it
> shouldn't be on the developer's path.

## The shellHook

`devShells.${system}.default.shellHook` delegates to
`scripts/welcome.sh`, which prints a `gum`-styled banner on every entry
showing:

- The current schema version (from `VERSION`).
- Live Postgres state for `./pgdata` &mdash; **RUNNING**, **STOPPED**, or
  **NOT INITIALIZED** &mdash; with a coloured chip.
- Every `nix run .#…` convenience app, grouped by concern (Postgres
  lifecycle, schema, docs site, apps).

This is intentional &mdash; the project rewards discoverability. New
contributors should see the toolkit, and the state of the database, before
they have to go grep for it. The welcome script degrades gracefully to plain
echo if `gum` isn't on PATH.

## CI integration

`.github/workflows/*.yml` all start with:

```yaml
- uses: DeterminateSystems/nix-installer-action@v22
- run: nix develop --command <whatever>
```

That's the entire bridge between the flake and CI. The `nix-installer-action`
is pinned to `v22` after we tried `v23` and `v17` and found CI behaviour
that didn't match local. There's no `magic-nix-cache-action`, no `cachix`
&mdash; cold Nix every run, deterministic results.

## When the flake feels heavy

A first `nix develop` on a fresh machine takes minutes (downloading QGIS,
GDAL, Postgres+PostGIS). Subsequent enters are sub-second. CI takes 30-90
seconds of Nix evaluation per workflow.

The win &mdash; "any contributor with Nix can reproduce CI exactly" &mdash;
is worth that cost. If you don't want to wait, that's a sign you should
keep your shell open, not a sign the flake is overweight.
