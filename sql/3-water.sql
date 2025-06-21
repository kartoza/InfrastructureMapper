-- --------------------------------------WATER-------------------------------------
-- WATER SOURCE
CREATE TABLE
water_source (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE water_source IS 'Water source refers to the geolocated water bodies that provide drinking water, e.g. Aquifer.';

COMMENT ON COLUMN water_source.id IS 'The unique water source ID. This is the Primary Key.';

COMMENT ON COLUMN water_source.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_source.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_source.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_source.name IS 'The name of the water source.';

COMMENT ON COLUMN water_source.notes IS 'Additional information of the water body.';

COMMENT ON COLUMN water_source.image IS 'Image of the water body.';

-- WATER POLYGON TYPE
CREATE TABLE
water_polygon_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE water_polygon_type IS 'Lookup table of the type of water polygon, e.g. Lake.';

COMMENT ON COLUMN water_polygon_type.id IS 'The unique water polygon ID. Primary Key.';

COMMENT ON COLUMN water_polygon_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_polygon_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_polygon_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_polygon_type.name IS 'The name of the water polygon type.';

COMMENT ON COLUMN water_polygon_type.notes IS 'Additional information of the water polygon type.';

COMMENT ON COLUMN water_polygon_type.image IS 'Image of the water polygon type.';

-- WATER POLYGON
CREATE TABLE
water_polygon (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    estimated_depth_m FLOAT,
-- Estimated depth of water polygon constraint (0m < Estimated Depth < 20m).
    CONSTRAINT depth_check CHECK (
        estimated_depth_m >= 0
        AND estimated_depth_m <= 20
    ),
    geometry GEOMETRY (POLYGON, 4326),
    water_source_uuid UUID NOT NULL REFERENCES water_source (uuid),
    water_polygon_type_uuid UUID NOT NULL REFERENCES water_polygon_type (uuid)
);

COMMENT ON TABLE water_polygon IS 'Water polygon refers to the geolocated land areas that are covered in water, either intermittently or constantly, e.g. River.';

COMMENT ON COLUMN water_polygon.id IS 'The unique water polygon ID. Primary Key.';

COMMENT ON COLUMN water_polygon.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_polygon.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_polygon.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_polygon.name IS 'The name of the water polygon.';

COMMENT ON COLUMN water_polygon.notes IS 'Additional information of the water polygon.';

COMMENT ON COLUMN water_polygon.image IS 'Image of the water polygon.';

COMMENT ON COLUMN water_polygon.estimated_depth_m IS 'The approximate depth of the water polygon measured in meters.';

COMMENT ON COLUMN water_polygon.geometry IS 'The location of the water polygon. Follows EPSG: 4326.';

-- WATER POINT TYPE
CREATE TABLE
water_point_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE water_point_type IS 'Lookup table on the types of water points, e.g. Drinking trough.';

COMMENT ON COLUMN water_point_type.id IS 'The unique water point type ID. Primary Key.';

COMMENT ON COLUMN water_point_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_point_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_point_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_point_type.name IS 'The name of the water point type.';

COMMENT ON COLUMN water_point_type.notes IS 'Additional information of the water point type.';

COMMENT ON COLUMN water_point_type.image IS 'Image of the water point type.';

-- WATER POINT 
CREATE TABLE
water_point (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    geometry GEOMETRY (POINT, 4326),
    water_source_uuid UUID NOT NULL REFERENCES water_source (uuid),
    water_point_type_uuid UUID NOT NULL REFERENCES water_point_type (uuid)
);

COMMENT ON TABLE water_point IS 'Water point refers to the geolocated water site that is available for use, e.g. Tap.';

COMMENT ON COLUMN water_point.id IS 'The unique water point ID. Primary Key.';

COMMENT ON COLUMN water_point.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_point.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_point.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_point.notes IS 'Additional information of the water point.';

COMMENT ON COLUMN water_point.image IS 'Image of the water point.';

COMMENT ON COLUMN water_point.geometry IS 'The coordinates of the water point. Follows EPSG: 4326.';

-- WATER LINE TYPE
CREATE TABLE
water_line_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    sort_order INT UNIQUE,
    pipe_length_m FLOAT,
    pipe_diameter_m FLOAT,
-- Pipe length & pipe diameter constraint (length, diameter > 0)
    CONSTRAINT pipe_length_and_diameter_check CHECK (
        pipe_length_m >= 0
        AND pipe_diameter_m >= 0
    ),
-- Unique together
    UNIQUE (pipe_length_m, pipe_diameter_m)
);

COMMENT ON TABLE water_line_type IS 'Description of the type of line through which water flows, e.g. Water pipe.';

COMMENT ON COLUMN water_line_type.id IS 'The unique water line type ID. Primary Key.';

COMMENT ON COLUMN water_line_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_line_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_line_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_line_type.name IS 'The name of the water line type.';

COMMENT ON COLUMN water_line_type.notes IS 'Additional information of the water line type.';

COMMENT ON COLUMN water_line_type.image IS 'Image of the water line type.';

COMMENT ON COLUMN water_line_type.sort_order IS 'Defines the pattern of how water line types are to be sorted.';

COMMENT ON COLUMN water_line_type.pipe_length_m IS 'The water line length measured in meters.';

COMMENT ON COLUMN water_line_type.pipe_diameter_m IS 'The water line diameter measured in meters.';

-- WATER LINE
CREATE TABLE
water_line (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    estimated_depth_m FLOAT,
-- Estimated depth of water line (depth > 0)
    CONSTRAINT estimated_depth_m CHECK (estimated_depth_m >= 0),
    geometry GEOMETRY (LINESTRING, 4326),
    water_source_uuid UUID NOT NULL REFERENCES water_source (uuid),
    water_line_type_uuid UUID NOT NULL REFERENCES water_line_type (uuid)
);

COMMENT ON TABLE water_line IS 'This is the geolocated path the water lines follow.';

COMMENT ON COLUMN water_line.id IS 'The unique water line ID. Primary Key.';

COMMENT ON COLUMN water_line.uuid IS 'The unique user ID.';

COMMENT ON COLUMN water_line.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN water_line.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN water_line.notes IS 'Additional information of the water line path.';

COMMENT ON COLUMN water_line.image IS 'Image of the water line path.';

COMMENT ON COLUMN water_line.estimated_depth_m IS 'The approximate depth of the water line measured in meters.';

COMMENT ON COLUMN water_line.geometry IS 'The location of the water line. Follows EPSG: 4326';
