#!/usr/bin/env bash
# Generate an SSH key and register it with the agent and Keychain.
#
# Not called by install.sh — the normal path for a new machine is to copy
# ~/.ssh across by hand, which keeps existing keys and known_hosts. This is
# the fallback for a genuinely fresh key.
#
#   bash setup/ssh-setup.sh [comment]
set -euo pipefail

KEY="$HOME/.ssh/id_ed25519"
COMMENT="${1:-$(whoami)@$(scutil --get ComputerName 2>/dev/null || hostname)}"

if [[ -f "$KEY" ]]; then
  echo "$KEY already exists — not overwriting."
else
  # ed25519 rather than RSA: shorter, faster, and no key-size question.
  ssh-keygen -t ed25519 -C "$COMMENT" -f "$KEY"
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
chmod 600 "$KEY"

# Persist the passphrase in the login Keychain. `ssh-add -K` was Apple's old
# spelling and newer macOS removed it.
cat > "$HOME/.ssh/config.d-apple.tmp" <<'EOF'
Host *
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
if [[ -f "$HOME/.ssh/config" ]] && grep -q "UseKeychain" "$HOME/.ssh/config"; then
  rm -f "$HOME/.ssh/config.d-apple.tmp"
else
  cat "$HOME/.ssh/config.d-apple.tmp" >> "$HOME/.ssh/config"
  rm -f "$HOME/.ssh/config.d-apple.tmp"
  echo "Appended Keychain settings to ~/.ssh/config"
fi
chmod 600 "$HOME/.ssh/config"

ssh-add --apple-use-keychain "$KEY"

echo
echo "Public key — add it at https://github.com/settings/keys"
echo
cat "${KEY}.pub"
command -v pbcopy >/dev/null && pbcopy < "${KEY}.pub" && echo && echo "(copied to clipboard)"
