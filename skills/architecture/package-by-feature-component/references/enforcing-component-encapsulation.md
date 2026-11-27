# Enforcing Component Encapsulation: Visibility, Assemblies and Architecture Tests

Sources: https://milanjovanovic.tech/blog/clean-architecture-the-missing-chapter · Last verified 2026-11-27

## What the article says
- `internal` limits access to one assembly, so within a single project it cannot stop every violation.
- Separate assemblies enforce boundaries more strictly but cost build complexity, slower IDE navigation and more deployable files.
- Pragmatic path: keep implementations internal (and `sealed`), expose only component interfaces, and add architecture tests that fail the build on violations (example: controllers may depend only on component interfaces).
- Closing point: pragmatism beats purism.

## Escalation ladder (the ordering is this skill's judgment)
| Step | Mechanism | Catches | Cost |
|---|---|---|---|
| 1 | internal / package-private implementations | accidental use, by the compiler | free |
| 2 | architecture tests | rules the compiler allows | small test suite |
| 3 | assembly or module per component | everything at compile time | build and artifact overhead |
Escalate only when the previous step failed in practice.

## Language notes
C# `internal` is assembly-scoped. Java package-private works per package (a general language fact, not from the article). Barrel files plus lint boundary rules for TypeScript are an inference; verify the tool for your stack (tools are named in `layered-n-tier-architecture` and `clean-architecture`).

## Example rules (pseudo-code)
```
rule: types in *.Web must not depend on *.Policies.Internal
rule: only IPoliciesComponent is public in assembly Policies
```

## How an agent should apply this
- Start at step 1; add the architecture test in the same change that introduces a component.
- Propose separate assemblies only after a violation tests cannot stop.
- Keep DI registrations beside the component so the interface-to-implementation map stays private.
- Never widen visibility to make a test compile.
