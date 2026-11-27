---
name: to-spec
description: "Turn the current conversation, plan, or requirements into a structured spec and publish it to the project issue tracker (or local .scratch/). Use after planning or grilling to synthesize agreed decisions without re-interviewing."
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The issue tracker and domain docs layout should have been configured (`docs/agents/issue-tracker.md`, `docs/agents/domain.md`). If not, either ask the user to run `setup-matt-pocock-skills` or fall back to local markdown under `.scratch/<feature-slug>/spec.md` (use `.scratch/` automatically during an autonomous end-to-end run when no tracker is configured).

## Process

1. **Explore & align domain language:** Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary (`GLOSSARY.md`) throughout the spec, and respect any ADRs in `docs/adr/` (see `adr-architecture`). Where significant architectural or API/schema choices were made in the conversation, reference `architecture-decision-trees-tradeoffs`, `arc42-api-contracts-architecture`, or `schema-and-constraints`.

2. **Sketch testing seams:** Sketch out the seams at which you're going to test the feature (using `codebase-design` vocabulary: **module**, **interface**, **seam**). Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better — the ideal number is one. Where deciding between unit, DB-backed route integration, or contract seams, align with `testing-pyramid-and-shapes` and `integration-tests`.

Check with the user that these seams match their expectations (and note what each seam catches and what it misses); if the user requested an autonomous end-to-end workflow, document the chosen seams directly in the spec and proceed.

3. **Write & publish:** Write the spec using the template below, then publish it to the project issue tracker (GitHub, GitLab, or `.scratch/<feature-slug>/spec.md`). Apply the `ready-for-agent` triage label when using a tracker with triage labels — no need for additional triage.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions (cross-referencing new or existing ADRs in `docs/adr/`)
- Schema changes and DB invariants (`schema-and-constraints`)
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior at agreed seams, not implementation details)
- Which modules and seams will be tested (with one-line notes on what each seam catches/misses)
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>

> Sources & MIT attribution: [references/sources.md](references/sources.md).
