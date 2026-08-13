#!/usr/bin/env bash
# macOS system preferences.
#
# Only the Dock settings below were customised on the previous machine; the
# rest were stock. Everything here is a deliberate choice rather than a
# restoration, so comment out anything you'd rather set by hand.
set -euo pipefail

echo "==> Applying macOS defaults..."

# ------------------------------------------------------------ appearance
# Dark mode. More than cosmetic: Ghostty's theme line is
# `light:GitHub Light High Contrast,dark:GitHub Dark High Contrast`, which
# follows the system appearance — so a fresh Mac, which ships in Light,
# gives you a blinding white terminal until this is set.
#
# osascript rather than `defaults write -g AppleInterfaceStyle`: the defaults
# key doesn't reliably reach a running session, and deleting it is how you
# get back to Light. This applies immediately.
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' 2>/dev/null || \
  echo "    Couldn't set dark mode — needs Automation permission for the terminal."

# ------------------------------------------------------------------ dock
defaults write com.apple.dock tilesize -int 84
defaults write com.apple.dock magnification -bool true

# Bottom-left hot corner puts the display to sleep.
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0

# -------------------------------------------------------------- keyboard
# Faster key repeat. KeyRepeat is in 15ms units, so 2 = 30ms; the System
# Settings slider bottoms out at 15ms (1) and its fastest UI value is 2.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Hold a key to repeat it rather than opening the accent picker. Required
# for key-repeat in vim; takes effect on app restart.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ---------------------------------------------------------------- finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ----------------------------------------------------------- screenshots
screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"
defaults write com.apple.screencapture location -string "$screenshot_dir"
defaults write com.apple.screencapture disable-shadow -bool true

# ------------------------------------------------------------------ misc
# Don't write .DS_Store onto network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "    Done. Some settings need a logout or app restart to take effect."
