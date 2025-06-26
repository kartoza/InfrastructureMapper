-- --------------------------------------POLES--------------------------------------------
-- By Charles Mudima
-- POLE MATERIAL
CREATE TABLE
IF NOT EXISTS pole_material (
    id serial NOT NULL PRIMARY KEY,
    name text UNIQUE NOT NULL,
    notes text,
    image text,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE pole_material IS 'Lookup table for the different pole materials available e.g. steel, concrete.';

COMMENT ON COLUMN pole_material.id IS 'The unique pole materials id, this is a primary key.';

COMMENT ON COLUMN pole_material.name IS 'The name of the pole material.';

COMMENT ON COLUMN pole_material.notes IS 'Any additional notes of the name of the pole material.';

COMMENT ON COLUMN pole_material.image IS 'Any visual representation of the material.';

COMMENT ON COLUMN pole_material.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pole_material.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pole_material.uuid IS 'Global unique identifier.';

-- POLE FUNCTION
CREATE TABLE
IF NOT EXISTS pole_function (
    id serial NOT NULL PRIMARY KEY,
    pole_function_name text NOT NULL,
    notes text,
    image text,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid DEFAULT gen_random_uuid()
);

COMMENT ON TABLE pole_function IS 'Lookup table for the different pole functions e.g. telecommunication pole.';

COMMENT ON COLUMN pole_function.id IS 'The unique pole function id, this is a primary key.';

COMMENT ON COLUMN pole_function.pole_function_name IS 'The name of the function of a pole e.g. street lighting pole or telecommunications pole.';

COMMENT ON COLUMN pole_function.notes IS 'Any additional information on the pole functionality.';

COMMENT ON COLUMN pole_function.image IS 'Any visual representation of the pole function.';

COMMENT ON COLUMN pole_function.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pole_function.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pole_function.uuid IS 'Global unique identifier.';

-- POLE
CREATE TABLE
IF NOT EXISTS pole (
    id serial NOT NULL PRIMARY KEY,
    notes varchar(255),
    installation_date date DEFAULT now() NOT NULL,
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    height float NOT NULL,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pole_material_id int NOT NULL,
    pole_function_id int NOT NULL,
    FOREIGN KEY (pole_material_id) REFERENCES pole_material (id),
    FOREIGN KEY (pole_function_id) REFERENCES pole_function (id)
);

COMMENT ON TABLE pole IS 'Pole table records any point entered as a pole e.g. street pole.';

COMMENT ON COLUMN pole.notes IS 'Anything unique or additional information about the pole.';

COMMENT ON COLUMN pole.installation_date IS 'The date and time when the pole was installed.';

COMMENT ON COLUMN pole.height IS 'The height for the pole created.';

COMMENT ON COLUMN pole.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pole.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pole.pole_material_id IS 'Foreign key for pole material.';

COMMENT ON COLUMN pole.pole_function_id IS 'Foreign key for pole function.';

COMMENT ON COLUMN pole.uuid IS 'Global unique identifier.';

-- POLE CONDITIONS
CREATE TABLE
IF NOT EXISTS pole_conditions (
    pole_uuid uuid NOT NULL,
    condition_uuid uuid NOT NULL,
    date date NOT NULL,
    notes text NOT NULL,
    image text,
    last_update timestamp DEFAULT now() NOT NULL,
    last_update_by text NOT NULL,
    uuid uuid DEFAULT gen_random_uuid(),
    PRIMARY KEY (pole_uuid, condition_uuid, date),
    FOREIGN KEY (pole_uuid) REFERENCES pole (uuid),
    FOREIGN KEY (condition_uuid) REFERENCES condition (uuid)
);

COMMENT ON TABLE pole_conditions IS 'The table that records the state of a pole.';

COMMENT ON COLUMN pole_conditions.pole_uuid IS 'A foreign key which is used as composite primary key.';

COMMENT ON COLUMN pole_conditions.condition_uuid IS 'A foreign key which is used as composite primary key.';

COMMENT ON COLUMN pole_conditions.notes IS 'Any additional information on the condition of the pole.';

COMMENT ON COLUMN pole_conditions.date IS 'Stores the date that is used in the composite key.';

COMMENT ON COLUMN pole_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pole_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pole_conditions.uuid IS ' Global unique identifier.';
