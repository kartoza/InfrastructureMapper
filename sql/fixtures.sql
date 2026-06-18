-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- vegetation
-- months of the year
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'January', 1
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'February', 2
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'March', 3
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'April', 4
);
INSERT INTO month (last_update_by, name, sort_order) VALUES ('Luna', 'May', 5);
INSERT INTO month (last_update_by, name, sort_order) VALUES ('Luna', 'June', 6);
INSERT INTO month (last_update_by, name, sort_order) VALUES ('Luna', 'July', 7);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'August', 8
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'September', 9
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'October', 10
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'November', 11
);
INSERT INTO month (last_update_by, name, sort_order) VALUES (
    'Luna', 'December', 12
);

-- plant growth activities type
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Sprouting', 1);
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Seeding', 2);
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Vegetative', 3);
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Budding', 4);
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Flowering', 5);
INSERT INTO plant_growth_activity_type (
    last_update_by, name, sort_order
) VALUES ('Luna', 'Ripening', 6);

-- plant usage
INSERT INTO plant_usage (last_update_by, name) VALUES ('Luna', 'Food Plant');
INSERT INTO plant_usage (last_update_by, name) VALUES ('Luna', 'Fodder Plant');
INSERT INTO plant_usage (last_update_by, name) VALUES (
    'Luna', 'Commercial Plant'
);


-- electricity
-- electricity line type
INSERT INTO electricity_line_type (
    last_update_by, name, sort_order, current_a, voltage_v
) VALUES ('Ashleigh', 'Low Voltage', 1, 50, 230);
INSERT INTO electricity_line_type (
    last_update_by, name, sort_order, current_a, voltage_v
) VALUES ('Ashleigh', 'Medium Voltage', 2, 75, 11000);
INSERT INTO electricity_line_type (
    last_update_by, name, sort_order, current_a, voltage_v
) VALUES ('Ashleigh', 'High Voltage', 3, 100, 33000);
INSERT INTO electricity_line_type (
    last_update_by, name, sort_order, current_a, voltage_v
) VALUES ('Ashleigh', 'Extra-High Voltage', 4, 120, 365000);
INSERT INTO electricity_line_type (
    last_update_by, name, sort_order, current_a, voltage_v
) VALUES ('Ashleigh', 'Ultra-High Voltage', 5, 150, 800000);

-- electricity line condition type
INSERT INTO electricity_line_condition_type (last_update_by, name) VALUES (
    'Ashleigh', 'Working'
);
INSERT INTO electricity_line_condition_type (last_update_by, name) VALUES (
    'Ashleigh', 'Broken'
);


-- water
-- water source
INSERT INTO water_source (last_update_by, name) VALUES ('Polly', 'Aquifer');
INSERT INTO water_source (last_update_by, name) VALUES ('Polly', 'River');
INSERT INTO water_source (last_update_by, name) VALUES ('Polly', 'Reservoir');
INSERT INTO water_source (last_update_by, name) VALUES ('Polly', 'Rainwater');

-- water polygon type
INSERT INTO water_polygon_type (last_update_by, name) VALUES (
    'Polly', 'Wetland'
);
INSERT INTO water_polygon_type (last_update_by, name) VALUES ('Polly', 'Lake');
INSERT INTO water_polygon_type (last_update_by, name) VALUES (
    'Polly', 'Reservoir'
);
INSERT INTO water_polygon_type (last_update_by, name) VALUES ('Polly', 'Pond');

-- water point type
INSERT INTO water_point_type (last_update_by, name) VALUES (
    'Polly', 'Drinking Trough'
);
INSERT INTO water_point_type (last_update_by, name) VALUES ('Polly', 'Tap');
INSERT INTO water_point_type (last_update_by, name) VALUES (
    'Polly', 'Borehole'
);
INSERT INTO water_point_type (last_update_by, name) VALUES (
    'Polly', 'Water Tank'
);

-- water line type
INSERT INTO water_line_type (last_update_by, name, sort_order) VALUES (
    'Polly', 'River', 1
);
INSERT INTO water_line_type (last_update_by, name, sort_order) VALUES (
    'Polly', 'Stream', 2
);

-- fence
-- fence type
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Barbed wire', 1
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Chain link', 2
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Electric fence', 3
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Split rail', 4
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Wall', 5
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Wood', 6
);
INSERT INTO fence_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Wrought fence', 7
);

-- point of interest
-- point of interest type
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Bridge', 1
);
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Electric', 2
);
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Fence', 3
);
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Gate', 4
);
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Ruin', 5
);
INSERT INTO point_of_interest_type (last_update_by, name, sort_order) VALUES (
    'Jeff', 'Water point', 6
);

-- condition
INSERT INTO condition (last_update_by, name) VALUES ('Jeff', 'Fixed');
INSERT INTO condition (last_update_by, name) VALUES ('Jeff', 'Broken');

-- pole_material 
INSERT INTO pole_material (last_update_by, id, name) VALUES (
    'Charles', 1, 'Metal'
);
INSERT INTO pole_material (last_update_by, id, name) VALUES (
    'Charles', 2, 'Wooden'
);
INSERT INTO pole_material (last_update_by, id, name) VALUES (
    'Charles', 3, 'Concrete'
);

-- pole_function
INSERT INTO pole_function (id, last_update_by, pole_function_name) VALUES (
    1, 'Charles', 'Telecommunications'
);
INSERT INTO pole_function (id, last_update_by, pole_function_name) VALUES (
    2, 'Charles', 'Electric'
);
INSERT INTO pole_function (id, last_update_by, pole_function_name) VALUES (
    3, 'Charles', 'Flag'
);
INSERT INTO pole_function (id, last_update_by, pole_function_name) VALUES (
    4, 'Charles', 'Street lighting'
);

-- pole 
INSERT INTO pole (
    last_update,
    last_update_by,
    installation_date,
    geometry,
    height,
    pole_material_id,
    pole_function_id
) VALUES (
    '2023-10-11',
    'Charles',
    '2023-10-11',
    ST_GEOMFROMTEXT('POINT(0 0)', 4326),
    20,
    1,
    1
);
INSERT INTO pole (
    last_update,
    last_update_by,
    installation_date,
    geometry,
    height,
    pole_material_id,
    pole_function_id
) VALUES (
    '2023-10-11',
    'Charles',
    '2023-10-11',
    ST_GEOMFROMTEXT('POINT(0 0)', 4326),
    10,
    1,
    2
);
INSERT INTO pole (
    last_update,
    last_update_by,
    installation_date,
    geometry,
    height,
    pole_material_id,
    pole_function_id
) VALUES (
    '2023-10-11',
    'Charles',
    '2023-10-11',
    ST_GEOMFROMTEXT('POINT(0 0)', 4326),
    70,
    1,
    3
);
INSERT INTO pole (
    last_update,
    last_update_by,
    installation_date,
    geometry,
    height,
    pole_material_id,
    pole_function_id
) VALUES (
    '2023-10-11',
    'Charles',
    '2023-10-11',
    ST_GEOMFROMTEXT('POINT(0 0)', 4326),
    80,
    1,
    2
);
INSERT INTO pole (
    last_update,
    last_update_by,
    installation_date,
    geometry,
    height,
    pole_material_id,
    pole_function_id
) VALUES (
    '2023-10-11',
    'Charles',
    '2023-10-11',
    ST_GEOMFROMTEXT('POINT(0 0)', 4326),
    20,
    1,
    2
);


-- culinary facilities
-- culinary_category
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Traditional', 'Traditional culinary options.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Fast Food', 'Quick and convenient food.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Street Food', 'Food stalls and street vendors.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Cafe/Bakery', 'Cafes and bakeries.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Seafood', 'Specializing in seafood dishes.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Desserts/Sweets', 'Desserts and sweet treats.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'Buffet', 'All-you-can-eat buffet style.'
);
INSERT INTO culinary_category (last_update_by, name, notes) VALUES (
    'Hefni', 'International Cuisine', 'Cuisine from around the world.'
);

-- facility_type
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Parking Area', 'Designated parking space.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Wi-Fi', 'Free wireless internet.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Outdoor Seating', 'Seating available outdoors.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Indoor Seating', 'Seating available indoors.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Restroom', 'Available restroom facilities.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Air Conditioning', 'Air-conditioned area.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Smoking Area', 'Designated smoking zone.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Kids Playground', 'Play area for children.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Nursing Room', 'Private room for nursing mothers.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Event Space', 'Space for hosting events.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Charging Station', 'Facilities to charge devices.'
);
INSERT INTO facility_type (last_update_by, name, description) VALUES (
    'Hefni', 'Prayer Room', 'Designated prayer area.'
);


-- roads
-- segment type
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'National', 'Highways connecting major cities'
);
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'Main Road', 'Major roads within towns/cities'
);
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'Street', 'Regular urban or suburban streets'
);
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'Gravel Road', 'Unpaved roads, often rural'
);
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'Private Road', 'Access roads in private areas'
);
INSERT INTO segment_type (last_update_by, type_name, description) VALUES (
    'Lindie', 'Footpath', 'Pedestrian-only paths'
);

-- segment status
INSERT INTO segment_status (last_update_by, status_name, description) VALUES (
    'Lindie', 'In Use', 'Fully constructed and open to traffic'
);
INSERT INTO segment_status (last_update_by, status_name, description) VALUES (
    'Lindie', 'Under Construction', 'Being built, not yet usable'
);
INSERT INTO segment_status (last_update_by, status_name, description) VALUES (
    'Lindie', 'Planned', 'Approved but construction hasn’t started'
);
INSERT INTO segment_status (last_update_by, status_name, description) VALUES (
    'Lindie', 'Closed', 'Permanently or temporarily not in use'
);
INSERT INTO segment_status (last_update_by, status_name, description) VALUES (
    'Lindie', 'Proposed', 'Early planning stage, not yet approved or funded'
);

-- segment surface
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES ('Lindie', 'Asphalt', 'Paved city streets, highways');
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES ('Lindie', 'Concrete', 'Urban roads, highways with heavy traffic');
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES ('Lindie', 'Gravel', 'Rural or farm roads');
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES ('Lindie', 'Dirt', 'Unmaintained roads or informal tracks');
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES (
    'Lindie', 'Paved (Other)', 'Brick, cobblestone, or other solid surfacing'
);
INSERT INTO segment_surface (
    last_update_by, surface_name, description
) VALUES ('Lindie', 'Unpaved', 'Catch-all for surfaces without hard topping');

-- segment condition
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES ('Lindie', 'Good', 'Smooth, well-maintained road');
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES ('Lindie', 'Fair', 'Usable, but with minor wear or occasional issues');
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES ('Lindie', 'Poor', 'Damaged or deteriorating surface, still passable');
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES (
    'Lindie', 'Very Poor', 'Major potholes, erosion, or unsafe for normal use'
);
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES ('Lindie', 'Closed', 'Temporarily or permanently blocked');
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES (
    'Lindie', 'Flooded', 'Water obstructs access (seasonal or emergency)'
);
INSERT INTO segment_condition (
    last_update_by, condition_name, description
) VALUES (
    'Lindie', 'Under Repair', 'Currently under maintenance or construction'
);


-- healthcare facilities
-- ownership_type
INSERT INTO ownership_type (last_update_by, ownership_type, notes) VALUES (
    'Nikita', 'Public', 'Government-owned healthcare facility.'
);
INSERT INTO ownership_type (last_update_by, ownership_type, notes) VALUES (
    'Nikita', 'Private', 'Privately operated healthcare facility.'
);

-- building_condition
INSERT INTO building_condition (last_update_by, condition_type, notes) VALUES (
    'Nikita', 'Good', 'Facility is in good condition.'
);
INSERT INTO building_condition (last_update_by, condition_type, notes) VALUES (
    'Nikita', 'Needs Repair', 'Some repairs or maintenance required.'
);
INSERT INTO building_condition (last_update_by, condition_type, notes) VALUES (
    'Nikita', 'Under Renovation', 'Currently being renovated.'
);
INSERT INTO building_condition (last_update_by, condition_type, notes) VALUES (
    'Nikita', 'Bad', 'Poor building condition, needs major work.'
);

-- healthcare_facility_type
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Hospital', 'General medical and surgical facility.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Doctors practice', 'General practitioner services.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Pharmacy', 'Dispenses medicine and medical supplies.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Diagnostic Imaging Centers', 'Radiology and imaging services.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Optometrist', 'Eye examinations and vision care.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Dental Office', 'Dentistry and oral care.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Community Healthcare Centres', 'Community-level primary healthcare.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Hospice', 'Pain management.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Womens Health', 'Women-specific healthcare services.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Dialysis Centre', 'Kidney dialysis treatment facility.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Physiotherapist', 'Rehabilitation and physical therapy.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Medical centre', 'General outpatient medical care.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Occupational therapist', 'Functional rehabilitation therapy.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Clinic', 'Primary healthcare clinic.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Optometry', 'Vision care services.'
);
INSERT INTO healthcare_facility_type (last_update_by, type, notes) VALUES (
    'Nikita', 'Chiropractor', 'Musculoskeletal adjustments and therapy.'
);

-- facility_services
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'General consultation', 'General doctor consultation.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Emergency care', 'Emergency medical response.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Surgery', 'General surgical procedures.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Radiology', 'Medical imaging services.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Physical therapy', 'Rehabilitation therapy.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Orthopedic services', 'Bone and joint treatments.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Pharmacy services', 'Dispensing medication.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Prenatal care', 'Pregnancy-related care.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Dental care', 'Dental treatment services.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Vaccinations', 'Immunization services.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Eye examinations/treatment', 'Optometry and visual health.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Counseling services', 'Mental health support.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Pain management', 'Pain relief and chronic care.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Occupational therapy', 'Functional rehabilitation.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Dialysis treatment', 'Kidney dialysis therapy.'
);
INSERT INTO facility_services (last_update_by, service, notes) VALUES (
    'Nikita', 'Chiropractic services', 'Spinal and musculoskeletal alignment.'
);
