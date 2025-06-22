-- --------------------------------------ELECTRICITY-------------------------------------
-- ELECTRICITY LINE TYPE
CREATE TABLE
electricity_line_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    sort_order INT UNIQUE,
    -- Add unique together constraint for voltage and current
    current_a FLOAT NOT NULL,
    voltage_v FLOAT NOT NULL,
    -- Unique together constraint for voltage and current
    UNIQUE (current_a, voltage_v)
);

COMMENT ON TABLE electricity_line_type IS 'Look up table for the types of electricity lines, e.g. Low-voltage line, High-voltage line etc.';

COMMENT ON COLUMN electricity_line_type.id IS 'The unique electricity line type ID. Primary key.';

COMMENT ON COLUMN electricity_line_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN electricity_line_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN electricity_line_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN electricity_line_type.name IS 'The name of the electricity line type.';

COMMENT ON COLUMN electricity_line_type.notes IS 'Additional information of the electricity line type.';

COMMENT ON COLUMN electricity_line_type.image IS 'Image of the electricity line type';

COMMENT ON COLUMN electricity_line_type.sort_order IS 'Defines the pattern of how electricity line type records are to be sorted.';

COMMENT ON COLUMN electricity_line_type.current_a IS 'The electricity line current measured in ampere.';

COMMENT ON COLUMN electricity_line_type.voltage_v IS 'The electricity line voltage measured in volt.';

-- ELECTRICITY LINE
CREATE TABLE
electricity_line (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    geometry GEOMETRY (LINESTRING, 4326) NOT NULL,
    electricity_line_type_uuid UUID NOT NULL REFERENCES electricity_line_type (
        uuid
    )
);

COMMENT ON TABLE electricity_line IS 'Electricity line refers to the geolocated wire or conductor used for transmitting or supplying electricity.';

COMMENT ON COLUMN electricity_line.id IS 'The unique electricity line ID. Primary key.';

COMMENT ON COLUMN electricity_line.uuid IS 'The unique user ID.';

COMMENT ON COLUMN electricity_line.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN electricity_line.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN electricity_line.notes IS 'Additional information of the electricity line.';

COMMENT ON COLUMN electricity_line.image IS 'Image of the electricity line';

COMMENT ON COLUMN electricity_line.geometry IS 'The location of the electricity line. Follows EPSG: 4326.';

-- ELECTRICITY LINE CONDITION
CREATE TABLE
electricity_line_condition_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    sort_order INT UNIQUE
);

COMMENT ON TABLE electricity_line_condition_type IS 'Look up table for the types of electricity line conditions, e.g. Working, Broken etc.';

COMMENT ON COLUMN electricity_line_condition_type.id IS 'The unique electricity line condition ID. Primary key.';

COMMENT ON COLUMN electricity_line_condition_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN electricity_line_condition_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN electricity_line_condition_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN electricity_line_condition_type.name IS 'The name of the electricity line condition.';

COMMENT ON COLUMN electricity_line_condition_type.notes IS 'Additional information of the electricity line condition.';

COMMENT ON COLUMN electricity_line_condition_type.image IS 'Image of the electricity line condition.';

COMMENT ON COLUMN electricity_line_condition_type.sort_order IS 'Defines the pattern of how  electricity line condition records are to be sorted.';

-- ASSOCIATION TABLES
-- ELECTRICITY LINE CONDITION
CREATE TABLE
electricity_line_conditions (
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    date DATE NOT NULL,
    electricity_line_uuid UUID NOT NULL REFERENCES electricity_line (uuid),
    electricity_line_condition_uuid UUID NOT NULL REFERENCES electricity_line_condition_type (
        uuid
    ),
    -- Composite primary key
    PRIMARY KEY (
        electricity_line_uuid,
        electricity_line_condition_uuid,
        date
    ),
    -- Unique together
    UNIQUE (
        electricity_line_uuid,
        electricity_line_condition_uuid,
        date
    )
);

COMMENT ON TABLE electricity_line_conditions IS 'Associative table which stores the electricity line and its condition on a particular day.';

COMMENT ON COLUMN electricity_line_conditions.uuid IS 'The unique user ID.';

COMMENT ON COLUMN electricity_line_conditions.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN electricity_line_conditions.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN electricity_line_conditions.notes IS 'Additional information of the electricity line and condition.';

COMMENT ON COLUMN electricity_line_conditions.image IS 'Image of the electricity line and condition.';

COMMENT ON COLUMN electricity_line_conditions.date IS 'The electricity line inspection date.';
