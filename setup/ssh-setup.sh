#!/usr/bin/env bash
# Generate an SSH key and register it with the agent and Keychain.
#
# Not called by install.sh, because it has to run before the repo can be
# cloned — the key is what clones it. Copy it across with scp, or curl it
# from the raw GitHub URL.
#
# A fresh key per machine is the intended path. Copying ~/.ssh across keeps
# known_hosts and saves a GitHub round trip, but any passphraseless private
# key is a plaintext credential and moving it is the risky part.
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

# macOS gives the agent socket to the GUI login session via launchd, so an
# incoming SSH connection has no SSH_AUTH_SOCK and ssh-add fails. Not fatal —
# UseKeychain and AddKeysToAgent above mean the first use in a console session
# stores the passphrase anyway. Don't let it abort before printing the key.
if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
  ssh-add --apple-use-keychain "$KEY"
else
  echo "No ssh-agent in this session — skipping ssh-add."
  echo "Run this in Terminal on the machine itself to store the passphrase:"
  echo "  ssh-add --apple-use-keychain $KEY"
fi

echo
echo "Public key — add it at https://github.com/settings/keys"
echo
cat "${KEY}.pub"
command -v pbcopy >/dev/null && pbcopy < "${KEY}.pub" && echo && echo "(copied to clipboard)"
