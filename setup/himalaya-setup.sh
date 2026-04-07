#!/usr/bin/env bash
# Sets up the himalaya password helper for the current platform.
# Run once per machine after storing the Gmail app password.
#
# macOS:  security add-generic-password -a 'tess@amperon.co' -s 'himalaya' -w '<app-password>'
# Linux:  secret-tool store --label='himalaya' service himalaya account tess@amperon.co

set -euo pipefail

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/get-himalaya-password.sh" << 'EOF'
#!/usr/bin/env bash
if [[ "$(uname)" == "Darwin" ]]; then
    security find-generic-password -a 'tess@amperon.co' -s 'himalaya' -w
else
    secret-tool lookup service himalaya account tess@amperon.co
fi
EOF

chmod +x "$HOME/.local/bin/get-himalaya-password.sh"
echo "Himalaya password helper installed at ~/.local/bin/get-himalaya-password.sh"
echo ""
echo "Now store your Gmail app password:"
echo "  macOS: security add-generic-password -a 'tess@amperon.co' -s 'himalaya' -w '<app-password>'"
echo "  Linux: secret-tool store --label='himalaya' service himalaya account tess@amperon.co"
