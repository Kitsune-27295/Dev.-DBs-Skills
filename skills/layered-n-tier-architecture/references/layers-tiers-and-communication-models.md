# Layers, Tiers, and Communication Models (Azure N-tier guide)

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/n-tier · Last verified 2026-11-23

## Definitions as the guide states them
- **Layers** separate responsibilities and manage dependencies: a higher layer may use services of a lower one, never the reverse.
- **Tiers** are physically separated and run on separate machines. Layers are logical; tiers are deployment.
- Layers and tiers are independent axes: each layer may get its own tier, but this is not required; several layers may share one tier.
- A classic three-tier app = presentation tier, optional middle tier, database tier. More complex apps can have more (the reference diagram has two middle tiers for different functional areas, plus a WAF in front, a cache beside the data tier, and a message queue feeding one middle tier).
- Physical separation buys scalability and resiliency but costs network latency.

## Closed vs open, strict vs relaxed
| Model | Rule | Upside | Downside |
|---|---|---|---|
| Closed layer / strict tier model | call only the next layer down; no skipping | fewest dependencies between layers | extra latency and overhead; pass-through traffic if a layer adds nothing |
| Open layer / relaxed tier model | may call any layer below | fewer hops | more couplings, so changes get harder |
| Mixed | both in one system | tune per path | needs explicit documentation of which paths are open |

Tier-to-tier calls can be direct or go through an asynchronous message queue (the diagram shows one middle tier reached via messaging).

## When the guide recommends N-tier
- Architectural requirements are still evolving.
- Migrating an on-premises app with minimal change.
- Apps spanning on-premises and cloud.

Benefits listed: portable across clouds and on-prem, low learning curve, cheap because no re-architecture, natural evolution of the traditional model, mixed Windows/Linux.

## Challenges listed (use them as review checks)
1. A middle tier that only does CRUD adds latency and complexity without value (the sinkhole).
2. Monolithic design blocks independent deployment of features.
3. Network security gets hard in large systems.
4. Requests and data crossing several tiers make testing and monitoring harder.

## Best practices (guide) and how they map to rules
- Autoscale; decouple tiers with async messaging; cache rarely-changing data.
- Database tier highly available (example given: SQL Server Always On availability groups).
- WAF between front end and internet; each tier in its own subnet used as a security boundary; data tier accepts requests from the middle tier only.

## IaaS reference deployment (VM example)
Internet -> load balancer -> perimeter network (2+ network virtual appliances) -> load balancer -> web tier VMs -> load balancer -> business tier VMs -> load balancer -> data tier (primary and secondary SQL Server); admin access through Azure Bastion, not direct RDP/SSH. Each tier is a scale set of 2+ VMs in its own subnet, so NSG rules and route tables apply per tier. Web and business tiers are stateless (any VM serves any request); the data tier is replicated. The guide notes VMs suit lift-and-shift; otherwise prefer managed services (App Service, Container Apps). Naming tip from the guide: use clear tier names in resources, e.g. `vmss-appname-business-tier`.
Also: with many tiers consider layer-7 routing; use separate tiers for services with different scale/reliability/security needs; extend the VNet to on-prem via VPN or ExpressRoute.

## Small example (own sketch, not from source)
```
client -> WAF -> web tier (presentation)
                   |-- sync --> middle tier A (orders) --> cache --> data tier
                   '-- queue -> middle tier B (billing) -> data tier
```
Strict on the orders path, relaxed for cached reads, async for billing.

## How an agent should apply this
- Draw layers (code) and tiers (runtime) as two separate views; never let one box mean both.
- Record per path whether it is strict or relaxed; flag unrecorded skips.
- Before proposing a new tier, name the scale, security, or reliability requirement it satisfies; otherwise keep layers in one process.
- Flag a middle tier whose methods are CRUD forwarding as a sinkhole candidate.
- For tiered designs require: WAF/edge, subnet per tier, data tier reachable only from the middle tier, autoscaling and cache/queue decisions.
