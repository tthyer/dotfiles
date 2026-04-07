#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# src:target pairs (colon-separated)
symlinks=(
  "shell/bash_profile:$HOME/.bash_profile"
  "shell/bashrc:$HOME/.bashrc"
  "shell/bash_functions.sh:$HOME/bash_functions.sh"
  "shell/terminal_setup.sh:$HOME/.terminal_setup.sh"
  "shell/warp_setup.sh:$HOME/.warp_setup.sh"
  "git/gitconfig:$HOME/.gitconfig"
  "git/gitignore_global:$HOME/.gitignore_global"
  "k8s/k8s:$HOME/.k8s"
  "vim/vimrc:$HOME/.vimrc"
  "java/java-setup.sh:$HOME/java-setup.sh"
  "config/himalaya/config.toml:$HOME/.config/himalaya/config.toml"
)

mkdir -p "$HOME/.config/himalaya"

for pair in "${symlinks[@]}"; do
  src="${pair%%:*}"
  target="${pair#*:}"
  source_path="$DOTFILES_DIR/$src"

  # Back up existing non-symlink files
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Backing up $target to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  ln -fsv "$source_path" "$target"
done

# iTerm2 Dynamic Profile (auto-loaded by iTerm2 from this directory)
iterm2_dynamic_profiles_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$iterm2_dynamic_profiles_dir"
ln -fsv "$DOTFILES_DIR/config/iterm2/tthyer-iterm-profile.json" "$iterm2_dynamic_profiles_dir/tthyer-iterm-profile.json"
