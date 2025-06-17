--create database farming;
-- add connect statement here
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis' AND installed_version IS NOT NULL) THEN
		CREATE EXTENSION postgis;
	END IF;
END $$;
