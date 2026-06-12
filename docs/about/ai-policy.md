<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# AI Assistance Policy

Infrastructure Mapper uses AI coding assistants &mdash; primarily Claude
Code &mdash; as part of the regular development workflow. This page
documents *how* they are used so contributors, downstream consumers, and
auditors know what to expect from the codebase.

## What AI is used for

- **Boilerplate and scaffolding**: docs page skeletons, mkdocs config,
  flake.nix conveniences.
- **Test generation**: drafting unit tests that the human reviewer then
  validates and prunes.
- **Migration drafting**: proposing a `pg/` migration paired with its
  `gpkg/` counterpart, reviewed line-by-line before commit.
- **Documentation**: hand-written narrative is often drafted by an
  assistant and edited by the maintainer.
- **CI debugging**: investigating failing workflow runs, proposing fixes.

## What AI is not used for

- **The schema itself**: every table, column, and constraint in `sql/` is
  reviewed by the maintainer with domain knowledge of the field-capture
  context. Schemas are decisions, not boilerplate.
- **Final code review**: AI-suggested PRs are still reviewed by a human
  before merge.
- **Security-relevant defaults**: SPDX licensing, immutability hooks, and
  the migration runners are written and reviewed with human judgement
  about what's safe to ship.

## Disclosure

When an entire commit was drafted by an AI assistant, the commit message
does **not** carry a "Co-Authored-By" assistant trailer &mdash; that's a
project rule. The reasoning: the human committer is the responsible party
under DCO, and a trailer doesn't change that. The git history reads as
human-authored because the human accepted, edited, and shipped the change.

This is a deliberate choice and contributors are expected to follow it.
If you used an AI assistant to draft your PR, the PR description is the
right place to say so &mdash; reviewers may want to weight their review
differently.

## What we will never do with AI

- Auto-merge AI-generated PRs.
- Run AI-generated migrations against production databases without a
  human-reviewed dry-run.
- Allow AI to choose schema version bumps. `scripts/release.sh --bump
  <type>` is a human decision every time.
- Push to `main` from an AI session without explicit user permission.
- Bypass pre-commit hooks (`--no-verify`) from an AI session.

The last two are enforced by repository conventions and CI; the first two
are policy.

## Why publish this

A schema project is a contract with everyone downstream of it. If the
contract is partly drafted by an AI, downstream consumers deserve to know
the review boundary &mdash; not because AI assistance is shameful, but
because *transparency about how decisions get made is part of trustworthy
infrastructure software*.

If you're a downstream consumer and you'd like more detail about a
specific change's provenance, the git log links every change to its issue
and the issue typically captures the decision context.
