#!/usr/bin/env bash
# Claude Code and Codex setup.
#
# Config here is *merged* rather than symlinked, because both tools write to
# their own settings files at runtime — Orca reinstalls its hook block on
# every launch, and Claude records plugin state in place. Symlinking would
# mean the repo and the tool overwriting each other.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OVERLAY_DIR="${DOTFILES_OVERLAY:-$HOME/github/tthyer/dotfiles-work}"

# ============================================================ Claude Code
# Install it if it isn't here. Everything below configures Claude Code, and
# for a long time nothing installed it — the Brewfile has codex and cmux but
# no claude, so a fresh machine got a fully configured tool that didn't
# exist. There is no Homebrew formula; the native installer is the supported
# route, and it self-updates thereafter (~/.claude.json records
# "installMethod": "native").
if ! command -v claude &>/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  echo "==> Installing Claude Code..."
  installer="$(mktemp)"
  if curl -fsSL https://claude.ai/install.sh -o "$installer"; then
    bash "$installer" || echo "    !! Claude Code install failed — continuing."
  else
    echo "    !! Couldn't fetch the Claude Code installer — continuing." >&2
  fi
  rm -f "$installer"
fi

mkdir -p "$HOME/.claude"

echo "==> Merging Claude settings..."
python3 - "$DOTFILES_DIR" "$OVERLAY_DIR" <<'PY'
import json, os, sys

dotfiles, overlay = sys.argv[1], sys.argv[2]
target = os.path.expanduser("~/.claude/settings.json")

with open(os.path.join(dotfiles, "config/claude/settings.json")) as f:
    desired = json.load(f)

# Preserve whatever the live file already has, so a runtime-managed key we
# don't track (Orca's hooks, most importantly) survives this merge.
live = {}
if os.path.exists(target):
    try:
        with open(target) as f:
            live = json.load(f)
    except json.JSONDecodeError:
        print(f"    {target} is not valid JSON; backing it up.")
        os.replace(target, target + ".bak")

merged = dict(live)
for key, value in desired.items():
    if key == "permissions":
        # Union the permission lists rather than replacing them, so
        # approvals granted since the last sync aren't silently revoked.
        perms = dict(live.get("permissions", {}))
        for bucket, entries in value.items():
            if isinstance(entries, list):
                existing = perms.get(bucket, [])
                perms[bucket] = sorted(set(existing) | set(entries))
            else:
                perms[bucket] = entries
        merged["permissions"] = perms
    else:
        merged[key] = value

# Overlay adds work-only permissions.
work = os.path.join(overlay, "config/claude/settings.work.json")
if os.path.exists(work):
    with open(work) as f:
        extra = json.load(f)
    perms = dict(merged.get("permissions", {}))
    for bucket, entries in extra.get("permissions", {}).items():
        perms[bucket] = sorted(set(perms.get(bucket, [])) | set(entries))
    merged["permissions"] = perms
    print("    merged work permissions from the overlay")

# statusLine is stored with $HOME so it survives a different username.
if "statusLine" in merged and "command" in merged["statusLine"]:
    merged["statusLine"]["command"] = merged["statusLine"]["command"].replace(
        "$HOME", os.path.expanduser("~"))

with open(target, "w") as f:
    json.dump(merged, f, indent=2)
    f.write("\n")

kept = "hooks" in merged
print(f"    wrote {target}")
print(f"    existing hooks preserved: {kept}")
PY

echo "==> Linking Claude assets..."
ln -fsv "$DOTFILES_DIR/config/claude/CLAUDE.md"            "$HOME/.claude/CLAUDE.md"
ln -fsv "$DOTFILES_DIR/config/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Skills and agents are contributed by BOTH repos, so link each item rather
# than the containing directory — a directory symlink would let whichever
# repo ran last hide the other's.
#
# `ln -sn` onto an existing directory also links *inside* it instead of
# replacing it, hence the explicit clear.
link_into() {
  local src_dir="$1" dest_dir="$2"
  [[ -d "$src_dir" ]] || return 0
  mkdir -p "$dest_dir"
  local item target
  for item in "$src_dir"/*; do
    [[ -e "$item" ]] || continue
    target="$dest_dir/$(basename "$item")"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "    replacing $target"
      rm -rf "$target"
    fi
    ln -fsnv "$item" "$target"
  done
}
link_into "$DOTFILES_DIR/config/claude/skills" "$HOME/.claude/skills"
link_into "$DOTFILES_DIR/config/claude/agents" "$HOME/.claude/agents"

# Plugins are regenerated, never copied: ~/.claude/plugins is a ~500MB cache.
if command -v claude &>/dev/null; then
  echo "==> Registering Claude plugin marketplaces..."
  claude plugin marketplace add max-sixty/worktrunk 2>/dev/null || true
  echo "    'amperon-claude-plugins' and 'claude-plugins-official' are added by the"
  echo "    overlay and by Claude itself respectively."

  # Adding a marketplace doesn't install anything from it. Without this the
  # plugin list on a new machine is empty, however many marketplaces are
  # registered — which is exactly what happened on totalbiscuit.
  #
  # Public plugins only; the amperon ones are installed by the overlay, which
  # is also what adds their marketplace. Deliberately not reinstated:
  # oh-my-claudecode and mcp2cli, both disabled on the old machine, and
  # mcp2cli's marketplace is a local directory that won't exist elsewhere.
  echo "==> Installing Claude plugins..."
  for plugin in \
    worktrunk@worktrunk \
    mattpocock-skills@claude-plugins-official \
    slack@claude-plugins-official
  do
    if claude plugin install "$plugin" 2>/dev/null; then
      echo "    installed $plugin"
    else
      echo "    !! $plugin didn't install — continuing."
    fi
  done

  # MCP servers are registered by the overlay's setup/mcp-servers.sh, which
  # is where the tokens are. This script used to also register grafana, with
  # no token, duplicating and half-undoing that work. grafana has since been
  # dropped entirely.
else
  echo "==> claude not on PATH; skipping plugin and MCP registration."
  echo "    Install Claude Code, then re-run this script."
fi

# ================================================================= Codex
mkdir -p "$HOME/.codex"

echo "==> Merging Codex config..."
if [[ -f "$HOME/.codex/config.toml" ]]; then
  # Keep the live file: it holds project trust levels and hook fingerprints
  # that are expensive to rebuild by hand. Only report the drift.
  echo "    ~/.codex/config.toml already exists — leaving it alone."
  echo "    Tracked baseline: $DOTFILES_DIR/config/codex/config.toml"
  echo "    Compare with: diff <(grep -v '^\[projects\|^\[hooks\|^trust_level\|^trusted_hash' ~/.codex/config.toml) $DOTFILES_DIR/config/codex/config.toml"
else
  cp "$DOTFILES_DIR/config/codex/config.toml" "$HOME/.codex/config.toml"
  echo "    installed a fresh ~/.codex/config.toml"
fi

link_into "$DOTFILES_DIR/config/codex/memories" "$HOME/.codex/memories"
link_into "$DOTFILES_DIR/config/codex/rules"    "$HOME/.codex/rules"

echo "==> Agent setup complete."
echo "    Run Orca once to reinstate its hooks in Claude, Codex, and Gemini."
