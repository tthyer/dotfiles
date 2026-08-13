# Migration log — havelock → totalbiscuit

Running notes on what actually happened, as against what MIGRATION.md said
would happen. Kept separately because MIGRATION.md gets deleted at the end
and the corrections shouldn't go with it.

**Old:** havelock, macOS 26.6.1, user `tessthyer`
**New:** totalbiscuit, M5 Pro / arm64, macOS 26.5.1 → 26.6.1, user `tess`

Note the account short name changed between machines. Anything in the repos
that assumes `tessthyer` is worth a grep.

---

## Approach

Asked whether the two machines could just be connected and driven from one
session. Settled on **SSH from havelock into totalbiscuit**, so the session
holding the migration context can inspect and verify the new machine.

Considered and dropped:

- **Migration Assistant.** Carries credentials across wholesale, which is the
  precise thing MIGRATION.md was designed to avoid — fresh SSH key,
  re-authenticated cloud creds.
- **Claude Code installed natively on totalbiscuit.** Viable, and its curl
  installer needs no Homebrew, but a fresh session would start with none of
  this context.

### The limit that shapes everything

The assistant's Bash tool has **no tty**. Every prompt — `sudo`, SSH
passwords, key passphrases, `chsh` — has to be answered by Tess in a real
terminal. So most of steps 2–5 and 7 are hers; the assistant takes step 6's
verification, inspection between steps, and diagnosis.

Working pattern: keep a Terminal window open running
`ssh tess@totalbiscuit.local`, paste commands there, and let the assistant
check state from its own session in between.

---

## Getting connected — three things went wrong

1. **Remote Login's user list.** Enabling Remote Login defaults to *Only
   these users*, and `tess` wasn't on it. A correct password is rejected
   exactly like a wrong one. Fixed by adding herself in
   System Settings → General → Sharing → (i) next to Remote Login.

2. **Agent keys exhausted the auth attempts.** `ssh-copy-id` offered
   identities from the agent before ever reaching the password, producing
   `Too many authentication failures`. Needed
   `-o PubkeyAuthentication=no -o PreferredAuthentications=password -o IdentityAgent=none`.

3. **The `!` prefix has no tty either.** Running `ssh-copy-id` through
   Claude Code's `!` bash prefix meant the password prompt read empty input
   and failed instantly, twice, looking like a typo. Diagnosable from the
   output: two *immediate* denials with no pause between them. Fixed by
   running it in a real Terminal window, where it worked first time.

Once the key was installed, both `10.0.0.64` and `totalbiscuit.local` work.
The `.local` name is the one to rely on — the IP is a DHCP lease.

That proved out immediately: the reboot for the OS update renewed the lease
and moved the machine from `10.0.0.64` to `10.0.0.53`. Connecting by IP gave
`host is down`, which reads like the machine is off rather than like a stale
address. Use the `.local` name and lease changes stop mattering. Note the
rename also changed the `.local` name, so the host key has to be accepted
again under `totalbiscuit.local`.

---

## Hostname rename — done ahead of the SSH key

Tess's call, and the right one. Step 3 builds the key comment from
`scutil --get ComputerName`, so renaming first means the key lands on GitHub
labelled `tess@totalbiscuit` instead of `tess@Tess's MacBook Pro`.

```bash
NAME=totalbiscuit; sudo scutil --set ComputerName "$NAME" && sudo scutil --set LocalHostName "$NAME" && sudo scutil --set HostName "$NAME"
```

All three stuck; no drift back to the Apple ID-derived name. One `sudo`
prompt for the three commands.

---

## Step 2 — done by command line where possible

Tess asked whether these could be done from the CLI rather than the GUI.
Mostly yes:

- **macOS update: yes.**
  `sudo softwareupdate -i "macOS Tahoe 26.6.1-25G76" -R --user tess`
  On Apple Silicon this needs volume-owner authorisation, so it prompts for
  the account password *as well as* sudo. After the restart the machine must
  be unlocked at its own keyboard before SSH comes back — FileVault holds the
  network stack until first unlock. Remote Login itself survives the reboot.

  Watching it run: the progress bar stuck at 98.5% is not a stall. The
  download finishes and the work moves to `UpdateBrainService`, which is CPU
  and disk bound — 65% CPU and 133 MB/s sustained, with network at 0 KB/s.
  The bar tracks the download, not the prepare. On Apple Silicon prepare is
  the long phase and the post-reboot install is short, so don't budget the
  15–20 minutes of reboot that Intel machines needed. Landed on 26.6.1 build
  25G76 with a total downtime under a minute.

- **Command line tools: yes, headless, but it took three goes.** The trigger
  file makes `softwareupdate` offer the tools. The assistant got the details
  wrong twice and concluded from its own broken test that Apple had removed
  the feature and a GUI was now unavoidable. Tess pushed back on that claim,
  which is the only reason it got checked rather than written into the repo
  as fact.

  The two mistakes, both worth remembering:

  - **The path is `/tmp`, not `/var/tmp`.** Different directories on macOS —
    `/private/tmp` against `/private/var/tmp`. The trigger only works in
    `/tmp`.
  - **The label is `Command Line Tools for Xcode 26.6-26.6`** — a space
    before the version, not a hyphen. A pattern written as
    `Command Line Tools for Xcode-[0-9.]*` cannot ever match.

  Together these produced a convincing false negative: `softwareupdate -l`
  genuinely reported `No new software available`, and the install failed with
  `No updates are available`, which is `softwareupdate -i ""` reacting to an
  empty label rather than any statement about the tools.

  The lesson for next time is to check the claim against Homebrew's
  `install.sh`, which does exactly this and stays current — it supplied both
  the correct path and the correct label-extraction pipeline. Worth noting
  that Homebrew's installer would have hit the same wall had the feature
  really been gone, since it uses the same mechanism.

  Wrapped in `setup/clt-setup.sh`. With the trigger in place, 26.6.1 offers
  both 26.5 and 26.6; `sort -V` takes the newer.

  Also useful for diagnosis: `/tmp` is world-writable, so the listing half
  can be tested with no sudo at all. And presence is better checked by
  `/Library/Developer/CommandLineTools/usr/bin/git` — what Homebrew checks —
  than by `xcode-select -p`, which only reports the active developer
  directory.

- **App Store sign-in: no.** GUI only. `mas signin` stopped working when
  Apple removed the private API behind it. *Recalled, not verified here —
  `mas` isn't installed until step 5.*

---

## Step 3 — the key

`setup/ssh-setup.sh` already did all of this; MIGRATION.md spelled the
commands out by hand instead of calling it. Its header comment was also stale
in a way that mattered — it described copying `~/.ssh` across as the normal
path and a fresh key as the fallback, the reverse of what was decided. Both
fixed.

There's a bootstrap ordering problem worth naming: the script lives in the
repo, but you need the key before you can clone the repo. Copied across with
`scp` this time. The dotfiles repo is public, so `curl` from the raw GitHub
URL would work on a machine with nothing on it at all — the better answer,
but only once the fixes here are pushed.

**`ssh-add` fails over SSH.** macOS hands the agent socket to the GUI login
session through launchd, so an incoming SSH connection has no
`SSH_AUTH_SOCK` and `ssh-add` reports `Could not open a connection to your
authentication agent`. Nothing wrong with the key. Because the script ran
under `set -e` it aborted there, having generated the key and written the
config, but before printing the public half — so it looked like a worse
failure than it was. Now guarded: it skips `ssh-add` when there's no agent,
says so, and still prints the key.

`UseKeychain` and `AddKeysToAgent` are already in `~/.ssh/config`, so the
first use from a console session stores the passphrase regardless. And
`ssh -T git@github.com` needs no agent at all — `IdentityFile` is enough,
with a passphrase prompt.

### Registering the key should have used `gh`, not a browser

The assistant printed the public key, copied it to the clipboard, and sent
Tess to github.com/settings/keys to paste it. Tess was sceptical this couldn't
be done with `gh`, and was right — `gh ssh-key add` exists and does exactly
this. It never got reached for.

The whole "generate on the new machine, register from the old one" flow is two
commands from havelock:

```bash
gh auth refresh -h github.com -s admin:public_key
gh ssh-key add <(ssh tess@totalbiscuit.local 'cat ~/.ssh/id_ed25519.pub') --title totalbiscuit
```

The one-time scope grant is why it isn't a straight drop-in: havelock's `gh`
token lacks `admin:public_key`, which is also why reading the key list returns
404 rather than an empty result. Worth granting once on havelock so the old
machine can register keys for the next one.

Generalises past this migration. Any time a step reads like "open this page
and paste", check whether `gh` covers it first.

---

## Fold back into the repo

- [ ] Add hostname rename as a numbered step, before the SSH key step, with
      the reason (key comment derives from `ComputerName`).
- [ ] Replace `xcode-select --install` with `setup/clt-setup.sh`.
- [ ] Point step 3 at `setup/ssh-setup.sh` instead of restating its commands,
      and say how to get it onto a machine that can't clone yet — `scp`, or
      `curl` from raw GitHub, since the repo is public.
- [ ] Replace the "paste it at github.com/settings/keys" instruction with
      `gh ssh-key add`, run from the old machine. Note the one-time
      `admin:public_key` scope grant.
- [ ] Say that App Store sign-in is GUI-only and why, so it isn't retried
      from the CLI.
- [ ] Note that macOS updates on Apple Silicon need `--user` and a second
      password prompt.
- [ ] Warn that a new account short name may differ from the old one.
- [x] Step 9: remove havelock's key from totalbiscuit's `authorized_keys`
      and turn Remote Login off. *(added)*

---

## Step 1

- [x] Both repos confirmed pushed — `0 uncommitted / 0 unpushed` each.
- [x] The `~/.ssh` survey was already done before this session, and is what
      produced the decision to generate a fresh key on the new machine rather
      than carry either existing one across. Both were passphraseless, so each
      private key file was a plaintext credential; the old RSA key predates
      havelock and wasn't doing the GitHub work. Nothing to redo.
- [ ] Note anything outside `~/github` and `~/Documents` worth keeping.
