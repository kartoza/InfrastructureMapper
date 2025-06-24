# 🗺️ Land use
<!-- cspell:ignore landuse -->

![Land use](../img/landuse-areas.png)

The **Land use** component models how land parcels are utilized or designated, such as agricultural, residential, commercial, or conservation areas. This schema enables the representation of land use types and individual land use polygons, supporting spatial analysis and planning.

**Entities from `sql/9-landuse.sql`:**

- `landuse_type`: Lookup table for different land use categories (e.g., agricultural, residential, industrial).
- `landuse`: Represents individual land use areas, with geometry and a reference to `landuse_type`.

```mermaid
erDiagram
  landuse_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  landuse {
    UUID uuid PK
    UUID landuse_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }

  landuse_type ||--o{ landuse : "has many"
```

> 🤖 **Prompt:** Add a subsection to ## Components which provides
>
>1. SubHeading: Land use
>2. Image: img/landuse.png
>3. Text: Summary of the entities in sql/9-landuse.sql
>4. Mermaid: Diagram of the entities in sql/9-landuse.sql
