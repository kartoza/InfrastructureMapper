-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------UNRELEASED-PG-MIGRATIONS------------------------
-- Append schema changes for the next release here. At release time this file is renamed
-- to vX.Y.Z.sql by scripts/release.sh and becomes immutable.
--
-- Required format for every appended block:
--
--   -- Issue #NNN: short description
--   <SQL statements>
--
-- Pre-commit hook (and the matching CI job) rejects any statement that is not preceded by
-- an `-- Issue #NNN:` header line.

-- Issue #56: Unify CRS to EPSG:4326 across all spatial tables.
-- Roads and intersections originally declared EPSG:32734 (WGS 84 / UTM Zone 34S)
-- while every other spatial table used EPSG:4326. Bring them onto the same
-- declared CRS so the canonical schema is uniform; users that need metric
-- accuracy reproject at build time via scripts/build_gpkg.sh --crs.
ALTER TABLE intersection ALTER COLUMN geom TYPE GEOMETRY (POINT, 4326) USING ST_TRANSFORM(geom, 4326);
ALTER TABLE road_segment ALTER COLUMN geom TYPE GEOMETRY (LINESTRING, 4326) USING ST_TRANSFORM(geom, 4326);
