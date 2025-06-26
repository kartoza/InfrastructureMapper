-- --------------------------------------INFRASTRUCTURE-------------------------------------
-- INFRASTRUCTURE TYPE
CREATE TABLE
infrastructure_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE infrastructure_type IS 'Lookup table for the types of infrastructure available, e.g. Furniture .';

COMMENT ON COLUMN infrastructure_type.id IS 'The unique infrastructure type ID. This is the Primary Key.';

COMMENT ON COLUMN infrastructure_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN infrastructure_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN infrastructure_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN infrastructure_type.name IS 'The infrastructure type name.';

COMMENT ON COLUMN infrastructure_type.notes IS 'Additional information of the infrastructure type.';

COMMENT ON COLUMN infrastructure_type.image IS 'Image of the infrastructure type.';

-- INFRASTRUCTURE ITEM
CREATE TABLE
infrastructure_item (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    geometry GEOMETRY (POINT, 4326),
    infrastructure_type_uuid UUID NOT NULL REFERENCES infrastructure_type (uuid)
);

COMMENT ON TABLE infrastructure_item IS 'Infrastructure item refers to any physical components found in the area, e.g. desk, chair.';

COMMENT ON COLUMN infrastructure_item.id IS 'The unique infrastructure item ID. Primary Key.';

COMMENT ON COLUMN infrastructure_item.uuid IS 'The unique user ID.';

COMMENT ON COLUMN infrastructure_item.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN infrastructure_item.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN infrastructure_item.name IS 'The name of the infrastructure item.';

COMMENT ON COLUMN infrastructure_item.notes IS 'Additional information of the infrastructure item.';

COMMENT ON COLUMN infrastructure_item.image IS 'Image of the infrastructure item.';

COMMENT ON COLUMN infrastructure_item.geometry IS 'The centroid location of the infrastructure item. Follows EPSG: 4326.';

-- INFRASTRUCTURE LOG ACTION
CREATE TABLE
infrastructure_log_action (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE infrastructure_log_action IS 'Infrastructure log action refers to the actions taken to maintain infrastructure items, e.g. Screwing, Painting, Welding.';

COMMENT ON COLUMN infrastructure_log_action.id IS 'The unique log action ID. Primary Key.';

COMMENT ON COLUMN infrastructure_log_action.uuid IS 'The unique user ID.';

COMMENT ON COLUMN infrastructure_log_action.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN infrastructure_log_action.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN infrastructure_log_action.name IS 'The name of the action taken.';

COMMENT ON COLUMN infrastructure_log_action.notes IS 'Additional information of the action taken.';

COMMENT ON COLUMN infrastructure_log_action.image IS 'Image of the action taken.';

-- INFRASTRUCTURE MANAGEMENT LOG 
CREATE TABLE
infrastructure_management_log (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    condition TEXT NOT NULL,
    infrastructure_item_uuid UUID NOT NULL REFERENCES infrastructure_item (
        uuid
    ),
    infrastructure_log_action_uuid UUID NOT NULL REFERENCES infrastructure_log_action (
        uuid
    )
);

COMMENT ON TABLE infrastructure_management_log IS 'Infrastructure management log refers to the process of task that needs to be done on an infrastructure item, e.g. Repair.';

COMMENT ON COLUMN infrastructure_management_log.id IS 'The unique management log ID. Primary Key.';

COMMENT ON COLUMN infrastructure_management_log.uuid IS 'The unique user ID.';

COMMENT ON COLUMN infrastructure_management_log.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN infrastructure_management_log.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN infrastructure_management_log.name IS 'The name of the process.';

COMMENT ON COLUMN infrastructure_management_log.notes IS 'Additional information of the process.';

COMMENT ON COLUMN infrastructure_management_log.image IS 'Image of the work flow.';

COMMENT ON COLUMN infrastructure_management_log.condition IS 'Circumstances or factors affecting the infrastructure item type.';
