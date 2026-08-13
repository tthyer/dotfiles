#!/usr/bin/env bash
# Install the Xcode Command Line Tools without the GUI dialog.
#
# `xcode-select --install` opens a dialog someone has to click, which is no
# use over SSH. softwareupdate can do it headlessly, but won't list the tools
# until a trigger file exists. Two details that are easy to get wrong:
#
#   - The path is /tmp, not /var/tmp. Different directories on macOS.
#   - The label reads "Command Line Tools for Xcode 26.6-26.6" — a space
#     before the version, not a hyphen. Patterns assuming a hyphen never match.
#
# Extraction follows Homebrew's installer, which is the reference for this and
# stays current. Several versions are usually offered; sort -V takes the newest.
#
# Needs sudo, so it prompts. Run before Homebrew — nothing in the Brewfile
# compiles without it.
#
#   bash setup/clt-setup.sh
set -euo pipefail

TRIGGER=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
CLT_DIR=/Library/Developer/CommandLineTools

if [[ -e "$CLT_DIR/usr/bin/git" ]]; then
  echo "Command Line Tools already installed at $CLT_DIR"
  exit 0
fi

# /tmp is world-writable, so listing needs no sudo — only installing does.
cleanup() { rm -f "$TRIGGER" 2>/dev/null || true; }
trap cleanup EXIT
touch "$TRIGGER"

LABEL=$(softwareupdate -l 2>/dev/null |
  grep -B 1 -E 'Command Line Tools' |
  awk -F'*' '/^ *\*/ {print $2}' |
  sed -e 's/^ *Label: //' -e 's/^ *//' |
  sort -V |
  tail -1)

if [[ -z "$LABEL" ]]; then
  echo "softwareupdate offered nothing. Falling back to the dialog — you'll" >&2
  echo "need to click through it on the machine itself." >&2
  xcode-select --install
  exit 1
fi

echo "==> Installing $LABEL"
sudo softwareupdate -i "$LABEL" --verbose

# Point xcode-select at what we just installed, as Homebrew does.
sudo xcode-select --switch "$CLT_DIR"

if [[ -e "$CLT_DIR/usr/bin/git" ]]; then
  echo
  echo "Installed at $(xcode-select -p)"
  echo "clang:  $(clang --version 2>/dev/null | head -1)"
  echo "git:    $(git --version 2>/dev/null)"
else
  echo "Install reported success but $CLT_DIR/usr/bin/git is missing." >&2
  exit 1
fi
