# 🛣️ Roads

![Roads](../img/roads.png)

The **Roads** component models transportation infrastructure, including roads, tracks, and paths within the mapped area. This schema enables the representation of different road types, individual road segments, and their spatial characteristics, supporting navigation, planning, and analysis.

**Entities from `sql/13-roads.sql`:**

- `segment_type`: Road classification (e.g. National, Main Road).
- `segment_status`: Road segment status (e.g. In Use, Planned).
- `segment_surface`: Surface material (e.g. Asphalt, Dirt).
- `segment_condition`: Physical condition (e.g. Good, Flooded).
- `road`: Logical grouping of road segments (has a name).
- `intersection`: Physical nodes (start/end points for road segments).
- `road_segment`: Actual line features with geometry and references to all lookup tables, the road it belongs to, and intersections.

```mermaid
erDiagram
  segment_type {
    UUID uuid PK
    TEXT type_name
    TEXT description
    TIMESTAMP last_update
    TEXT last_update_by
  }

  segment_status {
    UUID uuid PK
    TEXT status_name
    TEXT description
    TIMESTAMP last_update
    TEXT last_update_by
  }

  segment_surface {
    UUID uuid PK
    TEXT surface_name
    TEXT description
    TIMESTAMP last_update
    TEXT last_update_by
  }

  segment_condition {
    UUID uuid PK
    TEXT condition_name
    TEXT description
    TIMESTAMP last_update
    TEXT last_update_by
  }

  road {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }

  intersection {
    UUID uuid PK
    GEOMETRY geom
    TIMESTAMP last_update
    TEXT last_update_by
  }

  road_segment {
    UUID uuid PK
    INT segment_number
    INT lanes
    FLOAT length_m
    INT speed_limit_kmh
    BOOLEAN one_way
    GEOMETRY geom
    UUID road_uuid FK
    UUID type_uuid FK
    UUID status_uuid FK
    UUID surface_uuid FK
    UUID condition_uuid FK
    UUID start_node FK
    UUID end_node FK
    TIMESTAMP last_update
    TEXT last_update_by
  }

  segment_type ||--o{ road_segment : "classifies"
  segment_status ||--o{ road_segment : "describes status"
  segment_surface ||--o{ road_segment : "has surface"
  segment_condition ||--o{ road_segment : "has condition"
  road ||--o{ road_segment : "contains"
  intersection ||--o{ road_segment : "start node"
  intersection ||--o{ road_segment : "end node"
```

---

> 🤖 **Prompt:** Add a subsection to ## Components which provides
>
> 1. SubHeading: Roads
> 2. Image: img/roads.png
> 3. Text: Summary of the entities in sql/13-roads.sql
> 4. Mermaid: Diagram of the entities in sql/13-roads.sql
