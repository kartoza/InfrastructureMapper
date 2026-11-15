-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- ------------------------------GPKG-RELATED-TABLES-EXTENSION----------------------------
-- Canonical, always-current definitions for the GeoPackage "Related Tables Extension"
-- (http://www.geopackage.org/spec/#extension_relations) across this schema's foreign
-- keys. GPKG-only: unlike sql/extensions.sql (PG-only, applied via psql before export),
-- this file is applied via sqlite3 AFTER scripts/build_gpkg.sh's ogr2ogr export, since
-- the extension tables and mapping tables are a GeoPackage/SQLite-only concept -- Postgres
-- already enforces every one of these relationships natively via real FOREIGN KEY
-- constraints declared directly in sql/*.sql.
--
-- This file sits alongside sql/extensions.sql rather than under sql/migrations/ because
-- it is continuously maintained (new domains/relations get appended here going forward),
-- not a point-in-time delta. It is NOT subject to baseline immutability: its filename
-- does not match any pattern in check_schema_immutability.sh's is_frozen_path(), by
-- design, so it stays editable.
--
-- Applied by:
--   * scripts/build_gpkg.sh, every fresh rebuild (sqlite3 "$GPKG_OUTPUT" < this file)
--   * sql/migrations/gpkg/UNRELEASED.sql, pasted verbatim under -- Issue #69: for the
--     incremental-update path on already-existing .gpkg files (migrate_gpkg.py can't
--     include another file -- it executes raw SQL text, no SQLite dot-commands)
--
-- Every statement is idempotent (CREATE TABLE IF NOT EXISTS / INSERT OR IGNORE), since
-- build_gpkg.sh always starts from a fresh export and this file still has to be safe to
-- apply alongside whatever a future migration adds.

CREATE TABLE IF NOT EXISTS gpkgext_relations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    base_table_name TEXT NOT NULL,
    base_primary_column TEXT NOT NULL DEFAULT 'id',
    related_table_name TEXT NOT NULL,
    related_primary_column TEXT NOT NULL DEFAULT 'id',
    relation_name TEXT NOT NULL,
    mapping_table_name TEXT NOT NULL UNIQUE
);

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('gpkgext_relations', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

-- ================= 1-infrastructure.sql =================

-- 1-infrastructure.sql: infrastructure_item.uuid <-> infrastructure_type.uuid (via base.infrastructure_type_uuid)
CREATE TABLE IF NOT EXISTS rel_infrastructure_item_infrastructure_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('infrastructure_item', 'uuid', 'infrastructure_type', 'uuid', 'attributes', 'rel_infrastructure_item_infrastructure_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_infrastructure_item_infrastructure_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_infrastructure_item_infrastructure_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM infrastructure_item b JOIN infrastructure_type r ON b.infrastructure_type_uuid = r.uuid;

-- 1-infrastructure.sql: infrastructure_item.uuid <-> infrastructure_management_log.uuid (via related.infrastructure_item_uuid)
CREATE TABLE IF NOT EXISTS rel_infrastructure_item_infrastructure_management_log (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('infrastructure_item', 'uuid', 'infrastructure_management_log', 'uuid', 'attributes', 'rel_infrastructure_item_infrastructure_management_log');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_infrastructure_item_infrastructure_management_log', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_infrastructure_item_infrastructure_management_log (base_id, related_id)
SELECT b.uuid, r.uuid FROM infrastructure_item b JOIN infrastructure_management_log r ON r.infrastructure_item_uuid = b.uuid;

-- 1-infrastructure.sql: infrastructure_management_log.uuid <-> infrastructure_log_action.uuid (via base.infrastructure_log_action_uuid)
CREATE TABLE IF NOT EXISTS rel_infrastructure_management_log_infrastructure_log_action (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('infrastructure_management_log', 'uuid', 'infrastructure_log_action', 'uuid', 'attributes', 'rel_infrastructure_management_log_infrastructure_log_action');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_infrastructure_management_log_infrastructure_log_action', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_infrastructure_management_log_infrastructure_log_action (base_id, related_id)
SELECT b.uuid, r.uuid FROM infrastructure_management_log b JOIN infrastructure_log_action r ON b.infrastructure_log_action_uuid = r.uuid;


-- ================= 2-electricity.sql =================

-- 2-electricity.sql: electricity_line.uuid <-> electricity_line_type.uuid (via base.electricity_line_type_uuid)
CREATE TABLE IF NOT EXISTS rel_electricity_line_electricity_line_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('electricity_line', 'uuid', 'electricity_line_type', 'uuid', 'attributes', 'rel_electricity_line_electricity_line_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_electricity_line_electricity_line_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_electricity_line_electricity_line_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM electricity_line b JOIN electricity_line_type r ON b.electricity_line_type_uuid = r.uuid;

-- 2-electricity.sql: electricity_line.uuid <-> electricity_line_conditions.uuid (via related.electricity_line_uuid)
CREATE TABLE IF NOT EXISTS rel_electricity_line_electricity_line_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('electricity_line', 'uuid', 'electricity_line_conditions', 'uuid', 'attributes', 'rel_electricity_line_electricity_line_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_electricity_line_electricity_line_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_electricity_line_electricity_line_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM electricity_line b JOIN electricity_line_conditions r ON r.electricity_line_uuid = b.uuid;

-- 2-electricity.sql: electricity_line_conditions.uuid <-> electricity_line_condition_type.uuid (via base.electricity_line_condition_uuid)
CREATE TABLE IF NOT EXISTS rel_electricity_line_conditions_electricity_line_condition_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('electricity_line_conditions', 'uuid', 'electricity_line_condition_type', 'uuid', 'attributes', 'rel_electricity_line_conditions_electricity_line_condition_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_electricity_line_conditions_electricity_line_condition_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_electricity_line_conditions_electricity_line_condition_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM electricity_line_conditions b JOIN electricity_line_condition_type r ON b.electricity_line_condition_uuid = r.uuid;


-- ================= 3-water.sql =================

-- 3-water.sql: water_source.uuid <-> water_polygon.uuid (via related.water_source_uuid)
CREATE TABLE IF NOT EXISTS rel_water_source_water_polygon (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_source', 'uuid', 'water_polygon', 'uuid', 'features', 'rel_water_source_water_polygon');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_source_water_polygon', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_source_water_polygon (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_source b JOIN water_polygon r ON r.water_source_uuid = b.uuid;

-- 3-water.sql: water_polygon.uuid <-> water_polygon_type.uuid (via base.water_polygon_type_uuid)
CREATE TABLE IF NOT EXISTS rel_water_polygon_water_polygon_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_polygon', 'uuid', 'water_polygon_type', 'uuid', 'attributes', 'rel_water_polygon_water_polygon_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_polygon_water_polygon_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_polygon_water_polygon_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_polygon b JOIN water_polygon_type r ON b.water_polygon_type_uuid = r.uuid;

-- 3-water.sql: water_source.uuid <-> water_point.uuid (via related.water_source_uuid)
CREATE TABLE IF NOT EXISTS rel_water_source_water_point (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_source', 'uuid', 'water_point', 'uuid', 'features', 'rel_water_source_water_point');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_source_water_point', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_source_water_point (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_source b JOIN water_point r ON r.water_source_uuid = b.uuid;

-- 3-water.sql: water_point.uuid <-> water_point_type.uuid (via base.water_point_type_uuid)
CREATE TABLE IF NOT EXISTS rel_water_point_water_point_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_point', 'uuid', 'water_point_type', 'uuid', 'attributes', 'rel_water_point_water_point_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_point_water_point_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_point_water_point_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_point b JOIN water_point_type r ON b.water_point_type_uuid = r.uuid;

-- 3-water.sql: water_source.uuid <-> water_line.uuid (via related.water_source_uuid)
CREATE TABLE IF NOT EXISTS rel_water_source_water_line (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_source', 'uuid', 'water_line', 'uuid', 'features', 'rel_water_source_water_line');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_source_water_line', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_source_water_line (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_source b JOIN water_line r ON r.water_source_uuid = b.uuid;

-- 3-water.sql: water_line.uuid <-> water_line_type.uuid (via base.water_line_type_uuid)
CREATE TABLE IF NOT EXISTS rel_water_line_water_line_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('water_line', 'uuid', 'water_line_type', 'uuid', 'attributes', 'rel_water_line_water_line_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_water_line_water_line_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_water_line_water_line_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM water_line b JOIN water_line_type r ON b.water_line_type_uuid = r.uuid;


-- ================= 4-vegetation.sql =================

-- 4-vegetation.sql: vegetation_point.uuid <-> plant_type.uuid (via base.plant_type_uuid)
CREATE TABLE IF NOT EXISTS rel_vegetation_point_plant_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('vegetation_point', 'uuid', 'plant_type', 'uuid', 'attributes', 'rel_vegetation_point_plant_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_vegetation_point_plant_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_vegetation_point_plant_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM vegetation_point b JOIN plant_type r ON b.plant_type_uuid = r.uuid;

-- 4-vegetation.sql: vegetation_point.uuid <-> pruning_activity.uuid (via related.vegetation_point_uuid)
CREATE TABLE IF NOT EXISTS rel_vegetation_point_pruning_activity (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('vegetation_point', 'uuid', 'pruning_activity', 'uuid', 'attributes', 'rel_vegetation_point_pruning_activity');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_vegetation_point_pruning_activity', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_vegetation_point_pruning_activity (base_id, related_id)
SELECT b.uuid, r.uuid FROM vegetation_point b JOIN pruning_activity r ON r.vegetation_point_uuid = b.uuid;

-- 4-vegetation.sql: vegetation_point.uuid <-> harvest_activity.uuid (via related.vegetation_point_uuid)
CREATE TABLE IF NOT EXISTS rel_vegetation_point_harvest_activity (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('vegetation_point', 'uuid', 'harvest_activity', 'uuid', 'attributes', 'rel_vegetation_point_harvest_activity');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_vegetation_point_harvest_activity', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_vegetation_point_harvest_activity (base_id, related_id)
SELECT b.uuid, r.uuid FROM vegetation_point b JOIN harvest_activity r ON r.vegetation_point_uuid = b.uuid;

-- 4-vegetation.sql: plant_growth_activities.fid <-> plant_growth_activity_type.uuid (via base.fk_plant_activity_uuid)
CREATE TABLE IF NOT EXISTS rel_plant_growth_activities_plant_growth_activity_type (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('plant_growth_activities', 'fid', 'plant_growth_activity_type', 'uuid', 'attributes', 'rel_plant_growth_activities_plant_growth_activity_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_plant_growth_activities_plant_growth_activity_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_plant_growth_activities_plant_growth_activity_type (base_id, related_id)
SELECT b.fid, r.uuid FROM plant_growth_activities b JOIN plant_growth_activity_type r ON b.fk_plant_activity_uuid = r.uuid;

-- 4-vegetation.sql: plant_growth_activities.fid <-> plant_type.uuid (via base.fk_plant_type_uuid)
CREATE TABLE IF NOT EXISTS rel_plant_growth_activities_plant_type (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('plant_growth_activities', 'fid', 'plant_type', 'uuid', 'attributes', 'rel_plant_growth_activities_plant_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_plant_growth_activities_plant_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_plant_growth_activities_plant_type (base_id, related_id)
SELECT b.fid, r.uuid FROM plant_growth_activities b JOIN plant_type r ON b.fk_plant_type_uuid = r.uuid;

-- 4-vegetation.sql: plant_growth_activities.fid <-> month.uuid (via base.fk_month_uuid)
CREATE TABLE IF NOT EXISTS rel_plant_growth_activities_month (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('plant_growth_activities', 'fid', 'month', 'uuid', 'attributes', 'rel_plant_growth_activities_month');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_plant_growth_activities_month', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_plant_growth_activities_month (base_id, related_id)
SELECT b.fid, r.uuid FROM plant_growth_activities b JOIN month r ON b.fk_month_uuid = r.uuid;

-- 4-vegetation.sql: plant_type_usages.fid <-> plant_usage.uuid (via base.fk_plant_usage_uuid)
CREATE TABLE IF NOT EXISTS rel_plant_type_usages_plant_usage (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('plant_type_usages', 'fid', 'plant_usage', 'uuid', 'attributes', 'rel_plant_type_usages_plant_usage');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_plant_type_usages_plant_usage', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_plant_type_usages_plant_usage (base_id, related_id)
SELECT b.fid, r.uuid FROM plant_type_usages b JOIN plant_usage r ON b.fk_plant_usage_uuid = r.uuid;

-- 4-vegetation.sql: plant_type_usages.fid <-> plant_type.uuid (via base.fk_plant_type_uuid)
CREATE TABLE IF NOT EXISTS rel_plant_type_usages_plant_type (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('plant_type_usages', 'fid', 'plant_type', 'uuid', 'attributes', 'rel_plant_type_usages_plant_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_plant_type_usages_plant_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_plant_type_usages_plant_type (base_id, related_id)
SELECT b.fid, r.uuid FROM plant_type_usages b JOIN plant_type r ON b.fk_plant_type_uuid = r.uuid;


-- ================= 5-monitoring.sql =================

-- 5-monitoring.sql: monitoring_station.uuid <-> equipment_type.uuid (via base.equipment_type_uuid)
CREATE TABLE IF NOT EXISTS rel_monitoring_station_equipment_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('monitoring_station', 'uuid', 'equipment_type', 'uuid', 'attributes', 'rel_monitoring_station_equipment_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_monitoring_station_equipment_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_monitoring_station_equipment_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM monitoring_station b JOIN equipment_type r ON b.equipment_type_uuid = r.uuid;

-- 5-monitoring.sql: monitoring_station.uuid <-> readings.uuid (via related.monitoring_station_uuid)
CREATE TABLE IF NOT EXISTS rel_monitoring_station_readings (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('monitoring_station', 'uuid', 'readings', 'uuid', 'features', 'rel_monitoring_station_readings');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_monitoring_station_readings', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_monitoring_station_readings (base_id, related_id)
SELECT b.uuid, r.uuid FROM monitoring_station b JOIN readings r ON r.monitoring_station_uuid = b.uuid;

-- 5-monitoring.sql: readings.uuid <-> reading_unit.uuid (via base.reading_unit_uuid)
CREATE TABLE IF NOT EXISTS rel_readings_reading_unit (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('readings', 'uuid', 'reading_unit', 'uuid', 'attributes', 'rel_readings_reading_unit');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_readings_reading_unit', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_readings_reading_unit (base_id, related_id)
SELECT b.uuid, r.uuid FROM readings b JOIN reading_unit r ON b.reading_unit_uuid = r.uuid;


-- ================= 6-buildings.sql =================

-- 6-buildings.sql: building.uuid <-> building_type.uuid (via base.building_type_uuid)
CREATE TABLE IF NOT EXISTS rel_building_building_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building', 'uuid', 'building_type', 'uuid', 'attributes', 'rel_building_building_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_building_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_building_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM building b JOIN building_type r ON b.building_type_uuid = r.uuid;

-- 6-buildings.sql: building.uuid <-> building_materials.uuid (via related.building_uuid)
CREATE TABLE IF NOT EXISTS rel_building_building_materials (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building', 'uuid', 'building_materials', 'uuid', 'attributes', 'rel_building_building_materials');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_building_materials', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_building_materials (base_id, related_id)
SELECT b.uuid, r.uuid FROM building b JOIN building_materials r ON r.building_uuid = b.uuid;

-- 6-buildings.sql: building_materials.uuid <-> building_material.uuid (via base.building_material_uuid)
CREATE TABLE IF NOT EXISTS rel_building_materials_building_material (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building_materials', 'uuid', 'building_material', 'uuid', 'attributes', 'rel_building_materials_building_material');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_materials_building_material', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_materials_building_material (base_id, related_id)
SELECT b.uuid, r.uuid FROM building_materials b JOIN building_material r ON b.building_material_uuid = r.uuid;

-- 6-buildings.sql: building.uuid <-> building_conditions.uuid (via related.building_uuid)
CREATE TABLE IF NOT EXISTS rel_building_building_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building', 'uuid', 'building_conditions', 'uuid', 'attributes', 'rel_building_building_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_building_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_building_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM building b JOIN building_conditions r ON r.building_uuid = b.uuid;

-- 6-buildings.sql: building_conditions.uuid <-> condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_building_conditions_condition (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building_conditions', 'uuid', 'condition', 'uuid', 'attributes', 'rel_building_conditions_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_conditions_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_conditions_condition (base_id, related_id)
SELECT b.uuid, r.uuid FROM building_conditions b JOIN condition r ON b.condition_uuid = r.uuid;


-- ================= 7-fencing.sql =================

-- 7-fencing.sql: fence.uuid <-> fence_type.uuid (via base.fence_type_uuid)
CREATE TABLE IF NOT EXISTS rel_fence_fence_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('fence', 'uuid', 'fence_type', 'uuid', 'attributes', 'rel_fence_fence_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_fence_fence_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_fence_fence_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM fence b JOIN fence_type r ON b.fence_type_uuid = r.uuid;

-- 7-fencing.sql: fence.uuid <-> fence_conditions.uuid (via related.fence_uuid)
CREATE TABLE IF NOT EXISTS rel_fence_fence_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('fence', 'uuid', 'fence_conditions', 'uuid', 'attributes', 'rel_fence_fence_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_fence_fence_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_fence_fence_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM fence b JOIN fence_conditions r ON r.fence_uuid = b.uuid;

-- 7-fencing.sql: fence_conditions.uuid <-> condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_fence_conditions_condition (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('fence_conditions', 'uuid', 'condition', 'uuid', 'attributes', 'rel_fence_conditions_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_fence_conditions_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_fence_conditions_condition (base_id, related_id)
SELECT b.uuid, r.uuid FROM fence_conditions b JOIN condition r ON b.condition_uuid = r.uuid;


-- ================= 8-poi.sql =================

-- 8-poi.sql: point_of_interest.uuid <-> point_of_interest_type.uuid (via base.point_of_interest_type_uuid)
CREATE TABLE IF NOT EXISTS rel_point_of_interest_point_of_interest_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('point_of_interest', 'uuid', 'point_of_interest_type', 'uuid', 'attributes', 'rel_point_of_interest_point_of_interest_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_point_of_interest_point_of_interest_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_point_of_interest_point_of_interest_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM point_of_interest b JOIN point_of_interest_type r ON b.point_of_interest_type_uuid = r.uuid;

-- 8-poi.sql: point_of_interest.uuid <-> point_of_interest_conditions.uuid (via related.point_of_interest_uuid)
CREATE TABLE IF NOT EXISTS rel_point_of_interest_point_of_interest_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('point_of_interest', 'uuid', 'point_of_interest_conditions', 'uuid', 'attributes', 'rel_point_of_interest_point_of_interest_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_point_of_interest_point_of_interest_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_point_of_interest_point_of_interest_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM point_of_interest b JOIN point_of_interest_conditions r ON r.point_of_interest_uuid = b.uuid;

-- 8-poi.sql: point_of_interest_conditions.uuid <-> condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_point_of_interest_conditions_condition (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('point_of_interest_conditions', 'uuid', 'condition', 'uuid', 'attributes', 'rel_point_of_interest_conditions_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_point_of_interest_conditions_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_point_of_interest_conditions_condition (base_id, related_id)
SELECT b.uuid, r.uuid FROM point_of_interest_conditions b JOIN condition r ON b.condition_uuid = r.uuid;


-- ================= 9-landuse.sql =================

-- 9-landuse.sql: landuse_area_owner.uuid <-> landuse_area_ownership_type.uuid (via base.landuse_area_ownership_type_uuid)
CREATE TABLE IF NOT EXISTS rel_landuse_area_owner_landuse_area_ownership_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('landuse_area_owner', 'uuid', 'landuse_area_ownership_type', 'uuid', 'attributes', 'rel_landuse_area_owner_landuse_area_ownership_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_landuse_area_owner_landuse_area_ownership_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_landuse_area_owner_landuse_area_ownership_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM landuse_area_owner b JOIN landuse_area_ownership_type r ON b.landuse_area_ownership_type_uuid = r.uuid;

-- 9-landuse.sql: landuse_area.uuid <-> landuse_area_type.uuid (via base.landuse_area_type_uuid)
CREATE TABLE IF NOT EXISTS rel_landuse_area_landuse_area_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('landuse_area', 'uuid', 'landuse_area_type', 'uuid', 'attributes', 'rel_landuse_area_landuse_area_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_landuse_area_landuse_area_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_landuse_area_landuse_area_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM landuse_area b JOIN landuse_area_type r ON b.landuse_area_type_uuid = r.uuid;

-- 9-landuse.sql: landuse_area_owner.uuid <-> landuse_area.uuid (via related.landuse_area_owner_uuid)
CREATE TABLE IF NOT EXISTS rel_landuse_area_owner_landuse_area (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('landuse_area_owner', 'uuid', 'landuse_area', 'uuid', 'features', 'rel_landuse_area_owner_landuse_area');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_landuse_area_owner_landuse_area', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_landuse_area_owner_landuse_area (base_id, related_id)
SELECT b.uuid, r.uuid FROM landuse_area_owner b JOIN landuse_area r ON r.landuse_area_owner_uuid = b.uuid;

-- 9-landuse.sql: landuse_area_conditions.uuid <-> landuse_area_condition_type.uuid (via base.landuse_area_condition_type_uuid)
CREATE TABLE IF NOT EXISTS rel_landuse_area_conditions_landuse_area_condition_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('landuse_area_conditions', 'uuid', 'landuse_area_condition_type', 'uuid', 'attributes', 'rel_landuse_area_conditions_landuse_area_condition_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_landuse_area_conditions_landuse_area_condition_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_landuse_area_conditions_landuse_area_condition_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM landuse_area_conditions b JOIN landuse_area_condition_type r ON b.landuse_area_condition_type_uuid = r.uuid;

-- 9-landuse.sql: landuse_area.uuid <-> landuse_area_conditions.uuid (via related.landuse_area_uuid)
CREATE TABLE IF NOT EXISTS rel_landuse_area_landuse_area_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('landuse_area', 'uuid', 'landuse_area_conditions', 'uuid', 'attributes', 'rel_landuse_area_landuse_area_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_landuse_area_landuse_area_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_landuse_area_landuse_area_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM landuse_area b JOIN landuse_area_conditions r ON r.landuse_area_uuid = b.uuid;


-- ================= 10-gates.sql =================

-- 10-gates.sql: gate.uuid <-> gate_type.uuid (via base.gate_type_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_gate_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'gate_type', 'uuid', 'attributes', 'rel_gate_gate_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_gate_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_gate_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN gate_type r ON b.gate_type_uuid = r.uuid WHERE b.gate_type_uuid IS NOT NULL;

-- 10-gates.sql: gate.uuid <-> gate_function.uuid (via base.gate_function_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_gate_function (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'gate_function', 'uuid', 'attributes', 'rel_gate_gate_function');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_gate_function', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_gate_function (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN gate_function r ON b.gate_function_uuid = r.uuid WHERE b.gate_function_uuid IS NOT NULL;

-- 10-gates.sql: gate.uuid <-> gate_materials.uuid (via related.gate_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_gate_materials (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'gate_materials', 'uuid', 'attributes', 'rel_gate_gate_materials');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_gate_materials', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_gate_materials (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN gate_materials r ON r.gate_uuid = b.uuid;

-- 10-gates.sql: gate_materials.uuid <-> gate_material.uuid (via base.gate_material_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_materials_gate_material (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate_materials', 'uuid', 'gate_material', 'uuid', 'attributes', 'rel_gate_materials_gate_material');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_materials_gate_material', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_materials_gate_material (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate_materials b JOIN gate_material r ON b.gate_material_uuid = r.uuid;

-- 10-gates.sql: building.uuid <-> building_gates.uuid (via related.building_uuid)
CREATE TABLE IF NOT EXISTS rel_building_building_gates (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('building', 'uuid', 'building_gates', 'uuid', 'attributes', 'rel_building_building_gates');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_building_building_gates', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_building_building_gates (base_id, related_id)
SELECT b.uuid, r.uuid FROM building b JOIN building_gates r ON r.building_uuid = b.uuid;

-- 10-gates.sql: gate.uuid <-> building_gates.uuid (via related.gate_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_building_gates (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'building_gates', 'uuid', 'attributes', 'rel_gate_building_gates');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_building_gates', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_building_gates (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN building_gates r ON r.gate_uuid = b.uuid;

-- 10-gates.sql: fence.uuid <-> fence_gates.uuid (via related.fence_uuid)
CREATE TABLE IF NOT EXISTS rel_fence_fence_gates (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('fence', 'uuid', 'fence_gates', 'uuid', 'attributes', 'rel_fence_fence_gates');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_fence_fence_gates', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_fence_fence_gates (base_id, related_id)
SELECT b.uuid, r.uuid FROM fence b JOIN fence_gates r ON r.fence_uuid = b.uuid;

-- 10-gates.sql: gate.uuid <-> fence_gates.uuid (via related.gate_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_fence_gates (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'fence_gates', 'uuid', 'attributes', 'rel_gate_fence_gates');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_fence_gates', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_fence_gates (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN fence_gates r ON r.gate_uuid = b.uuid;

-- 10-gates.sql: gate.uuid <-> gate_conditions.uuid (via related.gate_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_gate_conditions (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate', 'uuid', 'gate_conditions', 'uuid', 'attributes', 'rel_gate_gate_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_gate_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_gate_conditions (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate b JOIN gate_conditions r ON r.gate_uuid = b.uuid;

-- 10-gates.sql: gate_conditions.uuid <-> condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_gate_conditions_condition (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('gate_conditions', 'uuid', 'condition', 'uuid', 'attributes', 'rel_gate_conditions_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_gate_conditions_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_gate_conditions_condition (base_id, related_id)
SELECT b.uuid, r.uuid FROM gate_conditions b JOIN condition r ON b.condition_uuid = r.uuid;


-- ================= 11-poles.sql =================

-- 11-poles.sql: pole.id <-> pole_material.id (via base.pole_material_id)
CREATE TABLE IF NOT EXISTS rel_pole_pole_material (
    base_id INTEGER NOT NULL,
    related_id INTEGER NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('pole', 'id', 'pole_material', 'id', 'attributes', 'rel_pole_pole_material');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_pole_pole_material', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_pole_pole_material (base_id, related_id)
SELECT b.id, r.id FROM pole b JOIN pole_material r ON b.pole_material_id = r.id;

-- 11-poles.sql: pole.id <-> pole_function.id (via base.pole_function_id)
CREATE TABLE IF NOT EXISTS rel_pole_pole_function (
    base_id INTEGER NOT NULL,
    related_id INTEGER NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('pole', 'id', 'pole_function', 'id', 'attributes', 'rel_pole_pole_function');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_pole_pole_function', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_pole_pole_function (base_id, related_id)
SELECT b.id, r.id FROM pole b JOIN pole_function r ON b.pole_function_id = r.id;

-- 11-poles.sql: pole.uuid <-> pole_conditions.fid (via related.pole_uuid)
CREATE TABLE IF NOT EXISTS rel_pole_pole_conditions (
    base_id TEXT NOT NULL,
    related_id INTEGER NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('pole', 'uuid', 'pole_conditions', 'fid', 'attributes', 'rel_pole_pole_conditions');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_pole_pole_conditions', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_pole_pole_conditions (base_id, related_id)
SELECT b.uuid, r.fid FROM pole b JOIN pole_conditions r ON r.pole_uuid = b.uuid;

-- 11-poles.sql: pole_conditions.fid <-> condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_pole_conditions_condition (
    base_id INTEGER NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('pole_conditions', 'fid', 'condition', 'uuid', 'attributes', 'rel_pole_conditions_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_pole_conditions_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_pole_conditions_condition (base_id, related_id)
SELECT b.fid, r.uuid FROM pole_conditions b JOIN condition r ON b.condition_uuid = r.uuid;


-- ================= 12-culinary.sql =================

-- 12-culinary.sql: culinary_facility.uuid <-> culinary_category.uuid (via base.culinary_category_uuid)
CREATE TABLE IF NOT EXISTS rel_culinary_facility_culinary_category (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('culinary_facility', 'uuid', 'culinary_category', 'uuid', 'attributes', 'rel_culinary_facility_culinary_category');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_culinary_facility_culinary_category', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_culinary_facility_culinary_category (base_id, related_id)
SELECT b.uuid, r.uuid FROM culinary_facility b JOIN culinary_category r ON b.culinary_category_uuid = r.uuid;

-- 12-culinary.sql: culinary_facility.uuid <-> culinary_facility_types.uuid (via related.culinary_facility_uuid)
CREATE TABLE IF NOT EXISTS rel_culinary_facility_culinary_facility_types (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('culinary_facility', 'uuid', 'culinary_facility_types', 'uuid', 'attributes', 'rel_culinary_facility_culinary_facility_types');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_culinary_facility_culinary_facility_types', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_culinary_facility_culinary_facility_types (base_id, related_id)
SELECT b.uuid, r.uuid FROM culinary_facility b JOIN culinary_facility_types r ON r.culinary_facility_uuid = b.uuid;

-- 12-culinary.sql: culinary_facility_types.uuid <-> facility_type.uuid (via base.facility_type_uuid)
CREATE TABLE IF NOT EXISTS rel_culinary_facility_types_facility_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('culinary_facility_types', 'uuid', 'facility_type', 'uuid', 'attributes', 'rel_culinary_facility_types_facility_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_culinary_facility_types_facility_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_culinary_facility_types_facility_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM culinary_facility_types b JOIN facility_type r ON b.facility_type_uuid = r.uuid;


-- ================= 13-roads.sql =================

-- 13-roads.sql: road.uuid <-> road_segment.uuid (via related.road_uuid)
CREATE TABLE IF NOT EXISTS rel_road_road_segment (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road', 'uuid', 'road_segment', 'uuid', 'features', 'rel_road_road_segment');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_road_segment', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_road_segment (base_id, related_id)
SELECT b.uuid, r.uuid FROM road b JOIN road_segment r ON r.road_uuid = b.uuid WHERE r.road_uuid IS NOT NULL;

-- 13-roads.sql: road_segment.uuid <-> segment_type.uuid (via base.type_uuid)
CREATE TABLE IF NOT EXISTS rel_road_segment_segment_type (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road_segment', 'uuid', 'segment_type', 'uuid', 'attributes', 'rel_road_segment_segment_type');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_segment_segment_type', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_segment_segment_type (base_id, related_id)
SELECT b.uuid, r.uuid FROM road_segment b JOIN segment_type r ON b.type_uuid = r.uuid;

-- 13-roads.sql: road_segment.uuid <-> segment_status.uuid (via base.status_uuid)
CREATE TABLE IF NOT EXISTS rel_road_segment_segment_status (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road_segment', 'uuid', 'segment_status', 'uuid', 'attributes', 'rel_road_segment_segment_status');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_segment_segment_status', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_segment_segment_status (base_id, related_id)
SELECT b.uuid, r.uuid FROM road_segment b JOIN segment_status r ON b.status_uuid = r.uuid;

-- 13-roads.sql: road_segment.uuid <-> segment_surface.uuid (via base.surface_uuid)
CREATE TABLE IF NOT EXISTS rel_road_segment_segment_surface (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road_segment', 'uuid', 'segment_surface', 'uuid', 'attributes', 'rel_road_segment_segment_surface');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_segment_segment_surface', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_segment_segment_surface (base_id, related_id)
SELECT b.uuid, r.uuid FROM road_segment b JOIN segment_surface r ON b.surface_uuid = r.uuid;

-- 13-roads.sql: road_segment.uuid <-> segment_condition.uuid (via base.condition_uuid)
CREATE TABLE IF NOT EXISTS rel_road_segment_segment_condition (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road_segment', 'uuid', 'segment_condition', 'uuid', 'attributes', 'rel_road_segment_segment_condition');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_segment_segment_condition', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_segment_segment_condition (base_id, related_id)
SELECT b.uuid, r.uuid FROM road_segment b JOIN segment_condition r ON b.condition_uuid = r.uuid;

-- 13-roads.sql: intersection.uuid <-> road_segment.uuid (via related.start_node)
CREATE TABLE IF NOT EXISTS rel_intersection_road_segment__start_node (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('intersection', 'uuid', 'road_segment', 'uuid', 'features', 'rel_intersection_road_segment__start_node');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_intersection_road_segment__start_node', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_intersection_road_segment__start_node (base_id, related_id)
SELECT b.uuid, r.uuid FROM intersection b JOIN road_segment r ON r.start_node = b.uuid WHERE r.start_node IS NOT NULL;

-- 13-roads.sql: intersection.uuid <-> road_segment.uuid (via related.end_node)
CREATE TABLE IF NOT EXISTS rel_intersection_road_segment__end_node (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('intersection', 'uuid', 'road_segment', 'uuid', 'features', 'rel_intersection_road_segment__end_node');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_intersection_road_segment__end_node', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_intersection_road_segment__end_node (base_id, related_id)
SELECT b.uuid, r.uuid FROM intersection b JOIN road_segment r ON r.end_node = b.uuid WHERE r.end_node IS NOT NULL;

-- 13-roads.sql: road_segment.uuid <-> road_segment_photo.uuid (via related.road_segment_uuid)
CREATE TABLE IF NOT EXISTS rel_road_segment_road_segment_photo (
    base_id TEXT NOT NULL,
    related_id TEXT NOT NULL,
    UNIQUE (base_id, related_id)
);

INSERT OR IGNORE INTO gpkgext_relations
    (base_table_name, base_primary_column, related_table_name, related_primary_column, relation_name, mapping_table_name)
VALUES ('road_segment', 'uuid', 'road_segment_photo', 'uuid', 'features', 'rel_road_segment_road_segment_photo');

INSERT OR IGNORE INTO gpkg_extensions (table_name, column_name, extension_name, definition, scope)
VALUES ('rel_road_segment_road_segment_photo', NULL, 'related_tables', 'http://www.geopackage.org/18-000.html#extension_relations', 'read-write');

INSERT OR IGNORE INTO rel_road_segment_road_segment_photo (base_id, related_id)
SELECT b.uuid, r.uuid FROM road_segment b JOIN road_segment_photo r ON r.road_segment_uuid = b.uuid;
