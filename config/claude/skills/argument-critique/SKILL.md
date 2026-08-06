---
name: argument-critique
description: Summarize an argumentative piece (web article, video, essay, or pasted text), analyze its rhetoric, and identify logical fallacies. Use when the user asks to "critique this article/video/essay/argument", "identify fallacies in <url or text>", "analyze the rhetoric of <source>", or "summarize this and analyze its argument".
allowed-tools: WebFetch, WebSearch, Skill, AskUserQuestion, Read
---

# Argument Critique

Three-stage critical analysis of an argumentative piece from any source.
Run only the stages the user asked for; offer the remaining ones at the end.

## Inputs
- Source: web article URL, video URL, pasted text, or local file path
- Requested stages (default: summary + rhetoric; fallacies on request)

## Steps

1. **Acquire the source.** Branch on input type:
   - **Web article URL** — two WebFetch calls (15-min cache makes the
     second cheap):
     a. *Substance:* title, author, date, full structure, key claims,
        statistics, named sources, conclusions — "preserving the
        author's actual wording".
     b. *Style:* 12-15 verbatim passages showing rhetorical technique
        (tone, repetition, direct address, rhetorical questions,
        sarcasm, analogies, characterization of opponents) plus overall
        length, opening/closing moves, typography (bold/italics/headings).
     - Pitfall: WebFetch's small model condenses by default. One generic
       fetch yields a summary with no quotable material; the second,
       style-targeted prompt is what makes the rhetoric analysis concrete.
   - **Video URL** — invoke `/summarize-video` to pull the transcript,
     then analyze the transcript directly. Caveat in the output:
     transcript analysis misses typography entirely, and tone devices
     (sarcasm, emphasis, pacing) only partially survive captioning —
     flag tone judgments as lower-confidence.
   - **Pasted text or local file** — use it directly (Read for files).
     Best case: full verbatim access, no lossy fetch-model intermediary.
2. **Apply /write-better** before drafting output (standing user preference).
3. **Summary** — thesis in one line, main arguments as bullets with the
   piece's own numbers and sources, conclusion. Attribute claims to the
   author ("Zitron argues..."), never adopt them as fact.
4. **Rhetoric analysis** — structure and tonal arc first, then numbered
   techniques. Name each device (anaphora, apostrophe, kafkatrapping,
   burden-shift), quote a verbatim example, and say what work it does on
   the audience. End with an audience-effectiveness judgment.
5. **Fallacies (on request)** — split into **genuine fallacies** and
   **borderline / rhetorically loaded but valid**. Name each with its
   classical label, quote or cite the specific move, and explain why it
   qualifies. Close with a fairness note: identify the author's strongest
   *non*-fallacious argument so the critique doesn't read as a hit piece.
6. **Offer fact-checking.** After delivering the analysis, list the
   piece's 3-6 most checkable empirical claims (surveys, dollar
   figures, attributed quotes) and ask the user (AskUserQuestion) whether
   to verify them, with an estimate scaled to the claim count:
   - **Quick pass** (~2-4 claims, 1 WebSearch + 1 WebFetch each):
     ~2-5 minutes, low token cost (~20-50k).
   - **Thorough pass** (all claims, primary sources fetched and quotes
     checked against originals): ~5-15 minutes, moderate token cost
     (~50-150k), more if sources are paywalled or hard to find.
   If the user opts in, verify each claim against the primary source
   (the actual survey/report, not coverage of it) and report: confirmed,
   distorted (how), or unverifiable.

## Success criteria
- Every rhetoric/fallacy claim is anchored to a verbatim quote or a
  specific cited move from the piece, not a paraphrase of the genre.
- Fallacy analysis distinguishes invalid reasoning from aggressive-but-
  valid argument (e.g. burden-of-proof shifts that are actually fair).
- Summary is readable standalone by someone who won't open the source.

## Constraints / pitfalls
- Cross-host redirects: WebFetch returns them; re-call with the new URL.
- Paywalled/JS-heavy pages: WebFetch may return navigation chrome or a
  truncated body — tell the user rather than analyzing a fragment.
- Very long articles (8k+ words) get lossy through the fetch model;
  lean on the two-fetch split and say when coverage is partial.
- Auto-generated video captions lack punctuation and speaker labels;
  don't over-read sentence-level style from them.
