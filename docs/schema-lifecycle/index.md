<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Schema Lifecycle

The schema is versioned. `VERSION` at the repo root holds the current semver;
every PG and GeoPackage database carries a `schema_migrations` table and a
`current_schema_version` view baked in by `sql/0-meta.sql`. Together they let
the project evolve the data model without losing track of what's in production.

```sql
SELECT version FROM current_schema_version;
-- → v0.1.0
```

<div class="grid cards" markdown>

-   :material-tag-multiple:{ .lg .middle } __Versioning__

    ---

    How `VERSION`, `schema_migrations`, and the baseline relate. Why semver,
    why a view, and where the source of truth lives.

    [:octicons-arrow-right-24: How versioning works](versioning.md)

-   :material-source-branch:{ .lg .middle } __Migrations__

    ---

    `Issue-NNN` annotations, paired PG/GPKG dialects, `UNRELEASED.sql`, and
    the strict-sequential runners.

    [:octicons-arrow-right-24: Writing a migration](migrations.md)

-   :material-rocket:{ .lg .middle } __Release Process__

    ---

    What `scripts/release.sh` does, what the Release GitHub Action
    publishes, and how to consume a release.

    [:octicons-arrow-right-24: Cut a release](release.md)

-   :material-shield-check:{ .lg .middle } __CI &amp; Pre-commit__

    ---

    How the immutability hook is enforced both locally and on PRs, and the
    flake-pinned tool versions that keep CI deterministic.

    [:octicons-arrow-right-24: The CI gates](ci.md)

</div>
