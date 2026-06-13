<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# CI &amp; Pre-commit

The same checks run locally as a pre-commit hook and on every PR in CI.
There's no "the CI has stricter rules" gotcha: if it passes locally, it
passes on the PR.

## The immutability hook

`scripts/check_schema_immutability.sh` is the load-bearing guardrail of
the whole lifecycle. It enforces one rule:

> Once a baseline file or a frozen `vX.Y.Z.sql` migration has shipped,
> it cannot be modified, only superseded by a new migration.

The hook diffs the working tree against `BASE_REF` (the merge base with
`main`, normally) and fails if any of these files have changed:

- `sql/0-meta.sql`
- `sql/extensions.sql`
- `sql/fixtures.sql`
- `sql/1-infrastructure.sql` … `sql/13-roads.sql`
- `sql/migrations/pg/vX.Y.Z.sql`
- `sql/migrations/gpkg/vX.Y.Z.sql`

`sql/migrations/{pg,gpkg}/UNRELEASED.sql` is *explicitly excluded* &mdash;
that's the staging area, edits there are the entire point.

### Bootstrap-aware exemption

The hook itself was added in PR #56, which had to modify several baseline
files to get them to a known-good starting state. To survive its own
introduction, the hook checks whether `scripts/check_schema_immutability.sh`
existed in `BASE_REF`:

- **Hook absent from BASE_REF** → bootstrap mode, skip the immutability check.
- **Hook present in BASE_REF** → enforce normally.

This is a one-time exemption that took effect on the PR that added the
hook and has been enforcing strictly on every PR since.

## Other pre-commit hooks

The full pre-commit suite (run via `pre-commit run --all-files` or
automatically on `git commit`):

| Hook | What it checks |
|---|---|
| `check-schema-immutability` | The rule above. |
| `check-migration-pairs` | Every `pg/X.sql` has a matching `gpkg/X.sql` and vice versa. |
| `check-migration-annotations` | Every statement in a migration has an `Issue-NNN:` prefix. |
| `sqlfluff` | SQL style (Postgres dialect, plus a GPKG-aware profile for the SQLite files). |
| `black` | Python formatting for the build/migration scripts. |
| `ruff` | Python lint. |
| `markdownlint` | Markdown style for docs and READMEs. |
| `cspell` | Spell-check, with the project dictionary in `cspell.config.yaml`. |
| `reuse` | SPDX license headers on every source file. |

All the tools are pinned to the same versions in the flake and in CI, so
there's no "works on my machine, fails in CI because of a black 24 vs 25
formatting change" surprise.

## CI workflow shape

`.github/workflows/ci.yml`:

```yaml
- uses: DeterminateSystems/nix-installer-action@v22
- run: nix develop --command pre-commit run --all-files
- run: nix develop --command ./scripts/check_schema_immutability.sh
- run: nix develop --command ./scripts/build_gpkg.sh
- run: nix develop --command ./scripts/run_tests.sh
```

Every step shells through `nix develop --command`, so the tool versions
are exactly the ones in `flake.lock`. CI doesn't `pip install` anything
on top of the Nix-provided environment &mdash; that's a project rule, not
just a defensive measure.

## Why no magic-nix-cache

Earlier iterations used `DeterminateSystems/magic-nix-cache-action` to
speed up Nix evaluations between CI runs. It was dropped because it
introduced version-skew failures that were significantly more painful than
the 30&ndash;90 seconds of evaluation it saved. CI is currently
"cold Nix every run", and that's deliberate &mdash; the determinism is
worth more than the speed.

## Local equivalents

```bash
# Run the full pre-commit suite locally:
pre-commit run --all-files

# Just the immutability hook:
./scripts/check_schema_immutability.sh

# Just the migration-pairing hook:
./scripts/check_migration_pairs.sh
```

All three need `nix develop` to be active so they pick up the pinned
tool versions.
