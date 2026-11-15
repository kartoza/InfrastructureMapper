#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Generate qgis_projects/InfrastructureMapper.qgz from the built GeoPackage.

Loads every real table in the target .gpkg as a layer, organised into one
layer-tree group per sql/N-domain.sql file (with a nested "Lookup Tables"
sub-group for that domain's non-spatial tables), defines every relation
already registered in the GPKG's own gpkgext_relations table (see
sql/gpkg_relations.sql) as a QgsRelation, gives lookup FK fields a
ValueRelation pick-list widget, gives entity-relation parents a drag-and-drop
form with an embedded panel listing their related child records, applies a
Kartoza-brand-palette renderer per layer, and populates layer metadata from
the schema's own COMMENT ON TABLE/COLUMN text.

Requires: the target .gpkg already built (`nix run .#build-gpkg`), Postgres
reachable (for metadata comments - reuses scripts/generate_schema_docs.py's
reference-DB machinery). Runs as a plain standalone script - no GUI, no
QApplication, no canvas/OpenGL - via `QgsApplication([], False)` (second arg
`False` = GUI disabled), which is exactly what headless PyQGIS scripting is
for and sidesteps needing any display/GLX at all. Needs `qgis.core`'s own
Qt binding importable: `nix run .#generate-project` runs this script with
a python built from QGIS 4.x's own python3 override plus its exact
pythonBuildInputs (pyqt6, gdal, psycopg2, sip, etc - mainline nixpkgs'
`qgis`, Qt6-based, sourced from a separate `nixpkgs-unstable` flake input
scoped to just this script - see flake.nix's `qgis4Python`/
`mkQgis4PythonApp`), rather than this script guessing or assembling a
separate Qt binding itself.

Usage:
    scripts/generate_project.py [--gpkg PATH] [--out PATH]
    (or just: nix run .#generate-project)
"""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import sqlite3
import sys
from typing import Dict, List, Optional, Tuple

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))

import generate_schema_docs as schema_docs  # noqa: E402  pylint: disable=wrong-import-position

# isort: off
# pylint: disable=wrong-import-position,import-error
from qgis.core import (
    QgsApplication,
    QgsAttributeEditorContainer,
    QgsAttributeEditorField,
    QgsAttributeEditorRelation,
    QgsCategorizedSymbolRenderer,
    QgsEditFormConfig,
    QgsEditorWidgetSetup,
    QgsFillSymbol,
    QgsLayerMetadata,
    QgsLineSymbol,
    QgsMarkerSymbol,
    QgsProject,
    QgsRelation,
    QgsRendererCategory,
    QgsSimpleLineSymbolLayer,
    QgsSingleSymbolRenderer,
    QgsVectorLayer,
)

# isort: on

DEFAULT_GPKG = ROOT / "gpkg" / "KartozaInfrastructureMapper.gpkg"
DEFAULT_OUT = ROOT / "qgis_projects" / "InfrastructureMapper.qgz"
BRAND_TOKENS_PATH = ROOT / "docs" / "assets" / "brand" / "tokens.json"

AUDIT_COLUMNS = {"id", "uuid", "last_update", "last_update_by", "description"}

# One hue + human title per sql/N-domain.sql file, keyed by filename stem.
# Not derivable from the schema itself - this is this script's own design
# data, unlike the table->domain mapping below (which is derived).
DOMAIN_STYLE = {
    "1-infrastructure": ("Infrastructure", "kartoza.grey"),
    "2-electricity": ("Electricity", "kartoza.amber"),
    "3-water": ("Water", "kartoza.blue"),
    "4-vegetation": ("Vegetation", "status.success"),
    "5-monitoring": ("Monitoring", "kartoza.grey"),
    "6-buildings": ("Buildings", "kartoza.grey"),
    "7-fencing": ("Fencing", "kartoza.grey"),
    "8-poi": ("Points of Interest", "kartoza.amber"),
    "9-landuse": ("Landuse", "kartoza.amber"),
    "10-gates": ("Gates", "kartoza.grey"),
    "11-poles": ("Poles", "kartoza.grey"),
    "12-culinary": ("Culinary", "kartoza.amber"),
    "13-roads": ("Roads", "surface.cloud"),
}

# Tables that only exist in sql/migrations/pg/UNRELEASED.sql, not yet in a
# baseline sql/N-domain.sql file, so they can't be found by _component_files().
EXTRA_TABLE_DOMAINS = {
    "road_segment_photo": "13-roads",
}

FK_RE = re.compile(r"FOREIGN KEY\s*\((\w+)\)\s*REFERENCES\s+(\w+)\s*\(")

# road_segment's own design data: real-world road hierarchy, widest first.
# Not derivable from the schema - segment_type.type_name is free text.
ROAD_TYPE_WIDTHS_MM = {
    "National": 1.8,
    "Main Road": 1.4,
    "Street": 1.0,
    "Gravel Road": 0.8,
    "Private Road": 0.6,
    "Footpath": 0.4,
}
DEFAULT_ROAD_WIDTH_MM = 0.6
# Road types at/above this width get a casing (border) + dashed centreline;
# narrower types render as a single plain line.
ROAD_CASING_MIN_WIDTH_MM = 1.2


def load_brand_colors() -> Dict[str, str]:
    """Load the Kartoza colour tokens.

    Returns:
        Mapping of token name (e.g. ``"kartoza.blue"``) to hex colour.
    """
    data = json.loads(BRAND_TOKENS_PATH.read_text(encoding="utf-8"))
    return data["color"]


def table_domains() -> Dict[str, str]:
    """Map every baseline table name to its owning domain file stem.

    Returns:
        Mapping of table name to a key into ``DOMAIN_STYLE`` (e.g.
        ``"13-roads"``), covering baseline tables plus the small
        ``EXTRA_TABLE_DOMAINS`` override for not-yet-released ones.
    """
    mapping: Dict[str, str] = {}
    for f in schema_docs._component_files():  # pylint: disable=protected-access
        for t in schema_docs.extract_table_names(f):
            mapping[t] = f.stem
    mapping.update(EXTRA_TABLE_DOMAINS)
    return mapping


def real_layer_tables(gpkg_path: pathlib.Path) -> List[Tuple[str, str]]:
    """List every real (non-GPKG-system) table to load as a layer.

    Args:
        gpkg_path: Path to the built ``.gpkg`` file.

    Returns:
        A list of ``(table_name, data_type)`` pairs, ``data_type`` being
        ``"features"`` (has geometry) or ``"attributes"`` (doesn't), as
        recorded in the GeoPackage's own ``gpkg_contents``.
    """
    conn = sqlite3.connect(str(gpkg_path))
    try:
        rows = conn.execute(
            "SELECT table_name, data_type FROM gpkg_contents"
        ).fetchall()
    finally:
        conn.close()
    skip_exact = {"schema_migrations", "current_schema_version", "gpkgext_relations"}
    skip_prefix = ("gpkg_", "rtree_", "rel_")
    return [
        (name, data_type)
        for name, data_type in rows
        if name not in skip_exact and not name.startswith(skip_prefix)
    ]


def read_relations(gpkg_path: pathlib.Path) -> List[Dict]:
    """Read every relation already registered in the built GeoPackage.

    Args:
        gpkg_path: Path to the built ``.gpkg`` file.

    Returns:
        A list of dicts with keys ``base_table_name``, ``base_primary_column``,
        ``related_table_name``, ``related_primary_column``, ``relation_name``,
        ``mapping_table_name`` - one per row of ``gpkgext_relations``
        (populated by ``sql/gpkg_relations.sql`` during the build).
    """
    conn = sqlite3.connect(str(gpkg_path))
    conn.row_factory = sqlite3.Row
    try:
        rows = conn.execute(
            "SELECT base_table_name, base_primary_column, related_table_name, "
            "related_primary_column, relation_name, mapping_table_name "
            "FROM gpkgext_relations"
        ).fetchall()
    finally:
        conn.close()
    return [dict(r) for r in rows]


def find_fk_column(holder_info: Dict, target_table: str) -> Optional[str]:
    """Find the column on an introspected table that FKs to another table.

    Args:
        holder_info: ``introspect_table()`` result for the candidate FK holder.
        target_table: Name of the table the FK should reference.

    Returns:
        The FK column name, or ``None`` if ``holder_info`` has no foreign key
        referencing ``target_table``.
    """
    for c in holder_info["constraints"]:
        if c["type"] != "f":
            continue
        m = FK_RE.search(c["def"])
        if m and m.group(2) == target_table:
            return m.group(1)
    return None


def display_column(table_info: Dict) -> str:
    """Pick the column that best represents a lookup row to a human.

    Args:
        table_info: ``introspect_table()`` result for a lookup table.

    Returns:
        The first column name that isn't an audit/PK column, falling back
        to ``"uuid"`` if nothing else is available.
    """
    for c in table_info["columns"]:
        if c["name"] not in AUDIT_COLUMNS:
            return c["name"]
    return "uuid"


def humanize(name: str) -> str:
    """Turn a snake_case identifier into a human-readable title.

    Args:
        name: A snake_case table or column name.

    Returns:
        Title-cased words separated by spaces.
    """
    return " ".join(w.capitalize() for w in name.split("_"))


def build_project(  # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    gpkg_path: pathlib.Path, out_path: pathlib.Path
) -> None:
    """Build and save the QGIS project.

    A single procedural pipeline (load layers, wire relations, style) rather
    than many small functions - there's no meaningful sub-unit to extract
    that wouldn't just be "this one step, called once".

    Args:
        gpkg_path: Path to the built ``.gpkg`` file to load layers from.
        out_path: Path to save the generated ``.qgz`` project to.
    """
    qgs = QgsApplication([], False)
    qgs.initQgis()
    try:
        project = QgsProject.instance()
        root = project.layerTreeRoot()
        colors = load_brand_colors()
        domains = table_domains()
        tables = real_layer_tables(gpkg_path)
        relations = read_relations(gpkg_path)

        layers: Dict[str, "QgsVectorLayer"] = {}
        infos: Dict[str, Dict] = {}
        groups = {}
        project_crs_set = False

        for stem, (title, _hue) in DOMAIN_STYLE.items():
            groups[stem] = root.insertGroup(len(groups), title)

        # Pass 1: create every layer, set metadata, place in its group.
        for table, data_type in tables:
            info = schema_docs.introspect_table(table)
            infos[table] = info

            layer = QgsVectorLayer(
                f"{gpkg_path}|layername={table}", humanize(table), "ogr"
            )
            layers[table] = layer

            # Project CRS follows the GPKG's own layers rather than
            # defaulting to WGS84 - take it from the first spatial layer
            # that has one (lookup tables are aspatial and skip this).
            if not project_crs_set and layer.crs().isValid():
                project.setCrs(layer.crs())
                project_crs_set = True

            md = QgsLayerMetadata()
            md.setIdentifier(table)
            md.setTitle(humanize(table))
            md.setAbstract(info["comment"] or f"{humanize(table)} layer.")
            md.setLicenses(["MIT"])
            contact = QgsLayerMetadata.Contact()
            contact.organization = "Kartoza"
            md.setContacts([contact])
            layer.setMetadata(md)

            for col in info["columns"]:
                if not col["comment"]:
                    continue
                idx = layer.fields().indexOf(col["name"])
                if idx >= 0:
                    layer.setFieldAlias(idx, col["comment"][:120])

            # Drag-and-drop form, "General" tab first - built here, before
            # pass 2 appends any relation tabs, since
            # QgsAttributeEditorContainer only supports appending children
            # (no insert-at-index), so creation order is the only way to
            # control tab order.
            cfg = layer.editFormConfig()
            cfg.setLayout(QgsEditFormConfig.TabLayout)
            general = QgsAttributeEditorContainer(
                "General", cfg.invisibleRootContainer()
            )
            for idx, field in enumerate(layer.fields()):
                general.addChildElement(
                    QgsAttributeEditorField(field.name(), idx, general)
                )
            cfg.invisibleRootContainer().addChildElement(general)

            project.addMapLayer(layer, False)
            stem = domains.get(table)
            target = groups.get(stem, groups["1-infrastructure"])
            if data_type != "features":
                if target.findGroup("Lookup Tables") is None:
                    target.addGroup("Lookup Tables")
                target = target.findGroup("Lookup Tables")
            target.addLayer(layer)

        # Pass 2: relations + widgets + cartography (needs every layer to exist).
        for rel in relations:
            base_table = rel["base_table_name"]
            related_table = rel["related_table_name"]
            if base_table not in infos or related_table not in infos:
                continue  # layer wasn't loaded (shouldn't happen, but don't crash)

            fk_on_base = find_fk_column(infos[base_table], related_table)
            fk_on_related = (
                None if fk_on_base else find_fk_column(infos[related_table], base_table)
            )

            if fk_on_base:
                # Lookup-shaped: base holds the FK into related. Plain pick-list,
                # no embedded subform.
                setup = QgsEditorWidgetSetup(
                    "ValueRelation",
                    {
                        "Layer": layers[related_table].id(),
                        "Key": rel["related_primary_column"],
                        "Value": display_column(infos[related_table]),
                        "AllowMulti": False,
                        "AllowNull": True,
                        "OrderByValue": True,
                    },
                )
                idx = layers[base_table].fields().indexOf(fk_on_base)
                if idx >= 0:
                    layers[base_table].setEditorWidgetSetup(idx, setup)
            elif fk_on_related:
                # Entity-shaped: related holds the FK back to base. QgsRelation's
                # "referencing" side is whoever holds the FK column.
                relation = QgsRelation()
                relation.setId(rel["mapping_table_name"])
                relation.setName(humanize(related_table))
                relation.setReferencingLayer(layers[related_table].id())
                relation.setReferencedLayer(layers[base_table].id())
                relation.addFieldPair(fk_on_related, rel["base_primary_column"])
                project.relationManager().addRelation(relation)

                base_layer = layers[base_table]
                base_layer.editFormConfig().setLayout(QgsEditFormConfig.TabLayout)
                root_container = base_layer.editFormConfig().invisibleRootContainer()
                rel_container = QgsAttributeEditorRelation(relation, root_container)
                root_container.addChildElement(rel_container)

        # Pass 3: brand-driven renderer for every layer (the "General" form
        # tab was already built in pass 1, before pass 2's relation tabs).
        for table, layer in layers.items():
            if table == "road_segment":
                layer.setRenderer(_road_segment_renderer(infos[table], colors))
                continue

            condition_fk = None
            condition_table = None
            for cand in ("condition", "segment_condition"):
                found = find_fk_column(infos[table], cand)
                if found:
                    condition_fk, condition_table = found, cand
                    break

            _, hue_token = DOMAIN_STYLE.get(
                domains.get(table, ""), ("", "kartoza.grey")
            )
            hue = colors.get(hue_token, colors["kartoza.grey"])
            symbol_cls = {0: QgsMarkerSymbol, 1: QgsLineSymbol, 2: QgsFillSymbol}.get(
                int(layer.geometryType())
            )
            if symbol_cls is None:
                continue  # non-spatial table, no renderer to set

            if condition_fk:
                status_map = {
                    "good": colors["status.success"],
                    "fair": colors["status.warn"],
                    "poor": colors["status.error"],
                    "very poor": colors["status.error"],
                    "closed": colors["status.error"],
                    "flooded": colors["status.error"],
                }
                categories = []
                for name_value, uuid_value in _lookup_name_uuid_rows(condition_table):
                    color = status_map.get(name_value.strip().lower(), hue)
                    sym = symbol_cls.createSimple({"color": color})
                    categories.append(QgsRendererCategory(uuid_value, sym, name_value))
                default_sym = symbol_cls.createSimple({"color": hue})
                categories.append(QgsRendererCategory(None, default_sym, "Other"))
                layer.setRenderer(
                    QgsCategorizedSymbolRenderer(condition_fk, categories)
                )
            else:
                sym = symbol_cls.createSimple({"color": hue})
                layer.setRenderer(QgsSingleSymbolRenderer(sym))

        pathlib.Path(out_path).parent.mkdir(parents=True, exist_ok=True)
        project.write(str(out_path))
    finally:
        qgs.exitQgis()


def _lookup_name_uuid_rows(lookup_table: str) -> List[Tuple[str, str]]:
    """Fetch a lookup table's (display name, uuid) rows from PG.

    Used to build categorized renderers keyed on a lookup table's uuid,
    e.g. condition/status colouring or road-type widths.

    Args:
        lookup_table: Name of the lookup table (e.g. ``"segment_condition"``
            or ``"segment_type"``).

    Returns:
        A list of ``(display_name, uuid)`` pairs.
    """
    info = schema_docs.introspect_table(lookup_table)
    name_col = display_column(info)
    # nosec B608: name_col/lookup_table come from this script's own fixed
    # candidate list ("condition"/"segment_condition"/"segment_type") and
    # introspect_table's column list, not user input.
    raw = schema_docs.psql(
        f'SELECT {name_col}, uuid FROM "{lookup_table}";'  # nosec B608
    )
    rows = []
    for line in raw.strip().split("\n"):
        if not line:
            continue
        name_value, uuid_value = line.split("|", 1)
        rows.append((name_value, uuid_value))
    return rows


def _road_line_symbol(
    total_width_mm: float, fill_color: str, casing_color: str, centerline_color: str
) -> "QgsLineSymbol":
    """Build a road_segment line symbol: plain, or cased with a centreline.

    Standard road cartography technique: a wide casing symbol layer on
    the bottom, a narrower fill layer on top of it, and (for wide/major
    roads only) a thin dashed centreline on top of that.

    Args:
        total_width_mm: Overall rendered width of the road casing, in mm.
        fill_color: Hex colour for the road surface fill.
        casing_color: Hex colour for the outer casing/border.
        centerline_color: Hex colour for the dashed centreline.

    Returns:
        A QgsLineSymbol with one or three symbol layers, bottom-to-top.
    """
    symbol = QgsLineSymbol([])
    if total_width_mm < ROAD_CASING_MIN_WIDTH_MM:
        symbol.appendSymbolLayer(QgsSimpleLineSymbolLayer(fill_color, total_width_mm))
        return symbol

    symbol.appendSymbolLayer(QgsSimpleLineSymbolLayer(casing_color, total_width_mm))
    symbol.appendSymbolLayer(QgsSimpleLineSymbolLayer(fill_color, total_width_mm * 0.6))
    centerline = QgsSimpleLineSymbolLayer(centerline_color, total_width_mm * 0.12)
    centerline.setUseCustomDashPattern(True)
    centerline.setCustomDashVector([4, 3])
    symbol.appendSymbolLayer(centerline)
    return symbol


def _road_segment_renderer(
    road_segment_info: Dict, colors: Dict[str, str]
) -> QgsCategorizedSymbolRenderer:
    """Build the road_segment renderer: width/casing/centreline by road type.

    Args:
        road_segment_info: ``introspect_table("road_segment")`` result,
            used to find the FK column into segment_type.
        colors: Kartoza brand hex colours, keyed by token name.

    Returns:
        A QgsCategorizedSymbolRenderer keyed on the segment_type FK column.
    """
    type_fk = find_fk_column(road_segment_info, "segment_type")
    fill_color = colors["surface.cloud"]
    casing_color = colors["text.default"]
    centerline_color = colors["kartoza.amber"]

    categories = []
    for name_value, uuid_value in _lookup_name_uuid_rows("segment_type"):
        width_mm = ROAD_TYPE_WIDTHS_MM.get(name_value, DEFAULT_ROAD_WIDTH_MM)
        symbol = _road_line_symbol(width_mm, fill_color, casing_color, centerline_color)
        categories.append(QgsRendererCategory(uuid_value, symbol, name_value))
    default_symbol = _road_line_symbol(
        DEFAULT_ROAD_WIDTH_MM, fill_color, casing_color, centerline_color
    )
    categories.append(QgsRendererCategory(None, default_symbol, "Other"))
    return QgsCategorizedSymbolRenderer(type_fk, categories)


def main() -> int:
    """Run the generator end-to-end.

    Returns:
        0 on success, 2 on bad arguments or missing prerequisites.
    """
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n", maxsplit=1)[0])
    ap.add_argument("--gpkg", type=pathlib.Path, default=DEFAULT_GPKG)
    ap.add_argument("--out", type=pathlib.Path, default=DEFAULT_OUT)
    args = ap.parse_args()

    if not args.gpkg.is_file():
        print(
            f"ERROR: {args.gpkg} does not exist. Run 'nix run .#build-gpkg' first.",
            file=sys.stderr,
        )
        return 2

    print(">> Building reference Postgres DB for layer/field metadata...")
    schema_docs.build_reference_db()
    try:
        # Also pick up not-yet-released tables/columns (e.g. road.gender,
        # road_segment_photo), same reasoning as build_gpkg.sh applying this.
        schema_docs.psql_file(ROOT / "sql" / "migrations" / "pg" / "UNRELEASED.sql")
        print(f">> Generating QGIS project from {args.gpkg}...")
        build_project(args.gpkg, args.out)
    finally:
        schema_docs.drop_reference_db()

    print(f">> Done: {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
