test -e "${HOME}/.bashrc" && source "${HOME}/.bashrc"

## Bash Completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

## AWS completion
complete -C '/usr/local/bin/aws_completer' aws

# Git Completion
if [[ -f "${HOME}/.git-completion.bash" ]]; then
  source "${HOME}/.git-completion.bash"
fi

## ALIASES
alias ls='ls -G'
alias epoch='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias notes='subl ~/Notes'
alias beep='echo -e "\a"'

## Always list directory contents and set title upon 'cd'
cd() { builtin cd "$@"; echo $PWD && ls -lFah; tabTitle ${PWD##*/}; }

## PATH MANIPULATION
# pathadd "/opt/homebrew/bin" # things installed by homebrew 
pathadd "${HOME}/.local/bin" # system-wide python installs

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
source ~/.config-java-spark.sh

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
  else
    AWS_PROFILE=service-catalog
    ssh -i ~/.ssh/id_rsa ec2-user@${target}
  fi
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

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

## iterm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true
eval "$(/opt/homebrew/bin/brew shellenv)"
