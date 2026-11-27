# Classifying a New Variable (Secret, Config or Local)

Sources: https://12factor.net/config · https://nextjs.org/docs/app/guides/environment-variables · https://vite.dev/guide/env-and-mode · Last verified 2026-11-27

The classification table and steps are this skill's own method; the factor III text and the two framework docs were re-read on the date above.

## What factor III says

See `factor-mechanics-and-anti-patterns.md` (III Config) for the definition, the publish-the-repo test and the named-environments caveat. This file only adds placement.

## Classify before you create

| Class | Test | Home | In the repo |
|---|---|---|---|
| Secret | revealing it grants access | secret store or platform secret, injected at run | the name only, in a template with an empty value |
| Deploy config | varies per deploy, harmless if public | per-deploy config (file or platform map) | the name, and a default in code if sane |
| Local | one developer's machine (ports, debug flags) | untracked local env file | an example file with names only |
| Constant | same in every deploy | code | not a variable |

Steps: (1) pick the class; (2) add the name to the code that reads it, the example template and the deploy manifests (pass-through, not value); (3) omit a value that equals the code default, to avoid drift; (4) record who rotates a secret; (5) update the documented list of required names; (6) add a repository check that flags a secret-class name found with a value in a tracked file (scanner design: `security-audit`).

## Only names are shared, never values

Tickets, chat, logs, pull requests and agent transcripts carry variable names and classes only. Do not paste, print or read a secret to debug; ask the owner to set it in the store. A missing-variable error names that variable and never echoes neighbors.

## Browser-exposed prefixes are public

- Next.js: variables without `NEXT_PUBLIC_` stay in the Node.js environment. With the prefix, the value is inlined into the JavaScript bundle at `next build`; after the build the app no longer responds to changes, so one image promoted across environments keeps the build-time value. Dynamic lookups such as `process.env[name]` are not inlined. The page also says server code can read environment values at request time under dynamic rendering, which lets a single image carry different values per environment.
- Vite: `VITE_` variables (prefix configurable with `envPrefix`) are exposed in client source after bundling; the docs say they should not contain sensitive information such as API keys and point to a backend or serverless function for secrets. `.env.local` is for local settings and should be git-ignored (`*.local`).
- Rule: a prefixed name is public by design. A secret there is an incident: remove it, rotate it (rotation steps: `security-audit`), and move the call behind a server route.
- Corollary: public config set at build time is not per-deploy runtime config. If it must vary per deploy, serve it from the server at runtime.

```text
DATABASE_PASSWORD     -> secret: store + empty template entry
SERVICE_BASE_URL      -> deploy config: per-deploy value
NEXT_PUBLIC_API_BASE  -> public config, baked at build; never a key
```

## How an agent should apply this

- Classify every new variable before writing code; refuse to add a secret to a tracked value file.
- Add names, not values, to templates and manifests; ask the owner to set values.
- Flag any secret-looking name under `NEXT_PUBLIC_`, `VITE_` or an equivalent prefix and route it server side.
- One owner per rule: this file owns classification; factor mechanics live in the mechanics reference, client-trust remediation in `never-trust-the-client`, secret scanning in `security-audit`.
