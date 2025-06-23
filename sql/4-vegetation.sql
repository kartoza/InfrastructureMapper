-- --------------------------------------VEGETATION-------------------------------------
-- PLANT GROWTH ACTIVITY TYPE
CREATE TABLE
plant_growth_activity_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    sort_order INT UNIQUE
);

COMMENT ON TABLE plant_growth_activity_type IS 'Plant growth activity type refers to the different growth stages of plants, e.g. Sprouting, Seeding etc.';

COMMENT ON COLUMN plant_growth_activity_type.id IS 'The unique plant growth activity ID. This is the Primary Key.';

COMMENT ON COLUMN plant_growth_activity_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN plant_growth_activity_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN plant_growth_activity_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN plant_growth_activity_type.name IS 'The name of the plant growth activity type.';

COMMENT ON COLUMN plant_growth_activity_type.notes IS 'Additional information of the plant growth activity type.';

COMMENT ON COLUMN plant_growth_activity_type.image IS 'Image of the plant growth activity type.';

COMMENT ON COLUMN plant_growth_activity_type.sort_order IS 'Defines the pattern of how plant growth activity type records are to be sorted.';

-- PLANT TYPE
CREATE TABLE
plant_type (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    scientific_name TEXT UNIQUE,
    plant_image TEXT,
    flower_image TEXT,
    fruit_image TEXT,
    variety TEXT,
    info_url TEXT
);

COMMENT ON TABLE plant_type IS 'Look up table of different types of plants, e.g. Oaktree.';

COMMENT ON COLUMN plant_type.id IS 'The unique plant type ID. This is the Primary Key.';

COMMENT ON COLUMN plant_type.uuid IS 'The unique user ID.';

COMMENT ON COLUMN plant_type.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN plant_type.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN plant_type.name IS 'The name of the plant type.';

COMMENT ON COLUMN plant_type.notes IS 'Additional information of the plant type.';

COMMENT ON COLUMN plant_type.image IS 'Image of the plant type.';

COMMENT ON COLUMN plant_type.scientific_name IS 'Scientific name of the plant type e.g. Quercus.';

COMMENT ON COLUMN plant_type.plant_image IS 'Path to image of plant.';

COMMENT ON COLUMN plant_type.flower_image IS 'Path to image of flower.';

COMMENT ON COLUMN plant_type.fruit_image IS 'Path to image of fruit.';

COMMENT ON COLUMN plant_type.variety IS 'Other variety of this plant type.';

COMMENT ON COLUMN plant_type.info_url IS 'URL link to more information about this specific plant type.';

-- MONTH
CREATE TABLE
month (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    sort_order INT UNIQUE
);

COMMENT ON TABLE month IS 'Look up table for different months of the year, e.g. January, February etc.';

COMMENT ON COLUMN month.id IS 'The unique month ID. This is the Primary Key.';

COMMENT ON COLUMN month.uuid IS 'The unique user ID.';

COMMENT ON COLUMN month.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN month.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN month.name IS 'Name of the different months in the year e.g. January';

COMMENT ON COLUMN month.notes IS 'Additional information of the month.';

COMMENT ON COLUMN month.image IS 'Image of the object stored.';

COMMENT ON COLUMN month.sort_order IS 'Defines the pattern of how month records are to be sorted.';

-- PLANT USAGE
CREATE TABLE
plant_usage (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT
);

COMMENT ON TABLE plant_usage IS 'Look up table for different usages of the plants e.g. Food plant, Commercial plant etc.';

COMMENT ON COLUMN plant_usage.id IS 'The unique plant usage ID. This is the Primary Key.';

COMMENT ON COLUMN plant_usage.uuid IS 'The unique user ID.';

COMMENT ON COLUMN plant_usage.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN plant_usage.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN plant_usage.name IS 'The name of the plant usage.';

COMMENT ON COLUMN plant_usage.notes IS 'Additional information of the plant usage.';

COMMENT ON COLUMN plant_usage.image IS 'Image of the plant stored.';

-- VEGETATION POINT
CREATE TABLE
vegetation_point (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    notes TEXT,
    image TEXT,
    estimated_crown_radius_m FLOAT,
    -- Must be positive number
    CONSTRAINT radius_check CHECK (estimated_crown_radius_m >= 0),
    -- Takes 4 digits only
    estimated_planting_year DECIMAL(4, 0),
    -- Must be before or equal this year
    CONSTRAINT year_check CHECK (estimated_planting_year >= 0),
    CONSTRAINT year_check2 CHECK (
        estimated_planting_year <= date_part('Year', now())
    ),
    estimated_height_m FLOAT,
    -- Must be positive number
    CONSTRAINT height_check CHECK (estimated_height_m >= 0),
    geometry GEOMETRY (POINT, 4326) NOT NULL,
    plant_type_uuid UUID NOT NULL REFERENCES plant_type (uuid)
);

COMMENT ON TABLE vegetation_point IS 'Vegetation point refers a geolocated plant. Table stores the individual plant location and the properties.';

COMMENT ON COLUMN vegetation_point.id IS 'The unique vegetation point ID. This is the Primary Key.';

COMMENT ON COLUMN vegetation_point.uuid IS 'The unique user ID.';

COMMENT ON COLUMN vegetation_point.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN vegetation_point.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN vegetation_point.notes IS 'Additional information of the vegetation point.';

COMMENT ON COLUMN vegetation_point.image IS 'Image of the vegetation point.';

COMMENT ON COLUMN vegetation_point.estimated_crown_radius_m IS 'Estimated radius of the plant''s crown measured in meters.';

COMMENT ON COLUMN vegetation_point.estimated_height_m IS 'Estimated height of plant measured in meters.';

COMMENT ON COLUMN vegetation_point.estimated_planting_year IS 'The year the plant was planted. The year must be in the range of 0 to current year.';

COMMENT ON COLUMN vegetation_point.geometry IS 'The coordinates of the vegetation point. Follows EPSG 4326.';

-- PRUNING ACTIVITY
CREATE TABLE
pruning_activity (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    date DATE NOT NULL,
    before_image TEXT,
    after_image TEXT,
    vegetation_point_uuid UUID NOT NULL REFERENCES vegetation_point (uuid)
);

COMMENT ON TABLE pruning_activity IS 'Pruning activity refers to the trimming of unwanted parts of a plant.';

COMMENT ON COLUMN pruning_activity.id IS 'The unique pruning activity ID. This is the Primary Key.';

COMMENT ON COLUMN pruning_activity.uuid IS 'The unique user ID.';

COMMENT ON COLUMN pruning_activity.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN pruning_activity.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN pruning_activity.name IS 'The name of the pruning activity.';

COMMENT ON COLUMN pruning_activity.notes IS 'Additional information of the  pruning activity.';

COMMENT ON COLUMN pruning_activity.image IS 'Image of the  pruning activity.';

COMMENT ON COLUMN pruning_activity.date IS 'The date of the pruning activity (yyyy:mm:dd).';

COMMENT ON COLUMN pruning_activity.before_image IS 'Path to image before the pruning activity was done.';

COMMENT ON COLUMN pruning_activity.after_image IS 'Path to image after the pruning activity was done.';

-- HARVEST ACTIVITY
CREATE TABLE
harvest_activity (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    name TEXT UNIQUE NOT NULL,
    notes TEXT,
    image TEXT,
    date DATE NOT NULL,
    quantity_kg FLOAT,
    vegetation_point_uuid UUID NOT NULL REFERENCES vegetation_point (uuid)
);

COMMENT ON TABLE harvest_activity IS 'Harvest activity refers to the gathering of ripe crop or fruits.';

COMMENT ON COLUMN harvest_activity.id IS 'The unique harvest activity ID. This is the Primary Key.';

COMMENT ON COLUMN harvest_activity.uuid IS 'The unique user ID.';

COMMENT ON COLUMN harvest_activity.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN harvest_activity.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN harvest_activity.name IS 'The name of the harvest activity.';

COMMENT ON COLUMN harvest_activity.notes IS 'Additional information of the harvest activity.';

COMMENT ON COLUMN harvest_activity.image IS 'Image of the harvest activity.';

COMMENT ON COLUMN harvest_activity.date IS 'The date of the harvest activity (yyyy:mm:dd).';

COMMENT ON COLUMN harvest_activity.quantity_kg IS 'The quantity of harvest measured in kilograms.';

-- ASSOCIATION TABLES
-- PLANT GROWTH ACTIVITIES
CREATE TABLE
plant_growth_activities (
    fk_plant_activity_uuid UUID NOT NULL REFERENCES plant_growth_activity_type (
        uuid
    ),
    fk_plant_type_uuid UUID NOT NULL REFERENCES plant_type (uuid),
    fk_month_uuid UUID NOT NULL REFERENCES month (uuid),
    -- Composite primary key using the three foreign keys above
    PRIMARY KEY (
        fk_plant_activity_uuid,
        fk_plant_type_uuid,
        fk_month_uuid
    )
);

COMMENT ON TABLE plant_growth_activities IS 'Associative table to store the plant growth activities and plant types at different months in the year e.g. January_activity.';

COMMENT ON COLUMN plant_growth_activities.fk_plant_activity_uuid IS 'The foreign key linking to plant growth activity type table''s UUID.';

COMMENT ON COLUMN plant_growth_activities.fk_plant_type_uuid IS 'The foreign key linking to plant type table''s UUID.';

COMMENT ON COLUMN plant_growth_activities.fk_month_uuid IS 'The foreign key linking to month table''s UUID.';

-- PLANT TYPE USAGES
CREATE TABLE
plant_type_usages (
    fk_plant_usage_uuid UUID NOT NULL REFERENCES plant_usage (uuid),
    fk_plant_type_uuid UUID NOT NULL REFERENCES plant_type (uuid),
    PRIMARY KEY (fk_plant_usage_uuid, fk_plant_type_uuid)
);

COMMENT ON TABLE plant_type_usages IS 'Associative table to store the different plant usages and plant types ';

COMMENT ON COLUMN plant_type_usages.fk_plant_usage_uuid IS 'The foreign key linking to plant usage table''s UUID.';

COMMENT ON COLUMN plant_type_usages.fk_plant_type_uuid IS 'The foreign key linking to plant type table''s UUID.';
