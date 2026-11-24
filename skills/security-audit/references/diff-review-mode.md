# Diff Review Mode (security review of a pull request)

Sources: https://owasp.org/www-project-code-review-guide/ · https://owasp.org/www-project-code-review-guide/assets/OWASP_Code_Review_Guide_v2.pdf · https://github.com/OWASP/www-project-code-review-guide · Last verified 2026-11-24

## What this mode is

The five-class audit sweeps a whole codebase. A diff review asks a narrower question: **does this change introduce, widen or remove a security control?** The OWASP Code Review Guide frames secure review as checking that the proper security and logical controls are present, work as intended, and are invoked in the right places, and it says review depth should follow risk: its criteria are ease of exposure (internet-facing or insider), value of what could be lost, and regulatory controls. Its own example contrasts a three-line CSS change with a redesign of authentication code; they should not receive the same effort.

Note on the source: the guide's current 3.0 branch is a short, work-in-progress draft (the repository is archived and read-only); the detailed checks below come from the 2.0 PDF, which predates some current practice. Where it conflicts with current guidance (password complexity rules, for example), defer to `authn-authz-guard`.

## Step 1: classify the diff by risk

Read the file list first. Assign the review depth from what the change touches:

| Change signal | Depth | Why |
|---|---|---|
| Authentication, sessions, tokens, password reset, roles, permission checks | Deep: read every changed line and its callers | A mistake here affects every feature |
| Queries, ORM filters, tenant or owner scoping, database policies, migrations | Deep | Isolation flaws leak other users' data |
| New or changed routes, handlers, webhooks, file uploads, redirects | Deep | New entry points |
| Rendering of user data (templates, markdown, HTML, emails) | Medium to deep | Output encoding |
| Secrets, configuration, CI, container and deploy files | Medium | Credentials and exposure |
| Dependency manifests and lockfiles | Medium | New code you do not control |
| Logging, error handling | Light to medium | Leaks and missing audit trail |
| Docs, tests, styling, copy, renames with no behavior change | Light: skim for secrets and test-only bypasses | Low exposure |

## Step 2: read what the diff does not show

A diff hides the most common failure: **a control that is absent**. For each new or changed entry point, open the surrounding code: where the route is registered, which middleware or decorator runs before it, who calls the changed function, and whether the check you expect exists anywhere on the path. Compare with a sibling handler that is known to be correct. The guide's preparation advice applies: know the business purpose, the sensitive data, the user roles, and the application type before judging a change.

## Step 3: apply the checks (OWASP-derived)

**Access control (highest yield).**
- Every new entry point and function is authorized; the check is central and consistent, not re-invented in the handler.
- Authorization runs before any business processing; execution stops when it fails (the guide gives the example of a view-only check while the action still executes).
- Decisions never rely on client-supplied data (headers, hidden fields, role flags in the body).
- Object access verifies ownership, not just a valid session (`never-trust-the-client`, `authn-authz-guard`).
- Request-to-object binding: new fields bound from the request must not include server-owned ones (price, role, tenant, status). Check whether the framework binds everything by default.
- Leftover test routes, debug actions and "allow all" defaults are removed.
- Role changes for high-risk roles are logged.

**Authentication and sessions.**
- Error messages do not reveal whether a username exists; invalid passwords are never logged.
- Login and reset flows are rate limited; the reset flow cannot be used to spam a user.
- High-risk functions have a stronger step (additional factor or re-authentication).
- Session identifiers do not travel in URLs; credentials never travel in GET; session data is validated and sessions expire after inactivity.

**Injection and input.**
- Queries are parameterized; user input is not concatenated into queries, commands or templates.
- Input is validated on the server for type, length, format and range; allowlists beat blocklists.
- Redirect and forward targets built from input use an allowlist or relative paths only.
- Output carrying untrusted data is encoded for its context (`xss-and-output-encoding-checks.md` has sinks and encoders).

**Request forgery.** A state-changing request carries a per-request token tied to the user. The guide lists measures that fail review: relying on a secret cookie or the session id (sent automatically), accepting only POST, and URL rewriting.

**Sensitive data and cryptography.**
- Sensitive data travels over TLS; keys and secrets are not in code (`secrets-in-git-history-and-rotation.md`); no sensitive values in logs or error output.
- No home-made cryptography or hashing schemes; current libraries and parameters.

**Dependencies.** A new library should be one the project is meant to use (or already uses), and should be recorded in whatever tracking exists so an advisory can be acted on quickly. A lockfile change with no manifest change needs an explanation.

**Concurrency and state.** Shared static state touched by requests, locks not released in a `finally` path, check-then-act sequences on balances or quotas (`race-condition-fix` has the fix patterns).

**Errors and logging.** Generic user-facing errors with detail kept in logs; security-relevant events (failed logins, denied access, role changes) are logged without personal or secret data.

**Tenant isolation.** Any new query, view, report, export or cache key that omits the user or organization filter, or any new table without a policy (`tenant-isolation-and-rls-checks.md`).

## Step 4: report only what the diff supports

- Report **verified** issues: file, line, snippet, why it is exploitable, severity (`vulnerability-triage` for rating and priority). Mark anything unverifiable as "not verified" and say why.
- Separate **introduced by this change** from **pre-existing in touched code**. Raise pre-existing items once, as follow-up for the full audit, not as blockers of this change.
- Record what is correct (for example "new route reuses the ownership middleware") so coverage is visible.
- Suggest the direction of the fix, not a rewrite; leave style to `code-review`.
- Keep exploit details out of public pull request comments for an unfixed exploitable flaw; follow the private route in `vulnerability-triage`.
- If the change alters architecture, a trust boundary or the data it handles, recommend a short `threat-modeling` update instead of trying to review it line by line.

## Output shape

1. Verdict: block, request changes, or approve with notes, with a one-line reason.
2. Findings (introduced by the diff), ordered by severity, each with file:line, issue, exploit path, fix direction.
3. Follow-ups (pre-existing).
4. What was checked and found correct; what was not verified and why.

## Failure modes

- Reviewing only the changed lines and missing the absent check.
- Treating the scanner's diff-scoped output as the review (tools need human verification of exploitability).
- Applying one depth to every change, wasting effort on low-risk files and skimming auth code.
- Mixing style comments with security blockers.
- Flagging pre-existing issues as blockers of an unrelated change.

## How an agent should apply this

- Classify the file list by risk before reading; spend depth where the table says deep.
- Open callers, routes and middleware around each change; compare with a known-good sibling.
- Run the category checks only for the categories the diff touches; name the ones skipped.
- Report introduced versus pre-existing issues separately, each verified or marked not verified.
- Route exploitable-and-unfixed findings privately; keep pull request comments free of working exploit text.
- Escalate design-level changes to `threat-modeling`, and rate findings with `vulnerability-triage`.
