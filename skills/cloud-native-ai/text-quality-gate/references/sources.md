# Sources — Text Quality Gate

Every URL below was checked during skill authoring (2026-11-24; re-fetched and rewritten 2026-11-27).

| Source | Retrieved status (2026-11-27) | What it contributed |
|---|---|---|
| https://vale.sh/docs | 301 to https://docs.vale.sh/ (read OK there via WebFetch) | Open-source prose linter; block and inline code ignored by default; `error` level fails CI |
| https://docs.vale.sh/topics/styles | 200 OK | Twelve check types, levels `suggestion`/`warning`/`error`, only errors set a non-zero exit. The page does not say code is ignored; that comes from the intro page |
| https://docs.vale.sh/topics/cli | 200 OK | Exit codes 0, 1, 2 and meanings; `--no-exit` does not change 2; `--minAlertLevel` |
| https://github.com/DavidAnson/markdownlint | 200 OK (README) | Per-rule config values, inline disable/enable comments (line, next line, file), `noInlineConfig`. CLI exit codes not read |
| https://git-scm.com/docs/githooks | 200 OK | `pre-commit` and `commit-msg` arguments, abort on non-zero exit, `--no-verify`, `core.hooksPath`, executable bit, working directory, `GIT_EDITOR=:` |
| https://code.claude.com/docs/en/hooks | 200 OK; about 300,000 characters read in three passes (last ~1,700 not read) | Exit 0/2/other semantics, PreToolUse JSON and decision values, Write/Edit `tool_input` fields, Stop payload (`stop_hook_active`, `last_assistant_message`), Stop block by JSON or exit 2, 8-continuation cap, `onFailure: block` (2.1.295+, no effect on Stop) |
| https://developers.google.com/style | 200 OK | "Guidelines, not rules" statement |
| https://developers.google.com/style/highlights | 200 OK | Highlights used as pattern candidates (sentence-case headings, descriptive links, serial commas) |
| https://developers.google.com/style/tone | 200 OK | Avoid "simply", "easy", "quickly" and "please note"; do not repeat the same sentence opener |
| Third-party skill read for ideas, no text reused (a pre-publish "slop" scanner plus its editorial counterpart; MIT per its repository) | Not re-opened | Idea only: rule-versus-gate framing, two-tier split, masking before scanning. All wording, patterns, examples and code here are original |

## Reading limits

- The Claude Code hooks page was read except its last ~1,700 characters. Events other than `PreToolUse` and `Stop` were not examined; the `PostToolUse` row of the earlier version was removed because it was not re-verified.
- Corrections on 2026-11-27: Stop can also block through exit 2; `stop_hook_active` and the 8-continuation cap added; Write/Edit field names now confirmed; `onFailure: block` details added.
- Vale and markdownlint were read as references for design (check types, severities, inline overrides), not run.
- The example script was run locally on small fixtures on 2026-11-24 and not re-run or edited on 2026-11-27 (scripts are out of scope for this pass); thresholds in the text are illustrations.
- That git's default message cleanup strips `#` comment lines before a `commit-msg` hook sees the file was not confirmed from githooks; the hook example filters them itself.

## Claims not adopted as fact

- Any claim about how often agents skip style rules in "writing" versus "layout" steps is an inference from experience, not a measured rate, and is written as a working hypothesis.
- Precision targets ("roughly even") and the threshold of 3 counted words are suggestions, not standards.
- Specific tell lists from third-party sources were not copied; the examples in this skill are generic and original.
