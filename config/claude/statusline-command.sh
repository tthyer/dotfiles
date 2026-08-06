#!/usr/bin/env bash
# Claude Code statusLine — mirrors robbyrussell oh-my-zsh theme
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
dir=$(basename "$cwd")

model=$(echo "$input" | jq -r '.model.display_name // empty')

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')

# Colors
reset='\033[0m'
bold_green='\033[1;32m'
green='\033[1;32m'
cyan='\033[0;36m'
bold_blue='\033[1;34m'
red='\033[0;31m'
yellow='\033[0;33m'

# Shared cheap context lookups (az/k8s/env) — same helper the shell prompt uses.
_ctx_helper="$HOME/github/tthyer/dotfiles/shell/context_segments.sh"
[ -r "$_ctx_helper" ] && source "$_ctx_helper"

# Arrow
arrow="${bold_green}➜${reset}"

# Directory
dir_str="${cyan}${dir}${reset}"

# Git info (skip optional locks to avoid hanging)
git_str=""
if git_branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null); then
  if git -C "$cwd" -c core.fsmonitor=false diff --quiet HEAD 2>/dev/null; then
    git_str=" ${bold_blue}git:(${reset}${red}${git_branch}${reset}${bold_blue})${reset}"
  else
    git_str=" ${bold_blue}git:(${reset}${red}${git_branch}${reset}${bold_blue})${reset} ${yellow}✗${reset}"
  fi
fi

# Kubernetes context/namespace (machine-global, read from ~/.kube/config)
k8s_str=""
if declare -f amp_k8s >/dev/null 2>&1; then
  k8s=$(amp_k8s)
  [ -n "$k8s" ] && k8s_str=" ${green}k8s:${k8s}${reset}"
fi

# Model + context
meta=""
if [ -n "$model" ]; then
  meta=" ${model}"
fi
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  meta="${meta} ctx:${used_int}%"
  if [ -n "$tokens" ]; then
    # Raw context tokens, abbreviated (e.g. 143966 -> 144k)
    tok_k=$(awk "BEGIN{printf \"%.0f\", ${tokens}/1000}")
    meta="${meta} ${tok_k}k"
  fi
fi

# Pass the line as an argument (not the format) so a literal "%" from ctx:NN%
# isn't parsed as a format directive; %b still expands the \033 color escapes.
printf '%b\n' "${arrow} ${dir_str}${git_str}${k8s_str}${meta}"

# --- Ghostty bottom-bar integration (additive; harmless outside tmux) ---
if [ -n "${TMUX_PANE:-}" ]; then
  mkdir -p "$HOME/.cache/ghostty-bar" 2>/dev/null
  {
    [ -n "$model" ] && printf '%s' "$model"
    [ -n "$used" ] && printf ' ctx:%s%%' "$(printf '%.0f' "$used")"
  } > "$HOME/.cache/ghostty-bar/claude-${TMUX_PANE}" 2>/dev/null || true
fi

# --- cmux sidebar (additive; harmless outside cmux) ---
if [ -n "${CMUX_SURFACE_ID:-}" ]; then
  # Write cache so bar-update.sh can include claude in the workspace description
  mkdir -p "$HOME/.cache/ghostty-bar" 2>/dev/null
  {
    [ -n "$model" ] && printf '%s' "$model"
    [ -n "$used" ] && printf ' ctx:%s%%' "$(printf '%.0f' "$used")"
  } > "$HOME/.cache/ghostty-bar/claude-${CMUX_SURFACE_ID}" 2>/dev/null || true

  claude_pill=""
  [ -n "$model" ] && claude_pill="$model"
  [ -n "$used" ] && claude_pill="${claude_pill} ctx:$(printf '%.0f' "$used")%"
  if [ -n "$claude_pill" ]; then
    /opt/homebrew/bin/cmux set-status claude "$claude_pill" --icon "cpu" --color "#1a4a6e" --priority 60 2>/dev/null || true
  fi
fi
