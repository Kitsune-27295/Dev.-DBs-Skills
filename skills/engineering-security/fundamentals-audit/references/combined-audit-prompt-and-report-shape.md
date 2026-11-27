# The combined audit prompt and its report shape

Sources: handout section "Prompt de auditoria (os 5 de uma vez, sem alterar nada)" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software); the five per-topic prompts in the same handout · Last verified 2026-11-24

The combined audit appears only in the handout, not in the video.

## Structure of the prompt and report shape

An opening role (senior engineer auditing an AI-built app) and a hard constraint: change no project file, run no migration, install nothing. Then five ordered steps with findings noted after each, and a report file. The five steps and the report shape are in `fundamentals-audit` SKILL.md ("The audit" and "Deliverable"); this file only adds how the handout prompt relates to them.

## How it maps to the per-topic prompts

Each audit step is the detection half of a fix prompt: step 3 mirrors the fix prompt's "list every read-decide-write", step 4 its inventory of webhooks and payment endpoints, step 2 its secret classification and policy review, step 5 its file mapping. The audit omits the fixing, testing and plan-approval halves. So the audit's output is a prioritized menu for the fix skills.

## Small differences (own observations)

- The audit prompt's step 3 adds a check that fix prompts only imply: it asks whether the database alone would suffice where a lock or cache is found.
- Step 1 conditions running tests on not touching production, a rule the integration prompt states as "never point at production".
- The report file is Portuguese-named in the handout; SKILL.md renames it.

## How an agent should apply this

- Keep the audit strictly read-only; if a check would need a write (a migration, an install), mark it "not verified".
- Fill every table with file and line evidence.
- Rank the top five by exploitability and money impact, then recommend one fix skill first.
- Do not start a fix in the same run.
