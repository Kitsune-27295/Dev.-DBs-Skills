# Sources for the twelve-factor-cloud-native skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Adam Wiggins et al., "The Twelve-Factor App" (2011/2026), https://12factor.net/ | Canonical definition of the 12 factors for Software-as-a-Service applications: declarative setup, clean operating system contracts, cloud platform suitability, continuous deployment, and horizontal scalability. |
| 2 | KloudEase, "12 to 15-Factor App: Cloud-Native Standards" (2024), https://kloudease.com/en/blog/12-15-factor-app-cloud-native-standards/ | Modern cloud-native extensions: API First design, comprehensive telemetry and observability, and zero-trust authentication/authorization across distributed microservice meshes. |
| 3 | https://12factor.net/config (re-read 2026-11-24, added) | Config definition, the open-source test, environments-grouping caveat |
| 4 | https://nextjs.org/docs/app/guides/environment-variables (added 2026-11-24; 200 OK via curl) | `NEXT_PUBLIC_` values inlined at build time; others stay server-side |
| 5 | https://vite.dev/guide/env-and-mode (added 2026-11-24; 200 OK via curl) | `VITE_` exposure, `envPrefix`, warning against secrets in prefixed variables |
| 6 | Internal placement checklist read for method only (added 2026-11-24) | Classify by class, share names not values; no names reused |
