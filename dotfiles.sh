#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="${DOTFILES_OVERLAY:-$HOME/github/tthyer/dotfiles-work}"

# src:target pairs (colon-separated)
symlinks=(
  "shell/bash_profile:$HOME/.bash_profile"
  "shell/bashrc:$HOME/.bashrc"
  "shell/bash_functions.sh:$HOME/bash_functions.sh"
  "shell/ghostty-bash:$HOME/.local/bin/ghostty-bash"
  "shell/terminal_setup.sh:$HOME/.terminal_setup.sh"
  "git/gitconfig:$HOME/.gitconfig"
  "git/gitignore_global:$HOME/.gitignore_global"
  "vim/vimrc:$HOME/.vimrc"
  "config/ghostty/config.ghostty:$HOME/.config/ghostty/config"
  "config/tmux/tmux.conf:$HOME/.config/tmux/tmux.conf"
  "config/tmux/bar.sh:$HOME/.config/tmux/bar.sh"
  "config/tmux/uninstall-bar.sh:$HOME/.config/tmux/uninstall-bar.sh"
  "config/cmux/bar-update.sh:$HOME/.config/cmux/bar-update.sh"
  "config/gh/config.yml:$HOME/.config/gh/config.yml"
)

for pair in "${symlinks[@]}"; do
  src="${pair%%:*}"
  target="${pair#*:}"
  source_path="$DOTFILES_DIR/$src"

  mkdir -p "$(dirname "$target")"

  # Back up existing non-symlink files
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Backing up $target to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  ln -fsv "$source_path" "$target"
done

# Worktrunk's config is assembled rather than symlinked: the generic half is
# tracked here, and the private overlay appends its project entries.
worktrunk_target="$HOME/.config/worktrunk/config.toml"
mkdir -p "$(dirname "$worktrunk_target")"
cat "$DOTFILES_DIR/config/worktrunk/config.toml" > "$worktrunk_target"
if [[ -f "$OVERLAY_DIR/config/worktrunk/projects.toml" ]]; then
  cat "$OVERLAY_DIR/config/worktrunk/projects.toml" >> "$worktrunk_target"
fi
echo "generated $worktrunk_target"

# tmux exists only to paint the Ghostty status bar. Off by default; the shell
# launcher honours this marker. Remove it to opt in.
tmux_disabled="$HOME/.config/tmux/DISABLED"
if [[ ! -e "$tmux_disabled" ]]; then
  touch "$tmux_disabled"
  echo "created $tmux_disabled (tmux status bar off; delete to enable)"
fi
