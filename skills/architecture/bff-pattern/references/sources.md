# Sources — BFF (Backend for Frontend) Pattern

Every URL below was checked during skill authoring (2026-11-27, rebuilt from the primary pages; earlier drafts dated 2026-11-22 to 2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://samnewman.io/patterns/architectural/bff/ | 200 OK (WebFetch, 2026-11-27); page dated 2015-11-18 | Definition, UI-team maintenance, one BFF per client type with a shared-BFF example, Gleadow and Hodgson attributions, desktop web and third-party cases, undecided perimeter stance, "third time" abstraction rule, wishlist partial-failure question |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends | 200 OK (WebFetch, 2026-11-27); ms.date 2025-03-19, updated 2026-11-21 | Problem, considerations, GraphQL and gateway alternatives, when not to use, workload pillars, API Management plus Azure Functions example |
| https://microservices.io/patterns/apigateway.html | 200 OK (WebFetch, 2026-11-27) | Forces, gateway solution, BFF variation, benefits, drawbacks, reactive implementation note, related patterns |
| https://nextjs.org/docs/app/api-reference/file-conventions/route | 200 OK (WebFetch, 2026-11-27); lastUpdated 2026-11-18 | `context.params` is a Promise since v15.0.0-RC; handler signature |
| https://zod.dev/basics | 200 OK (WebFetch, 2026-11-27) | `safeParse` returns a result object (success flag, data or error) instead of throwing |
| https://zod.dev/api | 200 OK (WebFetch, 2026-11-27) (added 2026-11-27) | `z.coerce.number()` documented as `Number(input)` |

Third-party skill or internal procedure read for ideas, no text reused (earlier draft of the route-handler example).

## Reading limits

- Pages were read through a summarizing fetch tool; wording in the references is paraphrase. The Microsoft page was returned in full; the Newman page was checked item by item, not read verbatim end to end.
- The route-handler snippet was not executed; `requireAccess` and `backend` are placeholders. Whether `.default(1)` after `z.coerce.number()` applies to a missing key was not checked against Zod docs.

## Claims not adopted as fact

- "Conway's Law" by name on Newman's page: not confirmed; only Hodgson's team-boundary observation was seen.
- Earlier draft said REA runs one BFF per client type with iOS and Android separate: the page only says Newman saw the pattern at REA; the split was not confirmed.
- Earlier draft said Newman is "warier" of shared BFFs: the page states a preference for one per client type and shows SoundCloud sharing; "warier" was not confirmed.
- Consumer-driven contract tests (Pact) authored by the BFF team and run in the downstream CI: not in any source read; removed.
- Voice, IoT, smart TV and wearable clients: not in the sources read (set-top box appears on Newman's page); removed.
- That perimeter concerns must never live in a BFF: Newman is undecided, so the skill records it as a decision.
