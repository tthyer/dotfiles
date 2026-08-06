#!/usr/bin/env bash
# Push sidebar status pills into cmux. Called from PROMPT_COMMAND.
# Only runs inside a cmux terminal (CMUX_WORKSPACE_ID must be set).
set -uo pipefail

[[ -z "${CMUX_WORKSPACE_ID:-}" ]] && exit 0

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

cache_get() {
  local f="/tmp/cmux-bar-$1" ttl="$2"
  [[ -f "$f" ]] || return 1
  local age=$(( $(date +%s) - $(stat -f %m "$f" 2>/dev/null || echo 0) ))
  [[ "$age" -le "$ttl" ]] || return 1
  cat "$f"
}
cache_put() { printf '%s' "$2" > "/tmp/cmux-bar-$1"; }

# --- Repo / worktree / branch ---
root=$(git -C "$PWD" rev-parse --path-format=absolute --show-toplevel 2>/dev/null) || root=""
if [[ -n "$root" ]]; then
  common=$(git -C "$PWD" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  reponame=$(basename "$(dirname "$common")")
  wt=$(basename "$root")
  cmux set-status repo "$reponame" --icon "folder.fill" --color "#032d57" --priority 100
  if [[ "$wt" != "$reponame" ]]; then
    cmux set-status worktree "$wt" --icon "folder.badge.gearshape" --color "#1e3d5c" --priority 99
  else
    cmux clear-status worktree 2>/dev/null || true
  fi
else
  cmux clear-status repo 2>/dev/null || true
  cmux clear-status worktree 2>/dev/null || true
fi

# --- Amperon env ---
if [[ -n "${AMPERON_ENV:-}" ]]; then
  cmux set-status amp "amp:${AMPERON_ENV}" --icon "bolt.fill" --color "#7a5f00" --priority 90
else
  cmux clear-status amp 2>/dev/null || true
fi

# --- Kube context (cached 10s) ---
if ! kube_val=$(cache_get kube 10); then
  ctx=$(kubectl config current-context 2>/dev/null || echo '—')
  ns=$(kubens -c 2>/dev/null || echo '')
  kube_val="$ctx${ns:+/$ns}"
  cache_put kube "$kube_val"
fi
cmux set-status kube "⎈ $kube_val" --color "#016b58" --priority 80

# --- Azure account (cached 60s) ---
if ! az_val=$(cache_get az 60); then
  az_val=$(az account show --query name -o tsv 2>/dev/null || echo '—')
  cache_put az "$az_val"
fi
cmux set-status az "$az_val" --icon "server.rack" --color "#1e3d5c" --priority 70

# --- Inject all status into workspace description (read by custom sidebar) ---
if [[ -n "$root" ]]; then
  desc="⊙  ${reponame}"
  [[ "$wt" != "$reponame" ]] && desc="${desc}|▸  ${wt}"
else
  desc=""
fi
desc="${desc:+${desc}|}☸  ${kube_val}|☁  ${az_val}"
[[ -n "${AMPERON_ENV:-}" ]] && desc="${desc}|△  ${AMPERON_ENV}"

# Append claude model/context if fresh (written by statusline-command.sh)
claude_cache="$HOME/.cache/ghostty-bar/claude-${CMUX_SURFACE_ID:-none}"
if [[ -f "$claude_cache" ]]; then
  claude_age=$(( $(date +%s) - $(stat -f %m "$claude_cache" 2>/dev/null || echo 0) ))
  if [[ "$claude_age" -le 120 ]]; then
    claude_val=$(cat "$claude_cache")
    [[ -n "$claude_val" ]] && desc="${desc}|✧  ${claude_val}"
  fi
fi

cmux workspace-action --action set-description --description "$desc" 2>/dev/null || true
