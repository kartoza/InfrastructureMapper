-- --------------------------------------LANDUSE AREA
-- -------------------------------------
-- LANDUSE AREA TYPE
CREATE TABLE
IF NOT EXISTS landuse_area_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE landuse_area_type IS 'Lookup table for the landuse area type. Eg: Agriculture, residential, recreation, commercial, transportation etc';

COMMENT ON COLUMN landuse_area_type.id IS 'The unique landuse area type ID. This is the Primary Key.';

COMMENT ON COLUMN landuse_area_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area_type.name IS 'The landuse area type field name. This is unique.';

COMMENT ON COLUMN landuse_area_type.notes IS 'Additional information of the landuse area type.';

COMMENT ON COLUMN landuse_area_type.image IS 'Image of the landuse area type.';

-- LANDUSE AREA OWNERSHIP TYPE
CREATE TABLE
IF NOT EXISTS landuse_area_ownership_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE landuse_area_ownership_type IS 'Lookup table for the landuse area ownership type. Eg: Public or private ';

COMMENT ON COLUMN landuse_area_ownership_type.id IS 'The unique landuse area ownership type ID. This is the Primary Key.';

COMMENT ON COLUMN landuse_area_ownership_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area_ownership_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area_ownership_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area_ownership_type.name IS 'The landuse area ownership type field name. This is unique.';

COMMENT ON COLUMN landuse_area_ownership_type.notes IS 'Additional information of the landuse area ownership type.';

COMMENT ON COLUMN landuse_area_ownership_type.image IS 'Image of the landuse area ownership type.';

-- LANDUSE AREA OWNER
CREATE TABLE
IF NOT EXISTS landuse_area_owner (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE,
    notes TEXT,
    image TEXT,
    address TEXT,
    landuse_area_ownership_type_uuid UUID NOT NULL REFERENCES landuse_area_ownership_type (
        uuid
    )
);

COMMENT ON TABLE landuse_area_owner IS 'Lookup table for the landuse area owner. ';

COMMENT ON COLUMN landuse_area_owner.id IS 'The unique landuse area owner ID. This is the Primary Key.';

COMMENT ON COLUMN landuse_area_owner.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area_owner.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area_owner.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area_owner.name IS 'The landuse area ownership field name. This is unique.';

COMMENT ON COLUMN landuse_area_owner.notes IS 'Additional information of the landuse area owner.';

COMMENT ON COLUMN landuse_area_owner.image IS 'Image of the landuse area owner.';

COMMENT ON COLUMN landuse_area_owner.address IS 'Address of the owner of the landuse area.';

COMMENT ON COLUMN landuse_area_owner.landuse_area_ownership_type_uuid IS 'The foreign key which references the uuid from the landuse area ownership type table.';

-- LANDUSE AREA
CREATE TABLE
IF NOT EXISTS landuse_area (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE,
    notes TEXT,
    image TEXT,
    geometry GEOMETRY (POLYGON, 4326),
    landuse_area_type_uuid UUID NOT NULL REFERENCES landuse_area_type (uuid),
    landuse_area_owner_uuid UUID NOT NULL REFERENCES landuse_area_owner (uuid)
);

COMMENT ON TABLE landuse_area IS 'Lookup table for the landuse area.';

COMMENT ON COLUMN landuse_area.id IS 'The unique landuse area ID. This is the Primary Key.';

COMMENT ON COLUMN landuse_area.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area.name IS 'The landuse area name. This is unique.';

COMMENT ON COLUMN landuse_area.notes IS 'Additional information of the landuse area.';

COMMENT ON COLUMN landuse_area.image IS 'Image of the landuse area.';

COMMENT ON COLUMN landuse_area.geometry IS 'The geometry of landuse (in this case a polygon) and the projection system used.';

COMMENT ON COLUMN landuse_area.landuse_area_type_uuid IS 'The foreign key which references the uuid from the landuse area type table.';

COMMENT ON COLUMN landuse_area.landuse_area_owner_uuid IS 'The foreign key which references the uuid from the landuse area owner table.';

-- LANDUSE AREA CONDITION TYPE
CREATE TABLE
IF NOT EXISTS landuse_area_condition_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE NOT NULL, --lookup names must be unique
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE landuse_area_condition_type IS 'Lookup table for the landuse area condition type. e.g. Bare, Occupied, Work in Progress';

COMMENT ON COLUMN landuse_area_condition_type.id IS 'The unique landuse area condition type ID. This is the Primary Key.';

COMMENT ON COLUMN landuse_area_condition_type.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area_condition_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area_condition_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area_condition_type.name IS 'The landuse area condition type field name.';

COMMENT ON COLUMN landuse_area_condition_type.notes IS 'Additional information of the landuse area condition type.';

COMMENT ON COLUMN landuse_area_condition_type.image IS 'Image of the landuse area condition type.';

-- ASSOCIATION TABLE
-- LANDUSE AREA CONDITIONS
CREATE TABLE
IF NOT EXISTS landuse_area_conditions (
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name VARCHAR UNIQUE,
    notes TEXT,
    image TEXT,
    date DATE NOT NULL,
    landuse_area_condition_type_uuid UUID NOT NULL REFERENCES landuse_area_condition_type (
        uuid
    ),
    landuse_area_uuid UUID NOT NULL REFERENCES landuse_area (uuid),
    -- Composite primary key
    PRIMARY KEY (
        landuse_area_condition_type_uuid,
        landuse_area_uuid,
        date
    ),
    -- Unique together
    UNIQUE (
        landuse_area_condition_type_uuid,
        landuse_area_uuid,
        date
    )
);

COMMENT ON TABLE landuse_area_conditions IS 'Associative table to store the landuse area of different landuse area condition type.';

COMMENT ON COLUMN landuse_area_conditions.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN landuse_area_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN landuse_area_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN landuse_area_conditions.name IS 'The landuse area conditions name which is unique.';

COMMENT ON COLUMN landuse_area_conditions.notes IS 'Additional information of the landuse area conditions.';

COMMENT ON COLUMN landuse_area_conditions.image IS 'Image of the landuse area conditions.';

COMMENT ON COLUMN landuse_area_conditions.date IS 'The datetime alteration of the conditions. This is the Primary and Composite Key';

COMMENT ON COLUMN landuse_area_conditions.landuse_area_uuid IS 'The foreign key linking to the landuse area table''s UUID.';

COMMENT ON COLUMN landuse_area_conditions.landuse_area_condition_type_uuid IS 'The foreign key linking to the landuse area condition type table''s UUID.';
