-- POINT OF INTEREST TYPE
CREATE TABLE
IF NOT EXISTS point_of_interest_type (
    id serial NOT NULL PRIMARY KEY,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    name text UNIQUE NOT NULL,
    notes text,
    image text,
    sort_order int UNIQUE
);

COMMENT ON TABLE point_of_interest_type IS 'Look up tables for point of interest types, e.g. types of gates';

COMMENT ON COLUMN point_of_interest_type.id IS 'The unique point of interest type item id. Primary key.';

COMMENT ON COLUMN point_of_interest_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN point_of_interest_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN point_of_interest_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN point_of_interest_type.name IS 'The name of the point of interest type.';

COMMENT ON COLUMN point_of_interest_type.notes IS 'Additional information of the point of interest type.';

COMMENT ON COLUMN point_of_interest_type.image IS 'Image of the point of interest type.';

COMMENT ON COLUMN point_of_interest_type.sort_order IS 'The pattern of how point of interest types are to be sorted.';

-- POINT OF INTEREST
CREATE TABLE
IF NOT EXISTS point_of_interest (
    id serial NOT NULL PRIMARY KEY,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    name text,
    notes text,
    image text,
    height_m float,
    installation_date date,
    is_date_estimated boolean,
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    point_of_interest_type_uuid uuid NOT NULL REFERENCES point_of_interest_type (
        uuid
    )
);

COMMENT ON TABLE point_of_interest IS 'The point of interest item refers to any geolocated point features found in the area, e.g. gate, ruin.';

COMMENT ON COLUMN point_of_interest.id IS 'The unique point of interest item id. Primary key.';

COMMENT ON COLUMN point_of_interest.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN point_of_interest.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN point_of_interest.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN point_of_interest.name IS 'The name of the point of interest item.';

COMMENT ON COLUMN point_of_interest.notes IS 'Additional information of the point of interest item.';

COMMENT ON COLUMN point_of_interest.image IS 'Image of the point of interest item.';

COMMENT ON COLUMN point_of_interest.height_m IS 'The height in meters of the point of interest.';

COMMENT ON COLUMN point_of_interest.installation_date IS 'The date the point of interest feature was installed/constructed.';

COMMENT ON COLUMN point_of_interest.is_date_estimated IS 'Is the point of interest date of construction estimated?';

COMMENT ON COLUMN point_of_interest.geometry IS 'The centroid location of the point of interest item. Follows EPSG: 4326.';

-- ASSOCIATION TABLE
-- POINT OF INTEREST CONDITIONS
CREATE TABLE
IF NOT EXISTS point_of_interest_conditions (
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    notes text,
    image text,
    date date NOT NULL,
    point_of_interest_uuid uuid NOT NULL REFERENCES point_of_interest (uuid),
    condition_uuid uuid NOT NULL REFERENCES condition (uuid),
    -- composite primary key
    PRIMARY KEY (point_of_interest_uuid, condition_uuid, date),
    -- unique together
    UNIQUE (point_of_interest_uuid, condition_uuid, date)
);

COMMENT ON TABLE point_of_interest_conditions IS 'An Association table for point of interest conditions, e.g. good, bad.';

COMMENT ON COLUMN point_of_interest_conditions.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN point_of_interest_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN point_of_interest_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN point_of_interest_conditions.notes IS 'Additional information of the point of interest conditions item.';

COMMENT ON COLUMN point_of_interest_conditions.image IS 'Image of the point of interest conditions item.';

COMMENT ON COLUMN point_of_interest_conditions.date IS 'The points of interest inspection date.';
