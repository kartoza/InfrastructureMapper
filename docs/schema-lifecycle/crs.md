<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Choosing a CRS

Every spatial column in the baseline (`sql/*.sql`) and its migrations
declares `EPSG:4326`. That's fine for global interoperability, but it's a
geographic CRS &mdash; distances and areas computed in it are only accurate
to ~2 m. Most deployments want a metric CRS instead (a UTM zone, a national
grid, etc.), and want it applied consistently everywhere: in the schema
they load, in every migration that lands later, and in both PostgreSQL and
GeoPackage.

This page covers the tooling that makes that a one-time choice instead of
a `--crs` flag you have to remember on every command.

## The remembered CRS

`scripts/generate_models.py` resolves a CRS in this order:

1. An explicit `--crs EPSG:NNNN` flag.
2. A CRS remembered from a previous run, in `.im-crs` at the repo root.
3. An interactive prompt (fails fast if stdin isn't a terminal and neither
   of the above applied &mdash; e.g. unattended CI).

Whatever is resolved gets written back to `.im-crs`. That file is
gitignored &mdash; it's machine-local state, not part of the schema &mdash;
so every checkout picks its own CRS independently, and every later command
(`apply-pg`, `build-gpkg`) reuses it without being told again.

## First run

```bash
nix run .#generate-models
# Target CRS for this checkout (e.g. EPSG:4326, EPSG:32734): EPSG:32734
```

This mirrors every `sql/**/*.sql` file &mdash; the baseline, `fixtures.sql`,
and every PG/GPKG migration &mdash; into `build/models/sql/`, with the
literal `4326` SRID token replaced by the CRS you chose. Nothing under
`sql/` is touched; `check_schema_immutability.sh` still governs those files
exactly as before. `build/` is gitignored.

!!! note "Why a literal token, not a parser"
    `4326` only ever appears in this codebase where it means "the baseline
    CRS" &mdash; in `GEOMETRY(type, 4326)` columns, `ST_GEOMFROMTEXT(...,
    4326)` fixtures, and `ST_TRANSFORM(..., 4326)` / `srs_id = 4326` in
    migrations. The one historical exception &mdash; `32734` on the
    original roads/intersection baseline, predating the `v0.2.0` fix
    forward &mdash; is never touched; it's corrected by the (also
    templated) `v0.2.0` migration, which uses `4326` like everything else.

## Loading into Postgres

```bash
nix run .#apply-pg -- gis
```

One command, idempotent either way:

- **First run against an empty/new database:** bootstraps it from the
  CRS-templated baseline + fixtures, then applies every released migration
  on top (so even the roads/intersection historical fix lands at your
  chosen CRS, not 4326).
- **Later runs:** just applies whatever migrations are newer than what's
  already on the database &mdash; delegating to
  [`migrate-pg`](migrations.md) under the hood.

## Building a GeoPackage

```bash
nix run .#build-gpkg
```

`build-gpkg` resolves the CRS the same way (`--crs` &gt; remembered &gt;
prompt) and rebuilds the `.gpkg` from scratch every time: a throwaway PG
database, baseline + migrations + fixtures, reprojected, exported via
`ogr2ogr`. There is deliberately no in-place CRS change for an existing
`.gpkg` &mdash; SQLite has no `ST_Transform` without SpatiaLite, so
`migrate_gpkg.py --crs` always refuses rather than risk silently wrong
geometries. Rebuilding is the supported path; re-import any captured field
data afterward.

## Keeping up to date

After `git pull` brings in new domains or migrations:

```bash
git pull
nix run .#generate-models   # refresh build/models/ at the remembered CRS
nix run .#apply-pg -- gis  # apply whatever is new to Postgres
nix run .#build-gpkg         # rebuild the GeoPackage, same CRS
```

No CRS has to be re-entered &mdash; `.im-crs` carries it forward.

## Changing your mind

```bash
nix run .#generate-models -- --reset-crs
```

Forces a fresh prompt and overwrites `.im-crs`. This only affects *new*
generation/build runs; it does not retroactively reproject a database
already loaded at the old CRS &mdash; use `migrate_pg.sh --crs` directly
for that, or start a fresh database with `apply-pg`.
