#!/usr/bin/env bash

packages=(jupyterlab ipython numpy pre-commit)
for package in "${packages[@]}"; do
  uv tool install --force "$package"
done
