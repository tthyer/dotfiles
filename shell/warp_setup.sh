#!/usr/bin/env bash

# Warp-optimized terminal setup
# This replaces the complex PS1 with Warp's built-in features

# Simplified prompt - let Warp handle Git, directory, and venv display
set_warp_prompt() {
  local venv=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv="($(basename "$VIRTUAL_ENV")) "
  fi
  
  # Simple prompt - Warp will handle the rest
  PS1="${venv}\$ "
}

# Status functions that can be called as needed
warp_status() {
  echo "=== Current Status ==="
  echo "Azure Account: $(az account show --query name -o tsv 2>/dev/null || echo 'Not logged in')"
  echo "K8s Context: $(kubectl config current-context 2>/dev/null || echo 'None')"
  echo "K8s Namespace: $(kubens -c 2>/dev/null || echo 'default')"
  echo "Amperon Env: ${AMPERON_ENV:-'Not set'}"
  echo "Time: $(date +'%H:%M:%S')"
  echo "===================="
}

# Quick status aliases
alias azstatus='az account show --query name -o tsv 2>/dev/null || echo "Not logged in"'
alias k8sstatus='echo "Context: $(kubectl config current-context 2>/dev/null || echo "None"), Namespace: $(kubens -c 2>/dev/null || echo "default")"'
alias ampstatus='echo "Amperon Env: ${AMPERON_ENV:-Not set}"'

# Function to show context in terminal title (Warp supports this)
update_terminal_title() {
  local context=$(kubectl config current-context 2>/dev/null || echo "no-k8s")
  local az_account=$(az account show --query name -o tsv 2>/dev/null || echo "no-az")
  echo -ne "\033]0;${az_account} | ${context}\007"
}

# Set up the prompt
PROMPT_COMMAND="set_warp_prompt; update_terminal_title"

# Colors for manual use
export WARP_BLUE='\033[01;34m'
export WARP_GREEN='\033[1;32m'
export WARP_YELLOW='\033[1;33m'
export WARP_NORMAL='\033[00m'

echo "Warp setup loaded! Try 'warp_status' for full status display."
