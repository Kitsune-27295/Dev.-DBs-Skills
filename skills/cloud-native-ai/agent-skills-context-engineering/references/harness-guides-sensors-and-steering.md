# Harness Guides, Sensors and the Steering Loop

Sources: https://martinfowler.com/articles/harness-engineering.html · Last verified 2026-11-27

## Contents
- Definitions
- Control matrix
- Timing
- Regulation categories and their maturity
- Steering loop
- Harnessability and templates
- Open problems
- How an agent should apply this

## Definitions
Böckeler (martinfowler.com, 2026-04-02) defines the harness as everything in an agent except the model (`Agent = Model + Harness`) and scopes the article to the outer, user-built controls around a coding agent, aimed at earning enough confidence to supervise less.
- **Guides (feedforward):** act before the agent acts, to raise the odds of a good first attempt: `AGENTS.md` conventions, skills, codemods, LSP and code intelligence.
- **Sensors (feedback):** observe after the agent acts and help it self-correct: linters, type checkers, structural tests, AI review.
- Feedback alone means the agent repeats predictable mistakes; feedforward alone never learns whether the rules worked.

## Control matrix
| | Computational (deterministic, fast, run by the CPU) | Inferential (semantic, slower, costlier, non-deterministic) |
|---|---|---|
| Guide | codemod or OpenRewrite recipe, LSP, scaffold | prose conventions, `AGENTS.md`, skills |
| Sensor | tests, lint, types, ArchUnit-style boundary checks, mutation tests | AI code review, LLM-as-judge |

Run computational sensors on every change; reserve inferential ones for where judgment is needed.

## Timing
Place checks as far left as possible, because earlier findings are cheaper to fix: fast checks before integration, expensive ones (mutation testing, broad review) after. Add continuous sensors outside the change lifecycle for slow drift (dead code, test-coverage quality, dependency scanning) and runtime signals (degrading SLOs, sampled response quality, log anomalies).

## Regulation categories
| Category | Article's assessment | Detail |
|---|---|---|
| Maintainability | easiest today (lots of existing tooling) | computational sensors catch duplication, complexity, coverage gaps, drift and style cheaply; LLM sensors partly catch semantic duplication and over-engineering, expensively and probabilistically; misdiagnosis, overengineering and misread requirements still slip through |
| Architecture fitness | no maturity rating given | fitness functions for performance, observability, import direction |
| Behavior | hardest, "the elephant in the room" | common practice (functional spec plus a green AI-generated test suite plus manual testing) "puts a lot of faith into the AI-generated tests, that's not good enough yet"; approved fixtures work for some, "not a wholesale answer" |

Implication: a green AI-written test suite is weak evidence of behavior. Anchor with specs, approved fixtures, contract tests and human review. Also: correctness is outside any sensor's remit if the human never specified what they wanted.

## Steering loop
"The human's job is to steer the agent by iterating on the harness": when an issue recurs, improve the guides and sensors so it becomes less likely or is prevented. AI can help author these controls. The goal is to direct human input to where it matters most, not to eliminate it. Example flow (own illustration): the agent keeps importing across a layer boundary, so add a dependency-direction test (sensor) and a one-line rule in `AGENTS.md` (guide).

## Harnessability and templates
Strong typing, explicit module boundaries and opinionated frameworks make an environment more legible to agents (the article calls these "ambient affordances"); greenfield can design for it, legacy needs it most and finds it harder. **Harness templates** (proposed, not an existing standard) would bundle guides and sensors per service topology; by Ashby's Law, committing to a topology reduces the variety the agent can produce, which makes a comprehensive harness feasible. The article expects templates to drift from upstream improvements once instantiated, with versioning problems like service templates.

## Open problems named by the article
Keeping guides and sensors coherent as they grow, conflicting signals between instructions and feedback, whether a quiet sensor means good quality or weak detection, and evaluating harness coverage and quality the way code coverage evaluates tests. The article offers no measured data on defect, review-effort or token savings.

## How an agent should apply this
- For each recurring failure, propose a pair: one guide and one sensor; prefer a computational sensor.
- Put fast sensors on the edit and commit path, slow inferential ones in CI or scheduled jobs.
- Do not claim behavior is verified because generated tests pass; name the anchor (spec, fixture, contract, human review).
- Suggest harness-friendly changes (types, module boundaries) when sensors are hard to write.
- Treat a quiet sensor as unproven until it has caught a seeded defect.
