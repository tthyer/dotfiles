#!/usr/bin/env bash
# Drive the Dock from macos/dock-items.txt.
#
#   bash macos/dock.sh              apply the file to the Dock
#   bash macos/dock.sh --capture    rewrite the file from the current Dock
#
# Not called by install.sh. Applying rebuilds the Dock from scratch, which
# throws away anything arranged by hand, so it should be a deliberate act.
#
# Groom by editing dock-items.txt and re-applying, or by rearranging the Dock
# and running --capture to write it back.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITEMS="$HERE/dock-items.txt"

read_items() {
  # Drop comment lines, strip trailing annotations (two-plus spaces then #),
  # trim, expand $HOME. Single spaces are left alone — "System Settings.app".
  sed -e 's/^[[:space:]]*#.*$//' \
      -e 's/[[:space:]]\{2,\}#.*$//' \
      -e 's/[[:space:]]*$//' "$ITEMS" |
    grep -v '^$' |
    sed -e "s|\$HOME|$HOME|g" -e "s|^~|$HOME|"
}

capture() {
  python3 - "$ITEMS" <<'PY'
import plistlib, subprocess, sys, urllib.parse, datetime, os
raw = subprocess.run(['defaults','export','com.apple.dock','-'],
                     capture_output=True).stdout
d = plistlib.loads(raw)

def path_of(tile):
    td = tile.get('tile-data', {})
    fd = td.get('file-data') or {}
    s = fd.get('_CFURLString') or (td.get('url') or {}).get('_CFURLString') or ''
    if s.startswith('file://'):
        s = s[7:]
    return urllib.parse.unquote(s).rstrip('/')

home = os.path.expanduser('~')
def tidy(p):
    return '$HOME' + p[len(home):] if p.startswith(home) else p

apps   = [tidy(path_of(t)) for t in d.get('persistent-apps', [])]
others = [tidy(path_of(t)) for t in d.get('persistent-others', [])]
host   = subprocess.run(['scutil','--get','ComputerName'],
                        capture_output=True, text=True).stdout.strip()
today  = datetime.date.today().isoformat()

out = [
  "# Dock contents, in order. Applied by macos/dock.sh.",
  "#",
  "# One path per line. Blank lines and # comments ignored. $HOME expands, so",
  "# don't hardcode /Users/<name> — the account short name isn't the same on",
  "# every machine.",
  "#",
  "# Anything after a tab or two spaces on the line is treated as a comment, so",
  "# you can annotate entries.",
  "#",
  f"# Captured from {host}, {today}. Groom freely — this is the source of",
  "# truth, and re-running dock.sh rebuilds the Dock to match exactly.",
  "",
  "# ------------------------------------------------------------- apps",
]
out += apps
out += ["", "# ----------------------------------------------------------- others",
        "# Stacks and folders, shown to the right of the divider."]
out += others
with open(sys.argv[1], 'w') as f:
    f.write("\n".join(out) + "\n")
print(f"Wrote {len(apps)} apps and {len(others)} others to {sys.argv[1]}")
PY
}

apply() {
  command -v dockutil >/dev/null || {
    echo "dockutil not installed — brew install dockutil" >&2
    exit 1
  }

  local missing=0 added=0
  # Check everything before touching the Dock, so a typo doesn't leave it bare.
  while IFS= read -r item; do
    [[ -e "$item" ]] || { echo "  missing: $item" >&2; missing=$((missing + 1)); }
  done < <(read_items)

  if (( missing )); then
    echo "$missing item(s) not on this machine. Install them, or remove them" >&2
    echo "from $(basename "$ITEMS"), then re-run." >&2
    exit 1
  fi

  echo "==> Rebuilding the Dock"
  dockutil --remove all --no-restart >/dev/null

  while IFS= read -r item; do
    if [[ "$item" == *.app ]]; then
      dockutil --add "$item" --no-restart >/dev/null
    else
      dockutil --add "$item" --view grid --display stack --no-restart >/dev/null
    fi
    added=$((added + 1))
  done < <(read_items)

  killall Dock 2>/dev/null || true
  echo "    $added items."
}

case "${1:-apply}" in
  --capture) capture ;;
  apply|--apply) apply ;;
  *) echo "usage: $(basename "$0") [--capture]" >&2; exit 2 ;;
esac
