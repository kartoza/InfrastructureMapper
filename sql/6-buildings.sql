-- -------------------------------------- LAND USE BUILDINGS
-- -------------------------------------
-- BUILDING TYPE --
CREATE TABLE
IF NOT EXISTS building_type (
-- We said this should be serial, not int. Also 'id', not 'building_type_id'
    id serial PRIMARY KEY,
-- this was named 'name' in the erd, not 'type_name'. Must be unique
    name varchar UNIQUE NOT NULL,
    notes text,
    image text,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE building_type IS 'Look up table for the types of buildings available, e.g barns, cottages, etc.';

COMMENT ON COLUMN building_type.id IS 'The unique building type ID. This is the Primary Key.';

COMMENT ON COLUMN building_type.name IS 'The name is unique to the buildings table.';

COMMENT ON COLUMN building_type.notes IS 'Where we make comments and a description about the building_type.';

COMMENT ON COLUMN building_type.image IS 'The image link associated with the building type.';

COMMENT ON COLUMN building_type.last_update IS 'The timestamp shown for when the building type table has been updated.';

COMMENT ON COLUMN building_type.last_update_by IS 'The name of the person who updated the table last.';

COMMENT ON COLUMN building_type.uuid IS 'Global Unique Identifier.';

-- BUILDINGS --
CREATE TABLE
IF NOT EXISTS building (
    id serial PRIMARY KEY,
    name varchar NOT NULL,
    notes text NOT NULL,
    address text NOT NULL,
    image text,
    geometry GEOMETRY (POLYGON, 4326),
    area_square_meter float NOT NULL,
    height_meter float NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    building_type_uuid uuid NOT NULL REFERENCES building_type (uuid)
);

COMMENT ON TABLE building IS 'Look up table for the types of buildings available, e.g residential';

COMMENT ON COLUMN building.id IS 'The unique building type ID. This is the Primary Key.';

COMMENT ON COLUMN building.name IS 'The name is unique for the building table.';

COMMENT ON COLUMN building.notes IS 'Where we make comments and a description about the building_type.';

COMMENT ON COLUMN building.address IS 'The address of the building to locate it in space.';

COMMENT ON COLUMN building.image IS 'The image link associated with the building_type.';

COMMENT ON COLUMN building.geometry IS 'The geometry of building (point, line or polygon) and the projection system used.';

COMMENT ON COLUMN building.area_square_meter IS 'The area covered by the building on the ground in m^2.';

COMMENT ON COLUMN building.height_meter IS 'The height of building which can be influenced by the shadow it casts over the nearby area depending on the position of the sun.';

COMMENT ON COLUMN building.last_update IS 'The timestamp shown for when the table has been updated.';

COMMENT ON COLUMN building.last_update_by IS 'The name of the person who upated the table last.';

COMMENT ON COLUMN building.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN building.building_type_uuid IS 'The foreign key which references the uuid from the building type table.';

-- BUILDING MATERIAL--
CREATE TABLE
IF NOT EXISTS building_material (
    id serial PRIMARY KEY,
    name varchar UNIQUE NOT NULL, --look up table names must be unique
    notes text,
    image text,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE building_material IS 'Look up table for the types of building materials e.g. wood, concrete, aluminuim sheets etc.';

COMMENT ON COLUMN building_material.id IS 'The unique building material type ID. This is the Primary Key.';

COMMENT ON COLUMN building_material.name IS 'The name is unique to the buildings table since it is a look up table.';

COMMENT ON COLUMN building_material.notes IS 'Where we make comments and a description about the building material.';

COMMENT ON COLUMN building_material.image IS 'The image link associated with the building material.';

COMMENT ON COLUMN building_material.last_update IS 'The timestamp shown for when the building material table has been updated.';

COMMENT ON COLUMN building_material.last_update_by IS 'The name of the person who upated the table last.';

COMMENT ON COLUMN building_material.uuid IS 'Globally Unique Identifier.';

-- BUILDING MATERIALS --
CREATE TABLE
IF NOT EXISTS building_materials ( -- association table
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    notes text,
    image text,
    date date NOT NULL,
    building_uuid uuid NOT NULL REFERENCES building (uuid),
    building_material_uuid uuid NOT NULL REFERENCES building_material (uuid),
    PRIMARY KEY (building_uuid, building_material_uuid, date), --composite keys
    UNIQUE (building_uuid, building_material_uuid, date)
);

COMMENT ON TABLE building_materials IS 'An association table between building and building material.';

COMMENT ON COLUMN building_materials.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN building_materials.last_update IS 'The timestamp shown for when the table has been updated.';

COMMENT ON COLUMN building_materials.last_update_by IS 'The name of the person who upated the table last.';

COMMENT ON COLUMN building_materials.notes IS 'Where we make comments and a description about the building materials.';

COMMENT ON COLUMN building_materials.image IS 'The image link associated with the building materials.';

COMMENT ON COLUMN building_materials.date IS 'The datetime alteration of the conditions. This is the Primary and Composite Key';

COMMENT ON COLUMN building_materials.building_uuid IS 'The composite key referenced from the building table.';

COMMENT ON COLUMN building_materials.building_material_uuid IS 'The composite key referenced from the building material table.';

-- BUILDING CONDITIONS --
CREATE TABLE
IF NOT EXISTS building_conditions ( -- association table
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    notes text,
    image text,
    date date NOT NULL,
    building_uuid uuid NOT NULL REFERENCES building (uuid),
    condition_uuid uuid NOT NULL REFERENCES condition (uuid),
    PRIMARY KEY (building_uuid, condition_uuid, date), --composite keys
    UNIQUE (building_uuid, condition_uuid, date)
);

COMMENT ON TABLE building_conditions IS 'An association table between building and building conditions type.';

COMMENT ON COLUMN building_conditions.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN building_conditions.last_update IS 'The timestamp shown for when the table has been updated.';

COMMENT ON COLUMN building_conditions.last_update_by IS 'The name of the person who upated the table last.';

COMMENT ON COLUMN building_conditions.notes IS 'Where we make comments and a description about the building conditions.';

COMMENT ON COLUMN building_conditions.image IS 'The image link associated with the building conditions.';

COMMENT ON COLUMN building_conditions.date IS 'The datetime alteration of the conditions. This is the Primary and Composite Key';

COMMENT ON COLUMN building_conditions.building_uuid IS 'The composite key referenced from the building table.';

COMMENT ON COLUMN building_conditions.condition_uuid IS 'The composite key referenced from the building table.';
