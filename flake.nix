# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
{
  description = "NixOS developer environment for QGIS plugins.";

  inputs.geospatial.url = "github:imincik/geospatial-nix.repo";
  inputs.nixpkgs.follows = "geospatial/nixpkgs";
  # Separate, independent pin (not geospatial/nixpkgs) just to reach QGIS 4.x
  # (Qt6) for scripts/generate_project.py. The June-2025 geospatial-nix pin
  # above only has QGIS 3.x (3.42.3 mainline, 3.40.7 LTR) either way, and
  # bumping it would also move the project's main nix run .#qgis app - this
  # input stays scoped to the one script that actually needs 4.x.
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      geospatial,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      system = "x86_64-linux";
      profileName = "InfrastructureMapper";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      # QGIS 4.x (Qt6-based) - plain nixpkgs, not geospatial-nix (which just
      # re-exports pkgs.qgis/pkgs.qgis-ltr unchanged; no need to go through
      # it here). The wrapped `qgis` package only bakes PyQt6/gdal/etc onto
      # PYTHONPATH for its own $out/bin/qgis (via wrapProgram in its
      # default.nix postBuild) - a standalone script needs its own python
      # derivation built the same way nixpkgs builds that PYTHONPATH:
      # qgis-unwrapped.py (QGIS's own python3, Qt6/PyQt6-aware override)
      # with qgis-unwrapped.pythonBuildInputs (pyqt6, gdal, psycopg2, sip,
      # etc - the exact set QGIS itself was built/wrapped against).
      qgis4 = pkgsUnstable.qgis;
      qgis4Unwrapped = qgis4.unwrapped;
      qgis4Python = qgis4Unwrapped.py.withPackages (_: qgis4Unwrapped.pythonBuildInputs);
      extraPythonPackages = ps: [
        ps.pyqtwebengine
        ps.jsonschema
        ps.debugpy
        ps.future
        ps.psutil
      ];
      qgisWithExtras = geospatial.packages.${system}.qgis.override {
        inherit extraPythonPackages;
      };
      qgisLtrWithExtras = geospatial.packages.${system}.qgis-ltr.override {
        inherit extraPythonPackages;
      };
      postgresWithPostGIS = pkgs.postgresql.withPackages (ps: [ ps.postgis ]);

      # migra + transitive deps (schemainspect, sqlbag) are not packaged in
      # nixpkgs (schemainspect was removed in May 2024 as broken under
      # SQLAlchemy 2.x). We build them here pinned to sqlalchemy_1_4, which is
      # the last version their unmaintained upstreams support.
      py = pkgs.python3Packages;
      sqlalchemy14 = py.sqlalchemy_1_4;

      schemainspect = py.buildPythonPackage rec {
        pname = "schemainspect";
        version = "3.1.1663587362";
        # Distributed via poetry but the sdist ships a generated setup.py and
        # the pyproject has no [build-system] — use the setuptools backend.
        format = "setuptools";
        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-opWtVvehnAnl4e+fFtrb9jkuJhlstfBbWv5hPJnOdGg=";
        };
        # pkg_resources is imported at runtime; bundle setuptools for Py 3.12.
        propagatedBuildInputs = [
          sqlalchemy14
          py.setuptools
        ];
        doCheck = false;
        pythonImportsCheck = [ "schemainspect" ];
      };

      sqlbag = py.buildPythonPackage rec {
        pname = "sqlbag";
        version = "0.1.1617247075";
        format = "setuptools";
        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-udeGLDsgMDVteWyocpB5Yv1UcEBml4166JOD9RIzZu0=";
        };
        propagatedBuildInputs = with py; [
          sqlalchemy14
          six
          packaging
          psycopg2
        ];
        doCheck = false;
        pythonImportsCheck = [ "sqlbag" ];
      };

      migra = py.buildPythonPackage rec {
        pname = "migra";
        version = "3.0.1663481299";
        format = "pyproject";
        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-DPDBJdVTAI2f9UAmY6UXA8zEdLtltaT0cnkG2/WOIX8=";
        };
        nativeBuildInputs = [ py.poetry-core ];
        propagatedBuildInputs = [
          schemainspect
          sqlbag
          py.six
          py.psycopg2
        ];
        doCheck = false;
        pythonImportsCheck = [ "migra" ];
      };

      # darglint was removed from nixpkgs (upstream is unmaintained); it has
      # no runtime dependencies, so vendor it the same way as migra et al.
      darglint = py.buildPythonPackage rec {
        pname = "darglint";
        version = "1.8.1";
        format = "setuptools";
        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-CA1RBt8UmxmYIufufeucAStJiRU48UoRvmgQRPC7INo=";
        };
        doCheck = false;
        pythonImportsCheck = [ "darglint" ];
      };
    in
    {
      packages.${system} = {
        default = qgisWithExtras;
        qgis-ltr = qgisLtrWithExtras;
        postgres = postgresWithPostGIS;
      };

      devShells.${system} = {
        # Lightweight shell for CI lint / immutability / docstring /
        # yaml / spelling jobs. Excludes QGIS, Qt5, GDAL, PostGIS,
        # mkdocs and the migra stack — pulling those for a job that
        # just needs bash + git triggers chronic cache.nixos.org
        # flakiness because of the download volume.
        minimal = pkgs.mkShell {
          packages = [
            pkgs.bash
            pkgs.coreutils
            pkgs.git
            pkgs.gnugrep
            pkgs.gawk
            pkgs.gnused
            pkgs.findutils
            pkgs.python3
            pkgs.shellcheck
            pkgs.shfmt
            pkgs.actionlint
            pkgs.markdownlint-cli
            pkgs.yamllint
            pkgs.yamlfmt
            pkgs.reuse
            pkgs.sqlfluff
            pkgs.nodePackages.cspell
            pkgs.python3Packages.black
            pkgs.python3Packages.isort
            darglint
          ];
        };

        default = pkgs.mkShell {
          packages = [
            pkgs.autoflake
            pkgs.chafa
            pkgs.ffmpeg
            pkgs.gdb
            pkgs.git
            pkgs.glow # terminal markdown viewer
            pkgs.gource # Software version control visualization
            pkgs.gum
            pkgs.gum # UX for TUIs
            pkgs.jq
            pkgs.gdal # ogr2ogr + ogrinfo for GPKG builds
            pkgs.sqlite # sqlite3 CLI for GPKG post-processing
            pkgs.libsForQt5.kcachegrind
            pkgs.nixfmt-rfc-style
            pkgs.pre-commit
            pkgs.pyprof2calltree # needed to covert cprofile call trees into a format kcachegrind can read
            pkgs.python3
            pkgs.qgis
            pkgs.qt5.full # so we get designer
            pkgs.qt5.qtbase
            pkgs.qt5.qtlocation
            pkgs.qt5.qtquickcontrols2
            pkgs.qt5.qtsvg
            pkgs.qt5.qttools
            pkgs.skate # Distributed key/value store
            pkgs.vim
            pkgs.virtualenv
            pkgs.vscode
            pkgs.sqlfluff
            pkgs.marp-cli
            pkgs.shellcheck
            pkgs.shfmt
            pkgs.markdownlint-cli
            pkgs.yamllint
            pkgs.yamlfmt
            pkgs.actionlint # for checking gh actions
            pkgs.bearer
            pkgs.reuse # SPDX/REUSE license compliance checker
            # Python security / quality tools used by pre-commit hooks.
            pkgs.python3Packages.bandit
            pkgs.python3Packages.pylint
            darglint
            pkgs.semgrep
            postgresWithPostGIS
            pkgs.nodePackages.cspell
            (pkgs.python3.withPackages (ps: [
              ps.python
              ps.pip
              ps.setuptools
              ps.wheel
              ps.pytest
              ps.pytest-qt
              ps.black
              ps.isort
              ps.click # needed by black
              ps.jsonschema
              ps.pandas
              ps.odfpy
              ps.psutil
              ps.httpx
              ps.toml
              ps.typer
              ps.paver
              # For autocompletion in vscode
              ps.pyqt5-stubs
              ps.debugpy
              ps.numpy
              ps.gdal
              ps.toml
              ps.typer
              ps.snakeviz # For visualising cprofiler outputs
              # Add these for SQL linting/formatting:
              ps.sqlfmt
              # MkDocs documentation site (Material theme + plugins).
              ps.mkdocs
              ps.mkdocs-material
              ps.mkdocs-material-extensions
              ps.mkdocs-glightbox
              ps.mkdocs-git-revision-date-localized-plugin
              ps.mkdocs-mermaid2-plugin
              ps.pymdown-extensions
              # Schema diff stack for build_artifacts / schema_diff.
              migra
              sqlbag
              schemainspect
              ps.psycopg2
            ]))
          ];
          shellHook = ''
            # Respect any PGHOST/PGPORT/PGDATABASE already set by the caller
            # (CI sets PGHOST=localhost so we hit the service-container PG);
            # only fall back to the project-local cluster when unset.
            : "''${PGHOST:=$PWD/pgdata}"
            : "''${PGPORT:=5432}"
            : "''${PGDATABASE:=gis}"
            export PGHOST PGPORT PGDATABASE

            # Install the pre-commit + pre-push git hooks (idempotent).
            # pre-push is what mirrors CI's docs + immutability checks.
            if command -v pre-commit >/dev/null && [ -d .git ]; then
              pre-commit install --install-hooks >/dev/null 2>&1 || true
            fi

            # Pretty welcome with live Postgres status.
            if [ -x scripts/welcome.sh ]; then
              bash scripts/welcome.sh || true
            fi
          '';
        };
      };

      apps.${system} =
        let
          # Wrap a repo-relative script so 'nix run .#foo' runs it inside the
          # project's nix develop shell, no matter the user's current dir.
          mkScriptApp = scriptPath: {
            type = "app";
            program = "${pkgs.writeShellScript "${baseNameOf scriptPath}" ''
              ROOT="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
              cd "$ROOT"
              exec nix develop --command bash "$ROOT/${scriptPath}" "$@"
            ''}";
          };
          mkPythonApp = scriptPath: {
            type = "app";
            program = "${pkgs.writeShellScript "${baseNameOf scriptPath}" ''
              ROOT="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
              cd "$ROOT"
              exec nix develop --command python "$ROOT/${scriptPath}" "$@"
            ''}";
          };
          # For scripts that import qgis.core standalone (no GUI, no
          # launching the qgis binary) - runs them with qgis4Python (QGIS
          # 4.x's own python3, built with its exact pyqt6/gdal/etc input
          # set - see the qgis4Python comment above), with
          # share/qgis/python (the qgis.core module tree) added on top.
          # Still goes through `nix develop` for psql/createdb/PGHOST etc.
          # (scripts/generate_schema_docs.py's reference-DB machinery) -
          # just not for the python interpreter itself.
          mkQgis4PythonApp = scriptPath: {
            type = "app";
            program = "${pkgs.writeShellScript "${baseNameOf scriptPath}" ''
              ROOT="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
              cd "$ROOT"
              # PYTHONPATH is set to exactly this one path, not appended to
              # whatever the devShell's own python3.12 env already put
              # there - qgis4Python is a self-contained python 3.14 build
              # with its own numpy/gdal/etc, and mixing in the devShell's
              # python3.12 site-packages on PYTHONPATH makes Python pick up
              # an ABI-incompatible numpy built for the wrong interpreter.
              #
              # QGIS_PREFIX_PATH: QgsApplication otherwise guesses its
              # resource prefix (srs.db, proj data, svg symbols, ...) from
              # the running executable's own directory - fine for the real
              # qgis binary, wrong here since we exec a bare python3, which
              # would point it at qgis4Python's nix store path instead of
              # qgis4's share/qgis/resources. Without this, CRS lookups by
              # EPSG code silently fail and the project is saved with no
              # CRS assigned.
              exec nix develop --command bash -c '
                export PYTHONPATH="${qgis4}/share/qgis/python"
                export QGIS_PREFIX_PATH="${qgis4}"
                exec "${qgis4Python}/bin/python3" "$0" "$@"
              ' "$ROOT/${scriptPath}" "$@"
            ''}";
          };
        in
        {
          qgis = {
            type = "app";
            program = "${qgisWithExtras}/bin/qgis";
            args = [
              "--profile"
              "${profileName}"
            ];
          };
          qgis-ltr = {
            type = "app";
            program = "${qgisLtrWithExtras}/bin/qgis";
            args = [
              "--profile"
              "${profileName}"
            ];
          };
          # Postgres lifecycle apps (act on the project-local ./pgdata cluster).
          pg-start = mkScriptApp "scripts/start_pg.sh";
          pg-stop = mkScriptApp "scripts/stop_pg.sh";
          pg-status = mkScriptApp "scripts/status_pg.sh";
          pg-restart = mkScriptApp "scripts/restart_pg.sh";
          pg-psql = mkScriptApp "scripts/psql_pg.sh";
          pg-logs = mkScriptApp "scripts/logs_pg.sh";
          pg-reset = mkScriptApp "scripts/reset_pg.sh";
          # Schema lifecycle convenience apps.
          build-gpkg = mkScriptApp "scripts/build_gpkg.sh";
          build-artifacts = mkScriptApp "scripts/build_artifacts.sh";
          schema-diff = mkPythonApp "scripts/schema_diff.py";
          migrate-pg = mkScriptApp "scripts/migrate_pg.sh";
          migrate-gpkg = mkPythonApp "scripts/migrate_gpkg.py";
          generate-models = mkPythonApp "scripts/generate_models.py";
          apply-pg = mkScriptApp "scripts/apply_pg.sh";
          docs = mkPythonApp "scripts/generate_schema_docs.py";
          generate-project = mkQgis4PythonApp "scripts/generate_project.py";
          release = mkScriptApp "scripts/release.sh";
          # MkDocs convenience apps.
          docs-serve = mkScriptApp "scripts/docs_serve.sh";
          docs-build = mkScriptApp "scripts/docs_build.sh";
        };
    };
}
