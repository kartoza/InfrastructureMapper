<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Data Model

The Infrastructure Mapper schema is split into capture domains. Each is
defined by a top-level `sql/N-domain.sql` baseline file and rendered into a
mkdocs page below. Every page has three parts:

1. **Narrative** &mdash; what the domain models and how its tables relate.
2. **Mermaid ERD** &mdash; visual diagram of the domain's tables and foreign keys.
3. **Schema Reference** &mdash; the auto-generated materialised view of the
   current schema (baseline + all applied PG migrations). This is regenerated
   on every push to `main` by the Docs CI workflow.

<div class="grid cards kz-domain-grid" markdown>

-   ![Infrastructure](../assets/brand/icons/infrastructure.svg){ .no-lightbox .kz-domain-img }

    __Infrastructure__

    Furniture, signage, generic point items.

    [:octicons-arrow-right-24: Open](01-infrastructure.md)

-   ![Electricity](../assets/brand/icons/electricity.svg){ .no-lightbox .kz-domain-img }

    __Electricity__

    Lines, conditions, voltage profiles.

    [:octicons-arrow-right-24: Open](02-electricity.md)

-   ![Water](../assets/brand/icons/water.svg){ .no-lightbox .kz-domain-img }

    __Water__

    Sources, points, lines, polygons.

    [:octicons-arrow-right-24: Open](03-water.md)

-   ![Vegetation](../assets/brand/icons/vegetation.svg){ .no-lightbox .kz-domain-img }

    __Vegetation__

    Plants, growth, harvests, prunings.

    [:octicons-arrow-right-24: Open](04-vegetation.md)

-   ![Monitoring](../assets/brand/icons/monitoring.svg){ .no-lightbox .kz-domain-img }

    __Monitoring__

    Stations, equipment, readings.

    [:octicons-arrow-right-24: Open](05-monitoring.md)

-   ![Buildings](../assets/brand/icons/buildings.svg){ .no-lightbox .kz-domain-img }

    __Buildings__

    Footprints, materials, conditions.

    [:octicons-arrow-right-24: Open](06-buildings.md)

-   ![Fencing](../assets/brand/icons/fencing.svg){ .no-lightbox .kz-domain-img }

    __Fencing__

    Lines, types, conditions.

    [:octicons-arrow-right-24: Open](07-fencing.md)

-   ![Points of Interest](../assets/brand/icons/poi.svg){ .no-lightbox .kz-domain-img }

    __Points of Interest__

    Bridges, ruins, landmarks.

    [:octicons-arrow-right-24: Open](08-poi.md)

-   ![Land Use](../assets/brand/icons/landuse.svg){ .no-lightbox .kz-domain-img }

    __Land Use__

    Areas, owners, ownership types.

    [:octicons-arrow-right-24: Open](09-landuse.md)

-   ![Gates](../assets/brand/icons/gates.svg){ .no-lightbox .kz-domain-img }

    __Gates__

    Hinge points, materials, links to fences and buildings.

    [:octicons-arrow-right-24: Open](10-gates.md)

-   ![Poles](../assets/brand/icons/poles.svg){ .no-lightbox .kz-domain-img }

    __Poles__

    Telecom, lighting, flag and electric poles.

    [:octicons-arrow-right-24: Open](11-poles.md)

-   ![Culinary Facilities](../assets/brand/icons/culinary.svg){ .no-lightbox .kz-domain-img }

    __Culinary Facilities__

    Restaurants, cafes, prices, facilities.

    [:octicons-arrow-right-24: Open](12-culinary.md)

-   ![Roads](../assets/brand/icons/roads.svg){ .no-lightbox .kz-domain-img }

    __Roads__

    Roads, segments, intersections, conditions.

    [:octicons-arrow-right-24: Open](13-roads.md)

</div>

## What's regenerated, what's hand-curated

The narrative and mermaid diagram at the top of each component page are
hand-written, just like commit messages or architecture notes. The
**Schema Reference** block at the bottom &mdash; delimited by
`<!-- SCHEMA-REFERENCE-START ... -->` markers &mdash; is rebuilt from a
fresh reference Postgres database every time the docs workflow runs.

If you change the schema, you don't touch the Schema Reference by hand;
you write a migration, and the next push to `main` rebuilds it for you.
