# 🍽️ Culinary

![Culinary](./img/food-services.png)

The **Culinary** component models food service infrastructure, such as kitchens, dining areas, and food storage facilities. This schema enables the representation of culinary-related spaces, their types, and their spatial relationships within the infrastructure.

**Entities from `sql/12-culinary.sql`:**

- `culinary_facility_type`: Lookup table for types of culinary facilities (e.g., kitchen, canteen, pantry).
- `culinary_facility`: Represents individual culinary facilities, with geometry and a reference to `culinary_facility_type`.
- `food_storage`: Represents food storage areas, with geometry and attributes for capacity and type.

```mermaid
erDiagram
  culinary_facility_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  culinary_facility {
    UUID uuid PK
    UUID culinary_facility_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  food_storage {
    UUID uuid PK
    GEOMETRY geometry
    TEXT name
    INTEGER capacity_kg
    TEXT storage_type
    TIMESTAMP last_update
    TEXT last_update_by
  }

  culinary_facility_type ||--o{ culinary_facility : "has many"
  culinary_facility ||--o{ food_storage : "contains"
```

> 🤖 **Prompt:** Add a subsection to here which has:
>
>1. SubHeading: Culinary
>2. Image: img/food-services.png
>3. Text: Summary of the entities in sql/12-culinary.sql
>4. Mermaid: Diagram of the entities in sql/12-culinary.sql
