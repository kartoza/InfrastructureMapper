----------------------------------------WASTE--------------------------------------------

-- CONTAINER TYPE
CREATE TABLE IF NOT EXISTS container_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    type_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE container_type IS 'Lookup table for types of waste containers (e.g. "Glass", "Plastic").';
COMMENT ON COLUMN container_type.id IS 'The unique container type ID. This is the Primary Key.';
COMMENT ON COLUMN container_type.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN container_type.last_update IS 'The date the last update was made (yyyy-mm-dd hh:mm:ss).';
COMMENT ON COLUMN container_type.last_update_by IS 'The name of the user responsible for the latest update.';
COMMENT ON COLUMN container_type.type_name IS 'The descriptive name for the container type. This is unique.';
COMMENT ON COLUMN container_type.description IS 'Additional information about the container type.';


-- CONTAINER CONDITION
CREATE TABLE IF NOT EXISTS container_condition (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    condition_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE container_condition IS 'Physical condition status of a container (e.g. "Good", "Damaged").';
COMMENT ON COLUMN container_condition.id IS 'The unique container condition ID. This is the Primary Key.';
COMMENT ON COLUMN container_condition.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN container_condition.last_update IS 'The date the last update was made (yyyy-mm-dd hh:mm:ss).';
COMMENT ON COLUMN container_condition.last_update_by IS 'The name of the user responsible for the latest update.';
COMMENT ON COLUMN container_condition.condition_name IS 'The name of the container condition. This is unique.';
COMMENT ON COLUMN container_condition.description IS 'Additional information about the container condition.';


-- WASTE LEVEL
CREATE TABLE IF NOT EXISTS waste_level (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    level_name VARCHAR UNIQUE NOT NULL,
    description TEXT
);
COMMENT ON TABLE waste_level IS 'Fill level of the container (e.g. "Empty", "Full").';
COMMENT ON COLUMN waste_level.id IS 'The unique waste level ID. This is the Primary Key.';
COMMENT ON COLUMN waste_level.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_level.last_update IS 'The date the last update was made (yyyy-mm-dd hh:mm:ss).';
COMMENT ON COLUMN waste_level.last_update_by IS 'The name of the user responsible for the latest update.';
COMMENT ON COLUMN waste_level.level_name IS 'The name of the waste level. This is unique.';
COMMENT ON COLUMN waste_level.description IS 'Additional information about the waste level.';


-- WASTE CONTAINER
CREATE TABLE IF NOT EXISTS waste_container (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    covered BOOLEAN,
    capacity_liters INT CHECK (capacity_liters > 0),
    geom GEOMETRY(POINT, 4326),
    type_uuid UUID NOT NULL REFERENCES container_type(uuid)
);
COMMENT ON TABLE waste_container IS 'Waste containers used in the field, linked to container type and location.';
COMMENT ON COLUMN waste_container.id IS 'The unique waste container ID. This is the Primary Key.';
COMMENT ON COLUMN waste_container.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_container.last_update IS 'The date the last update was made (yyyy-mm-dd hh:mm:ss).';
COMMENT ON COLUMN waste_container.last_update_by IS 'The name of the user responsible for the latest update.';
COMMENT ON COLUMN waste_container.covered IS 'True if the container has a cover.';
COMMENT ON COLUMN waste_container.capacity_liters IS 'Capacity of the container in liters.';
COMMENT ON COLUMN waste_container.geom IS 'Location of the waste container. EPSG: 4326 (WGS 84).';
COMMENT ON COLUMN waste_container.type_uuid IS 'Foreign key referencing container type.';



-- WASTE LOG
CREATE TABLE IF NOT EXISTS waste_log (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    log_description TEXT,
    observation_date DATE,
    observation_time TIME,
    container_uuid UUID NOT NULL REFERENCES waste_container(uuid),
    condition_uuid UUID NOT NULL REFERENCES container_condition(uuid),
    level_uuid UUID NOT NULL REFERENCES waste_level(uuid)
);
COMMENT ON TABLE waste_log IS 'Observations made about waste containers including condition and fill level.';
COMMENT ON COLUMN waste_log.id IS 'The unique waste log ID. This is the Primary Key.';
COMMENT ON COLUMN waste_log.uuid IS 'Global Unique Identifier.';
COMMENT ON COLUMN waste_log.last_update IS 'The date the last update was made (yyyy-mm-dd hh:mm:ss).';
COMMENT ON COLUMN waste_log.last_update_by IS 'The name of the user responsible for the latest update.';
COMMENT ON COLUMN waste_log.log_description IS 'Description of the observation or issue.';
COMMENT ON COLUMN waste_log.observation_date IS 'Date of the observation.';
COMMENT ON COLUMN waste_log.observation_time IS 'Time of the observation.';
COMMENT ON COLUMN waste_log.container_uuid IS 'Foreign key referencing the waste container.';
COMMENT ON COLUMN waste_log.condition_uuid IS 'Foreign key referencing the container condition.';
COMMENT ON COLUMN waste_log.level_uuid IS 'Foreign key referencing the waste level.';
-- trigger action
