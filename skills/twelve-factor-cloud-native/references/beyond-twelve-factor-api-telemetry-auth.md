# Beyond Twelve-Factor: API First, Telemetry, Authentication and Authorization

Sources: https://kloudease.com/en/blog/12-15-factor-app-cloud-native-standards/ · Last verified 2026-11-23

The article (a vendor blog, so treat framing as opinion) describes Kevin Hoffman's *Beyond the Twelve-Factor App* (2016): the original twelve reordered and sharpened, plus three factors for distributed systems. The original model covers a single app on a PaaS; the additions cover distribution, declarative operations and security by default.

## 13 API First

Design the interface before the implementation; a versioned contract (OpenAPI, Protobuf) is the first artifact. Payoffs: consumers build against mocks, breaking changes surface in review, contract tests run in CI. Reason for the factor: the original twelve say nothing about interfaces, yet many-service systems live or die on them.

## 14 Telemetry

Extends Logs (11) to three data kinds: application metrics (throughput, error rate), health metrics (status, availability), and domain events. Examples: structured logs, a Prometheus-compatible endpoint, distributed tracing with propagated context headers; OpenTelemetry is named as the common standard. Rationale quoted from the article: "What an application does not reveal about itself, no platform can make visible after the fact."

## 15 Authentication and Authorization

Every call is authenticated and authorized, internal ones included; identities short-lived, permissions explicit, secrets never in the image or repo. On Kubernetes: RBAC, central secrets management, mTLS between services, policy that rejects insecure configuration. Reason: no trusted internal network.

## Changes to original factors

| Original | Extended by |
|---|---|
| Logs (11) | Telemetry (14): metrics, health, events |
| Config (3) | Credentials (15): separate lifecycle, rotation, audit, storage outside repo |
| Disposability (9) | Kubernetes needs: health probes, resource requests, graceful SIGTERM, defined termination periods |

The article does not enumerate every other reformulation, so do not attribute further changes to it.

## Operational context

The CNCF Cloud Native Maturity Model is cited: from production readiness onward expect multiple replicas, externalised config, meaningful readiness probes, an SBOM per release, sized resources. Common obstacles: session state in memory or disk, secrets mixed into plain config, apps that ignore SIGTERM and drop requests. A provider running an app as SREaaS treats these as prerequisites (JSON logs with correlation ID, Prometheus metrics, health endpoint, SBOM).

```yaml
# illustrative Kubernetes fragment (own example)
readinessProbe: { httpGet: { path: /healthz, port: 8080 } }
resources: { requests: { cpu: 100m, memory: 128Mi } }
terminationGracePeriodSeconds: 30
envFrom: [ { secretRef: { name: app-credentials } } ]
```

## Use when / avoid when

Use the extra factors when many services exchange calls or run on Kubernetes. Avoid adopting 15 factors as a checklist for a single small monolith; the first twelve plus basic logging usually suffice (inference).

## How an agent should apply this

- Require an OpenAPI or Protobuf contract and contract tests before new service-to-service calls.
- Add health endpoint, metrics and trace propagation as part of "done" for a new service.
- Keep credentials in a secret store, not in ordinary env config files; plan rotation.
- Check probes, resource requests and SIGTERM handling in manifests.
- Cite the vendor article as opinion; cite 12factor.net for the original rules.
