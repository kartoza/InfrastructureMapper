-- -------------------------------------- FENCES -------------------------------------
-- FENCE TYPE
CREATE TABLE
IF NOT EXISTS fence_type (
    id serial NOT NULL PRIMARY KEY,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    name text UNIQUE NOT NULL,
    notes text,
    image text,
    sort_order int UNIQUE
);

COMMENT ON TABLE fence_type IS 'Look up table for fence types, e.g. electric, chain_link.';

COMMENT ON COLUMN fence_type.id IS 'The unique fence type item id. Primary key.';

COMMENT ON COLUMN fence_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN fence_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN fence_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN fence_type.name IS 'The name of the fence type item.';

COMMENT ON COLUMN fence_type.notes IS 'Additional information of the fence type item.';

COMMENT ON COLUMN fence_type.image IS 'Image of the fence type item.';

-- FENCE LINE
CREATE TABLE
IF NOT EXISTS fence (
    id serial NOT NULL PRIMARY KEY,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    notes text,
    image text,
    height_m float,
    installation_date date NOT NULL,
    is_date_estimated boolean,
    geometry GEOMETRY (LINESTRING, 4326) NOT NULL,
    fence_type_uuid uuid NOT NULL REFERENCES fence_type (uuid)
);

COMMENT ON TABLE fence IS 'The fence item refers to any geolocated line acting as boundary in the area, e.g. fence lines';

COMMENT ON COLUMN fence.id IS 'The unique fence item id. Primary key.';

COMMENT ON COLUMN fence.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN fence.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN fence.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN fence.notes IS 'Additional information of the fence item.';

COMMENT ON COLUMN fence.image IS 'Image of the fence item.';

COMMENT ON COLUMN fence.height_m IS 'Height of the fence in meters';

COMMENT ON COLUMN fence.installation_date IS 'The date the fence was installed.';

COMMENT ON COLUMN fence.is_date_estimated IS 'Is the fence item date of construction estimated?';

COMMENT ON COLUMN fence.geometry IS 'The location of the fence line. Follows EPSG: 4326.';

-- ASSOCIATION TABLE
-- FENCE CONDITIONS
CREATE TABLE
IF NOT EXISTS fence_conditions (
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    notes text,
    image text,
    date date NOT NULL,
    fence_uuid uuid NOT NULL REFERENCES fence (uuid),
    condition_uuid uuid NOT NULL REFERENCES condition (uuid),
-- composite primary key
    PRIMARY KEY (fence_uuid, condition_uuid, date),
-- unique together
    UNIQUE (fence_uuid, condition_uuid, date)
);

COMMENT ON TABLE fence_conditions IS 'An Association table showing the fence conditions, e.g. good, bad.';

COMMENT ON COLUMN fence_conditions.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN fence_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN fence_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN fence_conditions.notes IS 'Additional information of the fence conditions item.';

COMMENT ON COLUMN fence_conditions.image IS 'Image of the fence conditions item.';

COMMENT ON COLUMN fence_conditions.date IS 'The date of the current conditions are marked as changed';
