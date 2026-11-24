# Recipes: Proxies, Housekeeping and Audit Log

Sources: https://www.zabbix.com/documentation/7.0/en/manual/api/reference/proxy/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/proxy/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/housekeeping/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/housekeeping/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/auditlog/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/auditlog/object, https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/administration/housekeeping, https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/administration/audit_log, https://www.zabbix.com/documentation/7.0/en/manual/web_interface/frontend_sections/reports/audit_log · Last verified 2026-11-24 (Zabbix 7.0, parameters compared with 8.0)

Request bodies for `https://zabbix.example.com/api_jsonrpc.php` with `Authorization: Bearer ${ZABBIX_API_TOKEN}`. Placeholders: proxy id `10300`, time `1764000000`. Examples to adapt, not scripts; rules in `safe-use-and-access.md`.

## Proxies

Proxy object (7.0): `proxyid`, `name`, `operating_mode` (0 active, 1 passive), `lastaccess` (last time the proxy connected to the server), `state` (0 unknown, 1 offline, 2 online), `version` (a number with two digits per part: 70002 means 7.0.2; 0 unknown), `compatibility` (0 undefined, 1 current, 2 outdated but partially supported, 3 unsupported), `proxy_groupid` (0 when not in a group). The 8.0 proxy page adds a `selectApm` parameter; nothing used here was removed.

All proxies with their state and how many hosts they carry:

```json
{
  "jsonrpc": "2.0",
  "method": "proxy.get",
  "params": {
    "output": ["proxyid", "name", "operating_mode", "lastaccess", "state", "version", "compatibility", "proxy_groupid"],
    "selectHosts": "count",
    "sortfield": "name"
  },
  "id": 1
}
```

The output list is explicit and holds no TLS or address fields, because none are needed for the diagnosis.

Items unsupported behind one proxy, as a count then by host (reuse the unsupported-items recipes with `proxyids`):

```json
{
  "jsonrpc": "2.0",
  "method": "item.get",
  "params": { "countOutput": true, "monitored": true, "proxyids": ["10300"], "filter": { "state": 1 } },
  "id": 2
}
```

Hosts a proxy monitors:

```json
{
  "jsonrpc": "2.0",
  "method": "host.get",
  "params": {
    "output": ["hostid", "host", "status", "maintenance_status"],
    "proxyids": ["10300"],
    "monitored_hosts": true,
    "limit": 500
  },
  "id": 3
}
```

Reading it (own interpretation): a proxy with `state` 1 or an old `lastaccess` explains every unsupported item behind it with one finding; a proxy online but with `compatibility` 2 or 3 is a version problem worth reporting even when data flows; many hosts and items unsupported on one proxy only, while others are fine, points at that proxy or its network path. Compare `lastaccess` with the current time you obtained from the server host or your own clock and state which you used. Proxy outage tolerance depends on the proxy buffer settings in its configuration file (the manual's proxy pages mention an offline buffer parameter), which the API does not expose, so ask the owner when data is missing after an outage.

## Housekeeping

The housekeeper is a server process that periodically deletes outdated data and data removed by users; per the manual it runs hourly by default, and its frequency is a server configuration parameter (not visible through the API). The API object holds the retention settings:

```json
{
  "jsonrpc": "2.0",
  "method": "housekeeping.get",
  "params": {
    "output": [
      "hk_events_mode", "hk_events_trigger", "hk_events_internal", "hk_events_discovery", "hk_events_autoreg",
      "hk_services_mode", "hk_services",
      "hk_audit_mode", "hk_audit",
      "hk_sessions_mode", "hk_sessions",
      "hk_history_mode", "hk_history_global", "hk_history",
      "hk_trends_mode", "hk_trends_global", "hk_trends",
      "db_extension", "compression_availability", "compression_status", "compress_older"
    ]
  },
  "id": 4
}
```

The result is one object, not an array. Defaults on the object page: trigger events 365 days; internal, discovery, autoregistration and service events 1 day; services 365 days; audit 31 days; sessions 365 days; history 31 days; trends 365 days; modes enabled by default; the "override item history period" and "override item trend period" options enabled by default.

Reading it:

| Observation | Meaning | Check next |
|---|---|---|
| `hk_history_global` 1 | the global history period replaces each item's own `history` setting | compare `hk_history` with what the owner expects; items cannot keep longer |
| `hk_history_mode` 0 | the internal housekeeper does not delete history | an external process is expected to; confirm who |
| `hk_events_internal` is 1 day | internal events (including "item became unsupported") are kept only a day | "since when" questions need the audit log or other records beyond that |
| `hk_audit_mode` 1 and `hk_audit` 31 days | audit entries older than the period are deleted | an audit question about an older change cannot be answered here |
| `db_extension` is `timescaledb` | partitioned storage; the manual says outdated partitions are dropped only if the override and internal-housekeeping options for history and trends are enabled, otherwise warnings about incorrect configuration appear | confirm the options are on |
| `compression_status` 1 and `compress_older` | compression of history and trends older than that period (TimescaleDB) | database side: `database-audit` |

Database growth, table sizes, bloat and locks of the Zabbix backend are outside the API: hand them to `database-audit`, and to `postgres-diagnostics` or `sql-server-diagnostics` if the backend engine is one of those. Do not read the Zabbix database directly from this skill.

## Audit log

`auditlog.get` is available to the **Super admin** user type only (and a role may still revoke it). It records user and system actions. Audit logging can be turned off in the frontend (then nothing is recorded), "log system actions" controls whether discovery and autoregistration by the server are logged, and entries older than `hk_audit` days are removed. Data sent to trapper items shows in the audit log only when sent through the `history.push` method, not through the sender utility.

Object properties: `auditid`, `userid`, `username`, `clock`, `ip`, `action` (0 add, 1 update, 2 delete, 4 logout, 7 execute, 8 login, 9 failed login, 10 history clear, 11 config refresh, 12 push), `resourcetype` (examples: 0 user, 4 host, 13 trigger, 15 item, 26 proxy, 29 macro, 30 template, 41 housekeeping, 42 authentication, 45 API token), `resourceid`, `resourcename`, `recordsetid` (shared by all records created by one operation), `details`.

Changes to hosts and macros in a window, **without details**:

```json
{
  "jsonrpc": "2.0",
  "method": "auditlog.get",
  "params": {
    "output": ["auditid", "clock", "username", "ip", "action", "resourcetype", "resourceid", "resourcename", "recordsetid"],
    "filter": { "resourcetype": [4, 29], "action": [0, 1, 2] },
    "time_from": 1763400000,
    "time_till": 1764000000,
    "sortfield": "clock",
    "sortorder": "DESC",
    "limit": 200
  },
  "id": 5
}
```

Failed logins and logins in a window (shows credential trouble on the Zabbix side itself):

```json
{
  "jsonrpc": "2.0",
  "method": "auditlog.get",
  "params": {
    "output": ["auditid", "clock", "username", "ip", "action"],
    "filter": { "action": [8, 9] },
    "time_from": 1763400000,
    "sortfield": "clock",
    "sortorder": "DESC",
    "limit": 200
  },
  "id": 6
}
```

Details of one record, only after the owner agrees that old and new values may be read:

```json
{
  "jsonrpc": "2.0",
  "method": "auditlog.get",
  "params": { "auditids": ["<one auditid from the list>"], "output": ["auditid", "clock", "resourcename", "details"] },
  "id": 7
}
```

`details` is JSON text: each property path maps to an array such as `["update", "<new value>", "<old value>"]`, `["add"]` or `["delete"]`. The manual does not say whether secret macro values are masked in it, so treat details as possibly containing values and do not paste them anywhere.

Reading it: group by `recordsetid` (one operation, many rows) and by `username` plus `ip`. A change to a host or its macros shortly before items turned unsupported (compare with the first internal event or the first `lastclock` gap) is a strong lead, not proof of cause. Entries made by the "System" user are server activity (discovery, autoregistration).

## How an agent should apply this

- Check proxies whenever hosts sit behind one; a proxy finding often explains a whole site in one line.
- Read `housekeeping.get` before judging "missing" old data; retention explains many gaps.
- Use the audit log last, with a time window set from what the earlier groups found, and without `details` first.
- Say which window the audit log can cover (`hk_audit`) and whether audit logging is enabled; do not claim "nobody changed it" from an empty result.
- Hand database health questions to the database skills; this skill never connects to the Zabbix database.
