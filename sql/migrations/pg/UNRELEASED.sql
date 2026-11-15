-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------UNRELEASED-PG-MIGRATIONS------------------------
-- Append schema changes for the next release here. At release time this file is renamed
-- to vX.Y.Z.sql by scripts/release.sh and becomes immutable.
--
-- Required format for every appended block:
--
--   -- Issue #NNN: short description
--   <SQL statements>
--
-- Pre-commit hook (and the matching CI job) rejects any statement that is not preceded by
-- an `-- Issue #NNN:` header line.
-- Issue #56: Unify CRS to EPSG:4326 across all spatial tables.
-- Roads and intersections originally declared EPSG:32734 (WGS 84 / UTM Zone 34S)
-- while every other spatial table used EPSG:4326. Bring them onto the same
-- declared CRS so the canonical schema is uniform; users that need metric
-- accuracy reproject at build time via scripts/build_gpkg.sh --crs.

-- Issue #69: Add a gender field to roads, capturing whether the road's name
-- commemorates a male or female person, is of unknown gender, or has none
-- (e.g. a numbered street or a non-personal name).
ALTER TABLE road ADD COLUMN gender CHAR(1) NOT NULL DEFAULT '?' CHECK (gender IN ('m', 'f', '?', '-'));

COMMENT ON COLUMN road.gender IS 'Gender implied by the road name: m = male, f = female, ? = unknown, - = none (e.g. a numbered street).';

-- Issue #69: Add road_segment_photo for zero or more geotagged field photos
-- per road segment, captured via QGIS's Attachment widget.
CREATE TABLE IF NOT EXISTS road_segment_photo (
    id SERIAL NOT NULL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    last_update TIMESTAMP DEFAULT now() NOT NULL,
    last_update_by TEXT NOT NULL,
    photo_path TEXT NOT NULL,
    captured_at TIMESTAMP NOT NULL,
    bearing_deg FLOAT CHECK (bearing_deg >= 0 AND bearing_deg < 360),
    tilt_deg FLOAT CHECK (tilt_deg >= -90 AND tilt_deg <= 90),
    geom GEOMETRY (POINT, 4326) NOT NULL,
    road_segment_uuid UUID NOT NULL REFERENCES road_segment (uuid)
);

COMMENT ON TABLE road_segment_photo IS 'Zero or more geotagged field photos attached to a road segment.';

COMMENT ON COLUMN road_segment_photo.id IS 'The unique road segment photo ID. This is the Primary Key.';

COMMENT ON COLUMN road_segment_photo.uuid IS 'Global Unique Identifier.';

COMMENT ON COLUMN road_segment_photo.last_update IS 'The date that the last update was made (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN road_segment_photo.last_update_by IS 'The name of the user responsible for the latest update.';

COMMENT ON COLUMN road_segment_photo.photo_path IS 'Path or URL to the photo file, for use with the QGIS Attachment widget.';

COMMENT ON COLUMN road_segment_photo.captured_at IS 'The date and time the photo was taken (yyyy-mm-dd hh:mm:ss).';

COMMENT ON COLUMN road_segment_photo.bearing_deg IS 'Compass direction the camera was pointing, in degrees (0-360, 0 = north).';

COMMENT ON COLUMN road_segment_photo.tilt_deg IS 'Phone tilt angle at capture time, in degrees (-90 to 90).';

COMMENT ON COLUMN road_segment_photo.geom IS 'The location the photo was taken. EPSG: 4326.';

COMMENT ON COLUMN road_segment_photo.road_segment_uuid IS 'The foreign key which references the uuid from the road_segment table.';
