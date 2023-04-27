#!/usr/bin/env bash

set -e

# Move dotfiles into place
./dotfiles.sh

# Change the default shell to bash
# get user's default shell rather than the current shell available in the
# $SHELL variable
user_shell=$(finger $USER | grep 'Shell:*')
desired_shell="bash"
if grep -vq $desired_shell <<< $user_shell; then
  # this will prompt for password
  chsh -s /bin/bash
fi

# Install command line tools
if [[ -d /Library/Developer/CommandLineTools ]]; then
 echo "Xcode command line tools already installed, skipping."
else
 echo "Installing xcode command line tools"
  xcode-select --install
fi

# HOMEBREW
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "Done."
else
  echo "Homebrew is already installed, skipping."
fi

required_brew_dirs=( /usr/local/lib/pkgconfig /usr/local/share/info /usr/local/share/man/man3 /usr/local/share/man/man5 )
for i in "${required_brew_dirs[@]}"
do
  if [[ ! -d $i ]]; then
    echo "Making required brew directory $i"
    sudo mkdir -p $i
    sudo chown -R $(whoami) $i
    chmod u+w $i
  else
    echo "Required directory $i already exists"
  fi
done

if [[ -z $(which r) ]]; then
  pkgname=R-4.2.1.pkg
  dir=${HOME}/Downloads
  wget https://cran.r-project.org/bin/macosx/base/${pkgname} -P ${dir}
  sudo installer -pkg ${dir}/${pkgname} -target /
fi

installed_casks=( $(brew list --cask -1) )
casks=(
  iterm2
  sublime-text
  font-inconsolata-nerd-font
  intellij-idea-ce
  #r #install this from CRAN instead -- when installed from homebrew there are dependency issues
  rstudio
  docker
  slack
  google-chrome
  session-manager-plugin #https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
  )
for cask in "${casks[@]}"
do
  if [[ "${installed_casks[@]}" =~ "${cask}" ]]; then
    echo "${cask} is already installed, skipping."
  else
    echo "Installing ${cask} through Homebrew Cask..."
    brew install --cask "${cask}"
    echo "Done."
  fi
done

brew tap dbt-labs/dbt

installed_formulae=( $(brew list --formula -1) )
formulae=(
  openjdk
  tree
  wget
  gnu-sed
  bash-completion
  pyenv
  jq
  awscli
  graphviz
  watch
  utc-menu-clock
  dbt-redshift
  )
for formula in "${formulae[@]}"
do
  if [[ "${installed_formulae[@]}" =~ "${formula}" ]]; then
    echo "${formula} is already installed, skipping."
  else
    echo "Installing ${formula} through Homebrew..."
    brew install "${formula}"
    echo "Done."
  fi
done

# download git autocompletion script
if [ ! -e $HOME/git-completion.bash ]; then
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P $HOME
fi

# download dbt autocompletion script
if [ ! -e $HOME/.dbt-completion.bash ]; then
  wget https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash -P $HOME
fi

# Setup iTerm2 shell integration
curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash

# Setup Python
bash python-setup.sh

# Setup Java
bash java-setup.sh


source "${HOME}/.bash_profile"

# Set bottom left hot corner to sleep display
echo "Setting hot corner..."
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
killall Dock
echo "Done."

bash sublime.sh

other_things_todo=(
  "Log into Chrome"
  "Install LastPass extension in Chrome"
  "Paste license into Sublime"
  "Sync Sublime Settings"
  "Goto https://coderwall.com/p/h6yfda/use-and-to-jump-forwards-backwards-words-in-iterm-2-on-os-x for instructions on how to set up word navigation in iTerm"
  "TODO: find other keys configuration needed for iTerm"
  "Open Docker Desktop and login. You will also need to login on the command line."
  )

echo "Other things to do:"
for i in "${other_things_todo[@]}"
do
  echo $i
done

set +e
