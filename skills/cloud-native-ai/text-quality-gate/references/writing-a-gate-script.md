# Writing the Gate Script in Any Language

Sources: https://git-scm.com/docs/githooks · https://code.claude.com/docs/en/hooks · https://docs.vale.sh/topics/cli · Last verified 2026-11-27

Design is language-neutral; the example below is Python (standard library only) and was run during authoring (2026-11-24; not re-run on 2026-11-27) against fixtures: a file with an emoji heading, a filler phrase, a recap opener and a quoted tell exited 1 with three hits (the quoted tell and the fenced code were ignored); a text with three counted words exited 1; a text where the same words sit in backticks and quotes exited 0.

## 1. Anatomy

```
patterns (data)  ->  mask(text)  ->  scan(masked)  ->  report(hits)  ->  exit code
```

- **Patterns are data**: a table of label to regex, plus a counted-word regex and a threshold. In another language this is a map or a config file; nothing else changes.
- **mask** blanks code, quotes and exempt regions but keeps newlines.
- **scan** returns a list of `(line, label, excerpt)`; line 0 means "document-level".
- **report** prints `path:line: label: excerpt` to stderr.
- **exit**: 0 clean, 1 hits, 2 the gate could not run (let the exception propagate to a non-zero code other than 1, or catch and exit 2 explicitly).

## 2. Example (about 40 lines, Python 3)

```python
#!/usr/bin/env python3
"""Tiny text gate: exit 1 on any hard tell, or on too many counted words."""
import re, sys

HARD = {  # one hit fails: patterns that are almost never right
    "emoji heading": r"^#+\s*[\U0001F300-\U0001FAFF]",
    "throat-clearing": r"\b(it'?s worth noting|at the end of the day)\b",
    "recap opener": r"^(in conclusion|to summarize),",
    "flattery opener": r"^(great question|absolutely)\b",
}
COUNTED = r"\b(robust|seamless|leverage|streamline|delve|cutting-edge)\b"
LIMIT = 3  # decoration shows up as density, not as a single word

def mask(text):
    """Blank out code and quotes but keep newlines, so line numbers stay true."""
    blank = lambda m: re.sub(r"[^\n]", " ", m.group())
    text = re.sub(r"```.*?```", blank, text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", blank, text)
    return re.sub(r'"[^"\n]*"|“[^”\n]*”', blank, text)

def scan(raw):
    if re.search(r"gate-ok: \S+", raw):  # exemption must carry a reason
        return []
    text, hits = mask(raw), []
    for n, line in enumerate(text.splitlines(), 1):
        for label, pat in HARD.items():
            if re.search(pat, line.strip(), re.I):
                hits.append((n, label, line.strip()[:60]))
    words = re.findall(COUNTED, text, re.I)
    if len(words) >= LIMIT:
        hits.append((0, f"{len(words)} counted words", ", ".join(words)))
    return hits

if __name__ == "__main__":
    failed = False
    for path in sys.argv[1:] or ["-"]:
        raw = sys.stdin.read() if path == "-" else open(path, encoding="utf-8").read()
        for n, label, excerpt in scan(raw):
            print(f"{path}:{n}: {label}: {excerpt}", file=sys.stderr)
            failed = True
    sys.exit(1 if failed else 0)
```

Notes on the choices:

- `mask` runs fences first, then inline code, then quotes (see `hard-tells-and-counted-signals.md`).
- Patterns match per stripped line so `^` anchors work; counted words are counted over the whole masked text.
- The exemption regex requires a non-empty reason after `gate-ok:`.
- The script reads files or stdin (`-`), so the same code serves a git hook, CI and a pipe.
- Known weaknesses (say so in your own copy): whole-file exemption is coarse; the emoji range is a coarse approximation; `\b` is ASCII-minded for non-English text. Add language-specific patterns as data, not code.

## 3. Hook adapters

Git `commit-msg` (message file is argument 1; drop git's comment lines first):

```sh
#!/bin/sh
grep -v '^#' "$1" | python3 tools/text_gate.py -
```

Claude Code `PreToolUse` adapter for `Write` and `Edit`. Claude Code treats only exit code 2 as a block, so translate the gate's exit 1:

```python
import json, sys
from text_gate import scan          # the module above

payload = json.load(sys.stdin)
tool_input = payload.get("tool_input", {})
text = tool_input.get("content") or tool_input.get("new_string") or ""
hits = scan(text)
if hits:
    for n, label, excerpt in hits:
        print(f"line {n}: {label}: {excerpt}", file=sys.stderr)
    sys.exit(2)                     # blocks; the model sees stderr and can rewrite
sys.exit(0)
```

The hooks reference documents `content` for `Write` and `new_string` for `Edit` (plus `file_path` on both). Log one payload while wiring anyway; field names are the part most likely to drift.

For a `Stop` hook the same scan runs on `last_assistant_message` from the payload; answer with a JSON block decision on stdout and exit 0, or exit 2 with a reason, but not both. Return early (exit 0) when `stop_hook_active` is true, or a reply that cannot be fixed loops until the 8-continuation cap.

## 4. Porting the design

| Language | Regex notes | Where it shines |
|---|---|---|
| Python | `re`; stdlib only | quick, readable, portable |
| Node | `RegExp` with the `u` flag for emoji classes | repos already using Husky or lint-staged (`setup-pre-commit`) |
| POSIX shell + `grep -E` | no lazy quantifiers; mask code fences with `awk` state | smallest footprint, weakest masking |
| Go / Rust | compile patterns once; table-driven tests | single static binary for CI |
| Vale (config only) | existence and occurrence rules, YAML | when the patterns fit its checks |

Port the fixtures, not just the code: the same files must fail and pass in every implementation.

## 5. Fixtures and tests

```
fixtures/
  fail-emoji-heading.md        # must exit 1
  fail-throat-clearing.md      # must exit 1
  fail-counted-density.md      # three counted words, must exit 1
  pass-quoted-and-code.md      # tells only inside quotes or code, must exit 0
  pass-exhibit.md              # "gate-ok: <reason>" present, must exit 0
  pass-clean.md                # normal prose, must exit 0
```

Run each file through the script and assert the exit code; run the test in CI (`tdd`). Add a fixture for every false positive you fix.

## 6. Operating notes

- Start in report-only mode (always exit 0) for a week, then switch to blocking.
- Keep the message short: label, line, excerpt, and (optionally) the one-line fix.
- Version the script and patterns with the repository; they are code.
- Do not let the gate grow into a meaning-checker; hand that to a reviewer (`code-review`).

## How an agent should apply this

- Reuse the shape: data patterns, newline-preserving mask, per-line scan, stderr report, 0/1/2.
- Add an adapter for each call site instead of forking the scan logic.
- Ship fixtures with the script and add one for every pattern and every false positive fixed.
- Translate exit 1 to exit 2 (or a JSON decision) for Claude Code hooks and verify that a bad input really blocks.
- State plainly in the handoff which hook points run the gate and how each can be bypassed.
