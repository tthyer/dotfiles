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
)
for pkg in "${npm_globals[@]}"; do
  echo "==> npm install -g $pkg"
  npm install -g "$pkg"
done

# OpenRig runs under Node 24 (see shell/openrig/). npm 11 skips install scripts
# unless allowed, and better-sqlite3's fetches its native binary. npm's own bin
# links land in /opt/homebrew/bin, ahead of ~/.local/bin, and would shadow the
# wrappers that dotfiles.sh links there.
node24_bin=/opt/homebrew/opt/node@24/bin
if [[ -x "$node24_bin/npm" ]]; then
  echo "==> npm install -g @openrig/cli (Node 24)"
  PATH="$node24_bin:$PATH" npm install -g --allow-scripts=@openrig/cli,better-sqlite3 @openrig/cli
  rm -f "$(brew --prefix)/bin/rig" "$(brew --prefix)/bin/openrig-tui"
else
  echo "node@24 not found — skipping OpenRig." >&2
fi
