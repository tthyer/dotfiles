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

## Step 5 — install.sh reinstalled Homebrew

Tess noticed it installing Homebrew when Homebrew was already installed and
verified. The assistant's first read was that the check was defective, then
talked itself out of that on the grounds that a login shell has `brew` on
PATH, then had to go back to the original answer once she pasted the actual
output — the `curl | bash` installer really had re-run.

The cause is shell age, not PATH in general. Homebrew's installer adds itself
to `~/.zprofile`, which only affects shells started afterwards. Her SSH
session had been open since before Homebrew existed, so `command -v brew`
found nothing on a machine that plainly had it.

Harmless — Homebrew's installer is safe on an existing install and reported
success — but it cost a sudo prompt and produced output that reads like it's
overwriting a working install. Fixed by testing `/opt/homebrew/bin/brew`
directly and evaling `shellenv`, so the check doesn't depend on how old the
shell is.

Worth generalising: `command -v` answers a question about *this shell*, not
about the machine. For anything installed during the same session, test the
path.

### Two more things brew bundle stopped on

**Untrusted taps.** Homebrew now refuses to load formulae from non-official
taps: `Refusing to load formula hashicorp/tap/terraform from untrusted tap`.
Its suggested remedy trusts one formula, which means meeting the error again
for the next one — six times here, since the overlay's Brewfile.work adds four
taps of its own. `brew trust --tap` takes the whole tap; install.sh now does
all of them up front, read out of both Brewfiles so the list can't drift.

Worth noting the error surfaced a second time as `zsh: command not found:
brew`, same stale-shell cause as before — the session predated Homebrew.

**Orca's cask points at a release that doesn't exist.** `stablyai/orca/orca`
is at 1.4.181, but there is no `v1.4.181` on GitHub — only `v1.4.181-rc.0`, a
pre-release. Latest stable is `v1.4.180`, whose asset does download. Upstream
shipped a cask update ahead of the release it references.

Not patched around. The Brewfile entry is correct, including the fully
qualified `stablyai/orca/orca` — bare `orca` is plotly's deprecated cask in
core, which `brew info --cask orca` happily resolves to and which would be a
confusing thing to install by accident. Skipped for the run instead:

```bash
HOMEBREW_BUNDLE_CASK_SKIP="orca" ./install.sh
```

**The value is the bare token, not the qualified name.** `bundle/dsl.rb`
stores what the Brewfile wrote as `options[:full_name]` and then sanitises
`name` down through `Utils.name_from_full_name(...).downcase`, so
`stablyai/orca/orca` becomes `orca`. `skipper.rb` matches on `entry.name`.
Passing the qualified string silently skips nothing.

That mattered more than it sounds, because of how the fetch phase works.
`bundle/installer.rb` collects every entry into a single `brew fetch` call,
and if that one command fails it prints `Failed to fetch` followed by the
entire list — 90 packages, reading as though everything were broken. In fact
one 404 poisons the batch. Individual `brew fetch` calls for a core formula,
a cask and a tap formula all succeeded while the batch was "failing".

So: when `brew bundle` reports mass fetch failure, look for the single bad
entry rather than a systemic cause. Disk and network were both fine.

Resolved by installing `v1.4.180` by hand — download the dmg, mount, copy
`Orca.app` to `/Applications`. The cask declares `auto_updates`, so an older
install isn't a stale one: it pulls itself forward on first run. That beat
waiting on upstream, and beat checking the tap out at an older revision and
having to undo it later.

`curl` doesn't set `com.apple.quarantine` — only browsers do — so there's no
Gatekeeper prompt on first launch.

Consequence for step 5: `brew bundle check` will report `orca` missing,
because it isn't Homebrew-managed. Expected, not a failure. Once upstream
fixes the cask, `brew install --cask stablyai/orca/orca` adopts the existing
app.

---

## Step 4 — install.sh aborted four times before finishing

`set -euo pipefail` means any failure takes the whole run down, and
everything worth having is at the end: the symlinks, the login shell change,
krew, the language tooling, the overlay. So four separate small failures each
cost a full run, and for a long time the machine had 200-odd formulae and
nothing else.

In order: an untrusted tap; Orca's cask 404; krr failing with "failed to fix
install linkage" in the overlay's Brewfile; and `uv tool install pliers`.

That last one is the interesting one. **Amperon's `pliers` is an internal
tool** in `amperon/dev_tools/pliers`, run as `./bin/pliers`. There is an
unrelated public PyPI package of the same name, and that's what the public
dotfiles were installing. It failed loudly only because that package ships no
console entrypoints — had it shipped one, `install.sh` would have quietly put
a `pliers` on `PATH` that wasn't Amperon's. Dependency confusion in miniature,
and worth raising with security if internal tool names are resolved from
public indexes anywhere else.

Two failures inside the overlay's `apply.sh` did **not** stop the run, because
it warns and continues rather than inheriting `set -e` semantics:
`ssh-oauth-helper` and `openmetadata-ingestion`. That's the better behaviour —
worth considering whether the public `install.sh` should treat optional
package installs the same way, rather than making every one of them able to
abort a twenty-minute run.

### Removing the JVM stack broke every new shell

Deleting `java/java-setup.sh` left two references behind: `bash_profile`
sourced `~/java-setup.sh`, and `dotfiles.sh` symlinked it there. Every new
shell then opened with a "No such file or directory" error. Fixed, and the
stale symlink cleaned off totalbiscuit.

The lesson is narrow and worth stating: deleting a file from this repo means
grepping for it in `dotfiles.sh` and the shell configs, not just removing the
caller you happened to be looking at.

---

## Step 5 — verification

Clean, other than the two things that depend on step 6.

| Check | Result |
|---|---|
| `BASH_VERSION` | 5.3.15, not Apple's 3.2 |
| Login shell | `/opt/homebrew/bin/bash` |
| `~/.local/bin` on PATH | yes |
| `wt list` | works |
| Global git identity | the noreply address |
| Work identity via `includeIf` | `tess@amperon.co` inside `~/github/amperon` |
| `brew bundle check` | only `orca` missing, as expected |
| `tailscale status` | not signed in yet |

Two notes on method. `ssh host 'bash -l -s'` runs **Apple's** bash 3.2
regardless of what the login shell is set to, which made it look as though the
shell change hadn't taken — invoke `/opt/homebrew/bin/bash` explicitly. And
`wt list` fails with `git rev-parse --git-common-dir failed` when run from
`$HOME`, because `$HOME` isn't a repo; that's not a worktrunk problem.

The `includeIf` can be tested without cloning anything, which matters when the
key has a passphrase and the session can't prompt: `git init` a scratch
directory under `~/github/amperon/` and read back `git config user.email`.

---

## Step 6 — a wrong diagnosis that cost a morning

`setup/mcp-servers.sh` couldn't read the gateway token from the `ampprod-misc`
vault. Its failure message suggested activating PIM, so the morning went on
waiting for an elevation. PIM was never the problem.

The check that settled it took one command from havelock: same account, same
subscription, and the read succeeded. Whatever was failing on totalbiscuit,
it wasn't the account's permissions.

The actual error, once stderr was allowed through:

```
(Forbidden) Public network access is disabled and request is not from a
trusted service nor via an approved private link.
    Inner error: { "code": "ForbiddenByConnection" }
```

The vault refuses connections from off-net, and never reaches authorization at
all. Azure reports that as `Forbidden`, which reads exactly like a permissions
problem. `ForbiddenByConnection` and the mention of a private link are the only
things distinguishing it from one.

Both machines were behind the same public IP — `38.172.237.28` — which ruled
out an IP allowlist and left Tailscale as the only difference between the
machine that could read the secret and the machine that couldn't. Tailscale
had been treated as a low-priority item to do while PIM activated. It was the
blocker the whole time.

Three defects in the script came out of this, all now fixed:

- It discarded Azure's stderr with `2>/dev/null` and printed a guess in its
  place. The guess was a hypothesis written the day before, not something the
  machine had reported, and it was indistinguishable from a real diagnosis.
  It now prints what Azure actually said.
- Its header claimed the token fetch didn't need Tailscale and only the later
  queries did. Both need it.
- `claude mcp add` defaults to `local` scope, which binds the server to
  whatever directory the script ran in. havelock has `amperon-kb` at **user**
  scope, so the reconstructed script was quietly producing a narrower
  registration than the machine it was modelled on — it would have worked in
  `dotfiles-work` and appeared missing everywhere else. Now `--scope user`.

The general lesson is the one worth keeping: a script that catches a failure
and explains it in its own words will keep telling you that story long after
it stops being true. `mcp-servers.sh` had a plausible, confident, wrong
explanation baked into it, and it was believed over the evidence because the
evidence had been thrown away.

Two smaller things. Tailscale is installed twice on purpose — the App Store
app supplies the daemon (as `IPNExtension`, with no socket at
`/var/run/tailscaled.socket`) and the brew formula supplies the CLI that talks
to it; neither is redundant. And during sign-in the device showed in the
tailnet as `macbook-pro`, which resolved to `totalbiscuit` once the device was
approved — all three `scutil` names were correct throughout, so nothing needed
renaming.

---

## Step 7 — what a fresh clone doesn't bring

The checklist treated `~/github` as "re-clone it" and moved on. That's wrong,
and the survey is the most valuable thing this migration produced.

Cloning restores what's on the remote. It restores nothing that only ever
existed on havelock's disk:

| | havelock | on the remotes |
|---|---|---|
| `amperon/amperon` local-only branches | 12+, **354 commits** | none |
| `amperon/amperon-jobs` | 5 branches, 13 commits | none |
| `amperon/infra-azure` | 4 branches, 5 commits | none |
| stashes | 9 (7 in `amperon/amperon`) | n/a |
| repos with uncommitted changes | 6 | n/a |

The most recent of those branches was **21 hours old**. This was live work, not
archaeology, and it was one `diskutil eraseDisk` from gone. Stashes are worse
than branches here — nothing about a stash is visible from the remote, and
nothing warns you they exist.

So the rule for next time: **a repo that has a remote is not therefore backed
up.** Check `git log --branches --not --remotes` and `git stash list` in every
repo before wiping anything.

### Agent session history

`~/.claude` was 1.4G and `~/.codex` 437M — 1,244 Claude transcripts and 396
Codex sessions, plus 9 per-project `MEMORY.md` files, which are the quietest
possible thing to lose because nothing refers to them until they're missing.

The catch is that `~/.claude/projects` names each directory after the working
directory it belongs to, path-encoded:
`-Users-tessthyer-github-amperon-amperon`. The account short name changed in
this migration — `tessthyer` → `tess` — so every one of the 75 directories
pointed at a path that doesn't exist on the new machine. Copied as-is, the
transcripts are all present and all invisible, since Claude Code looks for
`-Users-tess-…`. They were renamed after the copy; one directory already
existed on the new machine and was merged rather than overwritten.

The `cwd` recorded *inside* each transcript still says `/Users/tessthyer/…`.
Left alone deliberately: rewriting 1,244 files to correct history is more risk
than the benefit, and the sessions really did happen on havelock.

### What was excluded, and why

- `.venv` (2.6G in `amperon/amperon` alone) — contains absolute paths to
  `/Users/tessthyer`. Copying it produces a venv that breaks confusingly
  rather than obviously. Same reasoning for `__pycache__`, `.mypy_cache`.
- `~/.claude/plugins` (518M) — `agents-setup.sh` and the overlay reinstall it.
- `~/.codex/logs_2.sqlite` (128M) — already on the delete list.
- `~/bin` (117M) — one stale `argo-3.6.4` binary; Homebrew supplies `argo`.
- `~/slush` (5.3G) and `~/Downloads` (3.6G) — declined. **These are now the
  only unclaimed data on havelock.**

### The login keychain

Not migrated. The decision was to recover items as they're missed, which is
reasonable and has one consequence worth stating plainly: it makes havelock's
continued existence a dependency, so the wipe step is now gated on it. The one
known item is the himalaya Gmail app password — signing into Gmail in a browser
does not regenerate an app password.

### Two rsync traps

`--info=stats2` isn't supported by the rsync macOS ships; it printed usage and
copied nothing. Worse, `rsync … | tail` reported **exit 0**, because the exit
status of a pipeline is the last command's. A "successful" transfer had moved
zero bytes. Verify copies by counting files on both ends, not by exit code.

Directory names under `~/.claude/projects` begin with `-`, so `mv "$d" "$t"`
parses them as options. `mv --` is required.

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
- [ ] Move Tailscale sign-in ahead of the MCP registration and say why: the
      vault read fails without it, in language that blames permissions.
- [ ] Rewrite step 7. "Re-clone `~/github`" loses every local-only branch,
      stash and uncommitted change. Add the audit commands, and add
      `~/.claude/projects` + `~/.codex/sessions` with the path-encoding
      rename that a changed account short name forces.

---

## Step 1

- [x] Both repos confirmed pushed — `0 uncommitted / 0 unpushed` each.
- [x] The `~/.ssh` survey was already done before this session, and is what
      produced the decision to generate a fresh key on the new machine rather
      than carry either existing one across. Both were passphraseless, so each
      private key file was a plaintext credential; the old RSA key predates
      havelock and wasn't doing the GitHub work. Nothing to redo.
- [ ] Note anything outside `~/github` and `~/Documents` worth keeping.
