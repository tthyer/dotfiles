
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# source ${HOME}/bash_functions.sh

set_prompt() {
  local venv=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv="($(basename "$VIRTUAL_ENV")) "
  fi

  PS1="${venv}${BLUE}\W ${GREEN}az:$(az account show --query name -o tsv 2>/dev/null) k8s:$(kubectl config current-context 2>/dev/null)/$(kubens -c 2>/dev/null) amp:$(echo $AMPERON_ENV) ${YELLOW}$(date +'%H:%M:%S') ${NORMAL}\$ "
}

PROMPT_COMMAND=set_prompt
eval "$(direnv hook bash)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
