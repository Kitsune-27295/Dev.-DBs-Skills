# Monolith First: Arguments, Evolution Paths and Counter-Argument

Sources: https://martinfowler.com/bliki/MonolithFirst.html · Last verified 2026-11-27 (article dated 2015-06-03, no later revisions shown)

## Claim and confidence
Do not start a new system with microservices, even one you expect to grow large. Observation: successful microservice systems mostly began as monoliths that grew too big; from-scratch microservice builds often ran into serious trouble. Fowler says he lacks enough anecdotes for a firm method, so all advice is tentative (written 2015, early in the field).

## Arguments
1. **Microservice premium**: managing a suite of services slows the team; a poor trade for simple apps.
2. **Feedback**: early on the open question is whether users want the product; a simple monolith gives the fastest answer.
3. **Boundaries**: microservices need stable boundaries (roughly bounded contexts). Good boundaries are hard to draw at the start, and refactoring across services is much harder than inside one codebase. A monolith lets boundaries be discovered and gives time to build operational practices.

## Evolution paths
| Path | Notes |
|---|---|
| Modular monolith then split | Modular at API and storage levels; Fowler would be more comfortable having heard more success stories; rules in `modular-monolith-architecture` |
| Peel services off at the edges | A large monolith usually stays at the core; most new work goes into services |
| Sacrificial monolith | Build it to be discarded if it gets you to market fast; theory in `yagni-evolutionary-architecture` |
| Coarse-grained start ("duolith") | A couple of large services to learn multi-service operation; split further when boundaries settle |
Caveat: you cannot assume any system can be decomposed; many have too many inter-module dependencies, and attempts often become messes. Gradual extraction worked mainly where the monolith was already well modularized.

## Counter-argument
Starting with microservices builds the habit of small separate teams early, team boundaries matching service boundaries ease scaling development, and replacements of known systems have more predictable boundaries; Fowler notes most of his contacts still favor monolith-first. His own rule: do not start with microservices unless the team already has experience building such a system. (Stefan Tilkov is only thanked in the article's acknowledgements; his position is not stated there.)

## How an agent should apply this
- Default recommendation for greenfield: one deployable with strict internal modules; justify any service split with a measured need.
- If the user insists on services, ask about team experience and boundary stability first.
- Treat "we may need to scale someday" as insufficient; ask what is unscalable today.
- Present evolution paths as options and flag that the evidence is anecdotal.
- Pair with `modular-monolith-architecture` for keeping boundaries splittable.
