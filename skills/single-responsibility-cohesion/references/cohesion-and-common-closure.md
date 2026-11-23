# Cohesion and the Common Closure Principle

Sources: https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html (cohesion/coupling framing, read) · https://martinfowler.com/bliki/CommonClosurePrinciple.html (404, not read) · Last verified 2026-11-23

**Source status:** the Fowler CCP URL returns 404; no such bliki page exists. Everything under "Common Closure Principle" below is **background knowledge, not read from source**, and is labelled as such.

## Cohesion and coupling (read from the SRP article)

The SRP article presents SRP as another way to say: increase cohesion among things that change for the same reasons; decrease coupling among things that change for different reasons. Cohesion here means "belongs together because it changes together for the same people", not "is thematically related".

Cohesion signals (inference): methods use overlapping fields; changes are co-committed; a single actor reviews them. Weak cohesion signals: disjoint field subsets, unrelated imports, multiple reviewers from different functions.

## Common Closure Principle (background knowledge, not read from source)

Statement as commonly attributed to R. C. Martin's package design principles: the classes in a package should be closed together against the same kinds of change; a change that affects a package affects all classes in it, and ideally no other package. It is SRP applied to packages/components.

Consequences (background + inference):
- Gather classes that change together into one package or module; separate those that change at different times or for different actors.
- Goal: a typical change request is confined to one package, so release, review and testing effort stay local.
- It is in tension with reuse-oriented grouping (reuse wants small, independently reusable units; closure wants change-cohesive units). Weigh them by how often the code is reused externally vs. changed internally.
- Feature-oriented layouts (`package-by-feature-component`, `vertical-slice-architecture`) are a practical expression: all code for one feature, one actor, lives together.

Use as a heuristic, not a citation: do not attribute exact wording to any page.

## Layer vs feature grouping (inference)

| Grouping | Changes together? | Verdict |
|---|---|---|
| By technical layer (controllers/, services/, repos/) | A feature edit spans all three | Poor closure for feature work |
| By feature/actor (billing/, shipping/) | A feature edit stays inside | Good closure |
| Hybrid: feature packages with layered internals | Mostly local | Common compromise |

## Measuring closure (author's recipe)

1. Take the last 30-50 commits; list files touched per commit.
2. Group files by directory/package.
3. Count packages touched per change. Median > 2 suggests poor closure.
4. Find pairs of files that co-change over 70% of the time but live in different packages: candidates to merge or colocate.

```bash
git log --name-only --pretty=format: -n 50 | sort | uniq -c | sort -rn | head
```

## Failure modes

- Over-merging: everything in one package "because it changes together", losing structure; check actors differ.
- Counting refactors as reasons to change (the SRP article excludes them).
- Treating CCP as a rule that overrides dependency direction; combine with `dependency-inversion-composition-root`.

## Use when / avoid when

Use when choosing package/module boundaries or when single changes sprawl across many modules. Avoid when the project is tiny; one package is already closed.

## How an agent should apply this

- Mark any CCP statement as background knowledge when citing; there is no source page.
- Use git co-change data to decide boundaries rather than naming alone.
- Prefer feature/actor grouping for application code; keep generic libraries separate.
- When two packages always change together, merge or colocate them.
- Re-measure after a reorganisation; the point is fewer packages per change.
