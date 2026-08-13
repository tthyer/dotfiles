#!/usr/bin/env bash
# Remove the Ghostty tmux bottom-bar shim and restore originals.
set -uo pipefail

# Derive the repo from this script's own location rather than hardcoding a
# home directory — the account short name isn't the same on every machine.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotfiles_dir="$(cd "$script_dir/../.." && pwd)"

dotfile="$dotfiles_dir/shell/ghostty-bash"
sl="$HOME/.claude/statusline-command.sh"
sl_bak="$HOME/.claude/statusline-command.sh.pre-tmux.bak"
ts="$dotfiles_dir/shell/terminal_setup.sh"

echo "Reverting dotfiles (ghostty-bash + terminal_setup.sh) ..."
if git -C "$(dirname "$dotfile")" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$(dirname "$dotfile")" checkout -- "$dotfile" "$ts" 2>/dev/null \
    && echo "  reverted via git" \
    || echo "  (git checkout failed; edit by hand)"
fi

echo "Restoring statusline-command.sh ..."
[ -f "$sl_bak" ] && cp "$sl_bak" "$sl" && echo "  restored from backup"

echo "Removing tmux config + helper ..."
rm -f "$HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/bar.sh"
rm -rf "$HOME/.cache/ghostty-bar"
rm -f /tmp/ghostty-bar-*

echo
echo "Done. Open a new Ghostty window for a plain bash shell."
echo "(tmux itself is still installed; 'brew uninstall tmux' to remove it.)"
