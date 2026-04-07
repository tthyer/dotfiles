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
  himalaya
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

# Check if a newer stable Python major/minor version is available
pinned_python="3.13"
latest_python=$(uv python list 2>/dev/null \
  | grep -oE 'cpython-[0-9]+\.[0-9]+\.[0-9]+-' \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
  | sort -t. -k1,1n -k2,2n -k3,3n \
  | tail -1 \
  | grep -oE '^[0-9]+\.[0-9]+')
if [[ -n "$latest_python" ]]; then
  pinned_minor=$(echo "$pinned_python" | cut -d. -f2)
  latest_minor=$(echo "$latest_python" | cut -d. -f2)
  if (( latest_minor > pinned_minor )); then
    echo "WARNING: Python $latest_python is available but dotfiles are pinned to $pinned_python."
    echo "         Update 'uv python find $pinned_python' in shell/bash_profile to use the newer version."
  else
    echo "Python pin ($pinned_python) is up to date."
  fi
fi

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
