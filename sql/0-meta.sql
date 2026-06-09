-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
-- --------------------------------------META----------------------------------------------
-- Schema version tracking. Both fresh-build and migration-applied state lands here so any
-- consumer (psql, QGIS, ogrinfo, automation) can introspect "what version is this DB on?".
CREATE TABLE IF NOT EXISTS schema_migrations (
    version TEXT NOT NULL PRIMARY KEY,
    major INTEGER NOT NULL,
    minor INTEGER NOT NULL,
    patch INTEGER NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    applied_by TEXT NOT NULL,
    checksum TEXT NOT NULL,
    is_baseline BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    CONSTRAINT schema_migrations_semver_nonneg CHECK (
        major >= 0 AND minor >= 0 AND patch >= 0
    )
);

CREATE INDEX IF NOT EXISTS idx_schema_migrations_semver -- noqa: PG01
ON schema_migrations (major DESC, minor DESC, patch DESC);

-- current_schema_version returns exactly one row representing the highest version applied.
-- Use: SELECT * FROM current_schema_version;
CREATE OR REPLACE VIEW current_schema_version AS
SELECT
    version,
    major,
    minor,
    patch,
    applied_at,
    is_baseline
FROM schema_migrations
ORDER BY major DESC, minor DESC, patch DESC
LIMIT 1;
