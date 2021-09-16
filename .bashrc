# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

## Bash Completion
test -e "$(brew --prefix)/etc/bash_completion" && . $(brew --prefix)/etc/bash_completion

## Iterm2 Shell Integration 
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

## AWS completinong
complete -C '/usr/local/bin/aws_completer' aws

# Git Completion
if [[ -f "${HOME}/.git-completion.bash" ]]; then
  source "${HOME}/.git-completion.bash"
fi

function iterm2_print_user_vars() {
  iterm2_set_user_var awsProfile "☁️ $AWS_PROFILE"
}
