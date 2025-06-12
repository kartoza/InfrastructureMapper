#!/usr/bin/env bash
echo "🪛 Running QGIS with the InfrastructureMapper profile:"
echo "--------------------------------"
echo "Do you want to enable debug mode?"

# This is the new way, using Ivan Mincis nix spatial project and a flake
# see flake.nix for implementation details
nix run .#default -- qgis --profile InfrastructureMapper
