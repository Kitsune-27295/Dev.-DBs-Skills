# Sources — Zabbix Diagnostics

Every URL below was checked during skill authoring (2026-11-24) and re-checked on 2026-11-27 (rebuild pass).

Retrieval used `curl`; pages were converted to text and read (Firecrawl had no credits). "200 OK" means the page returned content. Version of the manual read: **Zabbix 7.0** (all method, object and manual pages below). For the methods used by this skill the same pages of the **8.0** manual (labeled "current" on that date) were fetched and their parameter names compared with 7.0: no parameter used here is missing in 8.0; the differences found were additions (`maxValueSize` on `history.get`, `selectApm` on `proxy.get`, `selectDiscoveryData` and inherited-tag parameters on some methods). No other Zabbix version was read; behavior on 6.0, 7.2, 7.4 and others is **not verified**.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.zabbix.com/documentation/7.0/en/manual/api | 200 OK (whole page read) | JSON-RPC structure, request shape and content types, authentication (API token or `user.login`), Authorization header, deprecated `auth` property, error object, API version equals Zabbix version, advice to list `output` properties |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference_commentary | 200 OK (data types, behavior labels and common get parameters read) | `countOutput`, `editable`, `filter`, `limit`, `output`, `search`, `sortfield`, `sortorder` and the other common parameters; values returned as strings; `query` type |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/apiinfo/version | 200 OK | `apiinfo.version` is unauthenticated and takes an empty array |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/user/login | 200 OK | login parameters, `userData`, need for `user.logout`, failed-attempt counters, unavailable for MFA groups |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/user/logout | 200 OK | logout invalidates the token |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/user/checkauthentication | 200 OK | `token`, `sessionid`, `extend`, returned user `type` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/host/get | 200 OK (parameters read) | `monitored_hosts`, `proxyids`, `selectInterfaces`, `selectMacros`, `selectParentTemplates`, `with_monitored_items`, `severities` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/host/object | 200 OK | `monitored_by`, `proxyid`, `status`, `maintenance_status`, `active_available`, `ipmi_password` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/hostinterface/get | 200 OK | `hostids`, `selectItems`, `sortfield` values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/hostinterface/object | 200 OK | `available`, `error`, `errors_from`, `disable_until`, `details` carrying SNMP community and passphrases |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/item/get | 200 OK (parameters and examples read) | `monitored`, `filter`, `proxyids`, `selectHosts`, `sortfield` values, `countOutput`, example item rows (include a `password` property) |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/item/object | 200 OK | `state`, `status`, `error`, `lastclock`, `value_type`, `history`, `trends`, `delay`, `flags`, `password` and `ssl_key_password` without a write-only mark |
| https://www.zabbix.com/documentation/7.0/en/manual/config/items/item | 200 OK (unsupported items section read) | meaning of not supported, recheck at normal interval, state changes only on new data |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/usermacro/get | 200 OK | `globalmacro`, `hostids`, `groupids`, `sortfield` `macro` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/usermacro/object | 200 OK | macro `type` 0, 1, 2; `value` write-only only for secret macros; `automatic` |
| https://www.zabbix.com/documentation/7.0/en/manual/config/macros/user_macros | 200 OK (value types section read) | text, secret text and vault secret types; 2048-character value limit |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/problem/get | 200 OK | `recent`, `severities`, `suppressed`, `eventid_from`, `time_from`; only unresolved unless `recent`; `event.get` for older |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/problem/object | 200 OK | problem properties and severity values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/event/get | 200 OK (parameters read) | `source`, `object`, `value`, `time_from`, `groupBy` (value `objectid`), `sortfield` values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/event/object | 200 OK | internal-event values (1 means unknown or not supported), source and object types |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trigger/get | 200 OK (parameters read) | `monitored`, `only_true`, `min_severity`, `selectItems`, `expandDescription`, `filter`, `sortfield` values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trigger/object | 200 OK | `value`, `state`, `error`, `status`, `priority`, `lastchange` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/history/get | 200 OK | `history` value types, `itemids`, `time_from`, `time_till`, `sortfield`, retention note |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/history/object | 200 OK | history object shapes by value type |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trend/get | 200 OK | `itemids`, `time_from`, `time_till`, `output`, `countOutput` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trend/object | 200 OK | `clock`, `num`, `value_min`, `value_avg`, `value_max` |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/proxy/get | 200 OK | `proxyids`, `proxy_groupids`, `selectHosts` (count), `sortfield` values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/proxy/object | 200 OK | `state`, `lastaccess`, `version`, `compatibility`, `operating_mode`, `proxy_groupid` |
| https://www.zabbix.com/documentation/7.0/en/manual/distributed_monitoring/proxies | 200 OK (searched for offline and buffer statements only) | mention of an offline buffer parameter in the proxy configuration |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/housekeeping/get | 200 OK | only `output`; returns one object |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/housekeeping/object | 200 OK | retention properties and their defaults, TimescaleDB flags |
| https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/administration/housekeeping | 200 OK | housekeeper is a periodic server process, hourly by default, frequency set by a server parameter |
| https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/administration/audit_log | 200 OK | enable audit logging, log system actions, audit housekeeping period (31 days default) |
| https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/reports/audit_log | 200 OK | columns, recordset id, `history.push` caveat for trapper data, filter by IP since 7.0.4 |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/auditlog/get | 200 OK | Super admin only, parameters, sort fields |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/auditlog/object | 200 OK | action and resource type codes, `details` format |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/role/get | 200 OK | `roleids`, `selectRules`, `sortfield` values |
| https://www.zabbix.com/documentation/7.0/en/manual/api/reference/role/object | 200 OK (type and readonly properties read) | user types 1 User, 2 Admin, 3 Super admin |
| https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/users/user_roles | 200 OK (API access rows read) | API access switch, Allow and Deny lists of methods, wildcard examples, empty list is ignored, per-action rights tied to create, update and delete methods |
| https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/users/api_tokens | 200 OK | token per user, inherits permissions, shown once, expiry, regenerate when exposed |
| https://www.zabbix.com/documentation/8.0/en/manual/api/reference/item/get (and the same path for usermacro/get, problem/get, event/get, trigger/get, history/get, trend/get, proxy/get, housekeeping/get, auditlog/get, host/get, role/get, user/login, apiinfo/version) | 200 OK for each page fetched; parameter names compared with the 7.0 pages | no parameter used here is missing in 8.0; additions only |
| https://www.zabbix.com/documentation/7.0/en/manual/api/changes_7.0_-_7.2 | 404 (not found) | nothing; the API changelog was not read |
| Internal project skill read for the idea of grouped read-only diagnostics | read locally, no text reused | only the idea (group unsupported items by host and error, list macros by name, check problems, triggers, history and audit read-only); no address, host name, command, file name, convention or role setting was taken |

## Re-verification 2026-11-27

Re-fetched with a fetch tool (extracted text): api overview, apiinfo/version, user/login, user_roles, api_tokens, user_macros, usermacro/object, item/object, proxy/object, housekeeping/object and the frontend housekeeping page, audit_log frontend page, auditlog/get, problem/get, and the 8.0 item/get page (labeled "8.0 (current)"). All 200 OK. Confirmed: Bearer header (it also applies to tokens from `user.login`); `auth` deprecated; API version matches Zabbix version since 2.0.4; `apiinfo.version` only for unauthenticated calls; empty Allow/Deny list is ignored, wildcards supported; macro types 0/1/2 with `value` write-only only for type 1; 2048-character macro limit; item `password` is not write-only (read-only for inherited or discovered); proxy `state`, `compatibility` and `version` encoding; housekeeping defaults (including services 365d, sessions 365d, audit 31d) and the hourly default run with `HousekeepingFrequency`; audit log Super admin only; `problem.get` returns unresolved only unless `recent`. Corrections: none that change a rule. Not re-fetched this pass: the other method and object pages, the 8.0 pages other than item/get, and the changelog page.

## Reading limits

- Request bodies, scripts and SQL-like examples were not run or re-verified.

- Method pages were read for parameters, return values and object properties; the many worked examples on them were skimmed.
- The long frontend user-role and audit-log pages were read in the parts that concern API access and the audit columns.
- Nothing was run against a live Zabbix server: request bodies are built from the documentation and have not been executed. Treat them as documented shapes, and test against a non-production instance first.
- The list of methods in the manual's API navigation (for 7.0) was used to confirm that every method name in the skill exists.

## Claims not adopted as fact

- The manual states no API request rate limit in the pages read; the rate, size and pacing limits in this skill are the author's conservative choices, labeled "(own)".
- Whether secret macro values are masked inside audit log `details` is not stated on the pages read; the skill treats details as sensitive.
- Interpretation tables (what an error pattern "usually means", what a proxy state suggests) are the author's inference, labeled as such, not statements from the manual.
- The claim that a trigger on unsupported items reports "unknown" was not confirmed from the pages read; the skill says "unproven".
- Which user type is needed to call each `get` method beyond `auditlog.get` (Super admin) was not enumerated; pages state "available to users of any type" unless a role revokes it.
