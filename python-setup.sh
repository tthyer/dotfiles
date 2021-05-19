#! /bin/bash

python_version="3.9.4"
if ! (pyenv versions | grep "${python_version}"); then
  pyenv install "${python_version}"
fi
pyenv global "${python_version}"

python -m pip install --upgrade pip
packages=(jupyterlab pandas numpy synapseclient flake8)
installed_packages=( $(python -m pip list) )
for package in "${packages[@]}"
do
  if [[ "${installed_packages[@]}" =~ "${package}" ]]; then
    echo "${package} is already installed, skipping."
  else
    echo "Installing ${package} through pip."
    python -m pip install "${package}"
    echo "Done."
  fi
done

