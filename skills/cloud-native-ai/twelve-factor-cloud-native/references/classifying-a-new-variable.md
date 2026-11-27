# Classifying a New Variable (Secret, Config or Local)

Sources: https://12factor.net/config · https://nextjs.org/docs/app/guides/environment-variables · https://vite.dev/guide/env-and-mode · Last verified 2026-11-24

Method abstracted from an internal placement checklist; no internal names reused. The factor III text and the framework docs were read on the date above.

## What factor III says
Config is everything likely to vary between deploys: resource handles for backing services, credentials for external services, per-deploy values such as the hostname. The test: could the codebase be open-sourced at any moment without exposing a credential? Internal wiring that does not vary between deploys (route tables, how modules connect) is not config and stays in code. Named "environments" bundled in files scale badly (staging, qa, personal variants multiply); the factor prefers independent per-variable values held in the environment.

## Classify before you create

| Class | Test | Home | In the repo |
|---|---|---|---|
| Secret | revealing it grants access | secret store or platform secret, injected at run | the name only, in a template with an empty value; a rotation note |
| Deploy config | varies per deploy, harmless if public | versioned config file or platform config map per deploy | the name, and a default in code if one is sane |
| Local | only one developer's machine (ports, debug flags) | an untracked local env file | an example file with names only |
| Constant | same in every deploy | code | not an environment variable |

Steps for a new variable: (1) pick the class; (2) add the name to the code reader, the example template and the deploy manifests (pass-through, not value); (3) omit the value from config when it equals the code default, to avoid drift; (4) record who rotates a secret; (5) update the documented contract of required names; (6) run a repository check that flags a secret-class name found in a tracked value file.

## Only names are shared, never values
Tickets, chat, logs, pull requests and agent transcripts carry variable names and classes only. Do not paste, print or read a secret value to debug; ask the owner to set it in the store. A missing-variable error should name the variable, never echo neighbors.

## Browser-exposed prefixes are public
- Next.js: variables without the `NEXT_PUBLIC_` prefix stay in the Node.js environment; with the prefix the value is inlined into the JavaScript bundle at build time. After the build, changing the variable does not change the bundle, so one image promoted across environments carries the build-time value.
- Vite: variables prefixed `VITE_` (configurable with `envPrefix`) are exposed to client code through `import.meta.env`; the docs say such variables should not contain sensitive information such as API keys, and suggest a backend for secrets.
- Rule: a prefixed name is public by design. A secret there is an incident, not a style issue: remove it, rotate the secret, and move the call behind a server route.
- Corollary: public client config set at build time is not per-deploy runtime config; if it must vary per deploy, serve it from the server at runtime.

```text
DATABASE_PASSWORD        -> secret: store + empty template entry
SERVICE_BASE_URL         -> deploy config: per-deploy value
NEXT_PUBLIC_API_BASE     -> public config, baked at build; never a key
```

## How an agent should apply this
- Classify every new variable before writing code; refuse to add a secret to a tracked value file.
- Add names, not values, to templates and manifests; ask the owner to set values.
- Flag any secret-looking name with `NEXT_PUBLIC_`, `VITE_` or an equivalent prefix, and route it server side.
- Keep one owner for the rule: this file owns classification; broader factor mechanics live in the factor reference, client-trust remediation in `never-trust-the-client`, secret scanning in `security-audit`.
