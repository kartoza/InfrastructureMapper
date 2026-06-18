-- --------------------------------------Pollution--------------------------------------------

-- PROPERTY USE TYPE
CREATE TABLE IF NOT EXISTS property_use_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);
COMMENT ON TABLE property_use_type IS 'Lookup table for property use type, e.g. "Factory", "Storage".';

COMMENT ON COLUMN property_use_type.id IS 'The unique property use type ID. This is the Primary Key.';

COMMENT ON COLUMN property_use_type.name IS 'The use for the property.';

COMMENT ON COLUMN property_use_type.notes IS 'Additional information of the property use type.';

COMMENT ON COLUMN property_use_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN property_use_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN property_use_type.uuid IS 'Global Unique Identifier.';

-- POLLUTION SOURCE
CREATE TABLE IF NOT EXISTS pollution_source (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    geometry GEOMETRY (Point, 32735),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    property_use_type_id INTEGER NOT NULL REFERENCES property_use_type (id)
);
COMMENT ON TABLE pollution_source IS 'Location of a pollution source in the area of interest.';

COMMENT ON COLUMN pollution_source.id IS 'The unique pollution source ID. This is the Primary Key.';

COMMENT ON COLUMN pollution_source.name IS 'Name of the pollution source.';

COMMENT ON COLUMN pollution_source.geometry IS 'The location of pollution sources. EPSG: 32735 (WGS 84/UTM Zone 35S).';

COMMENT ON COLUMN pollution_source.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pollution_source.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pollution_source.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN pollution_source.property_use_type_id IS 'The foreign key which references the id from the property_use_type table.';

-- POLLUTANT
CREATE TABLE IF NOT EXISTS pollutant (
    id SERIAL NOT NULL PRIMARY KEY,
    type TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);
COMMENT ON TABLE pollutant IS 'Lookup table for pollutants, e.g. "Chemicals", "Fertilizers".';

COMMENT ON COLUMN pollutant.id IS 'The unique pollutant ID. This is the Primary Key.';

COMMENT ON COLUMN pollutant.type IS 'The type of pollutant.';

COMMENT ON COLUMN pollutant.notes IS 'Additional information of the pollutant.';

COMMENT ON COLUMN pollutant.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pollutant.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pollutant.uuid IS 'Global Unique Identifier.';

-- SOURCE POLLUTANT
CREATE TABLE IF NOT EXISTS source_pollutant (
    id SERIAL NOT NULL PRIMARY KEY,
    notes TEXT,
    images TEXT,
    concentration FLOAT NOT NULL,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pollution_source_id INTEGER NOT NULL REFERENCES pollution_source (id),
    pollutant_id INTEGER NOT NULL REFERENCES pollutant (id)
);
COMMENT ON TABLE source_pollutant IS 'Estimated concentration of pollutants.';

COMMENT ON COLUMN source_pollutant.id IS 'The unique source pollutant ID. This is the Primary Key.';

COMMENT ON COLUMN source_pollutant.notes IS 'Notes taken by observer of pollution.';

COMMENT ON COLUMN source_pollutant.images IS 'Images taken by observer of pollutant.';

COMMENT ON COLUMN source_pollutant.concentration IS 'Estimated value for concentration of pollutants.';

COMMENT ON COLUMN source_pollutant.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN source_pollutant.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN source_pollutant.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN source_pollutant.pollution_source_id IS 'The foreign key which references the id from the pollution_source table.';

COMMENT ON COLUMN source_pollutant.pollutant_id IS 'The foreign key which references the id from the pollutant table.';

-- IMPACT SEVERITY
CREATE TABLE IF NOT EXISTS impact_severity (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);
COMMENT ON TABLE impact_severity IS 'Lookup table for impact severity, e.g. "High", "Low".';

COMMENT ON COLUMN impact_severity.id IS 'The unique impact severity ID. This is the Primary Key.';

COMMENT ON COLUMN impact_severity.name IS 'Impact severity information.';

COMMENT ON COLUMN impact_severity.notes IS 'Additional information of impact severity.';

COMMENT ON COLUMN impact_severity.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN impact_severity.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN impact_severity.uuid IS 'Global Unique Identifier.';

-- WATERBODY TYPE
CREATE TABLE IF NOT EXISTS waterbody_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);
COMMENT ON TABLE waterbody_type IS 'Lookup table for waterbody type, e.g. "Dam", "River".';

COMMENT ON COLUMN waterbody_type.id IS 'The unique waterbody type ID. This is the Primary Key.';

COMMENT ON COLUMN waterbody_type.name IS 'Type of waterbody.';

COMMENT ON COLUMN waterbody_type.notes IS 'Additional information of waterbody type.';

COMMENT ON COLUMN waterbody_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN waterbody_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN waterbody_type.uuid IS 'Global Unique Identifier.';

-- WATER QUALITY STATUS
CREATE TABLE IF NOT EXISTS water_quality_status (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);
COMMENT ON TABLE water_quality_status IS 'Lookup table for water quality for waterbodies in the area of interest, e.g. "Good", "Poor".';

COMMENT ON COLUMN water_quality_status.id IS 'The unique water qulity status ID. This is the Primary Key.';

COMMENT ON COLUMN water_quality_status.name IS 'Condition of water in waterbody.';

COMMENT ON COLUMN water_quality_status.notes IS 'Additional information on water quality.';

COMMENT ON COLUMN water_quality_status.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_quality_status.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_quality_status.uuid IS 'Global Unique Identifier.';

-- WATERBODY
CREATE TABLE IF NOT EXISTS waterbody (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    geometry geometry (MULTIPOLYGON, 32735),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    waterbody_type_id INTEGER NOT NULL REFERENCES waterbody_type (id),
    water_quality_status_id INTEGER NOT NULL REFERENCES water_quality_status (id)
);
COMMENT ON TABLE waterbody IS 'Location for waterbodies in the area of interest.';

COMMENT ON COLUMN waterbody.id IS 'The unique waterbody ID. This is the Primary Key.';

COMMENT ON COLUMN waterbody.name IS 'Name of waterbody.';

COMMENT ON COLUMN waterbody.geometry IS 'The different geometries of waterbodies. EPSG: 32735 (WGS 84/UTM Zone 35S)';

COMMENT ON COLUMN waterbody.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN waterbody.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN waterbody.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN waterbody.waterbody_type_id IS 'The foreign key which references the id from the waterbody_type table.';

COMMENT ON COLUMN waterbody.water_quality_status_id IS 'The foreign key which references the id from the water_quality_status table.';

-- POLLUTION IMPACT
CREATE TABLE IF NOT EXISTS pollution_impact (
    id SERIAL NOT NULL PRIMARY KEY,
    distance_from_source FLOAT NOT NULL,
    notes TEXT,
    date DATE NOT NULL,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pollution_source_id  INTEGER NOT NULL REFERENCES pollution_source (id),
    waterbody_id INTEGER NOT NULL REFERENCES waterbody (id),
    pollutant_id INTEGER NOT NULL REFERENCES pollutant (id),
    impact_severity_id INTEGER NOT NULL REFERENCES impact_severity (id)  
);
COMMENT ON TABLE pollution_impact IS 'Represents the pollution impact from pollution sources at a single location.';

COMMENT ON COLUMN pollution_impact.id IS 'The unique pollution impact ID. This is the Primary Key.';

COMMENT ON COLUMN pollution_impact.distance_from_source IS 'Distance from the observation point to the nearest pollution source in meters.';

COMMENT ON COLUMN pollution_impact.notes IS 'Notes made by the observer at the pollution impact site.';

COMMENT ON COLUMN pollution_impact.date IS 'When the observation was made.';

COMMENT ON COLUMN pollution_impact.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pollution_impact.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pollution_impact.uuid IS 'Global unique identifier.';

COMMENT ON COLUMN pollution_impact.pollution_source_id IS 'The foreign key which references the id from the pollution_source table.';

COMMENT ON COLUMN pollution_impact.waterbody_id IS 'The foreign key which references the id from the waterbody_type table.';

COMMENT ON COLUMN pollution_impact.pollutant_id IS 'The foreign key which references the id from the pollutant table.';

COMMENT ON COLUMN pollution_impact.impact_severity_id IS 'The foreign key which references the id from the impact_severity table.';