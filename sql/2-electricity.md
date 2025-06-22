# ⚡ Electricity

![Electricity](../img/electricity.png)

The **Electricity** component models electrical infrastructure, including power lines, poles, and transformers. This schema enables the representation of the spatial layout and relationships of electricity distribution elements.

**Entities from `sql/2-electricity.sql`:**

- `power_line_type`: Lookup table for types of power lines (e.g., high voltage, low voltage).
- `power_line`: Represents individual power lines, with geometry and a reference to `power_line_type`.
- `power_pole_type`: Lookup table for types of power poles.
- `power_pole`: Represents individual power poles, with geometry and a reference to `power_pole_type`.
- `transformer`: Represents transformers, with geometry and attributes for capacity and type.

```mermaid
erDiagram
  power_line_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  power_line {
    UUID uuid PK
    UUID power_line_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  power_pole_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  power_pole {
    UUID uuid PK
    UUID power_pole_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  transformer {
    UUID uuid PK
    GEOMETRY geometry
    TEXT name
    INTEGER capacity_kva
    TEXT type
    TIMESTAMP last_update
    TEXT last_update_by
  }

  power_line_type ||--o{ power_line : "has many"
  power_pole_type ||--o{ power_pole : "has many"
  power_line ||--o{ power_pole : "has poles"
  power_pole ||--o{ transformer : "has transformers"
```
