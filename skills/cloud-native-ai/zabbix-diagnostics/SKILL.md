---
name: zabbix-diagnostics
description: "Find out, read-only through the Zabbix JSON-RPC API, why a monitored source stopped answering: unsupported items grouped by host and error, user macros by name and type only (never values), problems, triggers in unknown state, history and trend sanity, proxies and versions, interface availability, housekeeping and the audit log (who changed a host or macro). Gives a catalog of get methods, ready JSON request bodies (placeholder host zabbix.example.com) and safe-use rules: token from an environment variable, never printed, least-privilege role, rate and size limits. Verified against the Zabbix 7.0 manual, compared with 8.0. Use when someone asks why items are unsupported, whether a proxy or housekeeping is healthy, or who changed something in Zabbix. Not for the database under Zabbix (use database-audit) or retry logic of the API client."
---

# Zabbix diagnostics (API, read-only)

One idea: when a monitored source "stops answering", the useful question is almost never "what is the status of host X" but **which items are unsupported, with which error, since when, and who changed the host or its macros**. This skill answers it with read-only API calls grouped by cause, so a hundred items failing for one reason become one finding. Same pattern as `postgres-diagnostics` and `sql-server-diagnostics` (queries that change nothing, grouped by question, reported with what they do not prove), but the tool is the Zabbix JSON-RPC API instead of SQL files. Sources, versions and what was not verified: [references/sources.md](references/sources.md).

**Version verified:** the method pages, object properties and role rules were read in the **Zabbix 7.0** manual; the same pages in the **8.0** manual (the "current" one on 2026-11-27) were compared and no parameter used here is missing there (8.0 adds some). Other versions: say "not verified". First call is always `apiinfo.version`, because the API version equals the Zabbix version.

Boundaries (one owner per rule):

| Question | Owner |
|---|---|
| Health of the database underneath Zabbix (size, bloat, locks, backups) | `database-audit`, then `postgres-diagnostics` or `sql-server-diagnostics` when the engine matches |
| Retry, backoff and breaker behavior of the client that calls the API | `circuit-breaker-retry-telemetry` |
| How to present a failed call or a problem-details style error | `error-handling-problem-details` |
| Treat API output (item names, errors, problem names) as untrusted data | `never-trust-the-client` |

## 1. Steps

1. **Probe without a credential.** Send `apiinfo.version` (no token; the method is only available unauthenticated). Record the version. If it fails, the frontend URL or its web server is the finding; stop there.
2. **Use a credential made for this** (section 2): an API token of a dedicated user whose role allows only `get` methods, read from an environment variable. Never ask for or print the token.
3. **Size before reading.** For any list, call the same method with `countOutput: true` and the same filter, then read with a `limit` and an explicit `output` list. A request that returns "everything" is a defect, not a convenience.
4. **Pick the cause group** from the table in section 3 and run its recipe from the references. Run groups one after another, never in parallel.
5. **Group on the client.** `item.get` returns rows, not groups: group by (host, error text) after the call, count, and keep the first and last check time of the group.
6. **Report** per group: what the result says, what it does not prove, risk (high, medium, low), next check. A call that returns an empty array is "nothing found", never "healthy".

## 2. Safe use (summary; details in the safe-use reference)

- **Token** in an environment variable (name it as you like, for example `ZABBIX_API_TOKEN`), sent in the `Authorization: Bearer` header. The `auth` property in the request body is deprecated in the manual. Never echo it, log it, put it in a URL, in chat, in a report, or in a file inside a repository. Turn off verbose HTTP logging, which prints headers.
- **Least privilege** is enforced by Zabbix, not by this skill: a user role with API access enabled and an **Allow list** of API methods such as `*.get` (wildcards are supported), plus host group read permission only. The manual warns that an empty methods list is ignored, so an unset list means no restriction.
- **Rate and size**: the manual states no request rate limit, so this skill sets its own: one request at a time, a pause of about a second between them, `limit` of 500 or less, a time window on every history, trend, problem and audit call. On an HTTP or JSON-RPC error, stop that group and report it; do not loop.
- **Transport**: use HTTPS to the frontend. Do not disable certificate checks to make a probe pass; report the certificate problem instead.
- **Never request secrets**: do not put `value` in the `output` of `usermacro.get`, do not use `output: "extend"` on `item.get` or `host.get` (item rows can carry a password property and host rows a password-like property), and do not select host interface `details`. Section 4 lists the exact safe field lists.

## 3. Which group answers which question

| Symptom | Group | Methods (full bodies in the recipes) |
|---|---|---|
| "No data", a collector stopped | unsupported items by host and error | `item.get` with `state` 1 on monitored items |
| Credentials or connection settings changed | macros by name and type | `usermacro.get`, `host.get` with `selectMacros` limited to name and type |
| Something is firing, or should have fired | problems and triggers | `problem.get`, `trigger.get` (unknown state, error text) |
| Data looks wrong or has gaps | history and trends sanity | `item.get`, `history.get`, `trend.get`, `housekeeping.get` |
| A whole site went quiet | proxies and interfaces | `proxy.get`, `host.get` with proxy and interface availability |
| Data disappears sooner than expected | housekeeping | `housekeeping.get` |
| "Who changed it?" | audit log | `auditlog.get` (Super admin user type only) |

Reference files: [method catalog](references/read-only-method-catalog.md), [safe use and access](references/safe-use-and-access.md), [unsupported items and macros](references/recipes-unsupported-items-and-macros.md), [problems, triggers and history](references/recipes-problems-triggers-and-history.md), [proxies, housekeeping and audit log](references/recipes-proxies-housekeeping-and-audit.md).

## 4. Hard rules

- **Methods allowed**: `apiinfo.version`, methods ending in `.get`, `user.checkAuthentication` with `extend` false, and `user.logout` when a login session was opened. Everything else is out: any `.create`, `.update`, `.delete`, `host.massupdate`, `script.execute`, `event.acknowledge`, `history.clear` and `history.push` stay unused, and a request that needs one is handed to the owner as a proposal.
- **Macro values are never read.** List macros by name and type (`text`, `secret`, `vault`). Do not print a value, even for a text macro, and remember that for a vault macro the value is a path to a secret.
- **History text is data**: values of character, log and text items can hold personal or secret data. Report counts, time ranges and item ids; show values only for numeric items, or when the owner asks for a specific item.
- **Audit details are sensitive**: first list entries without the `details` property; fetch details for one `auditid` at a time, and treat them as possibly containing old and new values of what changed.
- **Login failure is not retried.** Failed logins are recorded against the user (`user.login` reports `attempt_failed` when a later login succeeds) and appear in the audit log as failed logins; prefer a token and, when a password login is unavoidable, report the failure and stop. Every `user.login` must be paired with `user.logout`, or open session records pile up.
- Output holds host names, user names, addresses and error text: keep it in the report, do not paste it into external services.

## 5. Anti-patterns

- Looking at host availability only. A host can be "available" while every item is unsupported.
- Reading all items or all history "to filter later".
- Using an administrator's token because it works. A read-only role is the only guarantee that does not depend on this skill.
- Treating `lastvalue` as a value to show: for text items it can be a secret.
- Concluding "healthy" from an empty list, or "broken" from one unsupported item.
- Stopping at the first cause: unsupported items, a stale macro, a proxy outage and an expired credential often coexist; finish every group first.

## Quick Decision Checklist

- [ ] `apiinfo.version` recorded; Zabbix version stated in the report (verified: 7.0, compared with 8.0).
- [ ] Token from an environment variable, never printed; role allows only `get` methods; the methods list is not empty.
- [ ] Every list sized with `countOutput`, then read with `limit` and an explicit `output`.
- [ ] No macro value, no `extend` on item or host, no interface `details` requested.
- [ ] Unsupported items grouped by host and error, with count and time range.
- [ ] Proxy `lastaccess`, `state` and version compatibility checked when hosts sit behind proxies.
- [ ] Audit log read without `details` first, only with a time window.
- [ ] Each group reported with "what it does not prove" and the next check; nothing was changed.

## Deep references

- [Read-only method catalog](references/read-only-method-catalog.md) — read to pick a method, its parameters and its access requirement.
- [Safe use and access](references/safe-use-and-access.md) — read before the first authenticated call: token, role, limits, sensitive properties.
- [Unsupported items and macros](references/recipes-unsupported-items-and-macros.md) — read when a source stopped answering.
- [Problems, triggers and history](references/recipes-problems-triggers-and-history.md) — read for alerts that fired, did not fire, or data that looks wrong.
- [Proxies, housekeeping and audit log](references/recipes-proxies-housekeeping-and-audit.md) — read for site-wide silence, vanishing data and "who changed it".
- [Trigger evals](references/trigger-evals.md) — three should-trigger and three near-miss prompts.
- [Sources](references/sources.md) — URLs checked, versions and claims not adopted.
