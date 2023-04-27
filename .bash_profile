### TERMINAL SETUP

## iterm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

## customize iterm2
test -h "${HOME}/.terminal_setup.sh" && source "${HOME}/.terminal_setup.sh"


### HOMEBREW ENVIRONMENT VARIABLES
eval "$(/opt/homebrew/bin/brew shellenv)"


### FUNCTIONS

# adds a string to PATH, if it's not there already
# from https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="${PATH:+"$PATH:"}$1"
  fi
}

## Always list directory contents and set title upon 'cd'
cd() { builtin cd "$@"; echo $PWD && ls -lFah; tabTitle ${PWD##*/}; }

dotenv() {
  set -x
  env_file=$1
  if [[ -z $env_file ]]; then
    echo "requires an environment file argument"
  fi
  set -a; source "$env_file"; set +a
  set +x
}

undotenv() {
  env_file=$1
  if [[ -z $env_file ]]; then
    echo "requires an environment file argument"
  fi
  unset $(grep -v '^#' "$env_file" | sed -E 's/(.*)=.*/\1/' | xargs)
}

# some unused functions have been moved to bash_functions.sh


### COMPLETION

## Bash Completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && source "/opt/homebrew/etc/profile.d/bash_completion.sh"

## AWS completion
complete -C '/usr/local/bin/aws_completer' aws

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


### PATH MANIPULATION

# pathadd "/opt/homebrew/bin" # things installed by homebrew 
pathadd "${HOME}/.local/bin" # system-wide python installs


### K8S aliases and functions
if [[ -f "${PWD}/.k8s" ]]; then
  source "${PWD}/.k8s"
fi


### TOKENS

if [[ -f "${HOME}/Dropbox/Code/tokens/homebrew" ]]; then
	export HOMEBREW_GITHUB_API_TOKEN="$(cat ${HOME}/Dropbox/Code/tokens/homebrew)"
fi
if [[ -f "${HOME}/Dropbox/Code/tokens/ghcr" ]]; then
  export GHCR_TOKEN="$(cat ${HOME}/Dropbox/Code/tokens/ghcr)"
fi


### PYTHON

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


### DOCKER BUSINESS
source /Users/tessthyer/.docker/init-bash.sh || true # Added by Docker Desktop


### SET DEFAULT AWS PROFILE
export AWS_PROFILE=devadmin


source "$HOME/java-setup.sh"
