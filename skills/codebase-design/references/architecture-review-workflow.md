# Using the Vocabulary: An Architecture-Review Workflow

Sources: https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md (MIT, read 2026-11-24 via the raw upstream file) · Last verified 2026-11-24

This file is a procedure for applying the vocabulary of `SKILL.md` (module, interface, depth, seam, adapter, leverage, locality) to an existing codebase. The vocabulary and principles stay owned by `SKILL.md`; step-by-step splitting of a god module is owned by `layered-refactor`; the interface-alternatives pattern is in `DESIGN-IT-TWICE.md`. Reference only: no deepening is performed by reading this file.

## Workflow (upstream idea, paraphrased)

**1. Scope before scanning (YAGNI).** Deepening pays off where change keeps happening, so weight recently changed areas. If the user named a direction (a module, subsystem or pain), take it. Otherwise read back a good stretch of history (`git log --oneline`, optionally `--name-only` counted per path) to find hotspots, the files that keep showing up, and look there first. If changes are scattered with no hotspot, widen the net.

**2. Read the domain language first.** A glossary names good seams, and ADRs record decisions not to re-litigate. Speak in the project's domain terms plus this vocabulary; avoid drifting to "component", "service", "API" or "boundary".

**3. Explore for friction, organically.** A fresh-context sub-agent walks the area and notes: concepts that need bouncing between many small modules; shallow modules (interface nearly as complex as implementation); pure functions extracted only for testability while bugs hide in how they are called (no locality); tightly coupled modules leaking across a seam; parts that are untested or hard to test through their interface.

**4. Apply the deletion test** to each suspect: would deleting it concentrate complexity or merely move it? "Concentrates" is the signal of a real module; "moves" marks pass-through.

**5. Report deepening opportunities, no interfaces yet.** Each candidate gets: files involved, the problem, a plain-language solution, benefits in terms of locality and leverage (and how tests improve), and a strength label (strong, worth exploring, speculative). End with the top recommendation. A visual report is optional; a short table is enough. A candidate that contradicts an ADR is listed only if the friction justifies reopening it, and is marked as such.

**6. Grill the chosen candidate** with `grilling`: constraints, dependencies, the shape of the deepened module, what sits behind the seam, which tests survive. Update the domain glossary with `domain-modeling` as terms firm up; offer an ADR only when a rejection has a load-bearing reason future reviewers would need.

**7. Alternative interfaces** (only if asked): use the design-it-twice pattern in `DESIGN-IT-TWICE.md`.

## Hotspot query (own example, standard Git)

```sh
git log --since="6 months ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20
```

Frequent paths are candidates for attention, not verdicts: a changelog or lockfile will top the list and should be filtered out (inference).

## How an agent should apply this

- Establish the scope first: user direction, else hotspots from history.
- Use the exact vocabulary and the deletion test on every claim of shallowness.
- Deliver a candidates report without proposing interfaces, then wait for the user's pick.
- Move to `grilling` for the chosen candidate; record glossary or ADR changes only through `domain-modeling` and with the user's agreement.
