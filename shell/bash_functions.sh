#!/usr/bin/env bash

# adds a string to PATH, if it's not there already
# from https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="${PATH:+"$PATH:"}$1"
  fi
}

testfunc() {
  echo "test func!"
}

## Always list directory contents and set title upon 'cd'
#cd() { builtin cd "$@"; echo $PWD && ls -lFah; tabTitle ${PWD##*/}; }


# Validate a Cloudformation template
validateTemplate() {
  template_path=$1
  profile=$2
  if [[ -z profile ]]; then
    profile=default
  fi
  aws --profile $profile cloudformation validate-template --template-body file://$template_path
}

# Create new python module
module() {
  moduleName=$1
  mkdir $moduleName
  touch $moduleName/__init__.py
  touch $moduleName/$moduleName.py
}

# create a kernel for use in jupyter notebook
pykernel() {
  ENVIRONMENT_NAME=$1
  if [[ -z $ENVIRONMENT_NAME ]]; then
    echo "a name for the environment must be the first argument"
  fi
  pipenv install ipykernel jupyterlab --dev
  pipenv run python -m ipykernel install --user --name=$ENVIRONMENT_NAME
  echo "A kernel ${ENVIRONMENT_NAME} was created."
  echo "To use activate the python environment, start jupyter, and select the kernel."
}

randomFreePort() {
  python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'
}

klogs() {
  # handles streaming logs from most k8s pods
  local pod="$1"
  local namespace="${2:-master}"
  kubectl logs -f "$pod" -n "$namespace" | jq -R -r --stream --unbuffered 'fromjson? | .message'
}

restart_gcpauth() {
  minikube addons disable gcp-auth && minikube addons enable gcp-auth
}

argo_fwd() {
  kubectl port-forward service/argo-server -n argo 2746:2746
}

az_subscription() {
  name=$1
  if [[ -z $name ]]; then
    echo "command requires a subscription name"
    return 1
  fi
  az account show --name $1 --query "id"
}

why() {
  python dev_tools/parse_argo_logs.py $1
}

# Login to Azure Container Registry
acr_login() {
  az acr login --name amperonopsmgmt
}

# Amperon workspace venv activation
amp() {
  source ~/github/amperon/amperon/.venv/bin/activate
}

omd() {
  source ~/github/amperon/openmetadata-dags/.venv/bin/activate
}

source ${HOME}/.terminal_setup.sh
