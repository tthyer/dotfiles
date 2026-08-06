# dotfiles

Personal dotfiles and machine setup for macOS. Bash, Ghostty, Homebrew.

Work-specific config lives in a separate private overlay repo. Everything here
stands alone without it.

## New machine

In order. Steps 1–3 are manual; the rest is scripted.

1. **Sign in and install the Xcode command line tools.**
   ```bash
   xcode-select --install
   ```

2. **Copy `~/.ssh` from the old machine by hand.** Never through a repo.
   ```bash
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
   ssh -T git@github.com          # expect a "successfully authenticated" greeting
   ```

3. **Clone both repos.**
   ```bash
   git clone git@github.com:tthyer/dotfiles.git ~/github/tthyer/dotfiles
   git clone git@github.com:tthyer/dotfiles-work.git ~/github/tthyer/dotfiles-work
   ```

4. **Run the installer.**
   ```bash
   cd ~/github/tthyer/dotfiles && ./install.sh
   ```
   Installs Homebrew and the Brewfile, links dotfiles, sets the login shell,
   installs krew and the language tooling, applies macOS defaults, then runs
   the overlay if it's present.

5. **Open a new shell and check it took.**
   ```bash
   echo $BASH_VERSION              # 5.x, not 3.2
   dscl . -read ~/ UserShell       # /opt/homebrew/bin/bash
   ```

6. **Sign in to everything.** `claude`, `codex`, Orca, then
   `gh auth login`, `az login`, `gcloud auth login`, `aws configure`.

7. **Add MCP tokens to the Keychain** — see the overlay's README.

8. **Copy the rest by hand:** `~/github`, `~/Documents`, the login keychain,
   and browser profiles.

9. **Re-authenticate rather than copying** `~/.kube/config`, `~/.azure`, and
   `~/.config/gcloud`. They hold live credentials and go stale.

## Day to day

```bash
./install.sh            # safe to re-run; idempotent
./dotfiles.sh           # relink only
brew bundle --file=Brewfile
brew bundle check --file=Brewfile --verbose    # what's missing
```

## Structure

```
Brewfile           packages: taps, formulae, casks, fonts
install.sh         main orchestrator
dotfiles.sh        symlink manager

shell/             bash_profile, bashrc, functions, prompt, Ghostty launcher
git/               gitconfig, gitignore_global
vim/               vimrc  (uses Apple's /usr/bin/vim; nothing to install)
java/              java-setup.sh, sourced by bash_profile
macos/             defaults.sh — Dock, keyboard, Finder, screenshots
setup/             python, node, and AI agent setup scripts
config/
  ghostty/         terminal config
  tmux/            status-bar shim only — see below
  cmux/            sidebar status pills
  gh/              GitHub CLI
  worktrunk/       generic half; the overlay appends project entries
  claude/          CLAUDE.md, agents, skills, statusline, settings baseline
  codex/           config, rules, memories
```

## Notes

**Terminal.** Ghostty. Its config links to `~/.config/ghostty/config`. Put
machine-specific overrides in `~/.config/ghostty/local.ghostty`, which is
deliberately untracked.

**tmux** exists only to paint a two-row status bar under Ghostty; Ghostty still
owns tabs and splits. It's **off by default** via a `~/.config/tmux/DISABLED`
marker that `dotfiles.sh` creates. Delete the marker to turn it on.

**Shell.** Homebrew bash 5, not Apple's `/bin/bash` 3.2. `install.sh` adds it to
`/etc/shells`, runs `chsh`, and then verifies with `dscl` — if the login shell
doesn't change, it says so rather than failing silently.

**Agent config is merged, not symlinked.** Claude Code and Codex both write to
their own settings at runtime, and Orca reinstalls its hook block on every
launch. `setup/agents-setup.sh` merges the tracked baseline into the live file
and unions permission lists, so nothing granted since the last sync is revoked.
Never track `~/.claude.json` — it holds MCP tokens in plaintext.

**Secrets** are never committed, to either repo. They live in the macOS
Keychain and are read at run time.
