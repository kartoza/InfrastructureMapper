<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Field Workflow

`gpkg/KartozaInfrastructureMapper.gpkg` is a snapshot of the canonical PG schema
plus its lookup data, packaged in a single file that QField and Mergin Maps both
understand natively. The schema design supports capturing in the field and
bringing changes back to the source PG.

## What the schema gives you for sync

- Every table carries a `uuid` column (stable across PG and GPKG), so rows can
  be matched across both stores regardless of the integer `id`.
- Every table carries `last_update` and `last_update_by`, so per-row "who
  touched this when" survives the round trip.
- The `schema_migrations` table and `current_schema_version` view travel with
  the file, so a returning field GeoPackage carries its own provenance.

!!! note "Sync direction"
    A custom sync script that merges a returning field GeoPackage back into the
    source PG isn't yet bundled with the project &mdash; the schema is ready
    for it, but the merge policy (last-write-wins vs review queue) is a
    project-level decision that hasn't been locked in.

## Three sync tooling paths

There are three reasonable approaches, in order of "off the shelf":

1. **QGIS built-in Offline Editing plugin (free, in-box).** Open your PG project
   in QGIS, *Database → Offline Editing → Convert to offline project*. QGIS
   tracks every change in hidden `logged_*` tables inside the GeoPackage. Open
   that project in QField, edit, come back, *Synchronize* &mdash; QGIS replays
   the captured changes against PG. Best when the schema isn't changing during
   the field season.

2. **Mergin Maps (Lutra Consulting, freemium).** Field users sync to a Mergin
   server (GeoPackage ↔ GeoPackage, very robust). At your office, a custom
   Mergin-to-PG step on top is still needed &mdash; Mergin doesn't speak PG
   natively. Best when multiple field users edit concurrently.

3. **Custom UUID-diff sync.** Walk each table by UUID and merge:
    - In GPKG but not in PG → INSERT
    - In both, `gpkg.last_update > pg.last_update` → UPDATE
    - In both modified after the snapshot → conflict (apply your chosen policy)

    Most flexible, works with any field tool, requires writing the merge logic.

## Versioned snapshots, not in-place migration

GeoPackages are treated as versioned snapshots, not databases that get
migrated in-place during a field trip. The recommended flow:

1. **Office**: a new schema version is released. Apply it to your
   production Postgres &mdash; see
   [Migrations](../schema-lifecycle/migrations.md).
2. **Office**: download a fresh GeoPackage at the current schema
   version, either from the
   [GitHub Releases page](https://github.com/kartoza/InfrastructureMapper/releases/latest)
   or by exporting one from your Postgres.
3. **Field**: capture against that snapshot.
4. **Office**: sync the returning GeoPackage back to Postgres. The
   field GeoPackage is then archived; the next field trip gets a fresh
   snapshot at the latest schema.

This means *the schema can evolve freely while data is in the field*
&mdash; the constraint is "sync before forking the next snapshot."

## When the GeoPackage itself is the production database

For QGIS-desktop-only deployments without a Postgres server, the
GeoPackage *is* production. There, in-place GeoPackage migration
matters: see
[Migrations](../schema-lifecycle/migrations.md) for the script that
advances an existing field GeoPackage to a newer schema version.
