# Sources - State Machine & Workflow Engine

Re-fetched with WebFetch on 2026-11-27 (Firecrawl had no credits). WebFetch returns a model-produced digest, not raw text.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://refactoring.guru/design-patterns/state | 200 OK, 2026-11-27 | State pattern intent, Document example, structure, six steps, State vs Strategy, pros and con |
| https://statecharts.dev/what-is-a-state-machine.html | 200 OK, 2026-11-27 | FSM definition, on/off example, 32-combination point, class vs object, execution steps |
| https://statecharts.dev/what-is-a-statechart.html | 200 OK, 2026-11-27 | Hierarchy, regions, guards, automatic and delayed transitions, history |
| https://stately.ai/docs/state-machines-and-statecharts | 200 OK, 2026-11-27 | Terminology, elements, createMachine basics |
| https://stately.ai/docs/guards | 200 OK, 2026-11-27 | Named guards via setup, pure-function recommendation |
| https://stately.ai/docs/actions | 200 OK, 2026-11-27 | entry/exit/transition actions, setup, provide |
| https://stately.ai/docs/actors | 200 OK, 2026-11-27 | createActor, start, send |

## Reading limits
- statecharts.dev pages only mention entry/exit actions; the phrase "state explosion" is ours.
- Nothing was run; the TypeScript and table examples are our illustrations and were not executed.

## Claims not adopted
- Machine definitions being serializable and testable through a pure transition helper: not confirmed on the pages read.
- XState behavior beyond the v5 `setup` usage shown on those pages.
- Persisting and migrating machine snapshots, and "delayed transitions survive restarts": our inference, not source claims.
