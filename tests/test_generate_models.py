# -*- coding: utf-8 -*-
# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
"""Tests for scripts/generate_models.py's CRS resolution and templating."""
from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import generate_models  # noqa: E402  pylint: disable=wrong-import-position


def test_validate_crs_accepts_epsg_prefixed():
    """``EPSG:3857`` normalises to the SRID and canonical EPSG string."""
    srid, epsg = generate_models.validate_crs("EPSG:3857")
    assert srid == "3857"
    assert epsg == "EPSG:3857"


def test_validate_crs_accepts_bare_srid():
    """A bare numeric SRID is accepted and given the EPSG: prefix."""
    srid, epsg = generate_models.validate_crs("32734")
    assert srid == "32734"
    assert epsg == "EPSG:32734"


def test_validate_crs_rejects_garbage():
    """Non-numeric input is rejected with a clear exit code."""
    with pytest.raises(SystemExit) as exc:
        generate_models.validate_crs("not-a-crs")
    assert exc.value.code == 2


def test_warn_if_geographic_warns_on_4326(capsys):
    """EPSG:4326 triggers the geographic-accuracy warning.

    Args:
        capsys: Pytest fixture capturing stdout/stderr.
    """
    generate_models.warn_if_geographic("4326")
    assert "geographic CRS" in capsys.readouterr().err


def test_warn_if_geographic_silent_otherwise(capsys):
    """A metric CRS does not trigger the warning.

    Args:
        capsys: Pytest fixture capturing stdout/stderr.
    """
    generate_models.warn_if_geographic("32734")
    assert capsys.readouterr().err == ""


@pytest.mark.parametrize(
    "source,expected",
    [
        (
            "geometry GEOMETRY (POINT, 4326) NOT NULL",
            "geometry GEOMETRY (POINT, 32735) NOT NULL",
        ),
        ("ST_GEOMFROMTEXT('POINT(0 0)', 4326)", "ST_GEOMFROMTEXT('POINT(0 0)', 32735)"),
        (
            "ALTER TABLE t ALTER COLUMN geom TYPE GEOMETRY (POINT, 4326) "
            "USING ST_TRANSFORM(geom, 4326);",
            "ALTER TABLE t ALTER COLUMN geom TYPE GEOMETRY (POINT, 32735) "
            "USING ST_TRANSFORM(geom, 32735);",
        ),
        (
            "UPDATE gpkg_geometry_columns SET srs_id = 4326",
            "UPDATE gpkg_geometry_columns SET srs_id = 32735",
        ),
    ],
)
def test_template_sql_substitutes_4326(source, expected):
    """Every documented 4326 context is substituted with the target SRID.

    Args:
        source: Input SQL fragment containing a literal 4326 token.
        expected: ``source`` with 4326 replaced by the test SRID.
    """
    assert generate_models.template_sql(source, "32735") == expected


def test_template_sql_leaves_other_srids_untouched():
    """A historical non-4326 SRID (e.g. roads' original 32734) is never touched."""
    source = "geom GEOMETRY (POINT, 32734) NOT NULL"
    assert generate_models.template_sql(source, "32735") == source


def test_template_sql_respects_token_boundaries():
    """4326 must not match inside a longer digit run."""
    source = "-- see ticket 144326 and 43260 for context"
    assert generate_models.template_sql(source, "32735") == source


def test_resolve_crs_uses_flag_and_persists(tmp_path, monkeypatch):
    """An explicit --crs wins and is written to the state file.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    state_file = tmp_path / ".im-crs"
    monkeypatch.setattr(generate_models, "CRS_STATE_FILE", state_file)

    srid, epsg = generate_models.resolve_crs("EPSG:32735", reset=False)

    assert (srid, epsg) == ("32735", "EPSG:32735")
    assert state_file.read_text(encoding="utf-8").strip() == "EPSG:32735"


def test_resolve_crs_uses_remembered_value(tmp_path, monkeypatch):
    """With no flag, a previously remembered CRS is reused without prompting.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    state_file = tmp_path / ".im-crs"
    state_file.write_text("EPSG:3857\n", encoding="utf-8")
    monkeypatch.setattr(generate_models, "CRS_STATE_FILE", state_file)

    srid, epsg = generate_models.resolve_crs(None, reset=False)

    assert (srid, epsg) == ("3857", "EPSG:3857")


def test_resolve_crs_reset_forces_prompt(tmp_path, monkeypatch):
    """--reset-crs ignores the remembered value and prompts interactively.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    state_file = tmp_path / ".im-crs"
    state_file.write_text("EPSG:3857\n", encoding="utf-8")
    monkeypatch.setattr(generate_models, "CRS_STATE_FILE", state_file)
    monkeypatch.setattr(sys.stdin, "isatty", lambda: True)
    monkeypatch.setattr("builtins.input", lambda _prompt: "EPSG:32734")

    srid, epsg = generate_models.resolve_crs(None, reset=True)

    assert (srid, epsg) == ("32734", "EPSG:32734")
    assert state_file.read_text(encoding="utf-8").strip() == "EPSG:32734"


def test_resolve_crs_errors_without_tty(tmp_path, monkeypatch):
    """No flag, nothing remembered, and a non-interactive stdin must fail loudly.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    state_file = tmp_path / ".im-crs"
    monkeypatch.setattr(generate_models, "CRS_STATE_FILE", state_file)
    monkeypatch.setattr(sys.stdin, "isatty", lambda: False)

    with pytest.raises(SystemExit) as exc:
        generate_models.resolve_crs(None, reset=False)
    assert exc.value.code == 2


def _write_fake_sql_tree(root: Path) -> None:
    (root / "migrations" / "pg").mkdir(parents=True)
    (root / "migrations" / "gpkg").mkdir(parents=True)
    (root / "1-infrastructure.sql").write_text(
        "geometry GEOMETRY (POINT, 4326) NOT NULL", encoding="utf-8"
    )
    (root / "13-roads.sql").write_text(
        "geom GEOMETRY (POINT, 32734) NOT NULL", encoding="utf-8"
    )
    (root / "migrations" / "pg" / "v0.2.0.sql").write_text(
        "ALTER TABLE intersection ALTER COLUMN geom TYPE GEOMETRY (POINT, 4326) "
        "USING ST_TRANSFORM(geom, 4326);",
        encoding="utf-8",
    )
    (root / "migrations" / "gpkg" / "v0.2.0.sql").write_text(
        "UPDATE gpkg_geometry_columns SET srs_id = 4326", encoding="utf-8"
    )


def test_generate_mirrors_tree_and_templates(tmp_path, monkeypatch):
    """generate() mirrors sql/ (including migrations/*) with 4326 substituted.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    sql_root = tmp_path / "sql"
    sql_root.mkdir()
    _write_fake_sql_tree(sql_root)
    monkeypatch.setattr(generate_models, "SQL_ROOT", sql_root)

    out_root = tmp_path / "out"
    count = generate_models.generate("32735", out_root)

    assert count == 4
    assert "32735" in (out_root / "1-infrastructure.sql").read_text(encoding="utf-8")
    # Historical non-4326 SRID on the roads baseline must survive untouched.
    assert "32734" in (out_root / "13-roads.sql").read_text(encoding="utf-8")
    assert "32735" in (out_root / "migrations" / "pg" / "v0.2.0.sql").read_text(
        encoding="utf-8"
    )
    assert "32735" in (out_root / "migrations" / "gpkg" / "v0.2.0.sql").read_text(
        encoding="utf-8"
    )


def test_generate_is_idempotent(tmp_path, monkeypatch):
    """Running generate() twice with the same inputs produces identical output.

    Args:
        tmp_path: Pytest fixture providing a per-test temp directory.
        monkeypatch: Pytest fixture for patching module attributes.
    """
    sql_root = tmp_path / "sql"
    sql_root.mkdir()
    _write_fake_sql_tree(sql_root)
    monkeypatch.setattr(generate_models, "SQL_ROOT", sql_root)

    out_root = tmp_path / "out"
    generate_models.generate("32735", out_root)
    first = (out_root / "1-infrastructure.sql").read_text(encoding="utf-8")
    generate_models.generate("32735", out_root)
    second = (out_root / "1-infrastructure.sql").read_text(encoding="utf-8")

    assert first == second
