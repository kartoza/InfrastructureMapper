#!/usr/bin/env bash
PSQL=$(which psql)
$PSQL gis -f sql/extensions.sql
$PSQL gis -f sql/1-infrastructure.sql
$PSQL gis -f sql/2-electricity.sql
$PSQL gis -f sql/3-water.sql
$PSQL gis -f sql/4-vegetation.sql
$PSQL gis -f sql/5-monitoring.sql
$PSQL gis -f sql/6-buildings.sql
$PSQL gis -f sql/7-fencing.sql
$PSQL gis -f sql/8-poi.sql
$PSQL gis -f sql/9-landuse.sql
$PSQL gis -f sql/10-gates.sql
$PSQL gis -f sql/11-poles.sql
$PSQL gis -f sql/12-culinary.sql
$PSQL gis -f sql/13-roads.sql
$PSQL gis -f sql/fixtures.sql
