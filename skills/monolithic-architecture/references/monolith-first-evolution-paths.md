# Monolith First: Arguments, Evolution Paths and Counter-Argument

Sources: https://martinfowler.com/bliki/MonolithFirst.html · Last verified 2026-11-23

## Claim and confidence
Do not start a new system with microservices, even one you expect to grow large. Observation: successful microservice systems mostly began as monoliths that grew too big; from-scratch microservice builds often ran into serious trouble. Fowler calls the evidence sparse and the advice tentative (written 2015, early in the field).

## Arguments
1. **Microservice premium**: managing a suite of services slows the team; a poor trade for simple apps.
2. **YAGNI / feedback**: early on you are still learning whether users want the product; a simple version is the fastest test. Scaling a successful but crude system is the better problem to have.
3. **Boundaries**: microservices need stable boundaries (roughly bounded contexts). Moving behavior between services is far harder than refactoring in one codebase; even experienced architects misplace boundaries in familiar domains. A monolith lets boundaries be discovered and gives time to build operational practices.

## Evolution paths
| Path | Notes |
|---|---|
| Modular monolith then split | Modular at API and storage levels; Fowler is less sure, having heard few success stories |
| Peel services off at the edges | A large monolith usually stays at the core; most new work goes into services |
| Sacrificial monolith | Build it to be discarded if it gets you to market fast |
| Coarse-grained start ("duolith") | A couple of large services to learn multi-service operation; split further when boundaries settle |
Caveat: you cannot assume any system can be decomposed; many have too many inter-module dependencies, and attempts often become messes. Gradual extraction worked mainly where the monolith was already well modularized.

## Counter-argument
Starting with microservices builds the habits early, teams scale along service lines, and replacements of known systems have clearer boundaries; staying modular enough to split later takes real discipline. Fowler's own rule: avoid starting with microservices unless the team already has experience with them.

## How an agent should apply this
- Default recommendation for greenfield: one deployable with strict internal modules; justify any service split with a measured need.
- If the user insists on services, ask about team experience and boundary stability first.
- Treat "we may need to scale someday" as insufficient; ask what is unscalable today.
- Present evolution paths as options and flag that the evidence is anecdotal.
- Pair with `modular-monolith-architecture` for keeping boundaries splittable.
