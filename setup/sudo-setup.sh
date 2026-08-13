#!/usr/bin/env bash
# Make sudo bearable during a setup run. Two independent changes.
#
# Touch ID, via /etc/pam.d/sudo_local — added in macOS 14, included by
# /etc/pam.d/sudo, and left alone by system updates. Editing /etc/pam.d/sudo
# directly works but gets reverted. The rule is `sufficient`, so where Touch
# ID isn't available the stack falls through to the password as before. It
# does not work over SSH: there's no sensor at the far end.
#
# Ticket scope and lifetime, via /etc/sudoers.d. macOS keeps a separate sudo
# ticket per terminal, and Homebrew's cask installers shell out to sudo from
# subprocesses that don't share yours — so a `brew bundle` run re-prompts
# repeatedly no matter how recently you authenticated. `!tty_tickets` makes
# the grant per-user, which is the part that actually stops it; the longer
# timeout then covers the gaps between casks.
#
# That is a real loosening: for the window, any terminal on the machine can
# use the grant, not only the one you typed into. Reasonable on a
# single-user laptop that locks on sleep. Undo with
# `sudo rm /etc/sudoers.d/dotfiles-sudo`.
#
#   bash setup/sudo-setup.sh
set -euo pipefail

PAM_SUDO=/etc/pam.d/sudo
PAM_LOCAL=/etc/pam.d/sudo_local
SUDOERS_D=/etc/sudoers.d/dotfiles-sudo
TIMESTAMP_TIMEOUT=${TIMESTAMP_TIMEOUT:-30}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Not macOS — nothing to do."
  exit 0
fi

enable_touch_id() {
  if ! grep -qE '^\s*auth\s+include\s+sudo_local' "$PAM_SUDO" 2>/dev/null; then
    echo "$PAM_SUDO doesn't include sudo_local — too old for this approach." >&2
    echo "Skipping rather than editing $PAM_SUDO, which updates revert." >&2
    return 0
  fi

  if [[ -f "$PAM_LOCAL" ]] && grep -qE '^\s*auth\s+sufficient\s+pam_tid\.so' "$PAM_LOCAL"; then
    echo "==> Touch ID for sudo already enabled."
    return 0
  fi

  # Enrolled fingerprints, as against a machine that merely has a sensor.
  if ! bioutil -r 2>/dev/null | grep -q 'Effective biometrics for unlock: 1'; then
    echo "No fingerprints enrolled — enrol one in System Settings first." >&2
    return 0
  fi

  echo "==> Enabling Touch ID for sudo"
  sudo tee "$PAM_LOCAL" >/dev/null <<'EOF'
# Managed by dotfiles: setup/sudo-setup.sh
# Included by /etc/pam.d/sudo, and preserved across system updates.
auth       sufficient     pam_tid.so
EOF
  sudo chmod 444 "$PAM_LOCAL"

  grep -q pam_tid.so "$PAM_LOCAL" || {
    echo "    Failed to write $PAM_LOCAL." >&2
    return 1
  }
}

set_ticket_policy() {
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" <<EOF
# Managed by dotfiles: setup/sudo-setup.sh
#
# Per-user rather than per-terminal tickets. Homebrew's cask installers shell
# out to sudo from subprocesses that don't share the invoking terminal's
# ticket, so the default re-prompts for every cask that wants root.
#
# Delete this file to restore the macOS defaults (5 minutes, per-terminal).
Defaults timestamp_timeout=$TIMESTAMP_TIMEOUT
Defaults !tty_tickets
EOF

  # Validate before it can take effect. A malformed file in sudoers.d breaks
  # sudo outright, and you need sudo to fix it.
  if ! visudo -cf "$tmp" >/dev/null 2>&1; then
    echo "Generated sudoers snippet failed validation — not installing." >&2
    rm -f "$tmp"
    return 1
  fi

  echo "==> Setting sudo ticket policy (${TIMESTAMP_TIMEOUT}m, per-user)"
  sudo install -m 440 -o root -g wheel "$tmp" "$SUDOERS_D"
  rm -f "$tmp"

  # Re-check the whole configuration, and back out if anything is wrong.
  if ! sudo visudo -c >/dev/null 2>&1; then
    echo "sudoers no longer parses — removing $SUDOERS_D" >&2
    sudo rm -f "$SUDOERS_D"
    return 1
  fi
}

enable_touch_id
set_ticket_policy
echo "    Done. Try 'sudo -k; sudo true' in a fresh terminal."
