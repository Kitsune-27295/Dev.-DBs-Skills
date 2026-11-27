# BaaS, FaaS and the Serverless Trade-off Ledger

Sources: https://martinfowler.com/articles/serverless.html (Roberts, 2018-05-22; the last 2.9 KB of the page was not read), https://martinfowler.com/bliki/Serverless.html (Janakiraman, 2016) · Last verified 2026-11-27

## Definition

Serverless = third-party **BaaS** (managed auth, databases, messaging that clients may call directly) plus custom code on **FaaS** (functions in ephemeral containers triggered by events, schedules or HTTP via an API gateway; the vendor provisions and scales). The 2016 view: clients take over control flow that servers used to hold, third parties supply capability, and custom code is short-lived, activated per request and then dormant, which enables per-request pricing.

## FaaS constraints that shape design

- **State**: nothing in local memory or disk may be relied on between invocations; externalize state.
- **Duration cap**: the 2018 article says Lambda allowed at most five minutes. AWS's Lambda timeout page (https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html, read 2026-11-27) now shows a 3-second default and a maximum of 1,800 seconds (30 minutes). Limits change; check the page before quoting.
- **Cold start**: latency ranges from milliseconds to seconds, depending on language, dependencies, VPC use and invocation frequency; at one event per hour nearly every call is cold, at ten per second cold starts are rare. The article mentions keep-alive pings as a mitigation.
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
| Concurrency limits | The account-wide limit lets a load test or batch job starve production functions; reserved concurrency caps and guarantees one function, but is off by default |
| Gateway configuration | Logic pushed into gateway definitions is hard to test and version |
| Complexity (2016) | Conceptual overhead grows with each service; broad stack tests and semantic monitoring help |

The article's outlook covers better tooling and platform improvements, edge functions such as Lambda@Edge, testing in production, and portability (CloudEvents through the CNCF working group; OpenWhisk, Fission and OpenFaaS in its open-source section).

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
