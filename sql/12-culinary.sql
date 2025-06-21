-- --------------------------------------CULINARY
-- FACILITIES-------------------------------------
-- By: Hefni R. R. A.
-- CULINARY CATEGORY
CREATE TABLE culinary_category (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT
);

COMMENT ON TABLE culinary_category IS 'Lookup table for culinary categories, e.g. traditional, fast food.';

COMMENT ON COLUMN culinary_category.id IS 'The unique ID for the culinary category. This is the Primary Key.';

COMMENT ON COLUMN culinary_category.uuid IS 'The unique UUID.';

COMMENT ON COLUMN culinary_category.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN culinary_category.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN culinary_category.name IS 'The name of the culinary category.';

COMMENT ON COLUMN culinary_category.notes IS 'Additional information about the culinary category.';


-- CULINARY FACILITY
CREATE TABLE culinary_facility (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    notes TEXT,
    rating_value DECIMAL(2, 1) CHECK (rating_value BETWEEN 0 AND 5),
    min_price DECIMAL(10, 2) NOT NULL,
    max_price DECIMAL(10, 2) NOT NULL,
    geometry GEOMETRY (POINT, 4326),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    culinary_category_uuid UUID NOT NULL REFERENCES culinary_category (uuid)
);

COMMENT ON TABLE culinary_facility IS 'Stores information about culinary facilities, including name, rating, price range, and geographical location.';

COMMENT ON COLUMN culinary_facility.id IS 'The unique ID for the culinary facility. This is the Primary Key.';

COMMENT ON COLUMN culinary_facility.name IS 'The name of the culinary facility.';

COMMENT ON COLUMN culinary_facility.description IS 'A description of the culinary facility.';

COMMENT ON COLUMN culinary_facility.notes IS 'Additional notes about the culinary facility.';

COMMENT ON COLUMN culinary_facility.rating_value IS 'The rating value of the culinary facility, ranging from 0 to 5.';

COMMENT ON COLUMN culinary_facility.min_price IS 'The minimum price of offerings at the facility.';

COMMENT ON COLUMN culinary_facility.max_price IS 'The maximum price of offerings at the facility.';

COMMENT ON COLUMN culinary_facility.geometry IS 'Geographical location of the facility, stored as a Point (longitude and latitude).';

COMMENT ON COLUMN culinary_facility.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN culinary_facility.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN culinary_facility.uuid IS 'A globally unique identifier for the culinary facility.';

COMMENT ON COLUMN culinary_facility.culinary_category_uuid IS 'The UUID of the culinary category, referencing the culinary_category table.';


-- FACILITY TYPE
CREATE TABLE facility_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE facility_type IS 'Lookup table for types of facilities associated with culinary spots.';

COMMENT ON COLUMN facility_type.id IS 'The unique ID for the facility type. This is the Primary Key.';

COMMENT ON COLUMN facility_type.name IS 'The name of the facility type.';

COMMENT ON COLUMN facility_type.description IS 'A description of the facility type.';

COMMENT ON COLUMN facility_type.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN facility_type.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN facility_type.uuid IS 'A globally unique identifier for the facility type.';


-- ASSOCIATION TABLE
-- CULINARY FACILITY TYPES
CREATE TABLE culinary_facility_types (
    culinary_facility_uuid UUID NOT NULL REFERENCES culinary_facility (uuid),
    facility_type_uuid UUID NOT NULL REFERENCES facility_type (uuid),
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    PRIMARY KEY (culinary_facility_uuid, facility_type_uuid)
);

COMMENT ON TABLE culinary_facility_types IS 'Association table linking culinary facilities and their associated facility types.';

COMMENT ON COLUMN culinary_facility_types.culinary_facility_uuid IS 'Foreign key referencing the UUID of the culinary facility.';

COMMENT ON COLUMN culinary_facility_types.facility_type_uuid IS 'Foreign key referencing the UUID of the facility type.';

COMMENT ON COLUMN culinary_facility_types.notes IS 'Additional information or remarks about the association.';

COMMENT ON COLUMN culinary_facility_types.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN culinary_facility_types.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN culinary_facility_types.uuid IS 'A globally unique identifier for the association record.';
