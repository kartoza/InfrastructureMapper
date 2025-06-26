-- --------------------------------------MONITORING
-- STATIONS-------------------------------------
-- READING UNIT
CREATE TABLE
IF NOT EXISTS reading_unit (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL
);

COMMENT ON TABLE reading_unit IS 'Look up table for monitoring station reading unit';

COMMENT ON COLUMN reading_unit.id IS 'The equipment type ID. This is the Primary Key.';

COMMENT ON COLUMN reading_unit.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN reading_unit.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN reading_unit.last_update_by IS 'The name of the person who updated the table last.';

COMMENT ON COLUMN reading_unit.name IS 'Where we make comments and a description about the reading_unit.';

COMMENT ON COLUMN reading_unit.abbreviation IS 'Where we make comments and a description about the reading_unit.';

-- EQUIPMENT TYPE
CREATE TABLE
IF NOT EXISTS equipment_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    url TEXT,
    notes TEXT,
    model TEXT,
    manufacturer TEXT,
    calibration_date TIMESTAMP DEFAULT now() NOT NULL
);

COMMENT ON TABLE equipment_type IS 'Look up table for equipment type, e.g. moisture tester, penetrometers.';

COMMENT ON COLUMN equipment_type.id IS 'The equipment type ID. This is the Primary Key.';

COMMENT ON COLUMN equipment_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN equipment_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN equipment_type.last_update_by IS 'The name of the person who updated the table last.';

COMMENT ON COLUMN equipment_type.name IS 'Where we make comments and a description about the equipment type.';

COMMENT ON COLUMN equipment_type.url IS 'The URL is unique to the equipment type.';

COMMENT ON COLUMN equipment_type.notes IS 'Additional information of the equipment type';

COMMENT ON COLUMN equipment_type.model IS 'Where we make comments and a description about the equipment type.';

COMMENT ON COLUMN equipment_type.manufacturer IS 'Information about the manufacturer that manufactured the equipment.';

COMMENT ON COLUMN equipment_type.calibration_date IS 'The last date the equipment was calibrated.';

-- ASSOCIATION TABLE
-- MONITORING STATION
CREATE TABLE
IF NOT EXISTS monitoring_station (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    image TEXT,
    equipment TEXT NOT NULL,
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    equipment_type_uuid UUID NOT NULL REFERENCES equipment_type (uuid)
);

COMMENT ON TABLE monitoring_station IS 'Look up table for monitoring station, e.g. station 1, station 2.';

COMMENT ON COLUMN monitoring_station.id IS 'The monitoring station ID. This is the Primary Key.';

COMMENT ON COLUMN monitoring_station.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN monitoring_station.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN monitoring_station.last_update_by IS 'The name of the person who updated the table last.';

COMMENT ON COLUMN monitoring_station.name IS 'Where we make comments and a description about the equipment name.';

COMMENT ON COLUMN monitoring_station.image IS 'The image link associated with the monitoring station image.';

COMMENT ON COLUMN monitoring_station.geometry IS 'The location of the monitoring station. Follows EPSG: 4326.';

COMMENT ON COLUMN monitoring_station.equipment_type_uuid IS 'Globally Unique Identifier.';

-- ASSOCIATION TABLE
-- READINGS
CREATE TABLE
IF NOT EXISTS readings (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    notes TEXT,
    equipment TEXT NOT NULL,
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    soil_ph FLOAT NOT NULL,
    soil_temperature FLOAT NOT NULL,
    estimated_depth_m FLOAT NOT NULL,
    monitoring_station_uuid UUID NOT NULL REFERENCES monitoring_station (uuid),
    reading_unit_uuid UUID NOT NULL REFERENCES reading_unit (uuid)
);

COMMENT ON TABLE readings IS 'Look up table for readings, e.g. reading at station 1, station 2.';

COMMENT ON COLUMN readings.id IS 'The monitoring station ID. This is the Primary Key.';

COMMENT ON COLUMN readings.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN readings.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN readings.last_update_by IS 'The name of the person who updated the table last.';

COMMENT ON COLUMN readings.name IS 'Where we make comments and a description about the readings name.';

COMMENT ON COLUMN readings.notes IS 'Additional information of the readings.';

COMMENT ON COLUMN readings.equipment IS 'Equipment name used for the readings.  e.g. moisture_testers, penetrometers';

COMMENT ON COLUMN readings.geometry IS 'The location of the monitoring station. Follows EPSG: 4326.';

COMMENT ON COLUMN readings.soil_ph IS 'The soil ph measured in pH scale is from 0 (most acid) to 14 (most alkaline) and a pH of 7 is neutral.';

COMMENT ON COLUMN readings.soil_temperature IS 'The soil temperature measured in degrees celcius.';

COMMENT ON COLUMN readings.estimated_depth_m IS 'The estimated_depth length measured in meters.';

-- ---------------------------------------------------------------------------------------------------
-- CONDITIONS
CREATE TABLE
IF NOT EXISTS condition (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE condition IS 'Look up table for condition, e.g. good, bad.';

COMMENT ON COLUMN condition.id IS 'The unique condition item id. Primary key.';

COMMENT ON COLUMN condition.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN condition.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN condition.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN condition.name IS 'The name of the condition item.';

COMMENT ON COLUMN condition.notes IS 'Additional information of the condition item.';

COMMENT ON COLUMN condition.image IS 'Image of the condition item.';
