# Beyond Twelve-Factor: API First, Telemetry, Authentication and Authorization

Sources: https://kloudease.com/en/blog/12-15-factor-app-cloud-native-standards/ · Last verified 2026-11-27

The article is a vendor blog, so treat its framing as opinion. It credits Kevin Hoffman's 2016 book *Beyond the Twelve-Factor App* with reordering and sharpening the original twelve and adding three factors. The original model covers one app on a platform; the additions address distribution and security. The primary text of the book was not read here.

## 13 API First

Design the interface before the implementation, with a versioned contract such as OpenAPI or Protobuf as the first artifact. Payoffs named: teams build against mocks, breaking changes surface in review, contract tests run in the pipeline.

## 14 Telemetry

Expose three kinds of data: application metrics, health status and domain events. Short-lived containers cannot be inspected by logging into a machine, so the app must provide the data itself: structured logs, a Prometheus-compatible metrics endpoint, distributed tracing; OpenTelemetry is named as the common standard. Quoted in the article: "What an application does not reveal about itself, no platform can make visible after the fact." Instrumentation design lives in `circuit-breaker-retry-telemetry`.

## 15 Authentication and Authorization

Authenticate and authorize every request, internal calls included. Identities are short-lived, permissions explicit, secrets kept out of images and repositories. On Kubernetes the article lists RBAC, central secrets management, mTLS and policy enforcement. Flow and token design lives in `authn-authz-guard`.

## Maturity context

The article cites the CNCF Cloud Native Maturity Model (five aspects across five levels). From the move into production onward it expects multiple replicas, externalized configuration, meaningful health probes and an SBOM per release. These are the article's reading of the model; the model itself was not fetched.

## Own illustration (not from the article)

```yaml
readinessProbe: { httpGet: { path: /healthz, port: 8080 } }
resources: { requests: { cpu: 100m, memory: 128Mi } }
terminationGracePeriodSeconds: 30     # keep above the app's drain time
envFrom: [ { secretRef: { name: app-credentials } } ]
```

## Use when and avoid when

Use the three factors when many services exchange calls or the platform is Kubernetes. A small single-service app usually needs the first twelve plus basic logging (this skill's judgment, not a source claim).

## How an agent should apply this

- Require a contract (OpenAPI or Protobuf) and contract tests before new service-to-service calls.
- Count a health endpoint, metrics and trace propagation as part of done for a new service.
- Keep credentials in a secret store, not in ordinary config files, and plan rotation.
- Check probes, resource requests and SIGTERM handling in manifests as practice, not as article claims.
- Cite the vendor article as opinion and 12factor.net for the original rules; do not attribute a mapping of old factors to new ones to it.
