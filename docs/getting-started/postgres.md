<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Load the schema into Postgres

If you already run a Postgres / PostGIS server, you can install the
Infrastructure Mapper schema into it directly &mdash; no Nix, no build
step. End result: a fully populated `gis` (or whatever you name it)
database that QGIS, web maps, and data-capture tools can read and
write against.

## Prerequisites

| Requirement | Tested against |
| --- | --- |
| **PostgreSQL** | 14 or newer |
| **PostGIS** | 3.x with topology and raster support optional |
| **`psql`** | The standard PostgreSQL client, on the machine that loads the schema |
| **`tar`** | Standard `tar(1)` to extract the release archive |

If you don't have a Postgres handy, the
[postgis/postgis Docker image] is the fastest path to one:

[postgis/postgis Docker image]: https://hub.docker.com/r/postgis/postgis

```bash
docker run --name im-pg \
  -e POSTGRES_PASSWORD=please-change-me \
  -e POSTGRES_DB=infrastructure \
  -p 5432:5432 \
  -d postgis/postgis:17-3.5
```

## 1. Download the schema

Every release on the [GitHub Releases page] publishes the schema as a
single self-contained SQL file plus per-domain slices:

[GitHub Releases page]: https://github.com/kartoza/InfrastructureMapper/releases/latest

| File pattern | What it is |
| --- | --- |
| `pg-schema-vX.Y.Z.sql` | **Everything** &mdash; extensions, meta, all 13 domains, fixtures. Apply to an empty database to bootstrap the full schema. |
| `pg-schema-NN-name-vX.Y.Z.sql` | **One domain only** &mdash; e.g. `pg-schema-07-fencing-vX.Y.Z.sql`. Self-contained; includes the extensions and meta layer plus that domain's tables and the lookup-table fixtures it needs. Pick this when you only care about, say, fences. |
| `pg-fixtures-vX.Y.Z.sql` | Data-only dump of lookup tables. Useful if you've already loaded the schema and want to refresh seed data. |
| `pg-migrations-vX.Y.Z.tar.gz` | Forward migrations from a previous baseline to this version. See [Migrations](../schema-lifecycle/migrations.md) for when to use these instead of a fresh load. |
| `schema-diff-vX.Y.Z.sql` | `migra`-generated diff vs the previous release &mdash; ALTER statements that would bring the prior version up to this one. |

```bash
# Composite (everything):
gh release download --repo kartoza/InfrastructureMapper \
  --pattern 'pg-schema-v*.sql' \
  --pattern 'pg-fixtures-v*.sql'

# Just one domain (example: fencing):
gh release download --repo kartoza/InfrastructureMapper \
  --pattern 'pg-schema-07-fencing-v*.sql'
```

## 2. Create your target database

```bash
createdb -h localhost -U postgres infrastructure
psql -h localhost -U postgres -d infrastructure \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

Adjust the host / user / database name to match your environment. The
schema only requires PostGIS &mdash; nothing else extra.

## 3. Apply the schema

The composite file is a single ordered SQL bundle &mdash; one `psql`
invocation loads everything:

```bash
DB=infrastructure
psql -v ON_ERROR_STOP=1 -h localhost -U postgres -d $DB \
  -f pg-schema-vX.Y.Z.sql
```

`ON_ERROR_STOP=1` is important &mdash; if any statement fails, the
whole load aborts rather than leaving the schema half-applied.

### Just one domain

The per-domain slices are equally self-contained &mdash; they bundle
the extensions, meta layer, that domain's tables, and the lookup-table
fixtures it needs. Loading `pg-schema-07-fencing-vX.Y.Z.sql` into an
empty database gives you a working `fence` / `fence_type` /
`fence_conditions` schema with no other domain present.

```bash
psql -v ON_ERROR_STOP=1 -h localhost -U postgres -d $DB \
  -f pg-schema-07-fencing-vX.Y.Z.sql
```

You can load several slices into the same database; they share the
extensions and meta-layer DDL idempotently (`CREATE TABLE IF NOT
EXISTS`), so re-running them after the first one is a no-op for the
shared bits.

## 4. Verify

```bash
$PSQL -c "SELECT version FROM current_schema_version;"
--  version
-- ---------
--  v0.1.0
```

A row at the version you downloaded means the baseline + every
released migration applied successfully.

## 5. Connect QGIS to your database

Once the schema is in Postgres, QGIS connects to it natively:

1. Open QGIS, open the **Browser** panel (`View &rarr; Panels &rarr;
   Browser`).
2. Right-click **PostgreSQL** &rarr; *New Connection*.
3. Fill in the connection details:

    - **Name** &mdash; any friendly label, e.g. `Infrastructure Mapper`
    - **Host** &mdash; your server hostname or IP (`localhost` for the
      Docker example above)
    - **Port** &mdash; usually `5432`
    - **Database** &mdash; `infrastructure` (or whatever you used)
    - **Authentication** &mdash; tick *Basic* and enter your username
      / password, or use a service file / Kerberos / SSL cert as
      appropriate

4. Click **Test Connection**. Green ticks mean you're in. Click
   **OK**.
5. Expand the new connection in the Browser panel. Every domain
   (`infrastructure`, `electricity`, `water`, &hellip;) shows up as a
   schema with its tables underneath.
6. **Drag any spatial table onto the canvas** to add it as a layer.
   Lookup tables appear as aspatial entries you can use for table
   joins or attribute pick-lists.

!!! tip "Editing through QGIS"
    QGIS can edit Postgres data directly (toggle the pencil icon on
    the layer). The schema's `last_update` / `last_update_by`
    columns auto-stamp on update via triggers, so per-row
    provenance is preserved without you doing anything.

## 6. (Optional) Tighten access for production

The instructions above assume a single-developer setup. If you're
deploying this to a team or to production:

- Create a dedicated PostgreSQL role for the app and grant it
  `USAGE` on the schema, `SELECT`/`INSERT`/`UPDATE` on tables, and
  `USAGE` on sequences.
- Keep the `gen_random_uuid()` default on every table &mdash; clients
  rely on it for UUID-stable sync to GeoPackages.
- Put a regular `pg_dump --clean` on a cron alongside your other
  database backups. The schema is reproducible, but your captured
  data isn't.

## What next?

- Take a snapshot of your Postgres into a GeoPackage and into the
  field &mdash; see [Field Workflow](field-workflow.md).
- When a new version of the schema is released, apply pending
  migrations to your Postgres without reloading the whole baseline
  &mdash; see [Migrations](../schema-lifecycle/migrations.md).
- Browse the [Data Model](../data-model/index.md) to see what each
  domain captures.
