# Karpathy-Style Rules: Before/After Examples

Sources: https://github.com/multica-ai/andrej-karpathy-skills (EXAMPLES.md, raw), https://github.com/multica-ai/andrej-karpathy-skills/pull/104 (read through the GitHub API diff) · Last verified 2026-11-24

## What the repo's EXAMPLES.md contains (summary)

About 520 lines of Python and prose, organized per principle with a "what LLMs do" half and a "what should happen" half.

| Principle | Scenarios shown | Lesson |
|---|---|---|
| Think Before Coding | "Export user data" built straight away with guessed scope, fields and location; "make search faster" answered with caching, indexes and async all at once | Surface the open questions and offer a simplest option first; list what "faster" could mean |
| Simplicity First | A strategy-class hierarchy for one discount calculation; speculative features bolted onto a simple task | One plain function until real variation appears |
| Surgical Changes | A fix for empty emails that also rewrites comments, adds docstrings and tightens other validation; a logging addition that also adds type hints and reformats | Change only the lines the request needs; match existing style |
| Goal-Driven Execution | Vague "improve it" versus a test-first bug fix; a multi-step plan with a check per step | Replace imperative wording with a pass/fail goal |

Its closing insight: the overbuilt versions are not wrong in isolation, they are early; solve today's problem and refactor when complexity is real. An anti-pattern table repeats each pairing. The code is illustrative and was not shown to be tested against a model.

## Three own short examples

**1. Think (hidden decision).** Request: "make the importer retry." Weak: adds exponential backoff, jitter and a retry-config file. Better:
```
Assumptions: retry network errors only, 3 tries, fixed 1 s wait, no new config.
Question: should 4xx responses retry? I assume no. Proceeding unless you object.
```

**2. Surgical (diff shape).** Request: "rename the CLI flag --out to --output."
```
- parser.add_argument("--out")
+ parser.add_argument("--output")
- args.out
+ args.output        # plus the README line and one test
```
Not acceptable in the same diff: sorting imports, renaming unrelated variables, rewording help text for other flags. Spotted an unused helper? Mention it in the reply and leave it.

**3. Goal-driven (plan with checks).** Request: "fix the date parsing crash."
```
1. Reproduce with parse("2026-02-30") -> verify: test fails with the reported error
2. Reject invalid days with a clear error -> verify: the new test passes
3. Run the full suite -> verify: previous pass count plus one, no new failures
```

## Multi-editor note (PR #104)

PR #104 "Add Codex skill metadata and docs" (open and unmerged when read; opened 2026-04-23) touches CURSOR.md, README.md, README.zh.md, `skills/karpathy-guidelines/SKILL.md` and a new `agents/openai.yaml`. Per its text, the same four principles live in several places that must stay in sync: `CLAUDE.md`, a Cursor `.mdc` rule, the skill, and the Codex metadata; the skill would be copied to `~/.codex/skills/karpathy-guidelines`. The existing Claude and Cursor flows were stated as unchanged. The Cursor `.mdc` rule is an existing repo file, not part of this PR's diff (the diff has no `.mdc` entry). Lesson: this is the copy-drift problem; the rule for keeping one source is SSOT-01 in [agents-md-standard-and-interoperability.md](agents-md-standard-and-interoperability.md).

## How an agent should apply this

- Use the examples as templates for the shape of a good reply (assumption list, minimal diff, plan with checks), not as code to copy.
- When reviewing a diff, test each hunk with the repo's trace-to-the-request question.
- Offer the simplest option first when a request has several readings.
