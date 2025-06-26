-- --------------------------------------GATES--------------------------------------------
-- added by Jeremy Ferris
-- GATE TYPE
CREATE TABLE
IF NOT EXISTS gate_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE gate_type IS 'Describes the type of gate.';

COMMENT ON COLUMN gate_type.id IS 'The unique management log ID. Primary Key.';

COMMENT ON COLUMN gate_type.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate_type.name IS 'The type of gate.';

COMMENT ON COLUMN gate_type.notes IS 'Additional information about the gate type.';

COMMENT ON COLUMN gate_type.image IS 'Path to the image file of a picture representing the gate type.';

-- GATE FUNCTION
CREATE TABLE
IF NOT EXISTS gate_function (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE gate_function IS 'This table lists the functions that a gate can perform.';

COMMENT ON COLUMN gate_function.id IS 'The unique management log ID. Primary Key.';

COMMENT ON COLUMN gate_function.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate_function.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate_function.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate_function.name IS 'Name of the gate function.';

COMMENT ON COLUMN gate_function.notes IS 'Additional information about the gate function.';

COMMENT ON COLUMN gate_function.image IS 'Path to the image file of a picture representing the gate function.';

-- GATE MATERIAL
CREATE TABLE
IF NOT EXISTS gate_material (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE gate_material IS 'This table lists the materials that a gate can consist of.';

COMMENT ON COLUMN gate_material.id IS 'The unique management log ID. Primary Key.';

COMMENT ON COLUMN gate_material.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate_material.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate_material.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate_material.name IS 'Name of the gate material.';

COMMENT ON COLUMN gate_material.notes IS 'Additional information about the gate material.';

COMMENT ON COLUMN gate_material.image IS 'Path to the image file of a picture representing the gate material.';

-- GATE
CREATE TABLE
IF NOT EXISTS gate (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    notes TEXT,
    pic TEXT,
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    height_m FLOAT,
    width_m FLOAT,
    installation_date DATE NOT NULL,
    is_date_estimated BOOLEAN,
    gate_direction_from_hinge_when_closed FLOAT NOT NULL,
    gate_open_maximum_degrees FLOAT,
    gate_open_minimum_degrees FLOAT,
    gate_type_uuid UUID REFERENCES gate_type (uuid),
    gate_function_uuid UUID REFERENCES gate_function (uuid)
);

COMMENT ON TABLE gate IS 'Items in the gate table can stand alone or be referenced from other entities like buildings and fences.';

COMMENT ON COLUMN gate.id IS 'The unique management log ID. Primary Key.';

COMMENT ON COLUMN gate.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate.name IS 'The name of the gate.';

COMMENT ON COLUMN gate.notes IS 'Additional notes about the gate.';

COMMENT ON COLUMN gate.pic IS 'Path to the image file of the gate.';

COMMENT ON COLUMN gate.geometry IS 'This is the point where the gate is mounted (i.e. the hinge side).';

COMMENT ON COLUMN gate.height_m IS 'Enter the height of the gate in meters.';

COMMENT ON COLUMN gate.width_m IS 'Enter the width of the gate in meters.';

COMMENT ON COLUMN gate.installation_date IS 'Enter the date the gate was installed. This can be an approximate date.';

COMMENT ON COLUMN gate.is_date_estimated IS 'Was the gate installation date estimated?';

COMMENT ON COLUMN gate.gate_direction_from_hinge_when_closed IS 'What direction does the gate go from the hinge? North = 0, East = 90, South = 180, West = 270, Maximum 360 (back to North).';

COMMENT ON COLUMN gate.gate_open_maximum_degrees IS 'Positive clockwise degrees the gate will open (zero if the gate only opens counterclockwise).';

COMMENT ON COLUMN gate.gate_open_minimum_degrees IS 'Negative counter-clockwise degrees that the gate opens (zero if the gate only opens clockwise).';

COMMENT ON COLUMN gate.gate_type_uuid IS 'The foreign key which references the uuid from the gate_type table.';

COMMENT ON COLUMN gate.gate_function_uuid IS 'The foreign key which references the uuid from the gate_function table.';

-- GATE MATERIALS
CREATE TABLE
IF NOT EXISTS gate_materials (
    PRIMARY KEY (gate_uuid, gate_material_uuid),
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    gate_uuid UUID NOT NULL REFERENCES gate (uuid),
    gate_material_uuid UUID NOT NULL REFERENCES gate_material (uuid)
);

COMMENT ON TABLE gate_materials IS 'A gate can be comprised of various and multiple materials that are selected from the material list.';

COMMENT ON COLUMN gate_materials.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate_materials.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate_materials.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate_materials.name IS 'Name of the gate material.';

COMMENT ON COLUMN gate_materials.notes IS 'Additional information about the gate material.';

COMMENT ON COLUMN gate_materials.image IS 'Path to the image file of a picture representing the gate material.';

COMMENT ON COLUMN gate_materials.gate_uuid IS 'The foreign key which references the uuid from the gate table.';

COMMENT ON COLUMN gate_materials.gate_material_uuid IS 'The foreign key which references the uuid from the gate_material table.';

-- BUILDING GATES
CREATE TABLE
IF NOT EXISTS building_gates (
    PRIMARY KEY (building_uuid, gate_uuid),
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    building_uuid UUID NOT NULL REFERENCES building (uuid),
    gate_uuid UUID NOT NULL REFERENCES gate (uuid)
);

COMMENT ON TABLE building_gates IS 'Gates that are attached to buildings.';

COMMENT ON COLUMN building_gates.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN building_gates.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN building_gates.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN building_gates.name IS 'Name of the gate.';

COMMENT ON COLUMN building_gates.notes IS 'Additional information about the gate.';

COMMENT ON COLUMN building_gates.image IS 'Path to the image file of a picture representing the gate.';

COMMENT ON COLUMN building_gates.building_uuid IS 'The foreign key which references the uuid from the building table.';

COMMENT ON COLUMN building_gates.gate_uuid IS 'The foreign key which references the uuid from the gate table.';

-- FENCE GATES
CREATE TABLE
IF NOT EXISTS fence_gates (
    PRIMARY KEY (fence_uuid, gate_uuid),
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    fence_uuid UUID NOT NULL REFERENCES fence (uuid),
    gate_uuid UUID NOT NULL REFERENCES gate (uuid)
);

COMMENT ON TABLE fence_gates IS 'Gates that are attached to fences.';

COMMENT ON COLUMN fence_gates.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN fence_gates.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN fence_gates.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN fence_gates.name IS 'Name of the gate.';

COMMENT ON COLUMN fence_gates.notes IS 'Additional information about the gate.';

COMMENT ON COLUMN fence_gates.image IS 'Path to the image file of a picture representing the gate.';

COMMENT ON COLUMN fence_gates.fence_uuid IS 'The foreign key which references the uuid from the fence table.';

COMMENT ON COLUMN fence_gates.gate_uuid IS 'The foreign key which references the uuid from the gate table.';

-- GATE CONDITIONS
CREATE TABLE
IF NOT EXISTS gate_conditions (
    PRIMARY KEY (gate_uuid, condition_uuid, date),
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT,
    name TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    date DATE NOT NULL,
    gate_uuid UUID NOT NULL REFERENCES gate (uuid),
    condition_uuid UUID NOT NULL REFERENCES condition (uuid)
);

COMMENT ON TABLE gate_conditions IS 'The gate_conditions table is an association table to record the conditions of gates at certain times.';

COMMENT ON COLUMN gate_conditions.uuid IS 'Universal Unique Identifier.';

COMMENT ON COLUMN gate_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN gate_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN gate_conditions.name IS 'Name of the gate condition.';

COMMENT ON COLUMN gate_conditions.notes IS 'Additional information about the gate condition.';

COMMENT ON COLUMN gate_conditions.image IS 'Path to the image file of a picture representing the gate condition.';

COMMENT ON COLUMN gate_conditions.date IS 'The date that the condition was observed.';

COMMENT ON COLUMN gate_conditions.gate_uuid IS 'The foreign key which references the uuid from the gate table.';

COMMENT ON COLUMN gate_conditions.condition_uuid IS 'The foreign key which references the uuid from the condition table.';
