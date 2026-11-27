# Sources: Twelve-Factor and Cloud-Native Design

Every URL below was re-fetched on 2026-11-27 with WebFetch (Firecrawl unavailable). Last verified 2026-11-27.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://12factor.net/ | 200 OK | The twelve factor titles; page credited to Adam Wiggins, marked "Last updated 2017", footer copyright 2026 Salesforce, no license stated |
| https://12factor.net/config | 200 OK | Config definition, publish-the-repo test, env vars, named-environments caveat |
| https://12factor.net/build-release-run | 200 OK | Three stages, release IDs, immutability, rollback, build vs run complexity |
| https://12factor.net/processes | 200 OK | Stateless share-nothing, sticky sessions, asset compile, scratch use |
| https://12factor.net/disposability | 200 OK | Fast start, SIGTERM, web and worker shutdown, re-entrant jobs, crash-only |
| https://12factor.net/logs | 200 OK | Unbuffered stdout, environment-side routing, Logplex, Fluentd, Splunk named |
| https://12factor.net/dev-prod-parity | 200 OK | Three gaps, SQLite/PostgreSQL advice, adapter caveat |
| https://kloudease.com/en/blog/12-15-factor-app-cloud-native-standards/ | 200 OK (vendor blog) | Three extra factors, Hoffman attribution, CNCF model mention, telemetry quote |
| https://nextjs.org/docs/app/guides/environment-variables | 200 OK (page lastUpdated 2026-08-25) | `NEXT_PUBLIC_` build-time inlining, frozen values, runtime reads under dynamic rendering |
| https://vite.dev/guide/env-and-mode | 200 OK | `VITE_` exposure, `envPrefix`, secrets warning, `.env.local` |
| Internal placement checklist (earlier draft) | Not re-read | Method only; no names reused |

## Reading limits

- Pages for factors I, II, IV, VII, VIII and XII were not re-fetched; the "typical violation" cells for them are own commentary.
- WebFetch returns a model-written summary of each page, not raw text, so exact wording was not compared.
- The Hoffman book and the CNCF Cloud Native Maturity Model were not read; they are known only through the vendor article.
- No scripts or data files exist in this skill.

## Claims not adopted as fact

- The earlier draft's "Retrieved 2026-11-22" and "(2011/2026)" edition labels: the site is marked last updated 2017.
- A table mapping original factors to extensions (Logs to Telemetry, Config to Credentials, Disposability to Kubernetes needs): not found in the article summary; dropped.
- A claim that an SREaaS provider treats JSON logs with correlation IDs, Prometheus metrics, a health endpoint and an SBOM as prerequisites: not confirmed; dropped.
- "Release is runnable instantly" and "Heroku" as co-author attribution: not confirmed.
- Kubernetes probe, resource and termination-period advice: practice, not a source claim.
