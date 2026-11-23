# BaaS, FaaS and the Serverless Trade-off Ledger

Sources: https://martinfowler.com/articles/serverless.html (Roberts, 2018; closing 3 KB was only boilerplate and acknowledgments), https://martinfowler.com/bliki/Serverless.html (Janakiraman, 2016) · Last verified 2026-11-23

## Definition

Serverless = third-party **BaaS** (managed auth, databases, messaging that clients may call directly) plus custom code on **FaaS** (functions in ephemeral containers triggered by events, schedules or HTTP via an API gateway; the vendor provisions and scales). The 2016 view: clients take over control flow that servers used to hold, third parties supply capability, and custom code is short-lived, activated per request and then dormant, which enables per-request pricing.

## FaaS constraints that shape design

- **State**: nothing in local memory or disk may be relied on between invocations; externalize state.
- **Duration cap**: at the time of writing Lambda allowed five minutes (check current limits; they change).
- **Cold start**: latency depends on language, code size and invocation frequency.
- **Architecture**: coordination moves toward choreography via events.
- **Operations remain**: monitoring, security, networking; Roberts debunks "no ops".

## Benefits stated

Lower operational cost, pay-per-use that suits bursty traffic (and rewards optimized code), automatic fine-grained scaling, simpler deployment, faster time to market, less idle capacity.

## Drawbacks stated

| Drawback | Detail |
|---|---|
| Vendor dependence | Less control over downtime, limits, pricing; switching drags other components |
| Multitenancy | Security, robustness and performance concerns on shared platforms |
| Security surface | Each vendor adds attack surface; IAM policies easy to misconfigure |
| Client-side logic | Full BaaS can duplicate logic across clients and lose server-side optimization |
| Testing/debugging | Integration testing hard, emulators imperfect, limited remote debugging |
| Concurrency limits | Account-wide limits let one workload throttle another, production included; use reserved concurrency |
| Gateway configuration | Logic pushed into gateway definitions is hard to test and version |
| Complexity (2016) | Conceptual overhead grows with each service; broad stack tests and semantic monitoring help |

Future directions the article names: better deployment, traffic shifting and monitoring tooling, hybrid server plus FaaS designs, edge functions, portability via CloudEvents and open-source platforms (OpenWhisk, Fission, OpenFaaS).

## Decision rules

- Prefer serverless for spiky, event-driven, low-ops-capacity workloads; avoid for steady high-throughput workloads where idle cost is already low, for latency-critical paths intolerant of cold starts, or for jobs longer than function limits (inference from the constraints above).
- Treat the account concurrency pool as shared infrastructure.

## Example: reserved concurrency as blast-radius control (pseudo-config)

```
function: checkout-handler
  reserved_concurrency: 50    # protects other functions from being starved
  timeout: 10s
  env: { TABLE: orders }      # state lives in the database, not the function
```

## How an agent should apply this

- Classify each component as BaaS or FaaS before drawing the architecture.
- Verify current platform limits instead of repeating 2018 numbers.
- Plan integration tests in a real cloud environment, since unit tests miss IAM, trigger and gateway behavior.
- Set reserved concurrency and budget alarms for each function that shares an account with production.
- Keep gateway definitions declarative and thin; keep logic in versioned, testable code.
