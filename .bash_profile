test -f ~/.bashrc && source ~/.bashrc

NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\e[1;33m\]"
GREEN="\[\e[1;32m\]"

# if [ -f /Users/tthyer/kube-prompt.sh ]; then
#   source ~/kube-prompt.sh
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
cd() { builtin cd "$@"; ls -lFah; tabTitle ${PWD##*/}; }

## sets the window name (tab) for iterm
unset PROMPT_COMMAND
test -n $ITERM_SESSION_ID && export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";


## ENVIRONMENT VARIABLES
export JAVA_HOME=$(/usr/libexec/java_home)
export SPARK_HOME=/spark-2.3.2-bin-hadoop2.7

## PATH MANIPULATION
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/opt/scala@2.11/bin:$PATH"     # for Scala
export PATH="$SPARK_HOME/bin:$PATH"                   # for Spark
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"    # for Homebrew
export PATH="/usr/local/opt/python/libexec/bin:$PATH" # for Python3

## JAVA
launchctl setenv JAVA_HOME $JAVA_HOME

## ALIASES
alias hidden='ls -a | grep "^\."'
alias hiddenl='ls -l -a | grep ".*\."'
alias epoch='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias timecurl='curl -w "@/Users/tthyer/.curl/curl-format.txt" -o /dev/null -s \!^'
alias notes='subl ~/Notes'
alias beep='echo -e "\a"'

### K8S ALIASES
alias kc='kubectl'
alias kc-context='kubectl config current-context'
alias kc-aws='kubectl config use-context aws'
alias kc-gke='kubectl config use-context gke'

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

## KAFKA
alias startKafka="zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties & kafka-server-start /usr/local/etc/kafka/server.properties"
alias stopKafka="kafka-server-stop & zookeeper-server-stop"

## MAVEN
alias quickBuild="mvn clean package -Dmaven.buildNumber.doCheck=false"

## SUBLIME
subl () {
    open -a "Sublime Text" $@
}

## HOMEBREW
export HOMEBREW_GITHUB_API_TOKEN="b9b2a0597f7163306bd302d5d6be416c729a2a53"

## BASH COMPLETION
test -e "$(brew --prefix)/etc/bash_completion" && . $(brew --prefix)/etc/bash_completion

# The next line updates PATH for the Google Cloud SDK.
# if [ -f /Users/tthyer/google-cloud-sdk/path.bash.inc ]; then
#   source '/Users/tthyer/google-cloud-sdk/path.bash.inc'
# fi

# The next line enables shell command completion for gcloud.
# if [ -f /Users/tthyer/google-cloud-sdk/completion.bash.inc ]; then
#   source '/Users/tthyer/google-cloud-sdk/completion.bash.inc'
# fi

# Kubectl shell completion
# if [-f /Users/tthyer/.kube/completion.bash.inc]; then
#   source '/Users/tthyer/.kube/completion.bash.inc'
# fi


test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/tessthyer/google-cloud-sdk/path.bash.inc' ]; then . '/Users/tessthyer/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/tessthyer/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/tessthyer/google-cloud-sdk/completion.bash.inc'; fi

complete -C '/usr/local/bin/aws_completer' aws
