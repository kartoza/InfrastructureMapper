# 🚧 Fencing

![Fencing](../img/fencing.png)

The **Fencing** component models boundary and enclosure features, such as fences and gates, that are not directly associated with buildings. This schema allows for the representation of different fence types, individual fence segments, and standalone gates, supporting detailed mapping of property boundaries and access points.

**Entities from `sql/7-fencing.sql`:**

- `fence_type`: Lookup table for types of fences (e.g., wire, wall, hedge).
- `fence`: Represents individual fence segments, with geometry and a reference to `fence_type`.
- `gate`: Represents gates, with geometry and attributes for name and access type.

```mermaid
erDiagram
  fence_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  fence {
    UUID uuid PK
    UUID fence_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  gate {
    UUID uuid PK
    GEOMETRY geometry
    TEXT name
    TEXT access_type
    TIMESTAMP last_update
    TEXT last_update_by
  }

  fence_type ||--o{ fence : "has many"
  fence ||--o{ gate : "has gates"
```

> 🤖 **Prompt:** Add a subsection to ## Components which provides
>
> SubHeading: Fencing
> Image: img/fencing.png
> Text: Summary of the entities in sql/7-fencing.sql
> Mermaid: Diagram of the entities in sql/7-fences.sql
