---
marp: true
theme: infrastructure
class: _lead
header: 'Infrastructure Mapper'
footer: 'Kartoza (Pty) Ltd. 2025'
---
<!-- cspell:ignore landuse -->
# Infrastructure Mapper

A spatial database for managing infrastructure-related data.

![bg contain left](../img/infrastructure-mapper.gif)

---

## What is it?

1. a [SQL Schema](sql/schema.README.md) for PostgreSQL,
2. a set of fixtures to load that schema with default values (particularly for lookup tables)
3. a set of QGIS forms and layer styles for visualising the data

![Logo](../img/logo-horizontal.png)

---

## Models 1

|  |  |
|------|-------------|
| <img src="../img/electricity.png" alt="Electricity" width="64" height="64"> | [Electricity](../sql/2-electricity.md) infrastructure such as power lines, transformers, and substations. |
| <img src="../img/infrastructure.png" alt="Infrastructure" width="64" height="64"> | General [infrastructure](../sql/1-infrastructure.md) elements like bridges, dams, and towers. |
| <img src="../img/water.png" alt="Water" width="64" height="64"> | [Water](../sql/3-water.md)-related infrastructure including pipes, tanks, and pumps. |
| <img src="../img/vegetation.png" alt="Vegetation" width="64" height="64"> | [Vegetation](../sql/4-vegetation.md) features such as trees, hedges, and planted areas. |
| <img src="../img/monitoring.png" alt="Monitoring" width="64" height="64"> | [Monitoring](../sql/5-monitoring.md) devices and their observations (e.g., sensors, cameras). |
| <img src="../img/buildings.png" alt="Buildings" width="64" height="64"> | [Buildings](../sql/6-buildings.md) and associated structures. |

---

## Models 2 (ctd.)

|  |  |
|------|-------------|
| <img src="../img/fencing.png" alt="Fencing" width="64" height="64"> | [Fencing](../sql/7-fencing.md) and enclosure features, including standalone gates. |
| <img src="../img/point-of-interest.png" alt="POI" width="64" height="64"> | [Points of Interest](./sql/8-poi.md) (POI) for notable locations or features. |
| <img src="../img/landuse-areas.png" alt="Land use" width="64" height="64"> | [Land use areas](../sql/9-landuse.md) such as agricultural, residential, or conservation zones. |
| <img src="../img/gates.png" alt="Gates" width="64" height="64"> | [Gates](../sql/10-gates.md) as access points for properties or enclosures. |
| <img src="../img/poles.png" alt="Poles" width="64" height="64"> | [Poles](../sql/11-poles.md) for lighting, signage, or utility support. |
| <img src="../img/food-services.png" alt="Culinary" width="64" height="64"> | [Culinary facilities](./sql/12-culinary.md) like kitchens, canteens, and food storage. |

---

## Models 3 (ctd.)

|  |  |
|------|-------------|
| <img src="../img/roads.png" alt="Roads" width="64" height="64"> | [Roads](../sql/13-roads.md), tracks, and paths for transportation infrastructure. |
