# Worksheets, Katas and Practice Resources

Sources: https://developertoarchitect.com/resources.html · https://nealford.com/katas/ · Last verified 2026-11-23

Limitation: the Neal Ford page is only an overview; its About, Rules and Lead subpages were not read, so the exact kata timing and scoring rules are not captured here.

## Worksheets (Mark Richards, Developer to Architect)

| Resource | Purpose | Use |
|---|---|---|
| Architecture Characteristics Worksheet | list the driving "-ilities" with definitions | work through it with stakeholders to find the few critical characteristics (a short video tutorial exists) |
| Architecture Styles Worksheet | star-rating chart, created with Neal Ford, comparing styles per characteristic | check whether the current style fits the drivers, or pick a migration target |
| Architecture Patterns Cross-Reference | which patterns, antipatterns and pitfalls improve or hurt given capabilities; also lookup by context | tied to the O'Reilly book on patterns, antipatterns and pitfalls (early release at read time) |
| Architecture Definition Language | pseudo-code for structural, operational and process aspects | structural parts can be paired with a prompt to generate code |

Suggested workflow (from the page): characteristics worksheet, then styles worksheet, then describe structure, then compare against kata solutions, then keep learning via trend sources (Thoughtworks Radar, InfoQ) with the 20-minute rule (a daily short learning slot; the page links it but does not explain it, other notes describe it as daily learning).

## Architectural katas

- Small groups of 3-5; ideally 4-10 groups work different katas in one session; a moderator keeps time, assigns a kata or draws one at random.
- Origin: Ted Neward; Neal Ford's version evolved from it. Rationale: architects get few greenfield opportunities, and designers learn by designing (Brooks), so deliberate repetition substitutes for scarce real projects.
- The pkardas notes add: timed design exercise, then peer voting and expert feedback.
- O'Reilly kata winners and semi-finalists are collected as GitHub repos (list by Jacqui Read) and show how to structure and present a solution.

## Using them as a decision aid

A kata forces you to pick the top characteristics, choose a style, and justify it in minutes. That is exactly the discipline for real decisions: constraints visible, trade-offs named.

```
Kata prompt -> rank 3 characteristics -> star-rate 3 styles -> pick least-worst
-> list 2 ADRs with consequences -> name 1 risk + mitigation
```

## How an agent should apply this

- Use the worksheet structure as the template for any style recommendation: characteristics first, style comparison second.
- Do not fabricate star ratings from memory; if ratings are needed, derive them from documented trade-offs and label them as judgment.
- Offer a kata-style time-boxed exercise when a team is stuck debating styles.
- Point to kata repos as examples for presenting an architecture, not as templates to copy.
- Disclose that the book-derived ratings and rules are practitioner heuristics.
