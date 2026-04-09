#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# src:target pairs (colon-separated)
symlinks=(
  "shell/bash_profile:$HOME/.bash_profile"
  "shell/bashrc:$HOME/.bashrc"
  "shell/bash_functions.sh:$HOME/bash_functions.sh"
  "shell/ghostty-bash:$HOME/.local/bin/ghostty-bash"
  "shell/terminal_setup.sh:$HOME/.terminal_setup.sh"
  "shell/warp_setup.sh:$HOME/.warp_setup.sh"
  "git/gitconfig:$HOME/.gitconfig"
  "git/gitignore_global:$HOME/.gitignore_global"
  "k8s/k8s:$HOME/.k8s"
  "vim/vimrc:$HOME/.vimrc"
  "java/java-setup.sh:$HOME/java-setup.sh"
  "config/ghostty/config.ghostty:$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  "config/himalaya/config.toml:$HOME/.config/himalaya/config.toml"
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

ghostty_new_config="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
if [[ -L "$ghostty_new_config" && "$(readlink "$ghostty_new_config")" == "$DOTFILES_DIR/config/ghostty/config.ghostty" ]]; then
  rm -v "$ghostty_new_config"
fi
