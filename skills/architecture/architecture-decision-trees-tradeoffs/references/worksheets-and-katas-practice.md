# Worksheets, Katas and Practice Resources

Sources: https://developertoarchitect.com/resources.html · https://www.architecturalkatas.com/ · Last verified 2026-11-27

Limitation: the old `nealford.com/katas/` URL now returns 404. The katas site names a Rules page and a Lead page that were not read, so timing and scoring rules are not captured here.

## Worksheets (Mark Richards, Developer to Architect)

| Resource | Purpose | Use |
|---|---|---|
| Architecture Characteristics Worksheet | list the driving "-ilities" with definitions | work through it with stakeholders to find the few critical characteristics (a short video tutorial exists) |
| Architecture Styles Worksheet | star-rating chart, created with Neal Ford, comparing styles per characteristic | check whether the current style fits the drivers, or pick a migration target |
| Architecture Patterns Cross-Reference | which patterns, antipatterns and pitfalls improve or hurt given capabilities; also lookup by context | tied to the O'Reilly book on patterns, antipatterns and pitfalls (early release at read time) |
| Architecture Definition Language | pseudo-code for structural, operational and process aspects | structural parts can be paired with a prompt to generate code |

Suggested workflow (from the page): characteristics worksheet, then styles worksheet, then describe structure, then compare against kata solutions, then the page points to the 20-minute rule for expanding technical breadth (it links the rule but does not define it).

## Architectural katas

- Origin: Ted Neward started it as a presentation workshop that "took on a life of its own". Rationale: architects architect fewer than a half-dozen times in a career, and Brooks is quoted that great designers design, so repetition substitutes for scarce real projects.
- The site offers experienced moderators and a page for people who want to run the workshop. Group size and timing are not stated on the page read.

## Using them as a decision aid

A kata forces you to pick the top characteristics, choose a style, and justify it in minutes. That is exactly the discipline for real decisions: constraints visible, trade-offs named.

```
Kata prompt -> rank 3 characteristics -> compare 3 styles -> pick least-worst
-> list 2 ADRs with consequences -> name 1 risk + mitigation
```

## How an agent should apply this

- Use the worksheet structure as the template for any style recommendation: characteristics first, style comparison second.
- Do not fabricate star ratings from memory; if ratings are needed, derive them from documented trade-offs and label them as judgment.
- Offer a kata-style time-boxed exercise when a team is stuck debating styles.
- Disclose that the book-derived ratings and rules are practitioner heuristics.
