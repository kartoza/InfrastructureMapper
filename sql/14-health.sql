-- -------------------------------------- HEALTHCARE FACILITIES --------------------------------------
-- By: Nikita Harripersadh
-- ---------------------------- HEALTHCARE FACILITIES ----------------------------

-- healthcare Facility Type Lookup Table
CREATE TABLE healthcare_facility_type (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE healthcare_facility_type IS 'Lookup table for the type of healthcare facilities (e.g., hospital, clinic, etc.).';

COMMENT ON COLUMN healthcare_facility_type.id IS 'The unique ID for the healthcare facility type. This is the Primary Key.';

COMMENT ON COLUMN healthcare_facility_type.name IS 'The name of the healthcare facility type (e.g., hospital, clinic).';

COMMENT ON COLUMN healthcare_facility_type.description IS 'A description of the healthcare facility type.';

COMMENT ON COLUMN healthcare_facility_type.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN healthcare_facility_type.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN healthcare_facility_type.uuid IS 'A globally unique identifier for the healthcare facility type.';


-- Building Condition Lookup Table
CREATE TABLE building_condition (
    id SERIAL PRIMARY KEY,
    condition_type TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE building_condition IS 'Lookup table for different conditions of the healthcare facility buildings.';

COMMENT ON COLUMN building_condition.id IS 'The unique ID for the building condition. This is the Primary Key.';

COMMENT ON COLUMN building_condition.condition_type IS 'Type of building condition (e.g., Good, Needs Repair).';

COMMENT ON COLUMN building_condition.notes IS 'Additional notes about the building condition.';

COMMENT ON COLUMN building_condition.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN building_condition.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN building_condition.uuid IS 'A globally unique identifier for the building condition record.';


-- Ownership Type Lookup Table
CREATE TABLE ownership_type (
    id SERIAL PRIMARY KEY,
    ownership_type TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE ownership_type IS 'Lookup table for ownership types of healthcare facilities (e.g., Public, Private).';

COMMENT ON COLUMN ownership_type.id IS 'The unique ID for the ownership type. This is the Primary Key.';

COMMENT ON COLUMN ownership_type.ownership_type IS 'The type of ownership (e.g., Public, Private).';

COMMENT ON COLUMN ownership_type.notes IS 'Additional notes about the ownership type.';

COMMENT ON COLUMN ownership_type.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN ownership_type.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN ownership_type.uuid IS 'A globally unique identifier for the ownership type record.';


-- Service Type Lookup Table (list of possible services)
CREATE TABLE facility_services (
    id SERIAL PRIMARY KEY,
    service TEXT UNIQUE NOT NULL,
    notes TEXT,
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE facility_services IS 'Lookup table for types of services that healthcare facilities can offer.';

COMMENT ON COLUMN facility_services.id IS 'The unique ID for the service type. This is the Primary Key.';

COMMENT ON COLUMN facility_services.service IS 'The name of the service (e.g., General consultation, Surgery).';

COMMENT ON COLUMN facility_services.notes IS 'Additional notes about the service.';

COMMENT ON COLUMN facility_services.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN facility_services.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN facility_services.uuid IS 'A globally unique identifier for the service type record.';


-- Healthcare Facility Table
CREATE TABLE healthcare_facility (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address VARCHAR(255),
    geometry GEOMETRY(Point, 4326),
    contact_number VARCHAR(20),
    capacity INTEGER,
    emergency_services BOOLEAN,
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    healthcare_facility_type_id INTEGER NOT NULL REFERENCES healthcare_facility_type(id),
    ownership_type_id          INTEGER NOT NULL REFERENCES ownership_type(id),
    building_condition_id      INTEGER NOT NULL REFERENCES building_condition(id)
);

COMMENT ON TABLE healthcare_facility IS 'Table storing healthcare facilities like hospitals, clinics, etc.';

COMMENT ON COLUMN healthcare_facility.id IS 'The unique ID for the healthcare facility. This is the Primary Key.';

COMMENT ON COLUMN healthcare_facility.name IS 'The name of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.address IS 'The address of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.geometry IS 'The geographic location of the facility as a point (WGS84).';

COMMENT ON COLUMN healthcare_facility.contact_number IS 'The contact number of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.capacity IS 'The capacity of the healthcare facility (e.g., number of beds).';

COMMENT ON COLUMN healthcare_facility.emergency_services IS 'Whether the healthcare facility provides emergency services or not.';

COMMENT ON COLUMN healthcare_facility.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN healthcare_facility.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN healthcare_facility.uuid IS 'A globally unique identifier for the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.healthcare_facility_type_id IS 'References the type of healthcare facility (e.g., hospital, clinic).';

COMMENT ON COLUMN healthcare_facility.ownership_type_id IS 'References the ownership type of the facility (e.g., Public, Private).';

COMMENT ON COLUMN healthcare_facility.building_condition_id IS 'References the building condition of the facility (e.g., Good, Needs Repair).';


-- Join Table: Healthcare Facility <-> Service (many-to-many)
CREATE TABLE healthcare_facility_services (
    id SERIAL PRIMARY KEY,

    healthcare_facility_id INTEGER NOT NULL REFERENCES healthcare_facility(id),
    facility_services_id   INTEGER NOT NULL REFERENCES facility_services(id),

    last_update TIMESTAMP NOT NULL DEFAULT now(),
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    UNIQUE (healthcare_facility_id, facility_services_id)
);

COMMENT ON TABLE healthcare_facility_services IS 'Join table storing which services are offered by which healthcare facilities.';

COMMENT ON COLUMN healthcare_facility_services.id IS 'The unique ID for the facility-service relationship. This is the Primary Key.';

COMMENT ON COLUMN healthcare_facility_services.healthcare_facility_id IS 'References the healthcare facility providing the service.';

COMMENT ON COLUMN healthcare_facility_services.facility_services_id IS 'References the type of service being offered.';

COMMENT ON COLUMN healthcare_facility_services.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN healthcare_facility_services.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN healthcare_facility_services.uuid IS 'A globally unique identifier for the facility-service relationship record.';
