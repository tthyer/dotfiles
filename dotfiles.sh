#!/usr/bin/env bash

files=(
    ".bashrc"
    ".bash_profile"
    ".vimrc"
    ".gitconfig"
    ".gitignore_global"
    ".k8s"
    ".terminal_setup.sh"
    )

for dotfile in "${files[@]}"
do
  ln -fsv "$(pwd)/$dotfile" "$HOME/$dotfile"
done
