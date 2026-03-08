### TERMINAL SETUP
source ${HOME}/bash_functions.sh

## iterm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

## customize iterm2
test -h "${HOME}/.terminal_setup.sh" && source "${HOME}/.terminal_setup.sh"


### HOMEBREW ENVIRONMENT VARIABLES
eval "$(/opt/homebrew/bin/brew shellenv)"

### UV PYTHON - prioritize over Homebrew Python
export PATH="${HOME}/.local/share/uv/python/cpython-3.13.3-macos-aarch64-none/bin:$PATH"

### AIRFLOW CLI
# Removed: was polluting PATH and breaking pre-commit hooks in other projects
# Use `uv run airflow` or activate the airflow venv explicitly when needed

### COMPLETION

## Bash Completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && source "/opt/homebrew/etc/profile.d/bash_completion.sh"

## AWS completion
complete -C '/opt/homebrew/bin/aws_completer' aws

## Git Completion
[[ -r "${HOME}/git-completion.bash" ]] && source "${HOME}/git-completion.bash"

## dbt completion
[[ -r "${HOME}/.dbt-completion.bash" ]] && source "${HOME}/.dbt-completion.bash"

## Terraform completion
complete -C /opt/homebrew/bin/terraform terraform


### ALIASES

alias ls='ls -G'
alias epoch='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias beep='echo -e "\a"'

# Directory navigation shortcuts
alias amperon='cd "$HOME/github/amperon/amperon" && echo "📁 Switched to amperon repo: $(pwd)" && ls -la'
alias infra='cd "$HOME/github/amperon/infra-azure" && echo "🏗️ Switched to infra-azure repo: $(pwd)" && ls -la'
alias repos='echo "Available repositories:" && echo "  amperon - Main amperon repository" && echo "  infra   - Infrastructure (Azure) repository"'


### PATH MANIPULATION

pathadd "${HOME}/.local/bin" # system-wide python installs
pathadd "${KREW_ROOT:-$HOME/.krew}/bin"
pathadd "/opt/homebrew/bin"
pathadd "${HOME}/go/bin"

### K8S aliases and functions
if [[ -f "${HOME}/.k8s" ]]; then
  source "${HOME}/.k8s"
fi


### PYTHON

#export PYENV_ROOT="$HOME/.pyenv"
#command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init -)"


### SET DEFAULT AWS PROFILE
#export AWS_PROFILE=devadmin


source "$HOME/java-setup.sh"

# The next line updates PATH for the Google Cloud SDK.
#if [ -f '/Users/tessthyer/.gcloud/google-cloud-sdk/path.bash.inc' ]; then . '/Users/tessthyer/.gcloud/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '/Users/tessthyer/.gcloud/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/tessthyer/.gcloud/google-cloud-sdk/completion.bash.inc'; fi


### ARGO
export ARGO_API_URL=http://localhost:2746/api/v1
export MONO="$HOME/github/amperon/amperon"

# disable bracketed paste mode
bind 'set enable-bracketed-paste off'

eval "$(direnv hook bash)"

if [ -f ~/.bashrc ]; then
    echo "sourcing .bashrc"
    source ~/.bashrc
fi


