# The combined audit prompt and its report shape

Sources: handout section "Prompt de auditoria (os 5 de uma vez, sem alterar nada)" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software); the five per-topic prompts in the same handout · Last verified 2026-11-24

The combined audit appears only in the handout, not in the video.

## Structure of the prompt

An opening role (senior engineer auditing an AI-built app) and a hard constraint: change no project file, run no migration, install nothing; read code, run read-only commands, write a report. Then five ordered steps, with findings noted at the end of each before moving on.

| Step | What it asks |
|---|---|
| 1 Integration tests | Test tool configured? Test database separate from production? Command to run everything? Run it only if it cannot touch production and count passes and failures. Which critical flows have route-level tests, which only mocked unit tests, which none |
| 2 Client trust | Rules only in the front end; keys in client code or browser-exposed variables classified public or secret; for an API-exposed database, tables with security off and over-permissive policies, each explained in plain language |
| 3 Race conditions | Each read-decide-write on a limited resource, what happens with two simultaneous requests, whether a constraint, atomic operation or row lock exists; flag in-memory locks, expiring Redis locks, cached reads, and say if the database alone would do |
| 4 Idempotency | Raw-body signature check, processed-events record with unique id, what happens on a double delivery, idempotency keys on gateway calls |
| 5 Separation | Longest files and whether each mixes screen, rules and data access; name candidate number 1 |

## Report shape

A report file at the project root: one table per step (finding, risk high/medium/low, file and line, suggested fix); at the top, the five highest-risk findings in order; "not verified" plus the reason for anything that could not be checked, never a guess; ends by naming which of the five fix prompts to run first and why.

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
