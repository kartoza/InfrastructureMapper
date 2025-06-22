-- waste
-- waste type
INSERT INTO waste_type (last_update_by, name, type, notes) VALUES
('Thato', 'Glass', 'Recyclable', 'Glass bottles and jars'),
('Thato', 'Plastic', 'Recyclable', 'Plastic bottles and containers'),
('Thato', 'Cans', 'Recyclable', 'Aluminium and tin cans'),
('Thato', 'Paper', 'Compostable', 'Includes paper, cardboard, newspaper'),
('Thato', 'General', 'Non-recyclable', 'Mixed waste with no clear category');

-- containers condition
INSERT INTO containers_condition (last_update_by, name, type, notes) VALUES
('Thato', 'Good', 'Physical', 'No damage, fully functional'),
('Thato', 'Damaged', 'Physical', 'Cracked lid or broken structure'),
('Thato', 'Fair', 'Physical', 'Minor wear but usable'),
('Thato', 'Leaking', 'Physical', 'Liquid seeping from the bottom');

-- waste fill level
INSERT INTO waste_fill_level (last_update_by, name, type, notes) VALUES
('Thato', 'Empty', 'Fill', 'Completely empty'),
('Thato', 'Half', 'Fill', 'About halfway full'),
('Thato', 'Full', 'Fill', 'Container is full'),
('Thato', 'Overflowing', 'Fill', 'Overfilled, waste may be spilling out');
