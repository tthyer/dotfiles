#!/usr/bin/env bash

set -e

# Move dotfiles into place
./dotfiles.sh

# Change the default shell to bash
user_shell=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
if [[ "$user_shell" != *bash* ]]; then
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

brew update

installed_casks=( $(brew list --cask -1) )
casks=(
  iterm2
  sublime-text
  docker
  slack
  google-chrome
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
  Azure/kubelogin/kubelogin
  azure-cli
  bash-completion
  gnu-sed
  jq
  kubectl
  kubectx
  openjdk
  tree
  utc-menu-clock
  uv
  watch
  wget
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

# install krew for k8s (idempotent)
if ! kubectl krew version &>/dev/null; then
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
fi

# download git autocompletion script
if [[ ! -e "$HOME/git-completion.bash" ]]; then
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P "$HOME"
fi

# Setup iTerm2 shell integration (idempotent)
if [[ ! -e "$HOME/.iterm2_shell_integration.bash" ]]; then
  curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
fi

# Setup Python
bash setup/python-setup.sh

# Setup Java
bash java/java-setup.sh


source "${HOME}/.bash_profile"

# Set bottom left hot corner to sleep display
echo "Setting hot corner..."
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
killall Dock
echo "Done."

bash config/sublime/sublime.sh

set +e
