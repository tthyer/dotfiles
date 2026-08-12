# Migration checklist

Work through this top to bottom. Self-contained — you shouldn't need the
README until the machine is running. **Delete this file when you're done.**

Keep the old laptop powered on and beside you until the last section.

---

## 1. On the OLD machine

- [ ] Confirm both repos are pushed. Both must report `0 / 0`:
      ```bash
      for r in ~/github/tthyer/dotfiles ~/github/tthyer/dotfiles-work; do echo "$(basename $r): $(git -C $r status --porcelain | wc -l | tr -d ' ') uncommitted / $(git -C $r log origin/master..HEAD --oneline | wc -l | tr -d ' ') unpushed"; done
      ```

- [ ] Glance at `~/.ssh/config` and `~/.ssh/known_hosts` for hosts you don't
      recognise — jump boxes, NAS, old clients. If the old RSA key is
      authorised somewhere, this is the only place it'll show.

- [ ] Note anything living outside `~/github` and `~/Documents` that you'd
      miss. Desktop, Downloads you care about, scratch dirs.

**Not transferring any SSH key.** Both are passphraseless, so each private
key file is a plaintext credential and moving it is the risky part. You'll
make a fresh one in step 3. The old RSA key
(`tessthyer@Tesss-MacBook-Air.local`) isn't used for GitHub — verbose SSH
shows `id_ed25519` doing that work — and predates this machine.

---

## 2. New machine — first boot

- [ ] Sign in to the Apple ID.
- [ ] **Sign in to the App Store** too. Four apps come from there later and
      `mas` will fail silently-ish without it.
- [ ] Install the command line tools, and let it finish:
      ```bash
      xcode-select --install
      ```

---

## 3. SSH identity

Fresh key. Nothing copied.

- [ ] Generate it. This one is interactive — it asks for a file location and
      then a passphrase twice, so run it on its own:
      ```bash
      ssh-keygen -t ed25519 -C "tessthyer@$(scutil --get ComputerName)"
      ```
- [ ] Load it into the agent and copy the public half:
      ```bash
      ssh-add --apple-use-keychain ~/.ssh/id_ed25519 && pbcopy < ~/.ssh/id_ed25519.pub
      ```
- [ ] Paste it at https://github.com/settings/keys
- [ ] Verify before going further:
      ```bash
      ssh -T git@github.com
      ```
      Expect `Hi tthyer! You've successfully authenticated`.

---

## 4. Homebrew

- [ ] Install it:
      ```bash
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ```
- [ ] Put it on PATH for this shell:
      ```bash
      eval "$(/opt/homebrew/bin/brew shellenv)"
      ```

---

## 5. Clone and install

- [ ] Clone both repos:
      ```bash
      mkdir -p ~/github/tthyer && git clone git@github.com:tthyer/dotfiles.git ~/github/tthyer/dotfiles && git clone git@github.com:tthyer/dotfiles-work.git ~/github/tthyer/dotfiles-work
      ```
- [ ] Run the installer:
      ```bash
      cd ~/github/tthyer/dotfiles && ./install.sh
      ```

It will stop and ask you for things:

- **`sudo` password** — adding Homebrew bash to `/etc/shells`
- **`chsh`** — may prompt again
- Long silences during `brew bundle`. `gdal` and `eccodes` pull a large
  geo/weather dependency tree.

The overlay is picked up automatically from
`~/github/tthyer/dotfiles-work`. It brings the work git identity, k8s
helpers, himalaya, Codex rules, and your worklog and handoffs.

- [ ] Open a **new** shell before continuing. The old one is still bash 3.2.

---

## 6. Verify

- [ ] `echo $BASH_VERSION` → 5.x, not 3.2
- [ ] `dscl . -read ~/ UserShell` → `/opt/homebrew/bin/bash`
- [ ] `brew bundle check --file=~/github/tthyer/dotfiles/Brewfile`
      → ignore "or updated"; only genuinely missing things matter
- [ ] `git config --global user.email` → the **noreply** address
- [ ] `ls -la ~/.claude/worklog.md ~/.claude/handoffs` → both symlinks resolve
- [ ] `wt list` → worktrunk reads its assembled config
- [ ] `tailscale status` → tailnet reachable

Then clone a work repo and check the identity switch:

- [ ] Clone it, then read back the identity — expect the **work** address,
      applied by the `includeIf`:
      ```bash
      git clone git@github.com:amperon/amperon.git ~/github/amperon/amperon && git -C ~/github/amperon/amperon config user.email
      ```

---

## 7. Sign in to everything

- [ ] `gh auth login`
- [ ] `az login`, then `gcloud auth login`, then `aws configure`
- [ ] Claude Code, Codex — sign in to each
- [ ] **Run Orca once.** It reinstates its hook block in Claude, Codex, and
      Gemini. Nothing else puts those back.
- [ ] MCP tokens into the Keychain. **Run these one at a time** — each waits
      for you to type the token, so pasting both together feeds the second
      command in as the first one's password:
      ```bash
      security add-generic-password -a "$USER" -s grafana-mcp-token -w
      ```
      ```bash
      security add-generic-password -a "$USER" -s amperon-kb-mcp-token -w
      ```
      Both tokens are on the old machine in `~/.claude.json` under
      `mcpServers` — copy them across by hand.
- [ ] Register the servers:
      ```bash
      bash ~/github/tthyer/dotfiles-work/setup/mcp-servers.sh
      ```
- [ ] `claude plugin list` → 7 enabled
- [ ] `claude mcp list` → grafana + amperon-kb

---

## 8. Copy the rest by hand

Nothing here is in a repo.

- [ ] `~/github` (or re-clone), `~/Documents`
- [ ] Login keychain, browser profiles
- [ ] Anything you noted in step 1
- [ ] **Re-authenticate, don't copy:** `~/.kube/config`, `~/.azure`,
      `~/.config/gcloud`. They hold live credentials and go stale.
      Substitute the real resource group — an unquoted `<rg>` would be read
      as an input redirect, not a placeholder:
      ```bash
      az aks get-credentials --resource-group RESOURCE_GROUP --name prod-aks
      ```
      ```bash
      kubelogin convert-kubeconfig -l azurecli
      ```
      `AAD_LOGIN_METHOD=azurecli` is already exported by the overlay, which
      is what stops kubectl hanging on a device-code prompt.

---

## 9. Once the new machine is earning its keep

- [ ] Delete the old SSH key from https://github.com/settings/keys
- [ ] Delete the backup mirror `~/dotfiles-backup-20260805-190555.git`
- [ ] Delete the `DROPPED` block at the bottom of `Brewfile`
- [ ] Delete `~/.codex/logs_2.sqlite` (132MB) if it came across
- [ ] Wipe the old laptop
- [ ] Delete this file

---

## Decided against

Recorded so they don't get re-litigated:

- **The UTM rehearsal.** Its value was finding repo bugs cheaply, before the
  machine arrived. With the new machine here and the old one beside it,
  rehearsing costs more than trying. A dry run against a throwaway `$HOME`
  already passed: 221 symlinks, none broken, both repos' skills and agents
  present, settings merged correctly.
- **Transferring the existing SSH keys.** Both passphraseless; fresh key
  instead.
- **Rotating the Grafana service-account token** in `~/.claude.json`. Raised,
  declined.
- **Asking GitHub Support to garbage-collect** the pre-scrub commits.
- **chezmoi.** The overlay repo solves the public/private split without it.
