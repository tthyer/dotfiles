### TERMINAL SETUP

## iterm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

## customize iterm2
test -h "${HOME}/.terminal_setup.sh" && source "${HOME}/.terminal_setup.sh"


### HOMEBREW ENVIRONMENT VARIABLES
eval "$(/opt/homebrew/bin/brew shellenv)"


source ${HOME}/bash_functions.sh


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


### PATH MANIPULATION

pathadd "${HOME}/.local/bin" # system-wide python installs
pathadd "/opt/homebrew/opt/mysql-client@5.7/bin"
pathadd "${KREW_ROOT:-$HOME/.krew}/bin"
pathadd "/opt/homebrew/bin"

#export PKG_CONFIG_PATH="$(brew --prefix mysql-client@5.7)/lib/pkgconfig"

### K8S aliases and functions
if [[ -f "${HOME}/.k8s" ]]; then
  source "${HOME}/.k8s"
fi


### PYTHON

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


### SET DEFAULT AWS PROFILE
export AWS_PROFILE=devadmin


source "$HOME/java-setup.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tessthyer/.gcloud/google-cloud-sdk/path.bash.inc' ]; then . '/Users/tessthyer/.gcloud/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/tessthyer/.gcloud/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/tessthyer/.gcloud/google-cloud-sdk/completion.bash.inc'; fi

