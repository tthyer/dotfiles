test -f ~/.bashrc && source ~/.bashrc

## Bash Completion
test -e "$(brew --prefix)/etc/bash_completion" && . $(brew --prefix)/etc/bash_completion

## AWS completinon
complete -C '/usr/local/bin/aws_completer' aws

# Git Completion
if [[ -f "${HOME}/.git-completion.bash" ]]; then
  source "${HOME}/.git-completion.bash"
fi

## iterm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Prompt colors
NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\e[1;33m\]"
GREEN="\[\e[1;32m\]"

## Set the Command Prompt
export PS1="${BLUE}\W ${GREEN}\u ${YELLOW}\$(date +'%H:%M:%S') ${NORMAL}\$ \[\$(iterm2_print_user_vars)\]"

## Colorizes output of `ls`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Add iterm2 vars
iterm2_print_user_vars() {
  iterm2_set_user_var awsProfile "☁️ $AWS_PROFILE"
}

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
export PATH="$(brew --prefix scala)/bin:${PATH}"    # Scala
export PATH="/opt/homebrew/bin:${PATH}"             # Homebrew bin
export PATH="${HOME}/.local/bin:${PATH}"            # Local pip installs
export PATH="/usr/local/opt/mysql-client/bin:$PATH" # mysql (client only)
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" # use gnu coreutils
export SPARK_HOME=$(brew --prefix apache-spark)/libexec
export PATH="$SPARK_HOME/bin/:$PATH"

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

# start an ssm session
ssmSession() {
  target=$1
  if [[ -z $target ]]; then
    echo "an aws EC2 ID must be the first argument"
    return 1
  fi
  aws ssm start-session --profile service-catalog \
                        --target "${target}" \
                        --document-name AWS-StartInteractiveCommand \
                        --parameters command="sudo su - ec2-user"
}

scSSH() {
  set -ex
  target=$1
  if [[ -z $target ]]; then
    echo "an aws EC2 ID must be the first argument"
    #return 1
  fi
  AWS_PROFILE=service-catalog
  ssh -i ~/.ssh/id_rsa ec2-user@${target}
  set +ex
}

ssmPortForward() {
  set -ex
  target=$1
  remotePort=$2
  localPort=$3
  if [[ -z $target || -z $remotePort || -z $localPort ]]; then
    echo "arguments for an EC2 ID, a remote port, and a local port must be specified, and in that order"
    #return 1
  fi
  aws ssm start-session --profile service-catalog \
                      --target "${target}" \
                      --document-name AWS-StartPortForwardingSession \
                      --parameters '{"portNumber":["8787"],"localPortNumber":["8787"]}'
  set +ex
}

listAwsProfiles() {
  cat ~/.aws/config | grep '\['  
}

awsLogin() {
  defaultProfile=etl-dev-admin
  profile=$1
  if [[ -z $profile ]]; then
    profile=$defaultProfile
  fi
  aws sso login --profile $profile
  export AWS_PROFILE=$profile
}

# this is a form of completion for sceptre
eval "$(_SCEPTRE_COMPLETE=source sceptre)"
