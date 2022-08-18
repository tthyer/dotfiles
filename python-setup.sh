#! /bin/bash

python_version="3.9:latest"
if ! (pyenv versions | grep "${python_version}"); then
  pyenv install "${python_version}"
fi
eval "$(pyenv init -)"
pyenv global "${python_version}"

python -m pip install --upgrade pip
packages=(pipenv jupyterlab pandas numpy synapseclient flake8 sceptre pre-commit cfn-flip)
installed_packages=( $(python -m pip list) )
for package in "${packages[@]}"
do
  if [[ "${installed_packages[@]}" =~ "${package}" ]]; then
    echo "${package} is already installed, skipping."
  else
    echo "Installing ${package} through pip."
    python -m pip install --user "${package}"
    echo "Done."
  fi
done
