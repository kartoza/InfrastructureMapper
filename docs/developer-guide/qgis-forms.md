<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# QGIS Form Conventions

`scripts/generate_project.py` builds every layer's drag-and-drop attribute
form the same way, so editing one table feels the same as editing any
other. These rules are enforced by the generator &mdash; don't hand-edit a
form in QGIS and expect it to survive the next `nix run .#generate-project`
regeneration; change the generator instead.

## Timestamp fields default to a live `now()` expression

Every column whose Postgres type starts with `timestamp` (found via
`introspect_table()`, not hardcoded by name) gets a client-side default
value of the QGIS expression `now()`:

```python
layer.setDefaultValueDefinition(idx, QgsDefaultValue("now()"))
```

This is deliberately **not** `CURRENT_TIMESTAMP` or relying on the
database column's own `DEFAULT now()`. Reasons:

- The GeoPackage/SQLite backend has no live equivalent of Postgres'
  `now()` column default, so relying on the database default behaves
  differently between the PG and GPKG backends. A QGIS-side default
  expression behaves identically on both.
- A client-side default shows up in the form immediately when a feature
  is created, before the row is ever saved &mdash; a database-side default
  is invisible until after the first commit.

Applies to every `timestamp` column, not just the common `last_update`
audit column &mdash; e.g. `road_segment_photo.captured_at` gets the same
treatment.

## `uuid` fields default to a Postgres-shaped `uuid()` expression

The GeoPackage/SQLite backend has no equivalent of Postgres'
`gen_random_uuid()` column default, so a feature digitised directly
against the `.gpkg` would otherwise get a null `uuid` until a later PG
migration backfills it. Every `uuid` column gets a client-side default
instead:

```python
layer.setDefaultValueDefinition(idx, QgsDefaultValue("uuid('WithoutBraces')"))
```

`'WithoutBraces'` matters: QGIS's default `uuid()` format wraps the value
in curly braces (`{xxxxxxxx-...}`), which doesn't match Postgres' own
lowercase, unbraced `gen_random_uuid()` output. `'WithoutBraces'` does.

## `last_update_by` defaults to the current device user

```python
layer.setDefaultValueDefinition(idx, QgsDefaultValue("@user_full_name"))
```

`@user_full_name` is QGIS's own expression variable for the OS-reported
full name of whoever is running QGIS &mdash; the field is never left for
the user to type in by hand.

## FK fields get a clean alias, not the raw schema comment

Foreign key columns across `sql/**/*.sql` are commented in several
different verbose, inconsistent styles, e.g.:

> The foreign key which references the uuid from the road segment types
> table.

None of that belongs in front of an end user. `scripts/generate_project.py`
detects every FK column structurally (via the table's own
`FOREIGN KEY ... REFERENCES` constraints, not the comment text), strips
the schema's known boilerplate wrappers down to the descriptive middle,
singularises a trailing plural, and sentence-cases the result:

```text
"The foreign key which references the uuid from the road segment types table."
  -> "Road segment type"
```

If a comment doesn't match any known boilerplate shape at all (e.g. "A
foreign key which is used as composite primary key."), the alias falls
back to the referenced table's own name instead.

## Non-FK field aliases drop filler words

Every other column alias is still taken from its schema comment, but
with a trailing period and a leading "The"/"A"/"An" dropped &mdash; humanistic
and clear without the filler:

```text
"The order of road segments." -> "Order of road segments"
```

## Layer names are humanised, not raw table names

A layer's name (shown in the legend and everywhere else in the QGIS UI)
is `humanize(table)` &mdash; e.g. `road_segment` &rarr; `Road Segment` &mdash;
never the raw snake_case table name. The user should never be exposed to
the schema's internal naming.
