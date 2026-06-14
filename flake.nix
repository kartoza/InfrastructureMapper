# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
{
  description = "NixOS developer environment for QGIS plugins.";

  inputs.geospatial.url = "github:imincik/geospatial-nix.repo";
  inputs.nixpkgs.follows = "geospatial/nixpkgs";

  outputs =
    {
      self,
      geospatial,
      nixpkgs,
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
    in
    {
      packages.${system} = {
        default = qgisWithExtras;
        qgis-ltr = qgisLtrWithExtras;
        postgres = postgresWithPostGIS;
      };

      devShells.${system}.default = pkgs.mkShell {
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

          if [ ! -d ".venv" ]; then
            python -m venv .venv
          fi

          # Activate the virtual environment
          source .venv/bin/activate

          # Upgrade pip and install packages from requirements.txt if it exists
          pip install --upgrade pip > /dev/null
          if [ -f requirements.txt ]; then
            echo "Installing Python requirements from requirements.txt..."
            pip install -r requirements.txt
          else
            echo "No requirements.txt found, skipping pip install."
          fi

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
          docs = mkPythonApp "scripts/generate_schema_docs.py";
          release = mkScriptApp "scripts/release.sh";
          # MkDocs convenience apps.
          docs-serve = mkScriptApp "scripts/docs_serve.sh";
          docs-build = mkScriptApp "scripts/docs_build.sh";
        };
    };
}
