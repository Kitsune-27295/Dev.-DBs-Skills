---
name: diataxis-documentation-architecture
description: Classify, write, split or audit technical documentation with the Diátaxis framework: place each page or paragraph in one of four forms (tutorial, how-to guide, reference, explanation) with the two-question compass (action or cognition, study or work), fix pages that blur forms, and decide whether new content deserves its own page. Not for architecture chapters (see `arc42-api-contracts-architecture`), decision records (see `adr-architecture`) or prose style (see `text-quality-gate`). Use when asked to structure, restructure, review or write product or developer docs, to decide where content belongs, or whether to add or split a documentation page.
---

# Diátaxis (Technical Documentation Information Architecture)

One idea: documentation confuses readers when one page tries to teach a beginner, solve a task, list every option and debate design at once. Separate it into four forms by what the reader needs: **tutorial**, **how-to guide**, **reference**, **explanation**, placed by two questions (action or cognition; study or work). Sources, statuses and claims not adopted: [references/sources.md](references/sources.md).

## 1. The map and the compass

| Form | Informs | Serves | Reader's question |
|---|---|---|---|
| Tutorial | action | study | "Lead me through a lesson so I learn by doing." |
| How-to guide | action | work | "How do I achieve this specific goal?" |
| Reference | cognition | work | "What are the exact facts?" |
| Explanation | cognition | study | "Why is it this way, and how does it connect?" |

Compass, asked of any page or paragraph: does it inform what the reader **does** or what they **know**; does it serve **acquiring** a skill (study) or **applying** it (work)? Many documentation faults come from crossing or blurring these boundaries. Detail and a worked split: [references/four-forms-map-and-compass.md](references/four-forms-map-and-compass.md).

## 2. Rules per form

**Tutorial.** The writer carries the responsibility for what the learner learns, as no instructor is present. Every step produces a visible, comprehensible result, with expected output shown. Leave out side paths (other options, alternative approaches). No explanation: link to it.

**How-to guide.** Starts from a real goal and is titled for exactly what it shows ("How to integrate monitoring", not a bare noun). Assumes a competent reader; no teaching, no digression, no list of every option (link to reference). Real work forks, so conditional steps ("if you want x, do y") are right here and wrong in a tutorial.

**Reference.** Neutral description only: no instruction, explanation, opinion or speculation. Uses consistent patterns, mirrors the structure of the thing it describes, and may carry short usage examples. Auto-generated output alone is not enough.

**Explanation.** Understanding-oriented and bounded by a topic: why things are this way, history, constraints, alternatives, reasoned opinions. Read away from the product. Decision records are one source of rationale (`adr-architecture`); architecture chapters live in `arc42-api-contracts-architecture`.

## 3. Workflow (iterate, do not scaffold)

1. Look at the documentation in front of you (or note there is none).
2. Ask whether it could be better.
3. Pick one small change and make it; repeat.

The source does not require planning a structure first; the four-part layout can emerge from repeated compass use. As a convention (not a source rule), avoid creating four empty top-level folders before content exists. Whether new content needs a page at all: [references/new-page-or-not-join-vs-split.md](references/new-page-or-not-join-vs-split.md).

## 4. Review table for a documentation change

| Symptom | Fix |
|---|---|
| A tutorial assumes setup or explains theory mid-lesson | keep one guided path; move theory to an explanation page and link |
| A how-to teaches basics or lists every parameter | cut to the goal; table to reference |
| Reference tells a story or argues | strip to facts; stories to how-to, arguments to explanation |
| Explanation buried in a procedure | move the why to its own page, leave a one-line link |
| Vague heading ("Webhooks") | name the form: "Tutorial: build your first webhook", "How to rotate webhook secrets", "Webhook payload reference", "Why webhooks deliver at least once" |

## Quick Decision Checklist

- [ ] Did I answer both compass questions before writing or editing?
- [ ] Does each page belong to exactly one form?
- [ ] Is the tutorial one guided path, with a visible result per step and no explanation?
- [ ] Does the how-to start from a goal and link out for option lists?
- [ ] Is reference neutral and shaped like the product?
- [ ] Did I move contaminating blocks to their own form and link them?
- [ ] Did I check whether a new page is justified, or whether a section will do?

## Deep references

- [Four forms, map and compass](references/four-forms-map-and-compass.md): read when classifying or splitting documentation pages.
- [Should this be a new page? Join versus split](references/new-page-or-not-join-vs-split.md): read before creating a page, folder or section, or when asked to split or merge pages.
- [Trigger evals](references/trigger-evals.md): read when tuning the description.
- [Sources](references/sources.md): retrieval statuses, reading limits, claims not adopted.
