# Google Review Standard and "What to Look For", Applied to Agent-Written Code

Sources: https://google.github.io/eng-practices/review/reviewer/standard.html · https://google.github.io/eng-practices/review/reviewer/looking-for.html · https://github.com/google/eng-practices (read as raw `review/reviewer/standard.md` and `looking-for.md`) · Last verified 2026-11-27

License: the repository ships a Creative Commons Attribution 3.0 Unported license file. This file paraphrases; attribution is given above. Google writes for human reviewers of a "CL" (change list); here the same checks become the author's self-review, because the agent is the author.

## The standard in one idea

The goal of review is that the overall health of the codebase improves over time. A change should be accepted once it definitely improves that health, even if it is not perfect: there is no perfect code, only better code. Two forces balance: authors must be able to make progress (a reviewer who blocks everything discourages improvement), and reviewers must not let health decline through many small shortcuts. Nothing justifies knowingly worsening health except a genuine emergency.

Principles stated there, restated: technical facts beat opinions; the style guide wins on style, and anything it does not cover is preference (follow the surrounding code; if none, accept the author's choice); design is almost never pure preference, so decide it on engineering principles, and accept the author's option only when equally valid options are shown; otherwise stay consistent with the codebase as long as health does not drop. Minor polish points should be labeled optional (the guide's marker is a "Nit:" prefix).

## The checklist, as an author self-review

| Google heading | What the guide asks | Agent self-check |
|---|---|---|
| Design | Do the pieces interact sensibly? Does it belong here or in a library? Is now the right time? | Does the change sit in the module that owns this concern? |
| Functionality | Does it do what was intended, and is that good for users (end users and future developers)? Think of edge cases, concurrency, user view. | Run it; list edge cases; check races only if concurrency exists. |
| Complexity | Too complex means it cannot be understood quickly, or invites bugs when changed; over-engineering deserves special vigilance. | Rules SIM-01 to SIM-03 in the simplicity file. |
| Tests | Right kind of tests, added in the same change; tests must fail when code breaks; tests are code too and must stay simple. | Would this test fail if I deleted the fix? |
| Naming | Long enough to say what the thing is or does, short enough to read. | Rename anything you had to explain in chat. |
| Comments | Mostly why, not what; review old comments too. | See `comments-why-not-what.md` (CM rules). |
| Style | The style guide is authoritative; do not mix large reformatting with functional changes. | Never reformat a file inside a feature change. |
| Consistency | Follow the guide; where it only recommends, bias to the guide unless local inconsistency would confuse; else match existing code. File a cleanup note rather than silently mixing styles. | Match neighbors before importing your preferences. |
| Documentation | If build, test, usage or release changes, update README and reference docs; if code is deleted, consider deleting its docs. | Grep docs for names you changed. |
| Every line | Look at every human-written line; understand all of it. If you cannot follow it, the next reader cannot. | Reread your own diff line by line before handoff. |
| Context | See the whole file and system, not just the diff: four added lines may land in a 50-line method that now needs splitting. | Open the whole function you touched. |
| Good things | Say what is done well. | Report a risky area you handled carefully. |

## Failure modes this prevents (own inference)

- Speculative abstractions (parameters, flags, interfaces nobody calls).
- Diffs that mix a rename sweep with a behavior change, which hides the real change.
- Tests that pass against broken code.
- Code the author cannot explain in one sentence.

## How an agent should apply this

- Before handoff, review your diff as if you were the reviewer: design fit, behavior, complexity, tests, names, comments, docs, every line, whole-function context.
- Aim for "clearly better than before", not "perfect"; do not stall on polish, and do not ship a known regression.
- Mark optional polish as optional in your summary instead of mixing it into the change.
- Keep style changes out of functional changes (CN-02); match the surrounding code when no rule applies (CN-01).
- Do not make drive-by refactors or unrelated improvements; report them instead (SC-02).
- If you cannot read a line you wrote without effort, rewrite it before asking a human to.
