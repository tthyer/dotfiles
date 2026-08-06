#!/usr/bin/env bash
# Segment emitter for the Ghostty bottom bar (driven by tmux status-format).
# Usage: bar.sh <segment> [arg]
#   repo   <pane_current_path>   -> "repo ▸worktree  ⑂branch"
#   kube                         -> current kube context/namespace (cached 10s)
#   az                           -> Azure account name   (cached 60s)
#   amp    <pane_id>             -> "amp:ENV" published by the shell prompt
#   claude <pane_id>             -> "Model ctx:NN%" written by Claude statusLine
set -uo pipefail

# tmux inherits Ghostty's minimal GUI PATH, so az/kubectl/git aren't found.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

cache_get() { # name ttl_seconds  -> echoes cached value if fresh, else nonzero
  local f="/tmp/ghostty-bar-$1" ttl="$2"
  [ -f "$f" ] || return 1
  local age=$(( $(date +%s) - $(stat -f %m "$f" 2>/dev/null || echo 0) ))
  [ "$age" -le "$ttl" ] || return 1
  cat "$f"
}
cache_put() { printf '%s' "$2" > "/tmp/ghostty-bar-$1"; }

case "${1:-}" in
  repo)
    p="${2:-$PWD}"
    root=$(git -C "$p" rev-parse --path-format=absolute --show-toplevel 2>/dev/null) || { printf -- '—'; exit 0; }
    branch=$(git -C "$p" symbolic-ref --short HEAD 2>/dev/null || git -C "$p" rev-parse --short HEAD 2>/dev/null || echo '?')
    common=$(git -C "$p" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    reponame=$(basename "$(dirname "$common")")
    wt=$(basename "$root")
    if [ "$wt" = "$reponame" ]; then
      printf '%s  ⑂%s' "$reponame" "$branch"
    else
      printf '%s ▸%s  ⑂%s' "$reponame" "$wt" "$branch"
    fi
    ;;
  kube)
    if v=$(cache_get kube 10); then printf '⎈ %s' "$v"; exit 0; fi
    ctx=$(kubectl config current-context 2>/dev/null || echo '—')
    ns=$(kubens -c 2>/dev/null)
    v="$ctx${ns:+/$ns}"
    cache_put kube "$v"; printf '⎈ %s' "$v"
    ;;
  az)
    if v=$(cache_get az 60); then printf '☁ %s' "$v"; exit 0; fi
    v=$(az account show --query name -o tsv 2>/dev/null || echo '—')
    cache_put az "$v"; printf '☁ %s' "$v"
    ;;
  amp)
    f="$HOME/.cache/ghostty-bar/amp-${2:-none}"
    [ -f "$f" ] || { printf ''; exit 0; }
    v=$(cat "$f")
    [ -n "$v" ] && printf 'amp:%s' "$v"
    ;;
  claude)
    f="$HOME/.cache/ghostty-bar/claude-${2:-none}"
    [ -f "$f" ] || { printf -- '—'; exit 0; }
    # stale (Claude not running in this pane anymore) after 2 min
    age=$(( $(date +%s) - $(stat -f %m "$f" 2>/dev/null || echo 0) ))
    if [ "$age" -gt 120 ]; then printf -- '—'; else cat "$f"; fi
    ;;
  *) printf '' ;;
esac
