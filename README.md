
# NAMING CONVENTION

***SQL*** keywords and statements must be written in ***upper case***, for example:

``SELECT * FROM electricity_line;``

***Entity Names*** must be ***Singular*** for example:

```electricity_line_type``` not ```electricity_line_types```

***Entity Names*** must be in ***lower case*** and use ***underscores (_)*** to seperate words, for example:

```water_point``` not ```WaterPoint```

***Lookup Table*** names must be in lower case, for example:

```electricity_line_condition``` not ```ElectricityLineCondition```

---

# ERD conventions

- `uuid`, `last_update`, and `last_update_by` fields must be grey.

- `geometry` fields must remain black and should be positioned above the greyed attributes.

- Foreign key fields must always be positioned last in the table and highlighted in green.

- Each table must start with `name(s)`, `type`, `notes`, in that order.

- All length and depth fields must explicitly include units (assume meters unless otherwise specified), for eaxmple: 

```crown_radius_m``` not ```crown_radius```

- Current must be measured in amperes.

- Voltage must be measured in volts.

- In the `image` field, insert the file path as text.

- Constraints and their associated fields must be highlighted in blue.

- Association (junction) tables must be displayed in blue.
