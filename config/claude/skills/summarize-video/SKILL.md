---
name: summarize-video
description: Pull the transcript from a YouTube (or other yt-dlp-supported) video URL and summarize it. Use when the user asks to "summarize this video", "transcribe this YouTube video", "what does this video say", or pastes a video URL with a request for the contents. Works on any site yt-dlp supports (YouTube, Vimeo, Twitch VODs, conference recordings, etc.).
allowed-tools: Bash, Read, Write
---

# Summarize Video

Pull captions from a video URL via `yt-dlp`, clean them into plain text, then summarize.

## Prerequisites

Requires `yt-dlp` on PATH. Verify with `yt-dlp --version`. If missing, tell the user to run `brew install yt-dlp` (macOS) or see https://github.com/yt-dlp/yt-dlp#installation. Do not auto-install without confirmation.

## Step 1: Resolve cache path

Cache transcripts at `~/.claude/cache/transcripts/<video-id>.txt`. Create the directory if missing: `mkdir -p ~/.claude/cache/transcripts`.

Extract the video ID with `yt-dlp --get-id <URL>`. If a cached transcript already exists for that ID, skip to Step 4.

## Step 2: Fetch metadata and captions

Run from a working directory, e.g. `cd ~/.claude/cache/transcripts`:

```bash
yt-dlp \
  --skip-download \
  --write-subs \
  --write-auto-subs \
  --sub-langs "en.*,en" \
  --sub-format vtt \
  --convert-subs vtt \
  --write-info-json \
  -o "%(id)s.%(ext)s" \
  "<URL>"
```

This produces:
- `<id>.info.json` — metadata (title, channel, upload date, description, duration)
- `<id>.en.vtt` (or similar) — captions. Manual subs preferred; auto-generated as fallback.

If no `.vtt` file is produced, captions are unavailable. Tell the user and stop — do not attempt audio download + transcription unless they explicitly ask.

## Step 3: Clean VTT into plain text

VTT files contain WEBVTT headers, cue timestamps, styling tags, and (for auto-captions) heavy line duplication from rolling cues. Strip them with:

```bash
awk '
  /^WEBVTT/ || /^Kind:/ || /^Language:/ || /^NOTE/ { next }
  /-->/ { next }
  /^[[:space:]]*$/ { next }
  /^[0-9]+$/ { next }
  {
    gsub(/<[^>]*>/, "")
    gsub(/&nbsp;/, " ")
    gsub(/&amp;/, "\\&")
    gsub(/&lt;/, "<")
    gsub(/&gt;/, ">")
    gsub(/&quot;/, "\"")
    gsub(/&#39;/, "'\''")
    if ($0 != prev) print
    prev = $0
  }
' "<id>.en.vtt" > "<id>.txt"
```

Then collapse repeated whitespace and remove the cue-overlap dupes that auto-captions produce. A simple final pass:

```bash
awk '!seen[$0]++' "<id>.txt" > "<id>.clean.txt" && mv "<id>.clean.txt" ~/.claude/cache/transcripts/<id>.txt
```

Delete the intermediate `.vtt` and `.info.json` after extracting what's needed (keep info as a header in the `.txt` if useful):

```bash
rm -f "<id>.en.vtt" "<id>.info.json"
```

## Step 4: Ask where the summary should go

Before producing the summary, ask the user:

> Show the summary in the terminal, or save it to a markdown file? (default: terminal)

If they say file (or "save", "write to disk", etc.):
- Default location: `~/.claude/plans/<slug>.md`
- Slug rule: lowercase the title from `info.json`, drop punctuation, replace spaces with hyphens, trim to ~6 words. Prefix with the speaker's last name if known and not already in the title (e.g. `appleton-collaborative-ai-engineering.md`).
- Confirm the path with the user before writing if it differs from what they asked for.

If they say terminal (or don't specify and the request reads as conversational), render inline.

Skip this question only if the user has already stated their preference in the same turn (e.g. "summarize and save to foo.md").

## Step 5: Produce the summary

Read `~/.claude/cache/transcripts/<id>.txt` with the Read tool. Summarize the content matching the user's request. Defaults if unspecified:

- **Format:** key points as a bulleted list, grouped by topic when the talk has clear sections.
- **Length:** ~150–300 words for a typical 30–60 min talk; scale up only if the user asks.
- **Up top:** title, speaker, and (if known) date — pulled from the info JSON or the first lines of the transcript. When writing to a file, also include the source URL.
- **Caveat verbatim quotes:** auto-captions have transcription errors. Don't quote unless the user explicitly asks; paraphrase instead.

Ask the user before producing a long-form writeup, transcript dump, or per-section breakdown — those are heavier asks.

## Notes

- yt-dlp supports ~1000 sites, not just YouTube. The same flow works for Vimeo, Twitch VODs, conference platforms, etc.
- Auto-captions are riddled with homophones and missed proper nouns. Flag named entities you're unsure about rather than guessing.
- For age-restricted or private videos, yt-dlp will fail; tell the user it's restricted rather than retrying.
- If the user asks for a transcript without summarization, just produce the cleaned `.txt` path and a short preview — don't dump the whole thing inline.
