-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------UNRELEASED-GPKG-MIGRATIONS----------------------
-- Append SQLite/GeoPackage schema changes for the next release here. Paired with the PG
-- equivalent in sql/migrations/pg/UNRELEASED.sql.
--
-- Required format for every appended block:
--
--   -- Issue #NNN: short description
--   <SQL statements>
--
-- Notes on GPKG dialect:
--   * SQLite ALTER TABLE is limited; for constraint changes use the SQLite 12-step
--     recreate pattern (CREATE new table, INSERT … SELECT, DROP old, RENAME).
--   * If a migration adds, renames, or drops a spatial table, also update
--     gpkg_contents and gpkg_geometry_columns and (re)build the rtree index.

-- Issue #56: Unify CRS to EPSG:4326 across all spatial tables (GPKG side).
-- The PG migration uses ST_Transform; SQLite/GPKG has no built-in equivalent
-- without SpatiaLite. Rebuild the GPKG from PG instead:
--     scripts/build_gpkg.sh [--crs EPSG:NNNN]
-- and re-import any captured field data. For records, also stamp this
-- migration as applied:
UPDATE gpkg_geometry_columns
SET srs_id = 4326
WHERE table_name IN ('intersection', 'road_segment');
