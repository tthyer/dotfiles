#!/usr/bin/env bash
# Install uv from Astral's standalone installer, not Homebrew.
#
# amperon/amperon's pyproject.toml pins the toolchain:
#   required-version = ">=0.12.5,<0.13"
# `make venv` and `make pre-commit` enforce it. A standalone install can move
# around inside that range with `uv self update <version>`; a Homebrew uv
# can't — brew refuses self-update for anything it manages, and it tracks
# latest, so it will cross 0.13 and start failing those targets.
#
# Homebrew also wins on PATH here: /opt/homebrew/bin sits well ahead of
# ~/.local/bin, so `brew install uv` doesn't sit harmlessly alongside this
# one, it shadows it. That's why uv is not in the Brewfile.
set -euo pipefail

# Inside the pyproject range above. Bump deliberately, and keep it < 0.13.
UV_VERSION="0.12.24"
INSTALL_DIR="$HOME/.local/bin"

if command -v uv >/dev/null 2>&1; then
  uv_path="$(command -v uv)"
  current="$(uv --version 2>/dev/null | awk '{print $2}')"

  if [[ "$uv_path" == /opt/homebrew/* ]]; then
    echo "!! uv on PATH is Homebrew's: $uv_path"
    echo "   It can't self-update, and it shadows ~/.local/bin."
    echo "   Run 'brew uninstall uv', then re-run this script."
    exit 1
  fi

  if [[ "$current" == "$UV_VERSION" ]]; then
    echo "==> uv $UV_VERSION already installed at $uv_path"
    exit 0
  fi
  echo "==> uv $current installed; moving to $UV_VERSION"
fi

# UV_INSTALL_DIR has to be explicit. The installer records where it put things
# in ~/.config/uv/uv-receipt.json, and `uv self update` reads that receipt back
# — so a run that defaults the directory can write a path that no longer makes
# sense and break self-update until uv is reinstalled. Setting it every time
# keeps the receipt honest regardless of the working directory.
#
# UV_NO_MODIFY_PATH because shell/bashrc already puts ~/.local/bin on PATH;
# letting the installer edit the shell files would duplicate that.
echo "==> Installing uv $UV_VERSION to $INSTALL_DIR"
curl -LsSf "https://astral.sh/uv/$UV_VERSION/install.sh" |
  env UV_INSTALL_DIR="$INSTALL_DIR" UV_NO_MODIFY_PATH=1 sh

installed="$("$INSTALL_DIR/uv" --version 2>/dev/null | awk '{print $2}')"
if [[ "$installed" != "$UV_VERSION" ]]; then
  echo "!! Expected uv $UV_VERSION, got '${installed:-nothing}'." >&2
  exit 1
fi
echo "==> uv $installed installed"
