# Escalation, Fallback and Safety Floors

Sources: https://github.com/Getty/skills/blob/main/claude/model-routing/SKILL.md · https://github.com/vishalsachdev/claude-skills (allocate-agent-models/SKILL.md) · https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md · https://github.com/masskrdjn/claudeskills · https://github.com/pedrohcgs/claude-code-my-workflow/blob/main/.claude/rules/model-routing.md · https://github.com/DeL-TaiseiOzaki/claude-code-orchestra/blob/main/.claude/skills/team-execute/SKILL.md · https://github.com/imbad0202/academic-research-skills · Last verified 2026-11-23

These are repo-author policies (opinion), not measurements. Vishal's skill says so itself: every matrix, count and default is "local starting policy" pending representative evals.

## 1. Escalation: when to go up

| Source | Trigger | Action |
|---|---|---|
| Getty | Failure or "unsure" | Go one tier up, pass the failed attempt as context; do not retry sideways. Cheap lanes must say "unsure" rather than guess. |
| orchestra | Sonnet teammate meets ambiguity or high-risk complexity | Stop the workstream, report concrete evidence, reassign the remainder to Opus. Decide before spawning when ambiguity, cross-system invariants, subtle security/concurrency/data/perf, or earlier failures are known. |
| masskrdjn | Hard task: subtle invariants, multi-module coupling, or a first failure carrying a conceptual signal | `builder` to `opus` by call parameter; second `architect` call to `fable` only after a decisive unresolved contradiction. Each escalation is announced and justified; never a default. |
| Vishal | Two substantive failures | Fresh high/xhigh pass on the top model, root-cause analysis before another edit. |
| Vishal | Three substantive failed fixes | Stop adding compute, question the approach, ask a human. |
| softspark | Validation failure (schema, tests, retrieval evidence, labels) | Escalate along an approved route with a bounded attempt count; no approved route left means fail or human review. Self-reported confidence is not a calibrated probability. |
| masskrdjn | Same error twice | Stop or reclassify with a new signal; no third identical attempt. Bounds: runner 3 correction cycles, builder 3 attempts, scout 3 fruitless searches, researcher 5 queries, environment 2 attempts. |

**Environment failure is not model failure** (Vishal, masskrdjn agree). Auth, permissions, sandbox, dependency, malformed tool input, broken fixture: repair the environment and retry on the same allocation; never climb a tier and never count it toward failure limits. Vishal adds a third class, scope change: reclassify from scratch.

## 2. Fallback: when the intended model is unavailable

- Vishal's order (OpenAI models, ported by analogy only): Luna to Terra to Sol at same effort; if the top model is unavailable, pause high-consequence, destructive, security-critical, weak-oracle or new-class work; lower-risk evaluated work may use the next tier at high effort with narrower scope and fresh independent review.
- Rule shared by Vishal, softspark and masskrdjn: **never substitute silently**. State model ID, effort, reason and changed verification plan. masskrdjn: if Fable access is absent, refused or undeterminable, consult the Opus architect and say explicitly it is an Opus opinion, never present a fallback as the original consultation.
- softspark: retry transient errors within the existing SDK retry policy before any model change; do not multiply SDK retries with another unbounded loop; a fallback must keep the user's model requirement, context limits, structured-output support and tool permissions. If model change is not authorized, stop with the original error.
- ARS: relative-tier resolution fails open. If the session cannot resolve the target tier or cannot dispatch a subagent, run on the session model and announce a one-line no-op notice; never guess a model ID. ARS also records a residual gap: the runtime may serve a classifier-flagged request on a different model, so provenance describes the declared model, not an attested one.
- masskrdjn distinguishes requested model, model resolved at launch and model observed at run time (hook reads `resolvedModel` from metadata); missing metadata means "not attested", not invalid, and no rework is triggered by that alone.

## 3. Safety floors for critical tasks

| Source | Floor |
|---|---|
| Vishal | Highest-risk factor wins; never average a destructive risk down because the edit is small. High-consequence, destructive, security-critical or weak-oracle work: top model at high effort minimum until local evals justify down-routing. Reviewer stays at the risk floor even if implementation was down-routed. |
| Getty | Never down-tier verification of high-stakes work because the diff is small. Cheap generation is acceptable only when verification is strong: up-tier the checker, not the typist. A cheap executor must not inherit open decisions (naming, ordering, edge cases). |
| pedrohcgs | Do not demote the four false-PASS gates (editor, two referees, claim verifier) to Sonnet; one wrong PASS costs more than running Opus on everything. Challenger and auditor must be on different tiers (same-tier models share blind spots and launder correlated errors). |
| ARS | `economy` never touches judgment agents and never goes below an Opus-class floor; `quality-boost` never downgrades anything and only lifts at integrity gates and final review. The author notes the reference savings came from ML-tuning tasks, not scholarly writing, hence the conservative floor. |
| masskrdjn | Never lower acceptance criteria, skip a needed check or simplify the request to make a cheaper model usable. A small risky change may still need independent review. Never run under `--dangerously-skip-permissions`/`bypassPermissions`; settings deny `git push`, `git reset --hard`, `rm -rf`. `architect` never executes tests. |
| Vishal, softspark | A stronger model, higher effort, reviewer role or fallback never widens authority. Permission or auth failures go back to the supervisor; they are not licenses for bypass. softspark: an access denial or safety refusal ends that route. |

## 4. Independent review pattern

Vishal and masskrdjn agree: reviewers get requirements, the change and raw evidence, not the implementer's conclusions; fresh session; implementer never approves its own work; dependent writes sequential, concurrent writers in isolated worktrees; coordinator owns synthesis. orchestra enforces it mechanically: ownership preflight (disjoint file sets) before spawn, reconcile against git after, and the lead re-runs the verify script rather than accepting a teammate's self-report.

## How an agent should apply this

- Classify a failure first (environment, scope change, substantive); only substantive failures count toward escalation.
- Escalate one tier with the failed attempt attached; after two substantive failures use a fresh top-tier pass with root-cause analysis; after three, stop and ask a human.
- Set the floor by the worst risk factor; keep the checker at that floor even when the worker is cheap.
- Never fall back silently: name model, effort, reason and the changed verification plan; if the fallback would breach the floor, pause instead.
- Use different tiers (or models) for challenger and auditor, and never let the implementer review its own output.
- Treat missing identity metadata as "not attested", not as proof of a wrong model.
