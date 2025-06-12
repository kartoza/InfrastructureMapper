#!/usr/bin/env bash
echo "🪛 Running QGIS with the InfrastructureMapper profile:"
echo "--------------------------------"

nix run .#qgis-ltr --profile InfrastructureMapper
