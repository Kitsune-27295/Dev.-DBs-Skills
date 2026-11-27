# Sources for the actor-model-space-based-architecture skill

Every URL below was re-fetched on 2026-11-27 with a page-reading tool (summaries, not raw text). Statements are in this pack's own words.

| # | Source | Retrieved status | What the skill takes from it |
|---|---|---|---|
| 1 | https://doc.akka.io/libraries/guide/concepts/akka-actor.html | 200, read | Actors enforce encapsulation without locks; sending a message does not transfer the sender's thread; domain task errors are ordinary replies, internal faults go to supervision; actors form a tree, a parent chooses restart or stop per failure, stopping a parent stops descendants, restarts are invisible to collaborators. No mailbox, backpressure, resume or escalate text. |
| 2 | https://doc.akka.io/libraries/akka-core/current/typed/fault-tolerance.html (added 2026-11-27) | 200, read | Resume, restart, stop (default); no escalate; watch, `ChildFailed`, death pact. |
| 3 | https://doc.akka.io/libraries/akka-core/current/typed/mailboxes.html (added 2026-11-27) | 200, read | Unbounded by default; bounded mailbox options and overflow behavior. |
| 4 | https://learn.microsoft.com/en-us/dotnet/orleans/overview | 200, read (page dated 2026) | Virtual actors, grains, silos, lifecycle, runtime services, version notes for 9.x and 10.0. |
| 5 | https://en.wikipedia.org/wiki/Space-based_architecture | 200, read | Tuple-space definition, Microsoft origin (1997-98), processing unit, three grids, SLA-driven container. No data pump or write-behind. |
| 6 | https://github.com/ahmedhammad97/Software-Architecture-Patterns-Notes | 200, read | Four-part middleware list, central store updated asynchronously, spiky-load fit. No pros and cons. |
| 7 | https://github.com/kbtale/awesome-architecture-patterns | 200, first 100,000 of 261,450 characters read | Units co-locating logic and in-memory partitioned data; data grid products named; no trade-offs. |

## Reading limits
- Summaries came from a fetch tool that answers a prompt over the page, so quotes are paraphrases. The rest of source 7 was not read.
- Akka Typed pages describe the Typed API; classic Akka and Erlang/OTP supervision were not read, so OTP claims are not made.
- The test-kit and in-process test cluster names are product vocabulary; only the Orleans test cluster is on a page read.
- No scripts or data files in this skill; nothing to run.

## Claims not adopted as fact
- Escalate as a supervisor directive (not on the Akka pages read); removed from the skill.
- "Write-behind", "data pump", "at least two replicas", and the old "10k+ concurrent bids" figure: not on any page read; kept only as labeled design judgment or dropped.
- Actors processing exactly one message at a time, and Hewitt as origin: not stated on the pages read. Orleans only says the model dates from the early 1970s.
- Combining actors inside processing units: inference.
- Trade-offs of SBA (memory cost, collisions, testing): inference except where secondary notes cite data collisions; the cited notes are covered by `architecture-decision-trees-tradeoffs`.

## Disagreements worth knowing
Classic Akka has you spawn actors, hold references and build supervision trees; Orleans addresses grains by key and the runtime owns activation, placement and recovery. Both rely on message-only access to state.
