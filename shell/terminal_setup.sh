# Set the following to suppress this message on opening terminal windows:
# "The default interactive shell is now zsh."
export BASH_SILENCE_DEPRECATION_WARNING=1

# Prompt colors
NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\033[1;33m\]"
GREEN="\[\033[1;32m\]"

# Cheap az/k8s/env lookups shared with the Claude Code statusline.
# Resolve the real path since this file is sourced via a ~/.terminal_setup.sh symlink.
_ts_src="${BASH_SOURCE[0]}"
_ts_dir="$(cd "$(dirname "$(readlink "$_ts_src" 2>/dev/null || echo "$_ts_src")")" && pwd)"
[[ -r "$_ts_dir/context_segments.sh" ]] && source "$_ts_dir/context_segments.sh"
unset _ts_src _ts_dir

set_prompt() {
  local venv=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv="($(basename "$VIRTUAL_ENV")) "
  fi

  # Publish AMPERON_ENV to a per-pane file the Ghostty bottom bar reads (it
  # can't see the shell's env directly). Harmless outside tmux.
  if [[ -n "${TMUX_PANE:-}" ]]; then
    mkdir -p "$HOME/.cache/ghostty-bar" 2>/dev/null
    printf '%s' "${AMPERON_ENV:-}" > "$HOME/.cache/ghostty-bar/amp-$TMUX_PANE" 2>/dev/null
  fi
  PS1="${venv}${BLUE}\W ${GREEN}az:$(amp_az) k8s:$(amp_k8s) amp:$(amp_env) ${YELLOW}$(date +'%H:%M:%S') ${NORMAL}\$ "
}

PROMPT_COMMAND=set_prompt

## Colorizes output of `ls`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Set terminal tab titles
tabTitle() { echo -ne "\033]0;$*\007"; }
