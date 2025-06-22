# 💧 Water

![Water](./img/water.png)

The **Water** component models water-related infrastructure, such as pipelines, tanks, and pumps. This schema enables the representation of the spatial layout and relationships of water distribution and storage elements.

**Entities from `sql/3-water.sql`:**

- `water_pipe_type`: Lookup table for types of water pipes (e.g., main, branch).
- `water_pipe`: Represents individual water pipes, with geometry and a reference to `water_pipe_type`.
- `water_tank_type`: Lookup table for types of water tanks.
- `water_tank`: Represents individual water tanks, with geometry and a reference to `water_tank_type`.
- `water_pump`: Represents pumps, with geometry and attributes for capacity and type.

```mermaid
erDiagram
  water_pipe_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  water_pipe {
    UUID uuid PK
    UUID water_pipe_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  water_tank_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  water_tank {
    UUID uuid PK
    UUID water_tank_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  water_pump {
    UUID uuid PK
    GEOMETRY geometry
    TEXT name
    INTEGER capacity_lph
    TEXT type
    TIMESTAMP last_update
    TEXT last_update_by
  }

  water_pipe_type ||--o{ water_pipe : "has many"
  water_tank_type ||--o{ water_tank : "has many"
  water_pipe ||--o{ water_tank : "feeds"
  water_pipe ||--o{ water_pump : "has pumps"
```

> 🤖 **Prompt:** Add a subsection to ## Components which provides
>
> 1. SubHeading: Water
> 2. Image: img/water.png
> 3. Text: Summary of the entities in sql/3-water.sql
> 4. Mermaid: Diagram of the entities in sql/3-water.sql
