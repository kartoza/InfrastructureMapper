<!-- SPDX-FileCopyrightText: Tim Sutton -->
<!-- SPDX-License-Identifier: MIT -->
# Developer Guide

Everything you need to work on Infrastructure Mapper itself &mdash; from
spinning up the Nix devshell, through the convenience scripts, to the
contribution flow.

<div class="grid cards" markdown>

-   :simple-nixos:{ .lg .middle } __The Nix Flake__

    ---

    What's in the devshell, why everything is pinned, and how to add a new
    dependency without breaking determinism.

    [:octicons-arrow-right-24: The flake](nix-flake.md)

-   :material-script-text:{ .lg .middle } __Scripts &amp; Apps__

    ---

    Every `scripts/*` entry point and its matching `nix run .#…` app, with
    what each one actually does.

    [:octicons-arrow-right-24: Browse scripts](scripts.md)

-   :material-file-tree:{ .lg .middle } __Project Structure__

    ---

    Top-level layout, why files live where they do, and the load order
    between `sql/`, `sql/migrations/`, and the runners.

    [:octicons-arrow-right-24: Tree map](project-structure.md)

-   :material-source-pull:{ .lg .middle } __Contributing__

    ---

    Branch from main, write a paired migration, annotate with
    `Issue-NNN:`, get the pre-commit suite green, open a PR.

    [:octicons-arrow-right-24: Contribution flow](contributing.md)

</div>
