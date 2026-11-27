# Secrets in Git History and Rotation

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html · https://github.com/gitleaks/gitleaks · Last verified 2026-11-27

Depth for class 4 of `security-audit`. For dependency and supply-chain review use `oss-deep-audit`; for how to keep secrets server-side in new code use `never-trust-the-client`.

## Why history matters

A commit is a permanent record. Deleting a key in a later commit leaves it readable in every earlier commit, clone and fork. OWASP's secrets guidance notes that squashing history to drop a secret rewrites history and breaks links to existing commits, so weigh it deliberately; it does not replace revoking. So the order is: revoke first, rotate second, clean up third.

## Scanning the history

Gitleaks (MIT license, regex rules in a TOML config) scans a repository's patches with `gitleaks git`, a directory with `gitleaks dir`, and stdin with `gitleaks stdin`. The older `detect` and `protect` commands were deprecated in v8.19.0 and are hidden from help but still work, so old tutorials remain valid. A commit range can be passed through `--log-opts`. Reports can be saved and reused as a baseline so later runs show only new findings. The README states the tool is feature-complete, with only security patches going forward, and names Betterleaks as the successor; check which one your team standardizes on before pinning it in a pipeline (the successor was not evaluated here).

Operate read-only: run with an output path inside the report folder, never commit the raw report (it contains the secrets it found).

## Triage of each hit

| Class | Example | Action |
|---|---|---|
| Real, live | payment gateway key, signing secret, DB password | revoke, rotate, check usage logs |
| Real, dead | key already rotated | record as historical, confirm it is invalid |
| Public by design | publishable client key | not a finding by itself; check that no privileged key sits beside it |
| Placeholder | `changeme`, `your_key_here` | informational; check whether code falls back to it at runtime |
| Test fixture | well-known sample tokens | allowlist with a reason |

Defaults of the form `${VAR:-default}` are findings when the default works as a credential and nothing rejects it at startup.

## Response sequence (from OWASP guidance, paraphrased)

1. Revoke the exposed secret and verify the revocation took effect.
2. Rotate to a new value, preferably automatically so no human reads it.
3. Remove it from all places it lives: code, logs, CI variables, caches.
4. Record who had access, when it was used, when last rotated.

Related ideas from the OWASP guidance: prefer short-lived credentials and OIDC-based CI access over long-lived static keys; run more than one detector and correlate results; detect at developer level (IDE, pre-commit) so the leak never lands; restarting an app does not revoke a stolen credential. Keeping production and development secrets apart is this skill's own practice.

## Client-bundle variant

Anything inlined into a front-end build is readable by every visitor. Audit the built output or the build config, not only `.env` files. Naming conventions that expose a variable to the client (framework prefixes) are a quick grep target.

## Example search plan (read-only)

```
1. gitleaks git over the whole repo, all branches, JSON report to the report folder
2. grep working tree for provider key prefixes, "BEGIN PRIVATE KEY", "password=", "secret"
3. inspect compose/CI/chart defaults for ${VAR:-...} patterns
4. inspect front-end env files and build config for secret-looking client variables
```

## How an agent should apply this

- Scan history, not just the checkout; say which branches and how many commits were covered.
- Classify every hit with the table above before reporting severity.
- Always write "revoke and rotate" in the fix, with deleting from history as optional hygiene.
- Mask secrets in the report (first and last few characters, never the full value).
- Do not run the scanner with network features or push anything; report tool and version used.
