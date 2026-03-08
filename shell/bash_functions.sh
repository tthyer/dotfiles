#!/usr/bin/env bash

# adds a string to PATH, if it's not there already
# from https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="${PATH:+"$PATH:"}$1"
  fi
}

# Create new python module
module() {
  local moduleName="$1"
  mkdir "$moduleName"
  touch "$moduleName/__init__.py"
  touch "$moduleName/$moduleName.py"
}

randomFreePort() {
  python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'
}

klogs() {
  local pod="$1"
  local namespace="${2:-master}"
  kubectl logs -f "$pod" -n "$namespace" | jq -R -r --stream --unbuffered 'fromjson? | .message'
}

argo_fwd() {
  kubectl port-forward service/argo-server -n argo 2746:2746
}

az_subscription() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "command requires a subscription name"
    return 1
  fi
  az account show --name "$name" --query "id"
}

why() {
  python dev_tools/parse_argo_logs.py "$1"
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
