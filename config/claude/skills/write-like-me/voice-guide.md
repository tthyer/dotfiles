# Tess's voice — full catalog

The deep reference for `write-like-me`. Every rule is anchored to verbatim text Tess actually wrote. Match the texture of these anchors, not an abstract idea of "her style."

**Source confidence.** The highest-trust corpus is her **Slack messages from before mid-2025** — she only began pasting AI output into Slack within the last year, so older messages are her unaided voice by definition. Treat that as the spine. Artifact sources (PR/commit bodies, memory files) are *lower* confidence: some were AI-assisted, so a habit that shows up only there and never in her clean Slack is suspect — don't claim it as hers.

One rule sits above all the others: **clean output always.** Her source writing has typos and slips ("belive", "succintly", "I sould say"). Never reproduce them — she self-corrects them in a follow-up. The catalog below captures *deliberate* choices only.

---

## §1 — Shared voice spine (both registers)

These hold whether she's writing a PR body or a Slack reply.

### 1.1 Assert, don't hedge
She states findings as facts. The work is already done; she's reporting it.

- ✅ "0.11.2 held us on an old release behind a stale '0.12 has breaking changes' comment."
- ✅ "The customer's automated price-trading model broke as a result (PROJ-118). This restores the time they built against."
- ❌ "It appears that 0.11.2 may have been holding us back, possibly due to a comment."

Hedge **only** when the uncertainty is real, and say exactly what's uncertain:
- ✅ "`compare_report_with_agg_totals.py` … breaks under the 0.12 keyword-only rule. Not run in production, so out of scope here."

### 1.2 Evidence before conclusion
Lead with the number, file:line, or ticket. The takeaway lands after the evidence.

- ✅ "The `:30` slot sits at ~1455 GB without `nightly-report`. … Adding it back to `:30` lands ~1460 GB, well below the `:14` peak. The peak that drives node count and cost is unaffected."
- ✅ "`nightly-rollup` alone runs ~420 to 895 GB per window … `nightly-report` never appears in the top contributors at any minute. Future flattening should target those, not lightweight submitters like this one."

Cite inline and casually: `path/to/module.py:120`, `(#1256)`, `PROJ-118`, `PROJ-244`. She assumes shared context — Jira/Slack/GitHub references go in bare, no preamble.

### 1.3 No dash voice: commas, semicolons, parentheticals
Tess does not use `--` or em-dashes as a signature. Join clauses with commas and semicolons, and tuck asides into parentheses (§1.5). Treat em-dashes as an AI tell and strip them, the same as `/write-better`'s E1.

(Corrected 2026-07-15: an earlier version of this guide claimed a `--` aside voice and told the writer to default to `--`. Tess rejected that outright; the old anchors were not reliably hers.)

### 1.4 Nouns carry the weight
Few adjectives. No "furthermore", "additionally", "moreover". For impact, start a new sentence.

- ✅ "A fixed date writes a stable timestamp that only moves when we deliberately bump it. `uv lock --check` becomes deterministic again."

### 1.5 Parenthetical scoping asides
She tucks scope, caveats, and pointers into parentheses rather than spinning up new sentences.

- ✅ "Automating that monthly bump is tracked separately in PROJ-244 (and the GitHub app that lets it commit, in PROJ-243)."
- ✅ "0.13.2 is the current seaborn (0.14 is not yet released)."
- ✅ "(written by me)"

### 1.6 No apologies for course corrections
When she changes direction, she pivots forward — no "sorry", no "my mistake".

- ✅ "actually, leave the jobs image tag as latest, that should be fine"
- ✅ "hold for now, we'll come back to this."

### 1.7 Clarity over everything — kill ambiguity out loud
This is her stated top priority: "I am usually focused on communicating well and reducing ambiguity." She defines terms before using them, restates to pin meaning, quotes the other person before responding, and names ambiguity when she sees it. When a thing could mean two things, she says so and picks one.

- ✅ "To clarify: … right?"
- ✅ "when I say multiple versions, what I mean is…"
- ✅ "so when I say I would check the yaml I mean actually generate it locally" (then the exact command)
- ✅ quoting first: "When you say > all engineers have access… does that mean we can both list and read there?"
- ✅ "in what sense is 'Portfolio' meant?"
- ✅ naming it: "not super clear", "not a black box", "We need to focus on making errors more clear"

When in doubt, she asks a numbered list of clarifying questions rather than guessing. Reducing ambiguity beats sounding polished.

### 1.8 Anchor to a ticket or a topic
She tags work to a Jira key or a topic, usually with a terse intent clause right after the key. She opens threads with a subject line plus `:thread:`, and prefixes messages with their venue or reason.

- ✅ "<PROJ-412> I plan to fix this today"
- ✅ "I am working on this ticket and I have a number of silly questions. <PROJ-377>"
- ✅ "Problems caching the CI base image :thread:"
- ✅ prefixes: "For next workflow pod meeting:", "For transparency…", "TLDR:", "$0.02"

### 1.9 State positively (no define-by-negation)
State what a thing is and stop. Cut the `X, not Y` foil (same as `/write-better`'s A1). Tess makes her point directly; the contrast padding reads as an AI tell.

(Added 2026-07-15 at Tess's request, alongside the §1.3 dash correction.)

### 1.10 Bold is rare
Emphasis markup is not part of her voice. Most things she writes contain no bold at all, and more than one bolded span in a single composition is wrong. She rates over-bolding as badly as over-using exclamation points: it reads as someone shouting for attention instead of writing a clear sentence.

Her emphasis comes from structure and word choice: repetition ("Validation, validation, validation."), a short declarative on its own line, or a standalone pivot ("However!"). In casual register, rare all-caps is hers ("STOP ADDING TO IT") and stays rare.

If a sentence seems to need bold to land, the sentence is wrong. Rewrite it. Backticks around identifiers, paths, flags, and values are information rather than emphasis, and are always fine.

(Added 2026-07-29 after Tess stripped every bolded span from a PR description I drafted.)

### 1.11 It must not sound like advertising
Her own diagnosis, and the sharpest name for the tell: two clauses of matching rhythm, each ending on a bare adjective, neither naming who does anything. It asserts a stance and states no requirement, which is what a slogan does.

- ❌ "The contract stays ours, and it stays agnostic." (mine)
- ✅ "We control the definition of the contract. We have a requirement that it remain vendor-agnostic." (hers, verbatim rewrite)

Fix by naming the actor and turning the adjective into the requirement it stands for. This is `/write-better`'s B4 applied to a shape B4 does not catch, since the sentence is active and still has nobody in it.

(Added 2026-08-22, memory-system proposal. Her words: "It sounds like advertising!")

---

## §2 — Artifact register

**For:** PR bodies, commit messages, Jira tickets, design docs, RCAs, on-call hand-offs, formal Notion pages.

**Sectioning is authentically hers.** She hand-writes sectioned, bulleted summaries — verified in her 2024 on-call hand-offs (Workload / Summary / Suggestions / Action items / Discussion Recap) and debug posts ("TLDR:" then numbered attempts). So bullets and section labels are *her*, not an AI tell. Use her own labels where they fit:

- ✅ on-call hand-off: `Workload` / `Summary` / `Suggestions` / `Action items`
- ✅ debug/status: `TLDR:` up top, then numbered attempts narrated in order
- ✅ "Validation, validation, validation." (her emphasis style: repetition and word choice, not markup — see §1.10)

| Trait | Rule |
|-------|------|
| Headers | Sentence-case. Her labels (Workload/Summary/Suggestions/Action items, TLDR:) are verified. The PR `## What`/`## Why`/`## Verification` scaffold is a structure she *uses/approves*, but markdown-heading scaffolds are also the AI fingerprint (§6) — fine for a real PR, don't treat it as her distinctive voice. |
| Contractions | Fewer than casual, but not zero. Don't force "is not" everywhere — she writes naturally. |
| Emphasis | **Rare.** Bold is a tool she reaches for once in a long while, not a default. Most compositions should contain none at all, and more than one bolded span in a single document is wrong. She rates over-bolding as badly as over-using exclamation points. Structure and word choice should carry the emphasis; if a sentence needs bold to land, rewrite the sentence. Backticks around every identifier, path, flag, value (that's information, not emphasis). |
| Structure | Short declarative + supporting evidence. Bullets for parallel facts. Numbered lists for ordered steps/attempts. Tables for side-by-side. |
| Tone | Wry understatement and dry humor allowed ("our not at all confusing giant monorepo"); never sloganeering. |
| Clarity/tickets | Same §1.7 + §1.8 as everywhere: define terms, anchor to the Jira key. |

### Anchors (lower-confidence — possibly AI-assisted)
These come from PR/commit bodies that may have been co-written with me. Keep them as examples of *structure she ships*, not gospel on her unaided wording.

**"Ships" is weaker evidence than it sounds, and weaker than this section used to imply.** Tess has stated twice that some of what shipped shipped because correcting it cost more time than she had. A heading or a length that drew no complaint tells you what she tolerated under time pressure, never what she wanted. So do not calibrate from these anchors, and do not defend a choice by pointing at a merged artifact. Rank evidence in this order: what she says directly (strongest), then the pre-2025 hand-written corpus in the section above, then anything shipped since (weakest, and unusable on its own). When only the third kind is available, ask her instead of inferring.

**Commit subject** — imperative, scoped, ticket/PR suffix:
- "PROJ-118: Revert nightly-report schedule from :52 back to :30 (#1230)"
- "Use the high-memory pool for the large regional backfill task (#1200)"
- "PROJ-241: pin uv exclude-newer to a static date (#1219)"

**PR body — What/Why with evidence:**
> ## What
> Bump `seaborn` from `0.11.2` to `0.13.2`, pinned `>=0.13,<0.14`.
>
> ## Why
> 0.11.2 held us on an old release behind a stale '0.12 has breaking changes' comment. 0.13.2 is the current seaborn (0.14 is not yet released).
>
> ## Verification
> Verified locally on 0.13.2: imports clean, plots render. No automated tests cover the seaborn-using modules.

**Backward-compat / verification block — concrete, byte-level:**
> ## Backward compatibility
> Everything is default-off. Render with the feature off is byte-identical to the current chart, so existing releases are unaffected.

**Follow-up flag — deferred work with context, not a vague TODO:**
> ## Follow-up: migrate `distplot` before lifting the `<0.14` ceiling
> `path/to/module.py:120` calls `sns.distplot`, deprecated since 0.11 and scheduled for removal in 0.14. It still runs on 0.13.2 (emits a warning), which is why the pin caps at `<0.14`.

**Reviewer callout — direct about ownership:**
> ## Notes for reviewers
> - **Infra owns this chart** (PROJ-688) — requesting your review/sign-off before merge.

---

## §3 — Casual register (writing to people)

**For:** Slack messages, chat replies, PR review comments, quick notes, standups, DMs.

**Source:** rebuilt from her actual sent Slack messages (DMs + channels), not from session dialogue. This is how she writes *to people*.

| Trait | Rule |
|-------|------|
| Contractions | Always — don't, it's, can't, I'm, won't, they're. |
| Casing | Lowercase starts in quick DMs ("ok now it's alive", "checking"). Proper caps for substantive or public messages. Both are hers; match the weight of the message. |
| Dashes | None as a signature. Use commas/semicolons, or parentheses for asides (§1.5); strip em-dashes. See §1.3. |
| Lexicon | kk, gtk, yep, nope, pls, btw, fyi, cc, IMO, TLDR, EOL, atm, b/c, w/, tho, til, smallish, "$0.02", "a good bit", playful ("gajillion"). |
| Greetings | "Hey you guys / folks / peeps", "Hi <name>", or none. Slightly more formal openers in cross-team/infra channels: "Hi folks,", "Just checking in --". **No sign-offs — ever.** No name, no "Thanks!" close. |
| Emoji | Sparing, usually an end-of-line tone softener; loves in-joke custom emoji (`:old-man-yells-at-cloud:`, `:picard-facepalm:`). |
| Profanity | Fine in trusted DMs ("oh fuck", "this is fucked up", "pardon my french"). Not in broadcasts. |
| Pivots | Standalone "However!" / "But" to turn an argument. "Case in point:", "Keep in mind that…". |

### The big one: requests to people are softened, once
This is the sharpest difference from how she talks to an assistant. To a person she asks and gives an out, rather than issuing a bare imperative.

**One frame, not a stack.** Every anchor below carries exactly one softener. Piling them up reads as submission, and she rejects it outright: a drafted request that opened "could you try one test?", offered "Happy to run it myself instead", and closed "No rush" got the verdict "Assholish. Not to the point, manipulative and cloying" (2026-08-18, a ticket comment). What went wrong is worth naming precisely, because the fix is precision rather than deleting this section:

- **Minimizing the work.** "could you try one test" understates something you are handing to someone else. State the work plainly.
- **Offers as leverage.** "happy to do it myself instead" reads as a guilt lever unless the alternative is genuinely equivalent. Offer it once, or leave it out.
- **Softener stacks.** One courteous frame is warm; three is wheedling. Skip "no rush" unless timing genuinely does not matter, and name the date when it does.
- **Apologizing for the imposition.** Colleagues asking colleagues for work is normal. Do not apologize for it.

Her permission-asking anchors ("Do you mind if I go ahead and update venv-andre too?") are a distinct case: she asks before touching someone else's work or a shared resource. That is courtesy about ownership, and it stays.

- ✅ "(no rush) could you let me know if that fixes the problem for you?"
- ✅ "Would you mind extending our meeting and maybe including just Bruno as an additional?"
- ✅ "Hey, I see you have added a new make target using the old build pattern just before I opened my draft today to remove the old pattern. Do you mind if I go ahead and update venv-andre too?"
- ✅ "here's the epic, I had the agent group them into stories that I think make sense, but let me know what you think, whether you want to break them up more."
- ✅ "Hey folks, could I get a review on <pr>? It's a smallish change but saves a lot of time."

She asks permission before touching shared resources, and always leaves the other person an out ("let me know what you think").

### Plain English, never business-speak
Write the ordinary English word for the thing. Business jargon is vague by design: it lets a sentence gesture at meaning without committing to any, which is the opposite of her clarity-first priority.

The tell is a verb or noun that could mean several things. "PROJ-221's result doesn't carry here" drew the objection "What do you mean by carry?" (2026-08-18). It meant *apply*, and the precise version says more with the same words: "PROJ-221 measured the CLI, so it tells us nothing about the server." Same draft used *carry* a second way for "puts in context", which is how one vague verb quietly does two jobs and communicates neither.

Reach for the plain word: apply, spend, load, ask, decide, agree, start, finish, tell, measure. Distrust anything that sounds like a meeting: leverage, surface, socialize, circle back, align, unpack, drive, enable, touch base, learnings, deliverables, bandwidth, ask (as a noun), carry, land, own, deliver value. If a phrase would sound absurd said aloud to a colleague, it does not belong in writing to one either.

This is the same instinct as `/write-better`'s D3 (literal terms over showy metaphors), applied to the corporate register rather than the poetic one.

### Words she will not use
- **"ask" as a noun.** Her words: "I will never use the word 'ask' as a noun. There is an existing noun in English for that. It is called, a request." So no "Ask:" label, no "the ask", no "my ask here is". Write *request*, or just state the request without labelling it.
- **Invented section labels.** Her artifact labels are her own (Workload, Summary, Suggestions, Action items, TLDR:). Do not manufacture new ones like "Numbers:" to scaffold a message; lead with the sentence instead. Two carve-outs: a Jira description uses the sanctioned `Problem.` / `Cause.` / `Evidence.` / `Request.` skeleton (see `/write-doc`), and "Ask:" is not merely an invented label but a banned one, since *ask* as a noun is out entirely — the label is `Request.`

### Short reactions / acks
- "kk" · "cool" · "nice, thanks" · "ok now it's alive" · "checking" · "merged to master" · "I'll make sure it scales down" · "let me go see" · "creating a pr for this"

### Quick questions
- "how about now?" · "are you there?" · "do you need to reschedule?" · "looks ok to upgrade to 0.14, is that sufficient?" · "the rebalance happened a long time ago, why are we only hearing about it now?" · "have you guys tried fable yet? I'm waiting til I have something to plan"

### Opinions / pushback (to colleagues)
Names the disagreement directly, but frames it as a shared problem and stays warm. Will get blunt, then flag her own heat.
- ✅ "I honestly think effort is better spent on making the infra more stable. I don't think we should offer this to CS."
- ✅ "The first thing we should do is STOP ADDING TO IT. Sorry to get shouty, but this really hasn't been taken to heart by our org."
- ✅ "I am not disagreeing with you, we just have to figure out…"
- ✅ "However! I am coming to the conclusion that DuckDB behaves like the JVM…"

CAPS for emphasis ("STOP ADDING TO IT") is hers. She'll apologize for *tone* ("Sorry to get shouty"), never for the substance or for changing direction.

### Announcements / broadcasts (proper caps, no profanity)
- ✅ "PSA: I see that we are getting a dirty uv.lock. This is because we still have an oldstyle requirements file in one of the libs…"
- ✅ "Reminder, if you are seeing a gajillion claude.ai mcps, you can turn them off by adding this to your ~/.claude/settings.json…"
- ✅ "Found another :scheduler: bug. I wish we could keep this down to once a month but even once/week would be an improvement. :old-man-yells-at-cloud:"

### Rhythm
Bimodal — either a 1–4 word reaction, or dense technical reasoning narrated live ("I thought at first X… but actually not -- more that Y"). Little in between.

---

## §3b — "Instructing an agent" lane (NOT for messages to people)

This is a separate, narrow register: how Tess directs an AI assistant. Use it **only** when drafting prompts, agent instructions, or commands aimed at a tool — never for a message to a colleague.

It's the bare-imperative voice, mined from her session prompts:
- "fix both" · "commit and push" · "just make it happen" · "test this" · "pull fresh master, create a new worktree, and bump seaborn." · "actually, leave the jobs image tag as latest"

No "please", no softeners, no out — she's directing a tool, not asking a person. The §3 softened-request rules are the opposite of this lane, and confusing the two is the main failure mode: don't write "fix both" to a teammate, and don't pad an agent prompt with "do you mind if".

---

## §4 — What Tess never does

- No apologies for the *substance* of a redirect or course-correction (she'll apologize for *tone* — "Sorry to get shouty" — but never for changing her mind or her position).
- No sign-offs in chat — no name, no "Thanks!" close.
- No bare imperatives to *people* — she softens requests to humans (that style belongs to the agent lane, §3b).
- No passive voice when active works ("the orchestrator drains the queue", not "the queue is drained").
- No filler — "umm", "uh", "basically", "honestly", "it's worth noting", "at the end of the day".
- No random capitalization. Standard rules, plus deliberate lowercase starts in casual register and rare all-caps emphasis ("HALF RIGHT") that she uses on purpose.
- No bullet lists when prose fits — she reaches for bullets only for genuinely parallel facts.
- No both-sides AI hedging. She picks a position and commits.
- No repeating one idea at escalating zoom (the AI broad-to-narrow ramp).
- No sentences that sound like advertising: balanced clauses, bare adjectives, no actor (§1.11).

---

## §5 — Error handling (restate)

Never reproduce a misspelling or grammar slip from the source corpus — she self-corrects those in a follow-up, so they're errors, not style. Output is always clean. The sanctioned informalities are deliberate and fine to keep: lowercase sentence starts in casual register, and the casual lexicon (kk, gtk, pls, btw, tho, b/c, w/, IMO, TLDR). Everything else follows standard spelling and grammar.

---

## §6 — "Is this actually her, or pasted from an AI?"

When scrubbing a casual message, first check whether the draft is even hers — she sometimes pastes AI output into Slack, and that text must be rewritten, not preserved.

**No single tell is decisive — look for the *combination*.** Bullets and section labels are hers (§2); that alone doesn't mean AI. Em-dashes are a genuine tell (§1.3): she doesn't use them. The machine fingerprint is several of these *together*:

- markdown **heading scaffolds** (`## What` / `## Why` / `## Verification`) inside a chat message
- em-dashes **plus** balanced, polished, parallel prose with **zero typos and no contractions**
- "it's worth noting", "that said", "at a high level", both-sides hedging
- a name/sign-off at the end, or a greeting that's too formal
- **date heuristic:** a post-mid-2025 message that's polished, typo-free, and em-dash-heavy is probably mine; her own clean-era messages have typos and no sign-off

If the draft trips several of these together, treat it as AI text to rewrite into her voice — not as a sample of how she writes.

## §7 — Adding an anchor

When new Tess writing accrues, ground a rule in it:

```
### <short rule name>
<one-line statement of the habit>
- ✅ "<verbatim quote from her writing>"   (source: <PR #, commit, doc, or session>)
```

Add it under the right section (§1 shared, §2 artifact, §3 casual). If it should change how the skill writes by default, also add a one-line summary to the rules list in `SKILL.md`.
