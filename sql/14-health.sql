-- --------------------------------------HEALTHCARE
-- FACILITIES-------------------------------------
-- By: Nikita Harripersadh
-- ---------------------------- HEALTHCARE FACILITIES ----------------------------

-- Healthcare Facility Type Lookup Table
CREATE TABLE healthcare_facility_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
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

-- Building condition Lookup Table
CREATE TABLE building_condition (
    id SERIAL NOT NULL PRIMARY KEY,
    condition_type TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
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

-- Healthcare facility Table
CREATE TABLE healthcare_facility (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    address VARCHAR(255),
    contact_number VARCHAR(20),
    capacity INTEGER,
    emergency_services BOOLEAN,
    location GEOMETRY(POINT, 4326), 
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    healthcare_facility_type_uuid UUID NOT NULL REFERENCES healthcare_facility_type(uuid),
    building_condition_uuid UUID NOT NULL REFERENCES building_condition(uuid)
);

COMMENT ON TABLE healthcare_facility IS 'Table storing healthcare facilities like hospitals, clinics, etc.';

COMMENT ON COLUMN healthcare_facility.id IS 'The unique ID for the healthcare facility. This is the Primary Key.';

COMMENT ON COLUMN healthcare_facility.name IS 'The name of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.address IS 'The address of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.contact_number IS 'The contact number of the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.capacity IS 'The capacity of the healthcare facility (e.g., number of beds).';

COMMENT ON COLUMN healthcare_facility.emergency_services IS 'Whether the healthcare facility provides emergency services or not.';

COMMENT ON COLUMN healthcare_facility.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN healthcare_facility.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN healthcare_facility.uuid IS 'A globally unique identifier for the healthcare facility.';

COMMENT ON COLUMN healthcare_facility.healthcare_facility_type_uuid IS 'References the type of healthcare facility (e.g., hospital, clinic).';

COMMENT ON COLUMN healthcare_facility.building_condition_uuid IS 'References the building condition of the facility (e.g., Good, Needs Repair).';

-- Ownership Type Lookup Table
CREATE TABLE ownership_type (
    id SERIAL NOT NULL PRIMARY KEY,
    ownership_type TEXT NOT NULL,
    notes TEXT,
    last_update TIMESTAMP DEFAULT now() NOT NULL,
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

-- Healthcare Facility Services Table
CREATE TABLE healthcare_facility_services (
    id SERIAL NOT NULL PRIMARY KEY,
    service TEXT NOT NULL,
    healthcare_facility_uuid UUID NOT NULL REFERENCES healthcare_facility(uuid),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid()
);

COMMENT ON TABLE healthcare_facility_services IS 'Table storing services offered by healthcare facilities (e.g., General consultation, Surgery).';

COMMENT ON COLUMN healthcare_facility_services.id IS 'The unique ID for the healthcare service. This is the Primary Key.';

COMMENT ON COLUMN healthcare_facility_services.service IS 'The service offered by the healthcare facility.';

COMMENT ON COLUMN healthcare_facility_services.healthcare_facility_uuid IS 'References the healthcare facility providing the service.';

COMMENT ON COLUMN healthcare_facility_services.last_update IS 'The date the record was last updated.';

COMMENT ON COLUMN healthcare_facility_services.last_update_by IS 'The user who last updated the record.';

COMMENT ON COLUMN healthcare_facility_services.uuid IS 'A globally unique identifier for the healthcare service record.';