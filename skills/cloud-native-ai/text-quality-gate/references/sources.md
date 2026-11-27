# Sources — Text Quality Gate

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://vale.sh/docs | 301 to https://docs.vale.sh/ (canonical variant used; read OK) | What Vale is (open-source prose linter, rules as YAML styles); block and inline code ignored by default; `level: error` fails CI builds. |
| https://docs.vale.sh/topics/styles | 200 OK (reached via a 301 from vale.sh/docs/topics/styles) | The twelve check types (`existence`, `substitution`, `occurrence`, `repetition`, `consistency`, `capitalization`, and others), rule anatomy (check, scope, message, action), levels `suggestion`/`warning`/`error`. The page does not document `ignorecase`; not claimed. |
| https://docs.vale.sh/topics/cli | 200 OK (reached via a 301 from vale.sh/docs/cli) | Exit codes 0, 1, 2 and their meanings; `--no-exit`; `--minAlertLevel`; only errors change the exit code. |
| https://github.com/DavidAnson/markdownlint | 200 OK (README; the separate docs pages were not fetched) | Rule model (numbered rules, tags), per-rule configuration values (`false`, `"warning"`, `"error"`), inline disable and enable comments, `noInlineConfig`. Exit codes belong to the CLI projects and were not read. |
| https://git-scm.com/docs/githooks | 200 OK | `pre-commit` and `commit-msg` arguments, abort on non-zero exit, `--no-verify`, `core.hooksPath`, executable-bit rule, working directory. |
| https://code.claude.com/docs/en/hooks | 200 OK, partial: first 100,000 of about 294,000 characters read | Events, hook configuration structure, stdin payload fields, exit code semantics (0, 2, other), JSON decision formats, precedence between exit codes and JSON, failure-default behavior. Later per-event tables and exact tool input field names for `Write`/`Edit` were not read. |
| https://developers.google.com/style | 200 OK | What the guide is, reference hierarchy, statement that it contains "guidelines, not rules". |
| https://developers.google.com/style/highlights | 200 OK (sub-page, one extra page) | List of highlights (voice, headings in sentence case, descriptive link text, serial commas, and so on) used as pattern candidates. |
| https://developers.google.com/style/tone | 200 OK (sub-page, one extra page) | Friendly, conversational tone; avoid wording that suggests a task is trivial. |
| Third-party skill read for ideas, no text reused (a pre-publish "slop" scanner plus its editorial counterpart; MIT per its repository) | Read locally; 3 files | Idea only: the rule-versus-gate framing, a two-tier split between one-hit tells and counted words, masking quotes and code before scanning, a hook form with `PreToolUse` and `Stop`. All wording, patterns, examples and code here are original. |

## Reading limits

- The Claude Code hooks page is large; only its first third was read. Anything about events beyond `PreToolUse`, `PostToolUse` and `Stop`, and the exact input field names of file tools, comes from outside that read and is labeled as unconfirmed where used.
- Vale and markdownlint were read as references for design (check types, severities, inline overrides), not run.
- The example script was run locally on small fixtures, not on a corpus; thresholds in the text are illustrations.

## Claims not adopted as fact

- Any claim about how often agents skip style rules in "writing" versus "layout" steps is an inference from experience, not a measured rate, and is written as a working hypothesis.
- Precision targets ("roughly even") and the threshold of 3 counted words are suggestions, not standards.
- Specific tell lists from third-party sources were not copied; the examples in this skill are generic and original.
