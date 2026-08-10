# Migration checklist — 2026-08

Working checklist for moving to the new laptop. **Delete this file once the
move is done.** The permanent runbook is in the README; this tracks the
one-off work around it.

## Before the new laptop arrives

- [ ] **Audit `~/.ssh`.** Which keys exist, are any still RSA, what's in
      `config`. Keys move by hand, never through a repo. Consider replacing
      RSA keys with ed25519 — `setup/ssh-setup.sh` generates one.
- [ ] **Rehearse in a VM.** `brew install --cask utm`, build a clean macOS
      guest, run the README runbook end to end. Every failure is a repo bug
      found while it's still cheap. VirtualBox can't do macOS guests on
      Apple Silicon, which is why it's not in the Brewfile.
      - App Store sign-in is unreliable in a guest VM, so the four `mas`
        entries won't be fully testable there. Check them on the real machine.
- [ ] **Note anything the rehearsal exposes** as a repo fix, not a manual step.

## On the new machine

Follow the README runbook. Then confirm:

- [ ] `echo $BASH_VERSION` → 5.x, not 3.2
- [ ] `dscl . -read ~/ UserShell` → `/opt/homebrew/bin/bash`
- [ ] `brew bundle check --file=Brewfile` → satisfied
- [ ] `git -C ~/github/amperon/amperon config user.email` → work address
- [ ] `git config --global user.email` → noreply address
- [ ] `claude plugin list` → 7 enabled
- [ ] `claude mcp list` → grafana + amperon-kb
- [ ] Run Orca once so it reinstates its hooks in Claude, Codex, and Gemini
- [ ] MCP tokens added to the Keychain — see the overlay's README

Copy by hand (nothing below is in a repo):

- [ ] `~/github`, `~/Documents`
- [ ] `~/.ssh`, then `chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*`
- [ ] login keychain, browser profiles
- [ ] Re-authenticate rather than copying: `~/.kube/config`, `~/.azure`,
      `~/.config/gcloud`

## Cleanup, once you're confident

- [ ] Delete the pre-scrub backup mirror
      `~/dotfiles-backup-20260805-190555.git`
- [ ] Delete the `DROPPED` block at the bottom of `Brewfile`
- [ ] Delete `~/.codex/logs_2.sqlite` (132MB) if it's still around
- [ ] Delete this file

## Decided against

Recorded so they don't get re-litigated:

- **Rotating the Grafana service-account token** in `~/.claude.json`. Raised,
  declined.
- **Asking GitHub Support to garbage-collect** the pre-scrub commits. They stay
  reachable by direct SHA until GitHub GCs on its own schedule. The identifiers
  involved are low-sensitivity and already scraped.
- **chezmoi.** Considered and set aside — the overlay repo solves the
  public/private split without the extra machinery.
