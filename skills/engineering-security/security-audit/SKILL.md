---
name: security-audit
description: "Audit a codebase, especially AI-generated or vibe-coded, for the five most common SaaS security flaws: missing tenant or owner isolation, permissions enforced only in the browser, IDOR, hardcoded or leaked keys (including git history), and unsanitized input (XSS). Read-only; detects the stack first, reports verified findings with file:line, lists what is correct and drafts ready-to-paste issues. Use when asked for a security review or pre-launch check of an app. Not for moving client-side business rules to the server (use never-trust-the-client), database exposure (use database-exposure), designing login or OAuth (use authn-authz-guard), design-time threats (use threat-modeling) or one scanner alert (use vulnerability-triage)."
---

# Security audit (five flaws, any stack)

An AI delivers an application that works and does not warn you which doors it left open. The same AI can find the holes once told to be suspicious. It does not know your business rules, so a generic "find the vulnerabilities" fails: name the five classes. Read-only on the project: change no source file, run no migration, install nothing globally. The only writes are the report, its generator script and its isolated environment, in a report folder (default `docs/security-audit/`).

## Step 0: detect the stack

Language, framework, ORM or query builder, auth mechanism, frontend, deploy files (Docker, CI, Helm, Terraform). Map each class below to that stack's equivalent. Say how in the report's method note. A class that does not apply (no frontend, no database exposed by API) is reported as **not applicable**, never forced into findings.

## The five classes

1. **Database without a lock (tenant or owner isolation).** Name the project's isolation mechanism first (row-level security, tenant middleware, manual `user_id` filter, ORM scope), then find where it is missing or holey. With row-level security, also check: views bypass it by default (owner rights; `security_invoker` fixes that), the table owner bypasses it unless `FORCE ROW LEVEL SECURITY`, and a table with it enabled but no policy denies all access. Look for listing, search, aggregate, report and export queries that do not filter by the authenticated user or their organization. For a database reachable through an API, its open port, policies and grants have their own checklist: `database-exposure`.
2. **Permission decided in the browser.** Privileged operations (admin, settings, user management, writes) where the UI hides things by role (`isAdmin`, `canEdit`) but the server does not check the same privilege. Cross every front-end gate with its endpoint.
3. **IDOR.** Routes that fetch, change or delete an object by id (path, query or body) without checking it belongs to the caller. Sequential ids make it trivial: change 105 to 106 and the next person's data arrives, and it is easy to automate when no rate limit exists. Random ids are only defense in depth, never a substitute for the ownership check (OWASP). Walk **every** route handler, not a sample.
4. **Exposed keys.** API keys, tokens, passwords, signing secrets (JWT, webhooks), private keys and default credentials in source, config, compose files, charts, CI, scripts and docs. Watch public defaults that become real secrets when not overridden (`${VAR:-default}`) and the absence of a startup check that rejects them. Search **git history** (a deleted key is still there; revoke it, deleting is not enough) and the front-end bundle (every client variable is readable JavaScript).
5. **Unhandled input (XSS).** Front end: `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `[innerHTML]`, unsanitized markdown or HTML, user-controlled `href`/`src` (`javascript:`), `eval`, `new Function`. Back end: user input in e-mail HTML, templates or responses without escaping. Check whether a sanitization library exists and is applied where found. Also uploads with no type or content check (the source video cites an image hiding a script that stole an admin session) and admin fields that accept raw HTML or script that then runs on every page. Treat everything the user types as hostile: validate, clean, limit.

## Audit rules

- Report only findings **verified in the real code**; no speculation. Each has file path, exact line(s), snippet, why it is exploitable and severity (critical, high, medium, low, informational).
- List file by file, line by line.
- Record what is **correct** too (e.g. "router X checks ownership in every handler"): it proves coverage and gives the strengths section.
- Note exploitability conditions (feature flags, insecure config required).
- Unverifiable item: write "not verified" and the reason.

## Deliverable

A report and ready-to-paste issue drafts (each with checkable acceptance criteria), in the language of the project's team; format in [references/report-and-issues.md](references/report-and-issues.md). Fixes follow `never-trust-the-client` (rules, secrets, policies, ownership, input); to sequence them against other concerns use `fundamentals-audit`.

## Free tools to add

| Tool | Finds |
|---|---|
| OWASP ZAP | dynamic scan of the running web application for common flaws |
| Gitleaks | keys and passwords across the whole git history (`gitleaks git`; `detect` in older versions) |
| Bandit | Python code flaws |
| OpenGrep (open fork of Semgrep) | pattern-based static analysis across languages |

Tool output feeds the audit; it does not replace the five-class review.

## Pre-deploy checklist

- The audit ran and the whole report was read, not just the summary.
- Every endpoint taking an id validates the owner before answering.
- Every listing, search and export filters by the signed-in user or tenant.
- Every permission the front end hides is re-checked by the server.
- No secret in code, front-end bundle, compose file or CI; git history searched and what appeared was **revoked**.
- Every user input is validated and sanitized before becoming HTML.
- If a database is exposed through an API: security policies on in every table, service key never in the front end.
- Findings became issues (hardening) or a private advisory (exploitable).

## Diff review mode (a pull request or local diff)

When the target is a change, not the whole repository, ask: does this diff introduce, widen or remove a security control? Classify the changed files by risk first (authentication, authorization, queries and tenant scoping, new entry points and rendering of user data get deep reading; docs, tests and styling get a skim), then open the code around each change, because the usual flaw is a check that is **missing** from the diff. Run only the five classes and the extra checks the diff touches, report issues introduced by the change separately from pre-existing ones, mark anything unverifiable, and keep exploit details out of public comments. Checks and output shape: [references/diff-review-mode.md](references/diff-review-mode.md). Rating and routing a finding: `vulnerability-triage`; a design-level change: `threat-modeling`; style and correctness: `code-review`.

## Quick Decision Checklist

- [ ] Have I detected the stack first and marked classes that do not apply as not applicable?
- [ ] Is this read-only on the project, with writes limited to the report folder?
- [ ] Do I cover all five classes, not a generic "find vulnerabilities" pass?
- [ ] Did I walk every route handler for ownership checks rather than a sample?
- [ ] Does the server re-check every permission that the front end hides?
- [ ] Did I search git history and the front-end bundle for keys, and require revocation?
- [ ] Is each finding verified in real code with file, lines, snippet and severity, and unverifiable items marked "not verified"?
- [ ] Did I also record what is correct?

## Deep references

- [Sources](references/sources.md) — origin of the five-class list, source status and caveats.
- [Five classes: attack and detection patterns](references/five-classes-attack-and-detection-patterns.md) — how each class shows up in generated code, how to verify it, false positives.
- [Tenant isolation and RLS checks](references/tenant-isolation-and-rls-checks.md) — read when auditing row-level security or tenant filters.
- [Secrets in git history and rotation](references/secrets-in-git-history-and-rotation.md) — read when scanning history and triaging leaked keys.
- [XSS and output encoding checks](references/xss-and-output-encoding-checks.md) — read when tracing sinks, uploads and admin HTML fields.
- [Diff review mode](references/diff-review-mode.md) — read when reviewing a pull request or diff: risk classification, absent-control hunting, OWASP-derived checks, introduced vs pre-existing findings.
