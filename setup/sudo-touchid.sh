#!/usr/bin/env bash
# Authenticate sudo with Touch ID instead of typing a password.
#
# macOS 14 added /etc/pam.d/sudo_local, which /etc/pam.d/sudo includes and
# which system updates leave alone. Editing /etc/pam.d/sudo directly works too
# but gets reverted, so this writes sudo_local.
#
# The rule is `sufficient`, so if Touch ID isn't available the stack falls
# through to the password as before. That matters because Touch ID does not
# work over SSH — there's no sensor on the far end of the connection. Run
# install.sh sitting at the machine to get the benefit; over SSH you'll still
# be typing.
#
# Costs one sudo prompt to save the rest.
#
#   bash setup/sudo-touchid.sh
set -euo pipefail

PAM_SUDO=/etc/pam.d/sudo
PAM_LOCAL=/etc/pam.d/sudo_local

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Not macOS — skipping Touch ID for sudo."
  exit 0
fi

if ! grep -qE '^\s*auth\s+include\s+sudo_local' "$PAM_SUDO" 2>/dev/null; then
  echo "$PAM_SUDO doesn't include sudo_local — too old for this approach." >&2
  echo "Skipping rather than editing $PAM_SUDO, which updates revert." >&2
  exit 0
fi

if [[ -f "$PAM_LOCAL" ]] && grep -qE '^\s*auth\s+sufficient\s+pam_tid\.so' "$PAM_LOCAL"; then
  echo "Touch ID for sudo already enabled."
  exit 0
fi

# Enrolled fingerprints, as against a machine that merely has a sensor.
if ! bioutil -r 2>/dev/null | grep -q 'Effective biometrics for unlock: 1'; then
  echo "No fingerprints enrolled — enrol one in System Settings first." >&2
  exit 0
fi

echo "==> Enabling Touch ID for sudo (needs sudo once)"
sudo tee "$PAM_LOCAL" >/dev/null <<'EOF'
# Managed by dotfiles: setup/sudo-touchid.sh
# Included by /etc/pam.d/sudo, and preserved across system updates.
auth       sufficient     pam_tid.so
EOF
sudo chmod 444 "$PAM_LOCAL"

if grep -q pam_tid.so "$PAM_LOCAL"; then
  echo "    Done. Open a new terminal and try 'sudo -k; sudo true'."
else
  echo "    Failed to write $PAM_LOCAL." >&2
  exit 1
fi
