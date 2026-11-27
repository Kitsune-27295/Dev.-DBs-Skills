# Monolith Structure, Deployment and the Monolith-vs-Microservices Comparison

Sources: https://learn.microsoft.com/pt-pt/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures (Portuguese edition, read) · https://aws.amazon.com/compare/the-difference-between-monolithic-and-microservices-architecture/ · Last verified 2026-11-23

## Definition and internal shapes (Microsoft)
A monolithic application is self-contained in its behavior: its core runs in one process and ships as one unit; horizontal scaling means cloning the whole app. Shapes:
- **All-in-one**: one project, folders for concerns. Turns to spaghetti as it grows (UI concerns scattered over many folders, unclear who may depend on whom).
- **N-layer** (UI, business, data): see `layered-n-tier-architecture` (`layered-vs-clean-dependency-direction.md`).
- **Clean Architecture**: see `clean-architecture`; the guide calls it the most appropriate way to structure non-trivial monoliths. Multiple projects are for organization; it still deploys as a unit.

## Containers
A single monolith in one container is simple to run and scale by adding copies behind a load balancer; images roll out fast and are immutable. Drawbacks: scaling the whole app when only a hot area (e.g. product browsing) needs it, and every change means full retest and redeploy. The guide says to split only if you can cut independent feature slices; otherwise splitting only adds complexity, and microservices bring event bus, resilience, retries and eventual consistency.

## When the guide says a monolith is the better choice
The app is not yet decomposable into well-separated services; there is no need to scale parts independently (cloning the app is cheap); boundaries are unclear in an MVP. Some of these conditions are temporary, others permanent.

## AWS comparison dimensions
| Dimension | Monolith | Microservices |
|---|---|---|
| Development | little upfront planning, harder to maintain later | more design upfront, easier later |
| Deployment | one unit | independent services |
| Debugging | one environment | distributed tracing, maybe several teams |
| Modification | ripple effects, full redeploy | independent change |
| Scaling | whole app | per service |
| Risk | single point of failure | failure contained |
| Cost | low upfront, higher ongoing | higher setup, long-term savings |
Choose by application size (prototypes vs large systems), team skills (cloud, APIs, containers, distributed debugging) and infrastructure maturity. AWS's migration outline: plan, containerize, adopt DevOps/CI-CD, build services incrementally. AWS is a vendor page that frames microservices as the destination.

## How an agent should apply this
- For a new monolith propose layered structure (`clean-architecture`) inside one deployable, not a single folder pile.
- State scaling honestly: clone-the-whole-app is acceptable until a specific hotspot proves otherwise.
- Use the comparison table as questions to ask, not as a verdict.
- Before recommending a split, check team skills and infrastructure readiness.
- Cite Microsoft for structure and AWS for the comparison; mark AWS's bias.
