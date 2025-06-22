
----------------------------------------WASTE--------------------------------------------

-- WASTE TYPE
CREATE TABLE IF NOT EXISTS waste_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT
);
COMMENT ON TABLE waste_type IS 'Lookup table for bin waste types (e.g. Plastic, Organic, Glass).';
COMMENT ON COLUMN waste_type.id IS 'Primary key for waste type.';
COMMENT ON COLUMN waste_type.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_type.last_update IS 'Timestamp of last update.';
COMMENT ON COLUMN waste_type.last_update_by IS 'User who last updated the row.';
COMMENT ON COLUMN waste_type.name IS 'The waste type name.';
COMMENT ON COLUMN waste_type.type IS 'The waste type category.';
COMMENT ON COLUMN waste_type.notes IS 'Additional information.';


-- WASTE CONDITION
CREATE TABLE IF NOT EXISTS containers_condition (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT
);
COMMENT ON TABLE containers_condition IS 'Lookup table for container physical condition (e.g. Good, Damaged, Leaking).';
COMMENT ON COLUMN containers_condition.id IS 'Primary key.';
COMMENT ON COLUMN containers_condition.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN containers_condition.last_update IS 'Timestamp of last update.';
COMMENT ON COLUMN containers_condition.last_update_by IS 'User who last updated.';
COMMENT ON COLUMN containers_condition.name IS 'Condition name.';
COMMENT ON COLUMN containers_condition.type IS 'Condition category.';
COMMENT ON COLUMN containers_condition.notes IS 'Extra details.';


-- WASTE FILL LEVEL
CREATE TABLE IF NOT EXISTS waste_fill_level (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT
);
COMMENT ON TABLE waste_fill_level IS 'Lookup for fill status (Empty, Half, Full, Overflowing).';
COMMENT ON COLUMN waste_fill_level.id IS 'Primary key.';
COMMENT ON COLUMN waste_fill_level.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_fill_level.last_update IS 'Last updated time.';
COMMENT ON COLUMN waste_fill_level.last_update_by IS 'Who updated it.';
COMMENT ON COLUMN waste_fill_level.name IS 'Level name.';
COMMENT ON COLUMN waste_fill_level.type IS 'Optional level type.';
COMMENT ON COLUMN waste_fill_level.notes IS 'Extra info.';


-- ADDRESS
CREATE TABLE IF NOT EXISTS address (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT,
    street TEXT,
    suburb TEXT,
    city TEXT,
    postal_code TEXT
);
COMMENT ON TABLE address IS 'Location-based info to identify bin placement.';
COMMENT ON COLUMN address.id IS 'Primary key.';
COMMENT ON COLUMN address.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN address.name IS 'Name or unit label (e.g. House 21).';
COMMENT ON COLUMN address.type IS 'Residential, public, etc.';
COMMENT ON COLUMN address.notes IS 'Additional location info.';
COMMENT ON COLUMN address.street IS 'Street number and name.';
COMMENT ON COLUMN address.suburb IS 'Suburb name.';
COMMENT ON COLUMN address.city IS 'City name.';
COMMENT ON COLUMN address.postal_code IS 'Postal code.';


-- WASTE CONTAINER
CREATE TABLE IF NOT EXISTS waste_container (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT,
    geometry GEOMETRY(Point, 4326),
    covered BOOLEAN,
    capacity_liters INT,
    waste_type_uuid UUID NOT NULL REFERENCES waste_type(uuid),
    address_uuid UUID NOT NULL REFERENCES address(uuid),
    waste_log_uuid UUID NOT NULL REFERENCES waste_log(uuid)
);
COMMENT ON TABLE waste_container IS 'Main table for bins or containers in the field.';
COMMENT ON COLUMN waste_container.id IS 'Primary key.';
COMMENT ON COLUMN waste_container.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_container.last_update IS 'Last time record was updated.';
COMMENT ON COLUMN waste_container.last_update_by IS 'User responsible for last update.';
COMMENT ON COLUMN waste_container.name IS 'Container label or ID.';
COMMENT ON COLUMN waste_container.type IS 'Type/category of bin.';
COMMENT ON COLUMN waste_container.notes IS 'Notes or condition details.';
COMMENT ON COLUMN waste_container.geometry IS 'Location of the container (EPSG:4326).';
COMMENT ON COLUMN waste_container.covered IS 'Whether the container is covered.';
COMMENT ON COLUMN waste_container.capacity_liters IS 'Capacity in litres.';
COMMENT ON COLUMN waste_container.waste_type_uuid IS 'FK to waste_type.';
COMMENT ON COLUMN waste_container.address_uuid IS 'FK to address.';
COMMENT ON COLUMN waste_container.waste_log_uuid IS 'FK to waste_log.';


-- WASTE LOG
CREATE TABLE IF NOT EXISTS waste_log (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT,
    type TEXT,
    notes TEXT,
    observation_date DATE,
    observation_time TIME,
    waste_container_uuid UUID NOT NULL REFERENCES waste_container(uuid),
    containers_condition_uuid UUID NOT NULL REFERENCES containers_condition(uuid),
    waste_fill_level_uuid UUID NOT NULL REFERENCES waste_fill_level(uuid)
);
COMMENT ON TABLE waste_log IS 'Event-based log for condition and fill level of bins.';
COMMENT ON COLUMN waste_log.id IS 'Primary key.';
COMMENT ON COLUMN waste_log.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_log.last_update IS 'Timestamp of update.';
COMMENT ON COLUMN waste_log.last_update_by IS 'User who updated.';
COMMENT ON COLUMN waste_log.name IS 'Optional log title.';
COMMENT ON COLUMN waste_log.type IS 'Type/category of log.';
COMMENT ON COLUMN waste_log.notes IS 'Observations or details.';
COMMENT ON COLUMN waste_log.observation_date IS 'Date of log event.';
COMMENT ON COLUMN waste_log.observation_time IS 'Time of log event.';
COMMENT ON COLUMN waste_log.waste_container_uuid IS 'FK to waste_container.';
COMMENT ON COLUMN waste_log.containers_condition_uuid IS 'FK to containers_condition.';
COMMENT ON COLUMN waste_log.waste_fill_level_uuid IS 'FK to waste_fill_level.';
