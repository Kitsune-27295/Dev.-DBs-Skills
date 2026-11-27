# Twelve-Factor Mechanics: Config, Release Pipeline, Processes, Disposability, Logs, Parity

Sources: https://12factor.net/ (index) · https://12factor.net/config · https://12factor.net/build-release-run · https://12factor.net/processes · https://12factor.net/disposability · https://12factor.net/logs · https://12factor.net/dev-prod-parity · Last verified 2026-11-27

All seven pages were re-fetched on the date above (see `sources.md`). The index lists the twelve factors; this file covers the six pages read for mechanics. Variable placement has its own owner: `classifying-a-new-variable.md`.

## III Config

Config is everything likely to differ between deploys: backing-service handles, credentials for external services, per-deploy values such as the hostname. Internal wiring that is the same in every deploy is not config. Rule: strict separation from code, held in environment variables (easy to change per deploy, hard to commit by accident, language and OS neutral). Test: could the codebase be made public at any time without exposing a credential?
Anti-pattern: grouping settings into named environments (`development`, `staging`, a developer's own). The page says this scales badly as deploys multiply; manage each variable independently per deploy.

## V Build, release, run

Build turns a code repo into an executable bundle (fetches dependencies, compiles). Release joins that build with the deploy's config. Run launches the app's processes from a chosen release. Every release has a unique ID (a timestamp or an incrementing number) and is immutable: a change means a new release, so the set of releases is an append-only record and rollback is the ordinary operation of selecting an earlier one. Keep run simple because it can restart unattended (a reboot at night); build may be complex because someone watches it.

## VI Processes

Processes are stateless and share-nothing; anything that must persist goes to a backing service, typically a database. Memory or disk is allowed as a single-transaction scratch space; never assume a cached value exists for a later request or job, since restarts and a different process serving the next request clear local state. Sticky sessions violate the factor; keep session data in an expiring store such as Redis or Memcached. Compile assets at build time rather than using the runtime filesystem as a cache.

## IX Disposability

Start in seconds. On SIGTERM shut down cleanly. Web process: stop listening on the port, let in-flight requests finish, exit; the page assumes short requests and long-polling clients reconnect. Worker: hand the current job back to the queue (a NACK on RabbitMQ; Beanstalkd does it on disconnect; lock-based queues must release the lock). Jobs must be re-entrant, usually by a transaction or an idempotent operation. Also tolerate sudden death (hardware failure); the page calls crash-only design the logical extreme of this idea.

```python
def on_sigterm(signum, frame):      # own illustration
    server.stop_accepting()         # no new connections
    server.drain(timeout=25)        # finish in-flight requests; keep below the platform kill timeout
    queue.nack_current_job()        # worker: hand the job back
    sys.exit(0)
signal.signal(signal.SIGTERM, on_sigterm)
```

The 25-second drain is arbitrary; set it below the platform's termination grace period (a platform setting this page does not cover).

## XI Logs

Each process writes its event stream, unbuffered, to stdout and never manages log files. The execution environment captures the streams, merges them and routes them to destinations the app does not know. Locally a developer watches the terminal; in staging and production a router (the page names Logplex and Fluentd) sends them to files or analysis systems such as Splunk or a data warehouse. Structured fields (JSON) are a common practice but are not stated on this page.

## X Dev/prod parity

Three gaps: time (weeks or months to production versus hours or minutes), personnel (people who write code also deploy it), tools (same type and version of each backing service in every deploy). The page advises resisting lightweight local stand-ins such as SQLite with PostgreSQL in production: adapters ease porting, but small incompatibilities make code that passed locally fail in production. Local installers and virtualization (Homebrew, apt-get, Docker, Vagrant are named) make matching services cheap.

## Failure-symptom table (own synthesis)

| Symptom | Likely factor |
|---|---|
| Works locally, fails on the production database | X Parity |
| Users lose carts or sessions on restart or scale-out | VI Processes |
| `if ENV == "staging"` branches, hard-coded hosts | III Config |
| Hotfix edited on a live server, no release ID | V Build, release, run |
| Jobs lost or run twice around deploys | IX Disposability |
| App rotates or ships its own log files | XI Logs |
| Migration runs inside request start-up | XII Admin processes |

## How an agent should apply this

- Grep for environment-name conditionals and hard-coded hosts; replace with per-variable config.
- Verify one build is promoted unchanged and each release is identifiable and rollback-able.
- Check SIGTERM handling and job idempotency before approving autoscaling or spot capacity.
- Reject sticky sessions and local-disk state; propose a datastore with expiry.
- Make the app log to stdout only; leave routing to the platform.
- Cite the page for a rule; label anything beyond it (timeouts, JSON logs) as practice, not as the factor.
