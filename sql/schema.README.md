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
  - [🚪 Gates](#-gates)
  - [🌍 Land Use Areas](#-land-use-areas)
  - [🛣️ Roads](#️-roads)

---

## 🏗️ Infrastructure

This section describes the core infrastructure elements, including types, items, and management logs.

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

***Explanation***

- **`infrastructure_type`**: Defines the type of infrastructure (e.g., roads, bridges).
- **`infrastructure_item`**: Represents individual infrastructure items with geometry and metadata.
- **`infrastructure_log_action`**: Tracks actions performed on infrastructure (e.g., maintenance, inspections).
- **`infrastructure_management_log`**: Logs management activities for infrastructure items.

---

## ⚡ Electricity

This section covers the schema for managing electricity infrastructure, including lines, types, and conditions.

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

***Explanation***

- **`electricity_line_type`**: Defines types of electricity lines (e.g., high voltage, low voltage).
- **`electricity_line`**: Represents individual electricity lines with geometry and metadata.
- **`electricity_line_condition_type`**: Defines possible conditions for electricity lines (e.g., damaged, operational).
- **`electricity_line_conditions`**: Tracks the condition of electricity lines over time.

---

## 💧 Water

This section describes the schema for managing water infrastructure, including sources, polygons, and points.

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

***Explanation***

- **`water_source`**: Represents sources of water (e.g., rivers, reservoirs).
- **`water_polygon_type`**: Categorizes water polygons (e.g., lakes, ponds).
- **`water_polygon`**: Represents water bodies with geometry and metadata.
- **`water_point_type`**: Categorizes water points (e.g., wells, taps).
- **`water_point`**: Represents specific water points with geometry and metadata.

---

## 🌱 Vegetation

This section focuses on vegetation, including plant types, pruning, harvesting, and usage.

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
        TEXT month
    }
    harvest_activity {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        UUID vegetation_point_uuid FK
        TEXT month
    }
    plant_usage {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        UUID vegetation_point_uuid FK
        TEXT usage_type
        TEXT notes
    }
    month {
        UUID uuid PK
        TEXT name
    }

    plant_type ||--o{ vegetation_point : "has many"
    vegetation_point ||--o{ pruning_activity : "pruned by"
    vegetation_point ||--o{ harvest_activity : "harvested by"
    vegetation_point ||--o{ plant_usage : "used for"
    pruning_activity ||--|| month : "occurs in"
    harvest_activity ||--|| month : "occurs in"
```

***Explanation***

- **`plant_type`**: Defines the type of plant, including its scientific name.
- **`vegetation_point`**: Represents a specific plant's location and type.
- **`pruning_activity`**: Tracks pruning activities, including the month they occurred.
- **`harvest_activity`**: Tracks harvesting activities, including the month they occurred.
- **`plant_usage`**: Records how a plant is used (e.g., medicinal, ornamental, food) and any additional notes.
- **`month`**: Represents the month in which pruning or harvesting activities occur.

---

## 🏠 Buildings and Fences

This section describes buildings, fences, and their associated materials and conditions.

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

***Explanation***

- **`building_type`**: Defines types of buildings (e.g., residential, commercial).
- **`building`**: Represents individual buildings with geometry and metadata.
- **`fence_type`**: Defines types of fences (e.g., wooden, metal).
- **`fence`**: Represents individual fences with geometry and metadata.
- **`gate`**: Represents gates attached to buildings or fences.

---

## 📡 Monitoring Stations

This section describes monitoring stations and their associated readings.

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

***Explanation***

- **`monitoring_station`**: Represents monitoring stations with geometry and metadata.
- **`readings`**: Tracks readings recorded by monitoring stations.

---

## 📍 Poles

This section describes poles, their materials, functions, and conditions.

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

***Explanation***

- **`pole_material`**: Defines materials used for poles (e.g., wood, steel).
- **`pole_function`**: Defines functions of poles (e.g., electricity, communication).
- **`pole`**: Represents individual poles with geometry and metadata.

---

## 🚪 Gates

This section describes gates, their types, functions, materials, and conditions.

```mermaid
erDiagram
    gate_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    gate_function {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    gate_material {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    gate {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID gate_type_uuid FK
        UUID gate_function_uuid FK
    }

    gate_type ||--o{ gate : "has type"
    gate_function ||--o{ gate : "has function"
    gate_material ||--o{ gate : "made of"
```

***Explanation***

- **`gate_type`**: Defines types of gates (e.g., wooden, metal).
- **`gate_function`**: Defines functions of gates (e.g., entry, exit).
- **`gate_material`**: Defines materials used for gates (e.g., wood, steel).
- **`gate`**: Represents individual gates with geometry and metadata.

---

## 🌍 Land Use Areas

This section describes land use areas, their types, ownership, and conditions.

```mermaid
erDiagram
    landuse_area_type {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    landuse_area_owner {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }
    landuse_area {
        UUID uuid PK
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geometry
        UUID landuse_area_type_uuid FK
        UUID landuse_area_owner_uuid FK
    }

    landuse_area_type ||--o{ landuse_area : "categorizes"
    landuse_area_owner ||--o{ landuse_area : "owned by"
```

***Explanation***

- **`landuse_area_type`**: Defines types of land use areas (e.g., residential, agricultural).
- **`landuse_area_owner`**: Represents owners of land use areas.
- **`landuse_area`**: Represents individual land use areas with geometry and metadata.

---

## 🛣️ Roads

This section describes roads, their segments, connecting points, type, construction/usage status, surface material, and conditions.

```mermaid
erDiagram
    segment_type {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        VARCHAR type_name UNIQUE
        TEXT description
    }
    
    segment_status {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        VARCHAR status_name UNIQUE
        TEXT description
    }

    segment_surface {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        VARCHAR surface_name UNIQUE
        TEXT description
    }

    segment_condition {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        VARCHAR condition_name UNIQUE
        TEXT description
    }

    intersection {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        GEOMETRY geom
    }

    road {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        TEXT name
    }

    road_segment {
        SERIAL id PK
        UUID uuid UNIQUE
        TIMESTAMP last_update
        TEXT last_update_by
        INT segment_number UNIQUE
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
    }

    segment_type ||--o{ road_segment : "defines type"
    segment_status ||--o{ road_segment : "defines status"
    segment_surface ||--o{ road_segment : "defines surface"
    segment_condition ||--o{ road_segment : "defines condition"
    intersection ||--o{ road_segment : "as start node"
    intersection ||--o{ road_segment : "as end node"
    road ||--o{ road_segment : "has segments"
```

***Explanation***

- **`segment_type`**: Defines the classification of road segments (e.g., National, Main Road, Gravel Road).
- **`segment_status`**: Describes the current status of road segments (e.g., In Use, Planned, Under Construction).
- **`segment_surface`**: Specifies the surface material of road segments (e.g., Asphalt, Gravel, Dirt).
- **`segment_condition`**: Records the current condition of road segments (e.g., Good, Poor, Flooded, Under Repair).
- **`intersection`**: Represents physical nodes (points) where road segments begin, end, or connect.
- **`road`**: Represents logical roads, typically composed of one or more connected road segments.
- **`road_segment`**: Represents physical sections of a road, linking two intersections and holding detailed metadata including type, status, surface, and condition.

---
