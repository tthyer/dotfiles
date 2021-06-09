test -f ~/.bashrc && source ~/.bashrc

NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\e[1;33m\]"
GREEN="\[\e[1;32m\]"

## Set the Command Prompt
#export PS1="${BLUE}\W ${GREEN}\u ${YELLOW}\$(date --iso-8601=seconds) ${NORMAL}\$ "
#export PS1="\$(iterm2_print_user_vars)${BLUE}\W ${GREEN}\u ${NORMAL}\$ "
export PS1="${BLUE}\W ${GREEN}\u ${NORMAL}\$ "

## Colorizes output of `ls`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Set iTerm2 tab titles
tabTitle() { echo -ne "\033]0;"$*"\007"; }

## ALIASES
alias ls='ls -G'
alias epoch='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias notes='subl ~/Notes'
alias beep='echo -e "\a"'

## Always list directory contents and set title upon 'cd'
cd() { builtin cd "$@"; echo $PWD && ls -lFah; tabTitle ${PWD##*/}; }

## sets the window name (tab) for iterm
unset PROMPT_COMMAND
test -n $ITERM_SESSION_ID && export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"${PROMPT_COMMAND}";

## PATH MANIPULATION
export PATH="$(brew --prefix scala)/bin:${PATH}" # Scala
export PATH="/opt/homebrew/bin:${PATH}".         # Homebrew bin
export PATH="${HOME}/.local/bin:${PATH}"         # Local pip installs

## K8S aliases and functions
if [[ -f "${PWD}/.k8s" ]]; then
  source "${PWD}/.k8s"
fi

## TOKENS
if [[ -f "${HOME}/Dropbox/Code/tokens/homebrew" ]]; then
	export HOMEBREW_GITHUB_API_TOKEN="$(cat ${HOME}/Dropbox/Code/tokens/homebrew)"
fi
if [[ -f "${HOME}/Dropbox/Code/tokens/ghcr" ]]; then
  export GHCR_TOKEN="$(cat ${HOME}/Dropbox/Code/tokens/ghcr)"
fi

## BASH COMPLETION
test -e "$(brew --prefix)/etc/bash_completion" && . $(brew --prefix)/etc/bash_completion

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

#complete -C '/usr/local/bin/aws_completer' aws

# Git Completion
if [[ -f "${HOME}/.git-completion.bash" ]]; then
  source "${HOME}/.git-completion.bash"
fi

# Validate a Cloudformation template
validateTemplate() {
  template_path=$1
  profile=$2
  if [[ -z profile ]]; then
    profile=default
  fi
  aws --profile $profile cloudformation validate-template --template-body file://$template_path
}

# Create new python module
module() {
  moduleName=$1
  mkdir $moduleName
  touch $moduleName/__init__.py
  touch $moduleName/$moduleName.py
}

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# create a kernel for use in jupyter notebook
pykernel() {
  ENVIRONMENT_NAME=$1
  if [[ -z $ENVIRONMENT_NAME ]]; then
    echo "a name for the environment must be the first argument"
  fi
  pipenv install ipykernel jupyterlab
  pipenv run python -m ipykernel install --user --name=$ENVIRONMENT_NAME
  echo "A kernel ${ENVIRONMENT_NAME} was created."
  echo "To use activate the python environment, start jupyter, and select the kernel."
}

# Configure Java and Spark
#echo "configuring java and spark"
#source ~/.config-java-spark.sh

#TODO troubleshoot java configuration 
