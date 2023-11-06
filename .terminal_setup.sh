## iterm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash" || true

# Set the following to suppress this message on opening terminal windows:
# "The default interactive shell is now zsh."
# "To update your account to use zsh, please run `chsh -s /bin/zsh`."
# "For more details, please visit https://support.apple.com/kb/HT208050."
export BASH_SILENCE_DEPRECATION_WARNING=1

# Prompt colors
NORMAL="\[\033[00m\]"
BLUE="\[\033[01;34m\]"
YELLOW="\[\033[1;33m\]"
GREEN="\[\033[1;32m\]"
AQUA="\[\033[1;36m\]"

## Set the Command Prompt
#export PS1="${BLUE}\W ${GREEN}\u ${YELLOW}\$(date +'%H:%M:%S') ${NORMAL}\$ \[\$(iterm2_print_user_vars)\]"
export PS1="${BLUE}\W ${GREEN}(gcp:\$(gcloud info --format='value(config.active_config_name)') k8s:\$(kubectl config current-context) amp:${AMPERON_ENV}) ${YELLOW}\$(date +'%H:%M:%S') ${NORMAL}\$ "

## Colorizes output of `ls`
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

## Add iterm2 vars
iterm2_print_user_vars() {
  iterm2_set_user_var awsProfile "☁️ $AWS_PROFILE"
  iterm2_set_user_var amperonEnv "⚡️ $AMPERON_ENV"
}

## Set iTerm2 tab titles
tabTitle() { echo -ne "\033]0;"$*"\007"; }

## sets the window name (tab) for iterm
unset PROMPT_COMMAND
test -n $ITERM_SESSION_ID && export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"${PROMPT_COMMAND}";
