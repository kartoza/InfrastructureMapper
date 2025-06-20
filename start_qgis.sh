#!/usr/bin/env bash
echo "🪛 Running QGIS with the InfrastructureMapper profile:"
echo "--------------------------------"

# This is the new way, using Ivan Mincis nix spatial project and a flake
# see flake.nix for implementation details
nix run .#default -- --profile InfrastructureMapper
