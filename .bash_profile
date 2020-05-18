test -f ~/.bashrc && source ~/.bashrc

NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\e[1;33m\]"
GREEN="\[\e[1;32m\]"

# if [ -f "${HOME}/kube-prompt.sh" ]; then
#   source "${HOME}/kube-prompt.sh"
# fi

## Set the Command Prompt
# export PS1="${BLUE}\W ${GREEN}\u${YELLOW}\$(__kube_ps1)${NORMAL} \$ "
export PS1="${BLUE}\W ${GREEN}\u ${NORMAL}\$ "

## Colorizes output of `ls`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Set iTerm2 tab titles
tabTitle() { echo -ne "\033]0;"$*"\007"; }

## Always list directory contents and set title upon 'cd'
cd() { builtin cd "$@"; ls  --color=auto -lFah; tabTitle ${PWD##*/}; }

## sets the window name (tab) for iterm
unset PROMPT_COMMAND
test -n $ITERM_SESSION_ID && export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"${PROMPT_COMMAND}";


## ENVIRONMENT VARIABLES
export JAVA_HOME=$(/usr/libexec/java_home)
export SPARK_HOME="/usr/local/Cellar/apache-spark/2.4.4"

## PATH MANIPULATION
export PATH="/usr/local/opt/scala@2.11/bin:${PATH}"         # Scala
export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"        # Homebrew
export PATH="/usr/local/opt/python/libexec/bin:${PATH}"     # Python3
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" # GNU utilities
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"          # openssl

## JAVA
launchctl setenv JAVA_HOME $JAVA_HOME

## ALIASES
alias ls='ls --color=auto'
alias epoch='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias notes='subl ~/Notes'
alias beep='echo -e "\a"'

if [[ -f "${HOME}/.aws_aliases" ]]; then
  source "${HOME}/.aws_aliases"
fi

### K8S ALIASES
alias kc='kubectl'
alias kc-context='kubectl config current-context'

getPodImage() {
 kc get pod $1 -o json | jq '.spec.containers[].image'
}

getPodNode() {
  kc get pod $1 -o json | jq '.spec.nodeName'
}

sshPod() {
  kc exec -it $1 -- bash
}

opsPodName() {
  cut -d'/' -f2 <<< $(kubectl -n=default get pod -l name=k8s-ops-tools -o name)
}

opsPod() {
  kc -n=default exec -it $(opsPodName) -- bash
}

opsPodExec() {
  kc -n=default exec -it $(opsPodName) -- $1
}

copyFromOpsPod() {
  kc cp default/$(opsPodName):$1 $2
}

copyToOpsPod() {
  kc cp $1 default/$(opsPodName):$2
}

## HOMEBREW
if [[ -f "${HOME}/Dropbox/Code/tokens/homebrew" ]]; then
	export HOMEBREW_GITHUB_API_TOKEN="$(cat ${HOME}/Dropbox/Code/tokens/homebrew)"
fi

## BASH COMPLETION
test -e "$(brew --prefix)/etc/bash_completion" && . $(brew --prefix)/etc/bash_completion

# The next line updates PATH for the Google Cloud SDK.
# if [[ -f "${HOME}/google-cloud-sdk/path.bash.inc" ]]; then
#   source "${HOME}/google-cloud-sdk/path.bash.inc"
# fi

# The next line enables shell command completion for gcloud.
# if [[ -f "${HOME}/google-cloud-sdk/completion.bash.inc" ]]; then
#   source "${HOME}/google-cloud-sdk/completion.bash.inc"
# fi

# Kubectl shell completion
# if [[ -f "${HOME}/.kube/completion.bash.inc" ]]; then
#   source "${HOME}/.kube/completion.bash.inc"
# fi


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
eval "$(pyenv init -)"
