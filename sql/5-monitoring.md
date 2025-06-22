# 📡 Monitoring

![Monitoring](../img/monitoring.png)

The **Monitoring** component captures infrastructure monitoring devices and their observations. This schema allows for the representation of sensors (such as weather stations, cameras, or environmental monitors), their types, and the data they collect over time.

**Entities from `sql/5-monitoring.sql`:**

- `monitoring_device_type`: Lookup table for types of monitoring devices (e.g., weather station, camera, sensor).
- `monitoring_device`: Represents individual monitoring devices, with geometry and a reference to `monitoring_device_type`.
- `monitoring_observation`: Stores observations or measurements recorded by monitoring devices, including timestamp, value, and type.

```mermaid
erDiagram
  monitoring_device_type {
    UUID uuid PK
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  monitoring_device {
    UUID uuid PK
    UUID monitoring_device_type_uuid FK
    GEOMETRY geometry
    TEXT name
    TIMESTAMP last_update
    TEXT last_update_by
  }
  monitoring_observation {
    UUID uuid PK
    UUID monitoring_device_uuid FK
    TIMESTAMP observed_at
    TEXT observation_type
    FLOAT value
    TEXT unit
    TIMESTAMP last_update
    TEXT last_update_by
  }

  monitoring_device_type ||--o{ monitoring_device : "has many"
  monitoring_device ||--o{ monitoring_observation : "records"
```

> 🤖 **Prompt**: Add a subsection to ## Components which provides
>
>SubHeading: Monitoring
>Image: img/monitoring.png
>Text: Summary of the entities in sql/5-monitoring.sql
> Mermaid: Diagram of the entities in sql/5-monitoring.sql
