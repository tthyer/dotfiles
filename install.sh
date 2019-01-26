#!/usr/bin/env bash

files=(
    ".bash_profile"
    ".vimrc"
    ".gitconfig"
    ".gitignore_global"
    )

for dotfile in "${files[@]}"
do
    if [[ -f "$HOME/$dotfile" ]]; then
      rm "$HOME/$dotfile"
      rm "$HOME/$dotfile.bck"
    fi
    ln -sv "$(pwd)/$dotfile" "$HOME/$dotfile"
done

# ln -sv ".bash_profile" ~
# ln -sv ".vimrc" ~
# ln -sv ".gitconfig" ~
# ln -sv ".gitignore_global" ~