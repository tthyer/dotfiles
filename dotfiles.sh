#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Map repo paths to home directory targets
declare -A symlinks=(
  ["shell/bash_profile"]="$HOME/.bash_profile"
  ["shell/bashrc"]="$HOME/.bashrc"
  ["shell/bash_functions.sh"]="$HOME/bash_functions.sh"
  ["shell/terminal_setup.sh"]="$HOME/.terminal_setup.sh"
  ["shell/warp_setup.sh"]="$HOME/.warp_setup.sh"
  ["git/gitconfig"]="$HOME/.gitconfig"
  ["git/gitignore_global"]="$HOME/.gitignore_global"
  ["k8s/k8s"]="$HOME/.k8s"
  ["vim/vimrc"]="$HOME/.vimrc"
  ["java/java-setup.sh"]="$HOME/java-setup.sh"
)

for src in "${!symlinks[@]}"; do
  target="${symlinks[$src]}"
  source_path="$DOTFILES_DIR/$src"

  # Back up existing non-symlink files
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Backing up $target to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  ln -fsv "$source_path" "$target"
done
