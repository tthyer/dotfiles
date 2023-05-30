#!/usr/bin/env bash


# adds a string to PATH, if it's not there already
# from https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathadd() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="${PATH:+"$PATH:"}$1"
  fi
}

testfunc() {
  echo "test func!"
}

## Always list directory contents and set title upon 'cd'
cd() { builtin cd "$@"; echo $PWD && ls -lFah; tabTitle ${PWD##*/}; }


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
  pipenv install ipykernel jupyterlab --dev
  pipenv run python -m ipykernel install --user --name=$ENVIRONMENT_NAME
  echo "A kernel ${ENVIRONMENT_NAME} was created."
  echo "To use activate the python environment, start jupyter, and select the kernel."
}

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

# use this to login if using AWS  SSO
awsLogin() {
  defaultProfile=etl-dev-admin
  profile=$1
  if [[ -z $profile ]]; then
    profile=$defaultProfile
  fi
  aws sso login --profile $profile
  export AWS_PROFILE=$profile
}

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
