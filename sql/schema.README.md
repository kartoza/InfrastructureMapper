# 📊 Infrastructure Mapper Schema Documentation

This document provides an overview of the database schema for **Infrastructure Mapper** using Mermaid diagrams. The schema is broken into logical units for better understanding.

---

## 📂 Table of Contents

- [📊 Infrastructure Mapper Schema Documentation](#-infrastructure-mapper-schema-documentation)
  - [📂 Table of Contents](#-table-of-contents)
  - [🏗️ Infrastructure](#️-infrastructure)
  - [⚡ Electricity](#-electricity)
  - [💧 Water](#-water)
  - [🌱 Vegetation](#-vegetation)
  - [🏠 Buildings and Fences](#-buildings-and-fences)
  - [📡 Monitoring Stations](#-monitoring-stations)
  - [📍 Poles](#-poles)

---

## 🏗️ Infrastructure

```mermaid
erDiagram
    infrastructure_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        TEXT notes
        TEXT image
    }
    infrastructure_item {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        TEXT notes
        TEXT image
        GEOMETRY geometry
        UUID infrastructure_type_uuid FK
    }
    infrastructure_log_action {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        TEXT notes
        TEXT image
    }
    infrastructure_management_log {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        TEXT notes
        TEXT image
        TEXT condition
        UUID infrastructure_item_uuid FK
        UUID infrastructure_log_action_uuid FK
    }

    infrastructure_type ||--o{ infrastructure_item : "has many"
    infrastructure_item ||--o{ infrastructure_management_log : "managed by"
    infrastructure_log_action ||--o{ infrastructure_management_log : "logs actions"
```

---

## ⚡ Electricity

```mermaid
erDiagram
    electricity_line_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        FLOAT current_a
        FLOAT voltage_v
    }
    electricity_line {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID electricity_line_type_uuid FK
    }
    electricity_line_condition_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    electricity_line_conditions {
        UUID uuid PK
        TIMESTAMP last_update
        UUID electricity_line_uuid FK
        UUID electricity_line_condition_uuid FK
        DATE date
    }

    electricity_line_type ||--o{ electricity_line : "has many"
    electricity_line ||--o{ electricity_line_conditions : "has conditions"
    electricity_line_condition_type ||--o{ electricity_line_conditions : "defines conditions"
```

---

## 💧 Water

```mermaid
erDiagram
    water_source {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    water_polygon_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    water_polygon {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID water_source_uuid FK
        UUID water_polygon_type_uuid FK
    }
    water_point_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    water_point {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID water_source_uuid FK
        UUID water_point_type_uuid FK
    }

    water_source ||--o{ water_polygon : "provides water"
    water_polygon_type ||--o{ water_polygon : "categorizes"
    water_source ||--o{ water_point : "provides water"
    water_point_type ||--o{ water_point : "categorizes"
```

---

## 🌱 Vegetation

```mermaid
erDiagram
    plant_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
        TEXT scientific_name
    }
    vegetation_point {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID plant_type_uuid FK
    }
    pruning_activity {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        UUID vegetation_point_uuid FK
    }
    harvest_activity {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        UUID vegetation_point_uuid FK
    }

    plant_type ||--o{ vegetation_point : "has many"
    vegetation_point ||--o{ pruning_activity : "pruned by"
    vegetation_point ||--o{ harvest_activity : "harvested by"
```

---

## 🏠 Buildings and Fences

```mermaid
erDiagram
    building_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    building {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID building_type_uuid FK
    }
    fence_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    fence {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID fence_type_uuid FK
    }
    gate {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
    }
    building ||--o{ gate : "has gates"
    fence ||--o{ gate : "has gates"
```

---

## 📡 Monitoring Stations

```mermaid
erDiagram
    monitoring_station {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
    }
    readings {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        UUID monitoring_station_uuid FK
    }

    monitoring_station ||--o{ readings : "records"
```

---

## 📍 Poles

```mermaid
erDiagram
    pole_material {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    pole_function {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    pole {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID pole_material_uuid FK
        UUID pole_function_uuid FK
    }

    pole_material ||--o{ pole : "used by"
    pole_function ||--o{ pole : "used by"
```

---

Feel free to expand or modify these diagrams as needed. Let me know if you need further assistance! 😊
