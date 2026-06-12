# SPDX-FileCopyrightText: Tim Sutton
# SPDX-License-Identifier: MIT
pre-commit clean > /dev/null
pre-commit install --install-hooks > /dev/null
pre-commit run --all-files || true
