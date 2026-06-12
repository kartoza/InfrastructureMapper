<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Installation

## Requirements

- A Unix-like system (Linux or macOS).
- [Nix](https://nixos.org/download) with flakes enabled.
- That's it &mdash; Postgres, PostGIS, GDAL, sqlfluff, black, mkdocs and every other
  tool are provisioned by the flake.

!!! tip "Why Nix?"
    Pinning tooling in `flake.nix` means CI and local environments share the
    exact same versions. The schema lifecycle relies on that pin &mdash;
    `sqlfluff` upgrading silently is the kind of drift the project actively
    rejects.

## Enable flakes

Add this to `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf` on multi-user installs):

```ini
experimental-features = nix-command flakes
```

## Clone and enter the dev shell

```bash
git clone https://github.com/kartoza/InfrastructureMapper.git
cd InfrastructureMapper
nix develop
```

The first `nix develop` pulls a few hundred MB of packages and may take a few
minutes. Subsequent shells take seconds. When the shell is ready you'll see a
banner listing the convenience commands you have available:

```text
╭────────────────────────────────────────────────────╮
│   🌐  Infrastructure Mapper  v0.1.0                │
│   Spatial schema + GeoPackage pipeline · Kartoza   │
╰────────────────────────────────────────────────────╯

🐘  Postgres   ● STOPPED   dir: ./pgdata · port: 5432
   nix run .#pg-start     Start (initdb on first run, idempotent)
   nix run .#pg-stop      Stop the cluster
   nix run .#pg-status    Show state, version, databases
   nix run .#pg-restart   Stop then start
   nix run .#pg-psql      Open psql against the 'gis' DB
   nix run .#pg-logs      Tail the server log
   nix run .#pg-reset     DESTROY pgdata and re-initialise (confirms first)

📦  Schema lifecycle
   nix run .#build-gpkg   Build gpkg/KartozaInfrastructureMapper.gpkg
   nix run .#migrate-pg   Apply pending PG migrations to a target DB
   nix run .#migrate-gpkg Apply pending GPKG migrations to a target file
   nix run .#docs         Regenerate Schema Reference in docs/data-model/*.md
   nix run .#release      Cut a release

📚  Documentation site (mkdocs-material)
   nix run .#docs-serve   Live preview at http://127.0.0.1:8000
   nix run .#docs-build   Strict build into ./site (CI parity)

🗺️  Apps
   nix run .#qgis         QGIS with the InfrastructureMapper profile
   nix run .#qgis-ltr     QGIS LTR with the same profile
```

The Postgres line is live &mdash; it changes between **NOT INITIALIZED**,
**STOPPED**, and **RUNNING** to reflect the actual state of `./pgdata`.

## Start Postgres

```bash
nix run .#pg-start
```

This provisions a Postgres data dir at `./pgdata`, starts the server on
Unix socket `./pgdata/.s.PGSQL.5432`, creates the `gis` database, and enables
PostGIS in it. The command is idempotent: re-running it when the cluster is
already up is a no-op.

Useful follow-ups:

```bash
nix run .#pg-status   # live state + database list
nix run .#pg-psql     # interactive psql against gis
nix run .#pg-logs     # follow ./pgdata/postgres.log
nix run .#pg-stop     # graceful shutdown
```

!!! note "Editor integration"
    The repo also ships a `.exrc` with project-specific Neovim WhichKey
    bindings under <kbd>&lt;leader&gt;p</kbd> &mdash; see
    [the dev shell README](../developer-guide/nix-flake.md) for the full
    cheat sheet.
