-- waste
-- waste type
INSERT INTO container_type (last_update_by, container_type_name, container_type_description) VALUES
('Thato', 'Glass', 'Used for collecting glass waste like bottles and jars'),
('Thato', 'Plastic', 'Used for collecting waste like plastic bottles, containers and packaging'),
('Thato', 'Cans', 'Used for collecting waste like aluminium and tin cans'),
('Thato', 'Paper', 'Used for collecting waste like paper, cardboard and newspaper'),
('Thato', 'General', 'Used for unsorted or mixed domestic waste');

-- containers condition
INSERT INTO container_condition (last_update_by, condition_name, condition_description) VALUES
('Thato', 'Good', 'No damage, fully functional'),
('Thato', 'Damaged', 'Cracked or broken lid, partially usable'),
('Thato', 'Fair', 'Minor dents or wear but functional'),
('Thato', 'Leaking', 'Liquid seeping from base or sides');

-- waste fill level
INSERT INTO waste_level (last_update_by, level_name, level_description) VALUES
('Thato', 'Empty', 'No waste inside'),
('Thato', 'Half', 'Approximately 50% full'),
('Thato', 'Full', 'Completely full, should be emptied'),
('Thato', 'Overflowing', 'Exceeds capacity, waste spilling out');
