#!/usr/bin/env bash
#
# Main setup orchestrator. Safe to re-run.
#
#   ./install.sh
#
# Picks up the private overlay automatically if it's cloned to
# ~/github/tthyer/dotfiles-work (override with DOTFILES_OVERLAY).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERLAY_DIR="${DOTFILES_OVERLAY:-$HOME/github/tthyer/dotfiles-work}"
HOMEBREW_BASH=/opt/homebrew/bin/bash

# --------------------------------------------------------------- sudo
# First, so the one prompt it costs covers the sudo calls further down.
bash "$DOTFILES_DIR/setup/sudo-touchid.sh"

# ---------------------------------------------------------------- xcode
if [[ -d /Library/Developer/CommandLineTools ]]; then
  echo "==> Xcode command line tools already installed."
else
  echo "==> Installing Xcode command line tools..."
  xcode-select --install
  echo "    Re-run this script once the installer finishes."
  exit 0
fi

# ------------------------------------------------------------- homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed."
fi

echo "==> Updating Homebrew..."
brew update

echo "==> Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

if [[ -f "$OVERLAY_DIR/Brewfile.work" ]]; then
  echo "==> Installing packages from the private overlay..."
  brew bundle --file="$OVERLAY_DIR/Brewfile.work"
fi

# --------------------------------------------------------------- dotfiles
# After Homebrew, so the symlinks land on a machine that has the tools.
echo "==> Linking dotfiles..."
"$DOTFILES_DIR/dotfiles.sh"

# ------------------------------------------------------------ login shell
# Homebrew bash 5, not Apple's /bin/bash 3.2. Verifies rather than assumes.
if [[ -x "$HOMEBREW_BASH" ]]; then
  if ! grep -qF "$HOMEBREW_BASH" /etc/shells; then
    echo "==> Adding $HOMEBREW_BASH to /etc/shells (requires sudo)..."
    sudo bash -c "echo $HOMEBREW_BASH >> /etc/shells"
  fi
  user_shell=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
  if [[ "$user_shell" != "$HOMEBREW_BASH" ]]; then
    echo "==> Setting login shell to $HOMEBREW_BASH..."
    chsh -s "$HOMEBREW_BASH"
    user_shell=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
    if [[ "$user_shell" != "$HOMEBREW_BASH" ]]; then
      echo "    WARNING: login shell is still '$user_shell'. Set it by hand." >&2
    fi
  else
    echo "==> Login shell already $HOMEBREW_BASH."
  fi
fi

# ------------------------------------------------------------------ krew
if ! kubectl krew version &>/dev/null; then
  echo "==> Installing krew..."
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

# ------------------------------------------------- git bash completion
if [[ ! -e "$HOME/git-completion.bash" ]]; then
  echo "==> Fetching git bash completion..."
  curl -fsSL -o "$HOME/git-completion.bash" \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
fi

# ------------------------------------------------------ language tools
bash "$DOTFILES_DIR/setup/python-setup.sh"
bash "$DOTFILES_DIR/setup/node-setup.sh"
bash "$DOTFILES_DIR/java/java-setup.sh"

# Warn when the pinned Python minor version has fallen behind.
pinned_python="3.13"
latest_python=$(uv python list 2>/dev/null \
  | grep -oE 'cpython-[0-9]+\.[0-9]+\.[0-9]+-' \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
  | sort -t. -k1,1n -k2,2n -k3,3n \
  | tail -1 \
  | grep -oE '^[0-9]+\.[0-9]+')
if [[ -n "$latest_python" ]]; then
  if (( $(echo "$latest_python" | cut -d. -f2) > $(echo "$pinned_python" | cut -d. -f2) )); then
    echo "WARNING: Python $latest_python is available but dotfiles pin $pinned_python."
    echo "         Update 'uv python find $pinned_python' in shell/bash_profile."
  fi
fi

# ----------------------------------------------------- agents & macOS
bash "$DOTFILES_DIR/setup/agents-setup.sh"
bash "$DOTFILES_DIR/macos/defaults.sh"

# ---------------------------------------------------------- overlay
if [[ -x "$OVERLAY_DIR/apply.sh" ]]; then
  echo "==> Applying private overlay from $OVERLAY_DIR..."
  bash "$OVERLAY_DIR/apply.sh"
else
  echo "==> No private overlay found at $OVERLAY_DIR (skipping)."
  echo "    Work config lives there; clone it and re-run to pick it up."
fi

echo
echo "==> Done. Open a new shell, then check:"
echo "      echo \$BASH_VERSION        # expect 5.x"
echo "      dscl . -read ~/ UserShell  # expect $HOMEBREW_BASH"
