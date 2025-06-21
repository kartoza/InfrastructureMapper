-- --------------------------------------ROADS--------------------------------------------
-- SEGMENT TYPE
CREATE TABLE IF NOT EXISTS segment_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    type_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE segment_type IS 'Lookup table for road type classification, e.g. "National", "Main Road"';

COMMENT ON COLUMN segment_type.id IS 'The unique segment type ID. This is the Primary Key.';

COMMENT ON COLUMN segment_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN segment_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN segment_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN segment_type.type_name IS 'The segment type field name. This is unique.';

COMMENT ON COLUMN segment_type.description IS 'Additional information of the segment type.';

-- SEGMENT STATUS
CREATE TABLE IF NOT EXISTS segment_status (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    status_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE segment_status IS 'Lookup table for construction and usage status, e.g. "In Use", "Planned"';

COMMENT ON COLUMN segment_status.id IS 'The unique segment status ID. This is the Primary Key.';

COMMENT ON COLUMN segment_status.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN segment_status.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN segment_status.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN segment_status.status_name IS 'The segment status field name. This is unique.';

COMMENT ON COLUMN segment_status.description IS 'Additional information of the segment status.';

-- SEGMENT SURFACE
CREATE TABLE IF NOT EXISTS segment_surface (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    surface_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE segment_surface IS 'Lookup table for segment surface material, e.g. "Asphalt", "Dirt"';

COMMENT ON COLUMN segment_surface.id IS 'The unique segment surface ID. This is the Primary Key.';

COMMENT ON COLUMN segment_surface.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN segment_surface.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN segment_surface.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN segment_surface.surface_name IS 'The segment surface field name. This is unique.';

COMMENT ON COLUMN segment_surface.description IS 'Additional information of the segment surface.';

-- SEGMENT CONDITION
CREATE TABLE IF NOT EXISTS segment_condition (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    condition_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE segment_condition IS 'Lookup table for segment condition, e.g. "Good", "Flooded"';

COMMENT ON COLUMN segment_condition.id IS 'The unique segment condition ID. This is the Primary Key.';

COMMENT ON COLUMN segment_condition.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN segment_condition.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN segment_condition.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN segment_condition.condition_name IS 'The segment condition field name. This is unique.';

COMMENT ON COLUMN segment_condition.description IS 'Additional information of the segment condition.';

-- INTERSECTIONS
CREATE TABLE IF NOT EXISTS intersection (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    geom GEOMETRY (POINT, 32734) NOT NULL
);
COMMENT ON TABLE intersection IS 'Points between road segments.';

COMMENT ON COLUMN intersection.id IS 'The unique intersection ID. This is the Primary Key.';

COMMENT ON COLUMN intersection.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN intersection.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN intersection.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN intersection.geom IS 'The location of the nodes between road segments. EPSG: 32734 (WGS 84/UTM Zone 34S)';

-- ROADS
CREATE TABLE IF NOT EXISTS road (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    geom GEOMETRY (LINESTRING, 4326) NOT NULL
);
COMMENT ON TABLE road IS 'Logical road entities, composed of road segments.';

COMMENT ON COLUMN road.id IS 'The unique road ID. This is the Primary Key.';

COMMENT ON COLUMN road.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN road.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN road.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN road.name IS 'Road name information.';

COMMENT ON COLUMN road.geom IS 'Approximate full geometry of the road. EPSG: 4326';

-- ROAD SEGMENTS
CREATE TABLE IF NOT EXISTS road_segment (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    segment_number INT UNIQUE NOT NULL,
    lanes INT CHECK (lanes > 0),
    length_m FLOAT CHECK (length_m > 0),
    speed_limit_kmh INT CHECK (speed_limit_kmh > 0),
    one_way BOOLEAN,
    geom GEOMETRY (LINESTRING, 32734) NOT NULL,
    road_uuid UUID NOT NULL REFERENCES road (uuid),
    type_uuid UUID NOT NULL REFERENCES segment_type (uuid),
    status_uuid UUID NOT NULL REFERENCES segment_status (uuid),
    surface_uuid UUID NOT NULL REFERENCES segment_surface (uuid),
    condition_uuid UUID NOT NULL REFERENCES segment_condition (uuid),
    start_node UUID NOT NULL REFERENCES intersection (uuid),
    end_node UUID NOT NULL REFERENCES intersection (uuid)
);
COMMENT ON TABLE road_segment IS 'Represents physical segments of a road between two nodes.';

COMMENT ON COLUMN road_segment.id IS 'The unique road segment ID. This is the Primary Key.';

COMMENT ON COLUMN road_segment.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN road_segment.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN road_segment.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN road_segment.segment_number IS 'The captured order of road segments.';

COMMENT ON COLUMN road_segment.lanes IS 'The total amount of lanes, including both sides.';

COMMENT ON COLUMN road_segment.length_m IS 'The length of the road segment in meters.';

COMMENT ON COLUMN road_segment.speed_limit_kmh IS 'The speed limit of the road segment.';

COMMENT ON COLUMN road_segment.one_way IS 'True if the segment is a one-way road.';

COMMENT ON COLUMN road_segment.geom IS 'Centreline location of the road segment. PCR for distance measurements, EPSG: 32734 (WGS 84/UTM Zone 34S)';

COMMENT ON COLUMN road_segment.road_uuid IS 'The foreign key which references the uuid from the roads table.';

COMMENT ON COLUMN road_segment.type_uuid IS 'The foreign key which references the uuid from the road segment types table.';

COMMENT ON COLUMN road_segment.status_uuid IS 'The foreign key which references the uuid from the road segment status table.';

COMMENT ON COLUMN road_segment.surface_uuid IS 'The foreign key which references the uuid from the road segment surface table.';

COMMENT ON COLUMN road_segment.condition_uuid IS 'The foreign key which references the uuid from the road segment condition table.';

COMMENT ON COLUMN road_segment.start_node IS 'The foreign key which references the uuid from the intersections table.';

COMMENT ON COLUMN road_segment.end_node IS 'The foreign key which references the uuid from the intersections table.';

-- TRIGGER FUNCTION - SEGMENT LENGTH
create or replace function calculate_length()
returns trigger
as $$
BEGIN
    NEW.length_m := ST_Length(NEW.geom);
    RETURN NEW;
END;
$$
language plpgsql
;

-- TRIGGER
CREATE TRIGGER set_length
BEFORE INSERT OR UPDATE ON road_segment
FOR EACH ROW
EXECUTE FUNCTION calculate_length();
