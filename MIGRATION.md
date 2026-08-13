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

- [x] Glance at `~/.ssh/config` and `~/.ssh/known_hosts` for hosts you don't
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
- [ ] Install the command line tools. Fetched from the public repo rather
      than cloned, because git doesn't work until this is done. Downloaded
      and then run, not piped into `bash` — a piped script owns stdin, which
      is hostile to anything that prompts:
      ```bash
      curl -fsSL https://raw.githubusercontent.com/tthyer/dotfiles/master/setup/clt-setup.sh -o /tmp/clt-setup.sh && bash /tmp/clt-setup.sh
      ```
      No dialog to click. Asks for `sudo` once, then downloads about 920MB.

---

## 3. SSH identity

Fresh key. Nothing copied.

Rename the machine first — the key comment is built from `ComputerName`, so
doing this afterwards leaves a key on GitHub labelled `Tess's MacBook Pro`:

```bash
NAME=newname; sudo scutil --set ComputerName "$NAME" && sudo scutil --set LocalHostName "$NAME" && sudo scutil --set HostName "$NAME"
```

- [ ] Generate the key, set permissions, and add the Keychain block to
      `~/.ssh/config`. Interactive — it asks for a passphrase twice:
      ```bash
      curl -fsSL https://raw.githubusercontent.com/tthyer/dotfiles/master/setup/ssh-setup.sh -o /tmp/ssh-setup.sh && bash /tmp/ssh-setup.sh
      ```
      Run it sitting at the machine. Over SSH there's no agent —
      `SSH_AUTH_SOCK` is unset, because macOS gives the socket to the GUI
      login session — so `ssh-add` is skipped and you'll be asked for the
      passphrase on first use instead.

- [ ] Register it with GitHub **from the OLD machine**, which already has an
      authenticated `gh`. Substitute the new machine's name:
      ```bash
      gh ssh-key add <(ssh NEW_MACHINE.local 'cat ~/.ssh/id_ed25519.pub') --title NEW_MACHINE
      ```
      One-time scope grant if it 404s or complains — reading the key list
      fails the same way without it:
      ```bash
      gh auth refresh -h github.com -s admin:public_key
      ```

- [ ] Verify on the new machine before going further:
      ```bash
      ssh -T git@github.com
      ```
      Expect `Hi tthyer! You've successfully authenticated`.

---

## 4. Clone and install

- [ ] Clone both repos:
      ```bash
      mkdir -p ~/github/tthyer && git clone git@github.com:tthyer/dotfiles.git ~/github/tthyer/dotfiles && git clone git@github.com:tthyer/dotfiles-work.git ~/github/tthyer/dotfiles-work
      ```
- [ ] Run the installer:
      ```bash
      cd ~/github/tthyer/dotfiles && ./install.sh
      ```

`install.sh` installs Homebrew itself if it isn't there, so there's no
separate step for it. It also handles the command line tools, though on a
truly bare machine that's academic — you needed them in step 2 to get git.

It will stop and ask you for things:

- **`sudo` password** — adding Homebrew bash to `/etc/shells`. Touch ID
  covers this if you're sitting at the machine; over SSH it falls back to
  the password.
- **`chsh`** — may prompt again
- Long silences during `brew bundle`. `gdal` and `eccodes` pull a large
  geo/weather dependency tree.

The overlay is picked up automatically from
`~/github/tthyer/dotfiles-work`. It brings the work git identity, k8s
helpers, himalaya, Codex rules, and your worklog and handoffs.

- [ ] Open a **new** shell before continuing. The old one is still bash 3.2.

---

## 5. Verify

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

## 6. Sign in to everything

- [ ] `gh auth login`
- [ ] `az login`, then `gcloud auth login`
- [ ] **Not `aws configure`.** The codebase uses boto3, but that runs in the
      cluster with its own credentials — there's no evidence of the CLI being
      driven from this laptop. Two minutes to set up the day you need it, and
      until then it's one less set of live keys sitting on disk.
- [ ] gcloud restores credentials but not settings. The overlay's
      `setup/gcloud-config.sh` sets the project and compute defaults, and
      `apply.sh` runs it.
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

## 7. Copy the rest by hand

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

## 8. Once the new machine is earning its keep

- [ ] Delete the old SSH key from https://github.com/settings/keys
- [ ] Remove havelock's key from `~/.ssh/authorized_keys` on totalbiscuit, and
      turn Remote Login back off. Both were added only so the old machine
      could drive the setup.
- [ ] Delete the backup mirror `~/dotfiles-backup-20260805-190555.git`
- [ ] Delete the `DROPPED` block at the bottom of `Brewfile`
- [ ] Delete `~/.codex/logs_2.sqlite` (132MB) if it came across
- [ ] **Keychain — the last thing havelock is holding.** The login keychain was
      deliberately not migrated; the plan is to recover items as they're missed.
      That only works while havelock exists, so this is the real gate on wiping
      it. The one known item is the himalaya Gmail app password (service
      `himalaya`, account `tess@amperon.co`) — nothing else recreates it, since
      signing into Gmail in a browser doesn't produce an app password. Anything
      else, list with:
      `security dump-keychain ~/Library/Keychains/login.keychain-db | grep '"svce"' | sort -u`
      Run on havelock in a real terminal — an SSH session can't see the login
      keychain. Copy across with `security add-generic-password -a <account>
      -s <service> -w`, omitting the value so it prompts instead of landing in
      shell history.
- [ ] Wipe the old laptop — **not before the line above**
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
