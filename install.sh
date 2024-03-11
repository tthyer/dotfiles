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

brew update

installed_casks=( $(brew list --cask -1) )
casks=(
  iterm2
  sublime-text
  docker
  slack
  google-chrome
  #rstudio
  #session-manager-plugin #https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
  dbeaver-community
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


installed_formulae=( $(brew list --formula -1) $(brew list --cask -1))
formulae=(
  openjdk
  tree
  wget
  gnu-sed
  bash-completion
  pyenv
  jq
  awscli
  azure-cli
  Azure/kubelogin/kubelogin #azure-specific kubectl plugin
  watch
  utc-menu-clock
  gdal # Geospatial Data Abstraction Library is a computer software library for reading and writing raster and vector geospatial data formats
  mysql-client@5.7
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

# install krew for k8s
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)


# download git autocompletion script
if [[ ! -e $HOME/git-completion.bash ]]; then
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P $HOME
fi

# download dbt autocompletion script
if [[ ! -e $HOME/dbt-completion.bash ]]; then
  wget https://raw.githubusercontent.com/fishtown-analytics/dbt-completion.bash/master/dbt-completion.bash -P $HOME
fi

#install r
if [[ -z $(which r) ]]; then
  pkgname=R-4.3.0-arm64.pkg
  dir=${HOME}/Downloads
  wget https://cran.r-project.org/bin/macosx/big-sur-arm64/base/${pkgname} -P ${dir}
  sudo installer -pkg ${dir}/${pkgname} -target /
fi

# Setup iTerm2 shell integration
curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash

# Setup Python
bash python-setup.sh

# Setup Java
bash java-setup.sh


source "${HOME}/.bash_profile"


# VS code -- TODO would be nice to have this installed from here.



## Google Cloud, and friends
bash gcloud.sh

# Set bottom left hot corner to sleep display
echo "Setting hot corner..."
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
killall Dock
echo "Done."

bash sublime.sh

set +e
