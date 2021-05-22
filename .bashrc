# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# bash: Place this in .bashrc.
function iterm2_print_user_vars() {
  iterm2_set_user_var awsProfile "☁️ $AWS_PROFILE"
}