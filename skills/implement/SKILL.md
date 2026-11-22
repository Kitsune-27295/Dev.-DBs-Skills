---
name: implement
description: "Implement a piece of work based on a spec or set of tickets using TDD at pre-agreed seams and two-axis code review. Use when executing tickets or specs in the engineering workflow."
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker (or `.scratch/<feature>/issues/`) and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with `tdd` where possible, at pre-agreed seams (or read `tdd/SKILL.md` directly if your harness has no Skill tool).

While building each slice:
- Enforce types, immutability, and explicit error pipelines at boundaries (`defensive-domain-modeling`) and avoid premature abstraction (`pragmatic-solid-and-ssot`).
- When a slice touches money, auth/permissions, shared stock/quotas, webhooks, or multi-table writes, apply the guardrails in `never-trust-the-client`, `transaction-fix`, `race-condition-fix`, and `idempotency-fix`.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with `code-review` (ideally in a fresh context window or clean parallel reviewer subagents) to review the work before finalizing.

Commit your work to the current branch.

> Sources & MIT attribution: [references/sources.md](references/sources.md).
