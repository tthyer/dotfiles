#!/usr/bin/env bash
# Python CLI tools installed into isolated environments.
# Work-only tools live in the overlay's apply.sh.
set -euo pipefail

# uv-managed tools
# `pliers` was here and should never have been. Amperon's pliers is an
# internal tool in amperon/dev_tools/pliers, run as ./bin/pliers from that
# repo. There is an unrelated public PyPI package of the same name — a
# multimodal feature-extraction library — and that's what this installed.
# It failed loudly only because that package ships no entrypoints.
uv_tools=(
  datamodel-code-generator
  ipython
  jupyterlab
  numpy
  pre-commit
)
for tool in "${uv_tools[@]}"; do
  echo "==> uv tool install $tool"
  uv tool install --force "$tool"
done

# pipx-managed tools. These need their own interpreter rather than uv's shims:
# pytest resolves plugins from the environment it was installed into, and
# scalene ships compiled extensions.
pipx_tools=(
  pytest
  scalene
)
for tool in "${pipx_tools[@]}"; do
  echo "==> pipx install $tool"
  pipx install --force "$tool"
done
