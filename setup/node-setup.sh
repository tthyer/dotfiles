#!/usr/bin/env bash
# Global npm packages. Node itself comes from the Brewfile; nvm is available
# for per-project versions and is sourced by shell/bashrc.
set -euo pipefail

if ! command -v npm &>/dev/null; then
  echo "npm not found — skipping global packages." >&2
  exit 0
fi

npm_globals=(
  dotenv-cli
  dotenv
)
for pkg in "${npm_globals[@]}"; do
  echo "==> npm install -g $pkg"
  npm install -g "$pkg"
done
