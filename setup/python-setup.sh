#!/usr/bin/env bash

packages=(jupyterlab ipython ipykernel pandas numpy scipy pre-commit)
for package in "${packages[@]}"; do
  uv tool install --force "$package"
done
