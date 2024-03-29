#!/usr/bin/env bash

files=(
    "bash_functions.sh"
    ".bashrc"
    ".bash_profile"
    ".vimrc"
    ".gitconfig"
    ".gitignore_global"
    ".k8s"
    ".terminal_setup.sh"
    "java-setup.sh"
    )

for dotfile in "${files[@]}"
do
  ln -fsv "$(pwd)/$dotfile" "$HOME/$dotfile"
done
