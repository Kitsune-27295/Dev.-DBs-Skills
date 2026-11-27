# Verifier Independence and Lanes

Sources: https://www.nasa.gov/ivv-overview/ · https://en.wikipedia.org/wiki/Verification_and_validation · https://code.claude.com/docs/en/best-practices · https://google.github.io/eng-practices/review/reviewer/looking-for.html · https://sre.google/sre-book/postmortem-culture/ · Last verified 2026-11-27

## Maker and checker

The party that produced a result is the worst-placed party to certify it: it shares the assumptions that produced the mistake and remembers its own intent instead of reading the artifact. Engineering fields institutionalize this as independent verification and validation (IV&V); the V&V article describes it as checking by a disinterested third party. NASA's IV&V page, citing IEEE's parameters, lists three kinds of independence: **technical** (assessors use their own expertise, separate from the developer), **managerial** (a separate organization decides what to analyze, which techniques, what schedule, which issues to pursue) and **financial** (budget comes from outside the developer). It also notes that many projects think ordinary V&V is enough and miss what independence adds.

Claude Code's best-practices page gives the agent-shaped version: a review by someone who did not write the code, in a fresh subagent that never saw the conversation, "isn't swayed by the reasoning that produced the code". It adds that a second session is the easiest independent reviewer, and that a subagent with only read tools is enforced by the harness, not requested in a prompt. Google's review guidance and the SRE book make the human equivalent: tests and postmortems are themselves reviewed, and "an unreviewed postmortem might as well never have existed" (SRE book, short quote).

Mapping to agents (the mapping is this skill's own inference):

| Independence | In an agent workflow |
|---|---|
| Technical | Fresh context; the verifier gets the ACs, the change and the commands, not the maker's explanation or its claimed results |
| Managerial | The verifier chooses what to re-run and may add checks; the maker cannot edit the verdict or the verifier's instructions mid-run |
| Financial (loosest analogy) | The verifier has its own budget line, so a nearly exhausted maker budget cannot silence it |

Independence is a spectrum. Use the strongest form the lane justifies.

| Level | What it is | Allowed in lanes |
|---|---|---|
| L0 | Maker states success | never counts as certification |
| L1 | Maker re-runs the checks in a separate pass after a context reset or deliberate break, quoting fresh output | tiny, normal |
| L2 | A different session or subagent, read-only on the source, fresh context, re-runs the checks | normal when risk is above trivial, full, bug |
| L3 | L2 on a different model tier or family than the maker, plus a human for irreversible effects | full when the effect is destructive, security-relevant or financial |

## Fresh-context verifier brief

Give the verifier exactly this and nothing the maker concluded. Keep it under about 40 lines.

```
ROLE: Verifier. You did not write this change. Do not edit source files.
GOAL: Decide for each acceptance criterion below whether it is met.
ACS:
  AC-1: <falsifiable statement>   check: <command/observation>
  AC-2: ...
CHANGE: <diff stat or list of changed paths>; where to find the diff
ENV: <how to run, working dir, env var NAMES, what must not be touched>
DO:
  - Re-run every check yourself; quote the signal lines of the real output.
  - Add one check of your own per AC if the given one could pass vacuously.
  - Report gaps that affect correctness; skip style and naming.
  - For user-visible ACs, observe the running behavior, not only tests.
DO NOT:
  - Trust any claim of success you were not handed output for.
  - Edit, revert, or "fix" anything. If a check needs a code edit, say so.
  - Print secrets; write <redacted>.
RETURN (table): AC | command run | output excerpt | PASS/FAIL/UNVERIFIED | notes
  then: files you changed (must be none), checks you could not run and why.
IF UNSURE: stop and say what is missing; do not guess.
```

The "skip style" clause is deliberate: Claude Code's best-practices page warns that a reviewer asked to find problems always finds something, and acting on every finding adds layers and tests for cases that cannot happen. Ask for evidence per AC, not for a general opinion.

After the verifier returns, the maker **does not edit the table**. It reads FAIL rows, fixes, and sends the work back for a new pass. Confirm the verifier changed nothing (working-tree status or file checksums before and after); a verifier that edited files has left the read-only role and its verdict is void.

Verifier tier, effort and the general delegation brief are owned by `model-effort-routing` (its section on delegation and its "checker floor"; the `delegation-brief-templates.md` reference there). Use those; this skill only adds the AC-based content of the brief.

## Lanes: ceremony by risk

Pick the lane from the **worst single dimension** (reversibility, blast radius, who sees it, data or money touched), as `model-effort-routing` triages work. When unsure between two lanes, take the heavier one.

| | tiny | normal | full | bug |
|---|---|---|---|---|
| Typical change | typo, comment, docs wording, rename with no callers, config value with a trivial check | feature or fix in one area, tests exist, easily reversible | cross-module, public API, auth, money, data or schema, migration, release-bound, hard to reverse | something reported broken, failing, slow |
| ACs | one implicit line in the report | 1-5 written ACs | every AC written; map each to the request or spec | AC-1 is the reproduction of the original symptom; add ACs for the cause and for neighbors |
| Checks | cheapest relevant (diff read, lint, one targeted test) | targeted checks per AC, then the full suite once at the end | all of normal, plus integration or end-to-end, plus runtime observation | red-green proof on the repro, regression test proven red on the pre-fix state, then suite |
| Verification pass | none; self-check allowed (L1) | L1 or L2 | L2; L3 for destructive, security or financial effect | L2 for the fix verdict |
| Runtime observation of user-visible behavior | skip | yes if user-visible | required | required if the symptom was user-visible |
| Loop caps and escalation | n/a | caps in [loop-limits-and-no-progress.md](loop-limits-and-no-progress.md) | caps plus a human sign-off for irreversible steps | caps; escalate if the cause stays unknown |
| Report | one line, state + the check run | state + ledger summary | state + full ledger + what was not verified | state + ledger + root cause (one sentence) |

Notes:
- **tiny** is not "no verification": a tiny edit still needs one observed check (or an honest "not run, reason") before any success wording.
- **bug** points to `diagnosing-bugs` for building the feedback loop and `tdd` for the red-green regression test; this skill adds only the certification of the result. After the cause is known, finish in the normal or full lane by blast radius.
- A change to a verification tool or the check itself (a test, a script) is at least normal, because it changes what "green" means.
- Do not downgrade a lane mid-task to finish faster; upgrade it the moment new risk appears (the change turns out to touch auth or data).

## How an agent should apply this

- Choose the lane first and state it in one line, with the worst-dimension reason.
- In normal and above, never certify your own work at L0; do at least an L1 pass that re-runs checks from a clean start and quotes output, and prefer L2 when risk is above trivial.
- Brief the verifier with ACs, the change location and commands only; do not hand it your conclusions or the expected outcome.
- After the verifier returns, check it edited nothing, copy its table into the ledger unchanged, and fix only FAIL rows.
- For destructive, security or financial effects, add L3 and put the irreversible step behind a human decision.
- Where the ACs cover UI behavior, hand execution to `playwright-qa-orchestrator` rather than describing browser steps here.
