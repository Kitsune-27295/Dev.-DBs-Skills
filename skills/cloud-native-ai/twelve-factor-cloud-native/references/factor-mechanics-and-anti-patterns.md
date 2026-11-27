# Twelve-Factor Mechanics: Config, Processes, Release Pipeline, Disposability, Logs, Parity

Sources: https://12factor.net/ (index) · https://12factor.net/config · https://12factor.net/processes · https://12factor.net/build-release-run · https://12factor.net/disposability · https://12factor.net/logs · https://12factor.net/dev-prod-parity · Last verified 2026-11-23

The index frames the methodology as a way to build SaaS apps with easy onboarding, portability, cloud deployability, dev/prod consistency and scaling without major change, language- and backing-service-agnostic. The 12 factors: codebase, dependencies, config, backing services, build-release-run, processes, port binding, concurrency, disposability, dev/prod parity, logs, admin processes. This file covers the six pages read in depth.

## III Config

Config = everything that varies between deploys: backing-service handles, third-party credentials, per-deploy values such as the canonical hostname. Rules: strict separation from code; store in environment variables; completeness test: could the codebase go open source right now without leaking credentials. Settings that do not vary by deploy (route tables, framework module wiring) stay in code.
Anti-patterns: constants in source; untracked config files (better, but scatter across formats and can be committed by mistake); named environment groups (`development`, `staging`, `joes-staging`) which explode combinatorially. Each env var is an independent, granular control per deploy.

## V Build, release, run

Build turns a commit into an executable bundle (dependencies, compiled assets); release = build + deploy config, runnable instantly; run launches processes. Strict separation: nothing flows back from run to build, so code cannot be edited at runtime. Every release has a unique ID (timestamp or v100) and is immutable, an append-only ledger, which makes rollback dependable. Build may be complex because a developer is watching; run should have minimal moving parts because it can fire unattended (reboot, restart).

## VI Processes

Stateless, share-nothing; persistent data goes to a backing service. Memory or disk may hold a single-transaction scratch. Never assume a cached item exists for the next request (it may hit a different process) and restarts wipe local state even with one process. Sticky sessions are a violation; use an expiring datastore such as Redis or Memcached. Compile assets at build time, not into a runtime filesystem cache.

## IX Disposability

Fast startup (seconds) and graceful SIGTERM shutdown. Web: stop accepting new connections, finish in-flight requests, exit; long-poll clients reconnect. Workers: return the job to the queue (NACK or automatic release), so jobs must be reentrant (idempotent or transactional). Also survive sudden death; the page presents crash-only design as the logical extension.

```python
def on_sigterm(signum, frame):
    server.stop_accepting()          # no new connections
    server.drain(timeout=25)         # finish in-flight requests
    queue.nack_current_job()         # worker: hand the job back
    sys.exit(0)
signal.signal(signal.SIGTERM, on_sigterm)
```

## XI Logs

Logs are a time-ordered stream of events. The app writes unbuffered to stdout and never manages files or destinations; the execution environment captures, merges and routes streams (Logplex, Fluentd cited) to files, terminals, Splunk or warehouses for search, trend graphs and threshold alerts.

## X Dev/prod parity

Three gaps: time (weeks to hours), personnel (devs also deploy and watch), tools (same backing service type and version everywhere). Adapters (ActiveRecord, Celery, ActiveSupport::Cache) permit portability but do not justify SQLite locally versus PostgreSQL in production: small incompatibilities break continuous deployment. Homebrew, apt, Docker and Vagrant make matching services cheap.

## Failure checklist

| Symptom | Violated factor |
|---|---|
| Works locally, fails on Postgres | Parity |
| Users lose carts on restart | Processes |
| `if ENV == "staging"` branches | Config |
| Hotfix edited on the server | Build/release/run |
| Dropped jobs on deploy | Disposability |
| Log files rotated by the app | Logs |

## How an agent should apply this

- Grep for environment-name conditionals and hard-coded hosts; replace with per-variable env config.
- Verify every release is built once and promoted unchanged across environments.
- Check SIGTERM handling and job idempotency before approving autoscaling or spot instances.
- Reject sticky sessions and local-disk state; propose Redis or a database.
- Make the app log to stdout only; leave routing to the platform.
