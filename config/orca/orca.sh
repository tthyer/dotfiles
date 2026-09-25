#!/usr/bin/env bash
# Share Orca's settings between machines through config/orca/settings.json.
#
#   bash config/orca/orca.sh             apply settings.json to this machine
#   bash config/orca/orca.sh --capture   rewrite settings.json from this machine
#
# Orca keeps its settings inside orca-data.json, alongside this machine's
# repos, projects, worktree metadata, SSH targets and automations. Only the
# `settings` subtree travels; the rest is local and is left alone. That's why
# this merges a subtree instead of copying the file — copying would clobber
# the receiving machine's entire workspace.
#
# Not called by install.sh. Applying overwrites settings changed by hand here,
# so it stays a deliberate act, same reasoning as macos/dock.sh.
#
# One known rough edge: terminalQuickCommands can be scoped to a repo by a
# repoId that is generated per machine. Those entries travel but stay inert on
# the receiving machine, because the id matches nothing there. Unscoped quick
# commands work everywhere. Left in rather than stripped, since dropping them
# would silently lose quick commands on the machine that authored them.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$HERE/settings.json"
SUPPORT="$HOME/Library/Application Support/orca"
INDEX="$SUPPORT/orca-profile-index.json"

# Settings that must not travel between machines.
#   workspaceDirHistory   absolute paths, and the account short name can differ
#   telemetry             holds installId; two machines sharing one would
#                         report to Orca as a single install
#   githubProjects        per-machine pinned/recent project state
#   activeRuntimeEnvironmentId, androidSdkPath,
#   mobileEmulatorDefaultDeviceUdid, mobilePairingCustomAddress(es)
#                         name hardware or paths local to one machine
EXCLUDE_KEYS='["workspaceDirHistory","telemetry","githubProjects","activeRuntimeEnvironmentId","androidSdkPath","mobileEmulatorDefaultDeviceUdid","mobilePairingCustomAddress","mobilePairingCustomAddresses"]'

# Anything whose name ends in key/token/secret/password/credential is dropped
# on capture, so a credential can't reach this public repo even if Orca grows
# a new field later. opencodeGoApiKey is the one that exists today, and it's
# empty. Anchored at the end deliberately: an unanchored "key" would also
# swallow the keybinding settings, which are worth sharing.
EXCLUDE_SUFFIX='(key|token|secret|password|credential)$'

die() { echo "!! $*" >&2; exit 1; }

command -v jq >/dev/null || die "jq is required (brew install jq)."
[[ -f "$INDEX" ]] || die "Orca isn't installed here — no $INDEX."

profile="$(jq -r '.activeProfileId // "local-default"' "$INDEX")"
DATA="$SUPPORT/profiles/$profile/orca-data.json"
[[ -f "$DATA" ]] || die "No orca-data.json for profile '$profile'."

capture() {
  jq -S --argjson drop "$EXCLUDE_KEYS" --arg suffix "$EXCLUDE_SUFFIX" '
      .settings
      | with_entries(select((.key as $k | $drop | index($k)) | not))
      | with_entries(select((.key | test($suffix; "i")) | not))
    ' "$DATA" > "$SETTINGS.tmp"
  jq -e . "$SETTINGS.tmp" >/dev/null || die "Captured settings aren't valid JSON."
  mv "$SETTINGS.tmp" "$SETTINGS"
  echo "==> captured $(jq -r 'keys|length' "$SETTINGS") settings"

  # Cheap tripwire: the rules above go by name, so flag any value that looks
  # like an opaque credential regardless of what its field is called.
  local suspicious
  suspicious="$(jq -r 'to_entries[]
      | select(.value|tostring|test("[A-Za-z0-9_-]{32,}"))
      | .key' "$SETTINGS")"
  if [[ -n "$suspicious" ]]; then
    echo "    Review before committing — these hold long opaque values:"
    sed 's/^/      /' <<<"$suspicious"
  fi
}

apply() {
  [[ -f "$SETTINGS" ]] || die "No $SETTINGS to apply."
  jq -e . "$SETTINGS" >/dev/null || die "$SETTINGS isn't valid JSON."

  # Orca holds this file in memory and rewrites it, so a merge written while
  # it's running is discarded when it quits.
  if pgrep -x Orca >/dev/null 2>&1; then
    die "Orca is running. Quit it first, or the merge will be overwritten."
  fi

  local backup="$DATA.bak.dotfiles-$(date +%Y%m%d-%H%M%S)"
  cp "$DATA" "$backup"

  # `*` deep-merges, so the keys held back on capture keep this machine's
  # values rather than being blanked.
  if jq --slurpfile new "$SETTINGS" '.settings = (.settings * $new[0])' \
       "$DATA" > "$DATA.tmp" && jq -e . "$DATA.tmp" >/dev/null; then
    mv "$DATA.tmp" "$DATA"
    echo "==> applied $(jq -r 'keys|length' "$SETTINGS") settings to profile '$profile'"
    echo "    backup: ${backup/#$HOME/\~}"
  else
    rm -f "$DATA.tmp"
    die "Merge failed; $DATA is untouched."
  fi
}

case "${1:-}" in
  --capture)  capture ;;
  ""|--apply) apply ;;
  *)          die "Usage: orca.sh [--capture|--apply]" ;;
esac
