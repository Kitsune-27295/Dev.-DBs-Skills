# Description Writing and Trigger Evals

Sources: https://agentskills.io/specification · https://agentskills.io/skill-creation/optimizing-descriptions · https://agentskills.io/skill-creation/evaluating-skills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://code.claude.com/docs/en/skills · Last verified 2026-11-27

## Contents
- Why the description matters
- Real length limits
- Writing patterns
- Trigger eval sets
- Running and scoring
- Train/validation loop
- Output evals
- How an agent should apply this

## Why the description matters

At startup a host loads only each skill's name and description; the agent activates a skill when a task seems to match. The description therefore carries the entire trigger burden. The optimization guide adds a nuance: agents tend to consult skills only for tasks beyond what they handle alone, so a trivial one-step request may not trigger even a perfect description. Tune for tasks with real specialized content.

## Real length limits

| Where | Limit found |
|---|---|
| Spec and `skills-ref` validator | 1-1024 characters (format facts: `agent-skills-context-engineering`) |
| Claude Code listing | `description` plus `when_to_use` truncated at 1,536 characters |
| This pack's rule | at most 1,000 characters, ends with "Use when ..." |

The pack's 1,000 is a deliberate margin inside the 1,024 spec cap, not a vendor number. Descriptions grow during tuning, so recount after every edit with a script.

## Writing patterns

- Imperative framing: tell the agent when to act ("Use when ...").
- User intent over implementation: describe what the person wants, including phrasings that do not name the domain.
- Slightly pushy: list contexts explicitly.
- Concise: a few sentences; it is paid for on every turn across all skills.
- Third person, exclusion clause naming the neighbor skill, and collision handling: `skill-description-and-trigger-design` in `skill-orchestrator` (description as routing condition).

Before: `description: Process CSV files.`
After (own example): `description: Analyze tabular data files (CSV, TSV, spreadsheets): summary stats, derived columns, charts, cleaning. Not for database loading or formula editing in a workbook. Use when the user has a data file and wants to explore or visualize it, even if they never say "CSV".`

## Trigger eval sets

Aim for about 20 labeled prompts: 8 to 10 should-trigger, 8 to 10 should-not-trigger. Should-trigger prompts vary in formality, explicitness, detail and number of steps; the most informative ones are those where the need is real but not named. Should-not-trigger prompts must be near-misses that share keywords with the skill but need something else; "write a fibonacci function" tests nothing. Make prompts realistic: file paths, personal context, typos.

## Running and scoring

Run each prompt in a clean session with the skill installed and read the host's logs for whether the skill file was loaded. Because behavior is nondeterministic, run about 3 times and compute a trigger rate. A should-trigger prompt passes above 0.5; a should-not-trigger prompt passes below it. Script this (20 prompts times 3 runs is 60 runs). The detection logic is host-specific; the guide's example checks Claude Code JSON output for a Skill tool call.

## Routing A/B check across a whole catalog (measured 2026-11-27, one run)
Compare two versions of a catalog by giving a router the name and description of every skill and a batch of requests with the expected skill hidden, then score the picks in a script. Keep the model, effort, batching and **catalog order** identical across arms: in one run the same new descriptions scored 82.6% when listed grouped by category and 93.7% when listed alphabetically (old descriptions: 90.3%; 392 requests, a small model at low effort, single run, requests written by the same author as the new descriptions, so the gap over the old arm is an upper bound). Discard requests a router left unanswered in either arm, and read a gap smaller than about five points as noise.

## Train/validation loop

Split about 60 percent train and 40 percent validation, shuffled once, kept fixed, with both polarities in both sets. Evaluate on both; use only train failures to edit; broaden if positives fail, add boundary if negatives fire; do not paste failed queries' keywords in (that is overfitting), generalize the concept; try a structurally different phrasing if stuck. Choose the iteration with the best validation pass rate, which may not be the last. About five iterations is usually enough. Finish with 5 to 10 fresh prompts never used in tuning. The `skill-creator` skill in Anthropic's repository automates this loop; the guide says so, and its text was read, not run.

## Output evals

Store test prompts (id, prompt, expected output, optional files) in `evals/evals.json`; start with 2 or 3. Run each case with the skill and without (or against a snapshot of the old version), each from a clean context, into `iteration-N/<case>/with_skill|without_skill/`, saving tokens and duration. Add assertions after seeing outputs: objective, countable, not brittle. Grade PASS only with quoted evidence; script the mechanical checks. Aggregate pass rate, time and tokens, and look at the delta. Drop assertions that pass in both arms; investigate ones failing in both; study ones that flip with the skill. Add a blind human or judge comparison for qualities assertions cannot capture.

## How an agent should apply this

1. Draft the description, count characters by script, keep it at or under 1,000.
2. Build the 20-prompt set with real near-miss negatives; freeze the split.
3. Measure trigger rates on both splits; edit from train failures only.
4. Select by validation rate; confirm with fresh prompts.
5. Run the output eval against the baseline; report quality delta and token delta together.
6. Note in `references/sources.md` that the numbers (20, 60/40, 3 runs, 0.5, 5) are the guide's starting points, not laws.
