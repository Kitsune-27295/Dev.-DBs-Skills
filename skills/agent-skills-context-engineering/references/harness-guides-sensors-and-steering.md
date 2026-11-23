# Harness Guides, Sensors and the Steering Loop

Sources: https://martinfowler.com/articles/harness-engineering.html · Last verified 2026-11-23

## Contents
- Definitions
- Control matrix
- Timing: keep quality left
- Regulation categories and their maturity
- Harnessability and templates
- Open problems
- How an agent should apply this

## Definitions
Böckeler scopes "harness" to the outer, user-built controls around a coding agent, aimed at earning enough confidence to supervise less.
- **Guides (feedforward):** act before the agent acts: AGENTS.md conventions, skills, codemods, templates.
- **Sensors (feedback):** observe after: linters, type checkers, structural tests, AI review; they let the agent self-correct.
- Feedback alone means the agent repeats predictable mistakes; feedforward alone never learns whether the rules worked.

## Control matrix
| | Computational (deterministic, fast, cheap) | Inferential (semantic, slower, costly, non-deterministic) |
|---|---|---|
| Guide | codemod, scaffold, schema | prose conventions, skills |
| Sensor | tests, lint, types, ArchUnit-style checks | AI code review, LLM-as-judge |

Run computational sensors on every change; reserve inferential ones for where judgment is needed.

## Timing
Cheap checks before commit or integration; expensive ones (mutation testing, broad architecture review) after integration. Add continuous sensors for slow drift (dead code, dependency rot, coverage quality) and runtime signals (SLOs, response quality).

## Regulation categories
| Category | Today | Why |
|---|---|---|
| Maintainability | strongest | computational sensors reliably catch duplication, complexity, style; but misdiagnosis, overengineering and misread requirements slip through |
| Architecture fitness | good | fitness functions for performance, observability, import direction |
| Behaviour | weakest | relies on AI-generated tests plus manual testing, judged not good enough; approved fixtures help in some areas |

Implication: a green AI-written test suite is weak evidence of behaviour. Anchor with specs, approved fixtures, contract tests and human review.

## Steering loop
When a failure recurs, the human's job is to change the harness (tighter guide or new sensor) rather than fix the output again. AI can help author these controls. Example flow (own illustration): agent keeps importing across a layer boundary -> add a dependency-direction test (sensor) and a one-line rule in AGENTS.md (guide).

## Harnessability and templates
Strong typing, explicit module boundaries and opinionated frameworks make sensors easier to build; greenfield can design for it, legacy needs it most but is harder. **Harness templates** bundle guides and sensors per service topology; via Ashby's Law, narrowing the topology reduces variety the agent can produce, making a comprehensive harness feasible. Versioning and keeping instances in sync remain unsolved.

## Open problems named by the article
Keeping guides and sensors coherent as they grow, resolving conflicting signals, distinguishing "silent because quality is good" from "silent because detection is weak", and measuring harness coverage the way code coverage measures tests.

## How an agent should apply this
- For each recurring failure, propose a pair: one guide and one sensor; prefer a computational sensor.
- Put fast sensors on the edit/commit path, slow inferential ones in CI or scheduled jobs.
- Do not claim behaviour is verified because generated tests pass; name the anchor (spec, fixture, contract, human review).
- Suggest harness-friendly changes (types, module boundaries) when sensors are hard to write.
- Treat a quiet sensor as unproven until it has caught a seeded defect.
