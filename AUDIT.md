# Package audit

Standing list of things in the Brewfile worth a second look, and the evidence
needed to decide. Separate from MIGRATION.md, which is one-off and gets
deleted — this outlives the move.

Nothing here is a decision. The point is to hold the questions until there's
evidence, rather than guessing twice.

---

## Waiting on evidence

### gdal and eccodes — 3.3GB of LLVM behind them

`gdal` is 43MB. What it drags in is not:

- `gdal` → `llvm@21` — 1.5GB
- `gdal` → `apache-arrow` → `llvm` — 1.8GB

They're in the Brewfile because `amperon/pyproject.toml` declares `fiona` and
`geopandas`, which bind to GDAL, and `eccodes`, `eccodes-python` and `pygrib`,
which bind to the ecCodes C library. The formulae exist so those build
locally.

That reasoning may be out of date. `fiona` 1.10 ships wheels with GDAL
bundled, and `pygrib` ships wheels bundling ecCodes. If `uv` resolves to
wheels rather than building from source, both formulae are dead weight.

**Test:** build the amperon venv on a machine without `gdal` and `eccodes`
installed, and see whether `fiona`, `geopandas` and `pygrib` come from wheels.
If they do, drop both — it's several gigabytes and a large chunk of
`brew bundle` runtime.

Worth noting `projects/mir/Dockerfile` builds ecCodes from source inside the
container, so that path never needed the local formula.

### Casks with no recent launches

From `kMDItemLastUsedDate` on havelock, 2026-08-12:

| Cask | Last opened | Note |
|---|---|---|
| `1password` | never | Probably the browser extension is what's used. Ask before dropping. |
| `brave-browser` | 118 days | |
| `telegram` | 107 days | |
| `hidden-bar` (mas) | 54 days | |
| `utc-time` (mas) | 58 days | |

### openjdk — kept, but on a single thread

`openjdk` was pulled by exactly two formulae, `gradle` and
`openapi-generator`. Gradle is gone — there is no `build.gradle` anywhere in
`~/github`, and the only JVM projects there are Maven and third-party
(`argo-workflows`, `OpenMetadata`).

So the whole JVM stack now rests on `openapi-generator`, which is genuinely
referenced: the argo-workflows SDK Makefiles, and
`amperon/.claude/skills/workflow/SKILL.md`. Worth knowing that's the only
thing holding it up.

If SDK generation ever moves into CI or a container, three things go together:
`openapi-generator`, `openjdk`, and `java/java-setup.sh` — which would also
remove a `sudo` prompt from `install.sh`, since it symlinks the JDK into
`/Library/Java/JavaVirtualMachines`.

### CLI formulae — no usable evidence yet

Homebrew records install dates but not usage, and bash history on havelock was
only 633 lines: `HISTSIZE=100000` and `histappend` landed on 2026-08-05, so
coverage is about a week. Absence from history means nothing.

`crane` prompted this — Google's `go-containerregistry` tool for inspecting
and copying images straight from a registry without a Docker daemon. Zero
history hits, which is not evidence.

**Revisit around 2026-10** with a month or two of real history behind the new
machine, and audit all 75 formulae at once rather than piecemeal.

---

## Decided — don't re-open

- **`zoom` stays.** 182 days since launch, comparable to NordVPN, kept
  deliberately. The Brewfile line says so.
- **Dropped 2026-08-12:** `notunes` (never launched, and didn't do the one
  thing it was for), `session-manager-plugin` (no `aws ssm` calls in history),
  `nordvpn` (184 days). All in the Brewfile's DROPPED block with reasons.

---

## How to gather the evidence

Cheap to re-run, and worth doing before any decision here.

App last-used dates, sorted by staleness:

```bash
cd /Applications; today=$(date +%s)
for a in *.app; do
  d=$(mdls -name kMDItemLastUsedDate -raw "$a" 2>/dev/null)
  if [ "$d" = "(null)" ]; then printf "%6s  %s\n" never "${a%.app}"
  else ts=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$d" +%s 2>/dev/null)
       [ -n "$ts" ] && printf "%6s  %s\n" "$(( (today-ts)/86400 ))d" "${a%.app}"
  fi
done | sort -rn
```

What's pulling a heavy dependency — the question that found the LLVM above:

```bash
brew uses --installed llvm
du -sh /opt/homebrew/Cellar/*
```

Whether a formula backs a real project dependency, rather than being there
speculatively:

```bash
grep -rInE '^[^#]*(gdal|eccodes|pygrib)' ~/github/amperon/amperon/pyproject.toml
```
