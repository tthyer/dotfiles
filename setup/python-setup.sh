#!/usr/bin/env bash

packages=(jupyterlab ipython ipykernel pandas numpy scipy pre-commit)
uv tool install --force "${packages[@]}"
