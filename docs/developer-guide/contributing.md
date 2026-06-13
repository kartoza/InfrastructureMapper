<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Contributing

We welcome bug fixes, schema migrations, doc improvements, and feature
work. This page is the contribution flow specific to Infrastructure Mapper
&mdash; if you've never contributed to an open-source project at all,
GitHub's [First Contributions](https://github.com/firstcontributions/first-contributions)
walk-through is a friendlier starting point.

## Before you start

- Pick (or open) an issue. Every schema change ends up annotated with an
  `Issue-NNN:` prefix, so the issue number is the entry point.
- Read the relevant page in [Data Model](../data-model/index.md) and
  [Schema Lifecycle](../schema-lifecycle/index.md). The schema has
  conventions (naming, units, lookup tables) that aren't intuitive without
  a quick skim.
- Have Nix installed. The dev shell is the only supported environment.

## The branch flow

```bash
git clone git@github.com:kartoza/InfrastructureMapper.git
cd InfrastructureMapper
nix develop
git checkout -b feature/short-description
```

Branch names: `feature/<slug>`, `fix/<slug>`, `docs/<slug>`,
`chore/<slug>`. Issue numbers in the slug are welcome but not required &mdash;
they belong in the commit message and the migration annotation.

## Making a schema change

The unhappy path for new contributors is "I edited `sql/4-vegetation.sql`
and the pre-commit hook screamed at me." It will. Baseline files are
immutable.

Instead:

1. Edit `sql/migrations/pg/UNRELEASED.sql` &mdash; add your statements.
2. Edit `sql/migrations/gpkg/UNRELEASED.sql` &mdash; mirror the same change
   in SQLite/GPKG dialect.
3. Prefix every statement (or logical block) with `-- Issue-NNN:`.
4. Run `nix run .#build-gpkg` to verify your changes build cleanly from a
   fresh baseline.
5. Run `pre-commit run --all-files`.

See [Migrations](../schema-lifecycle/migrations.md) for the dialect
differences between PG and GPKG.

## Making a docs change

1. Edit the relevant Markdown file under `docs/`.
2. `nix run .#docs-serve` to preview at <http://127.0.0.1:8000>.
3. `nix run .#docs-build` (which runs `mkdocs build --strict`) to catch
   broken links before opening the PR.

### Data-model pages — what's hand-written, what's regenerated

Each capture domain has a top-level `sql/N-domain.sql` baseline file
and a matching `docs/data-model/NN-domain.md` page. Every page has
three parts:

1. **Narrative** &mdash; what the domain models and how its tables
   relate.
2. **Mermaid ERD** &mdash; visual diagram of the domain's tables and
   foreign keys.
3. **Schema Reference** &mdash; the auto-generated materialised view
   of the current schema (baseline + all applied PG migrations).

The narrative and mermaid diagram at the top are hand-written, just
like commit messages or architecture notes. The **Schema Reference**
block at the bottom &mdash; delimited by
`<!-- SCHEMA-REFERENCE-START ... -->` markers &mdash; is rebuilt from
a fresh reference Postgres database every time the Docs CI workflow
runs.

If you change the schema, you don't touch the Schema Reference by
hand; you write a migration, and the next push to `main` rebuilds it
for you.

## Coding standards

| Domain | Tool | What it enforces |
|---|---|---|
| Python | `black` | Formatting. Line length 88. |
| Python | `ruff` | Lint. Unused imports, undefined names. |
| Bash | `shfmt` | Formatting. 4-space indent. |
| Bash | `shellcheck` | Lint. Quote your `$variables`. |
| SQL | `sqlfluff` | Postgres dialect for `sql/*.sql` and `sql/migrations/pg/*.sql`; SQLite dialect for `sql/migrations/gpkg/*.sql`. UPPER-case keywords. |
| Markdown | `markdownlint-cli` | Sensible defaults. Long lines and inline HTML allowed. |
| Spelling | `cspell` | Custom dictionary in `cspell.config.yaml`. Add project terms there, not inline. |
| Licensing | `reuse` | Every source file has SPDX-FileCopyrightText + SPDX-License-Identifier. |

The pre-commit suite runs all of the above. It's also what CI runs &mdash;
no surprises between local and PR.

## SQL naming conventions

These predate the project's automation, so the linters won't catch
violations but reviewers will:

- **Singular table names**: `electricity_line`, not `electricity_lines`.
- **snake_case**: `electricity_line_condition`, not `ElectricityLineCondition`.
- **Lookup tables** are lowercase, singular, and named for the attribute
  they bound: `electricity_line_voltage`, `vegetation_condition`.
- **Units in column names** for length/depth/area: `crown_radius_m`,
  `bole_circumference_cm`. Amperes for current (`current_a`), volts for
  voltage (`voltage_v`).
- **Standard columns** on every table: `uuid` (stable cross-store
  identifier), `last_update`, `last_update_by`.

ERD conventions (see [Data Model](../data-model/index.md) pages for the
mermaid diagrams):

| Colour | Used for |
|---|---|
| Grey | `uuid`, `last_update`, `last_update_by` |
| Black | Geometry columns (placed above the grey trio) |
| Green | Foreign keys (always last) |
| Blue | Junction/association tables, constraints |

## Commit messages

```text
<Type> <short imperative summary>

Optional longer body. Wrap at 72 cols.

Fixes #42
```

Types: `Fix`, `Add`, `Update`, `Remove`, `Refactor`, `Docs`, `Chore`.

`Fixes #N` (or `Closes #N`) in the body auto-closes the linked issue on
merge. Use that &mdash; reviewers shouldn't have to hunt for the issue.

## Opening the PR

`gh pr create` works from inside the dev shell. Title and body conventions:

- **Title**: same shape as the commit subject. Under 70 chars.
- **Body**: a `## Summary` with 1-3 bullets and a `## Test plan` with a
  checklist of what you verified. Reference the issues this fixes.

CI runs the full pre-commit suite + the immutability hook + a fresh
GeoPackage build + the test suite. A green CI on a PR is the precondition
for review.

## Code of Conduct

Be kind, be specific, be patient. The full text is at
[Code of Conduct](../about/code-of-conduct.md) &mdash; it's the
Contributor Covenant v2.1.

## Need help?

Open a Discussion on the repo, or email
[info@kartoza.com](mailto:info@kartoza.com).
