# Recipes: Problems, Triggers and History

Sources: https://www.zabbix.com/documentation/7.0/en/manual/api/reference/problem/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/problem/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/event/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/event/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trigger/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trigger/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/history/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/history/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trend/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/trend/object · Last verified 2026-11-24 (Zabbix 7.0, parameters compared with 8.0)

Request bodies to send to `https://zabbix.example.com/api_jsonrpc.php` with `Authorization: Bearer ${ZABBIX_API_TOKEN}`. Placeholders: item id `42269`, host id `10084`, a Unix time such as `1764000000`. Examples to adapt, not scripts. Safe-use rules: `safe-use-and-access.md`.

## Problems

`problem.get` returns unresolved problems; with `recent: true` it also returns problems resolved within the "recent" period set in the frontend's general administration settings. Problems resolved before that period are no longer in the problem table; use `event.get` for them. Problem properties: `eventid`, `objectid` (the trigger id for trigger problems), `clock`, `r_eventid`, `r_clock`, `name` (resolved problem name), `acknowledged`, `severity` (0 not classified to 5 disaster), `suppressed`, `opdata`.

Count high and disaster problems:

```json
{ "jsonrpc": "2.0", "method": "problem.get",
  "params": { "countOutput": true, "severities": [4, 5] }, "id": 1 }
```

Read the newest unresolved problems of one host:

```json
{
  "jsonrpc": "2.0",
  "method": "problem.get",
  "params": {
    "output": ["eventid", "objectid", "clock", "name", "severity", "acknowledged", "suppressed"],
    "hostids": ["10084"],
    "recent": false,
    "sortfield": "eventid",
    "sortorder": "DESC",
    "limit": 100
  },
  "id": 2
}
```

Reading it: many problems with the same `name` pattern across hosts is one cause. `suppressed` 1 means the problem is hidden by maintenance or manual suppression, which explains silent alerting. A burst of problems with `clock` close together points at a shared dependency (a proxy, a network segment). The absence of a problem does not prove health: a trigger that cannot evaluate raises none (see triggers).

## Events (when something ended or began in the past)

Internal events record state changes of objects. For `source` 3 (internal event), `object` 4 means an item and `value` 1 means the "unknown or not supported" state, so these events date **when items became unsupported**, within the retention for internal events (the housekeeping object's `hk_events_internal`, default 1 day; read it with `housekeeping.get` in the platform recipes):

```json
{
  "jsonrpc": "2.0",
  "method": "event.get",
  "params": {
    "output": ["eventid", "objectid", "clock", "name", "value", "r_eventid"],
    "source": 3,
    "object": 4,
    "value": 1,
    "hostids": ["10084"],
    "time_from": 1764000000,
    "time_till": 1764086400,
    "sortfield": "eventid",
    "sortorder": "DESC",
    "limit": 200
  },
  "id": 3
}
```

Trigger problem history works the same with `source` 0, `object` 0 and `value` 1. Keep the time window narrow; the events table is large. `event.get` accepts `sortfield` values `eventid`, `objectid` and `clock`.

A flapping trigger shows up as one object with a huge event count. `event.get` supports `groupBy` with `objectid` (its only documented value), combined with `countOutput`:

```json
{
  "jsonrpc": "2.0",
  "method": "event.get",
  "params": {
    "countOutput": true,
    "groupBy": "objectid",
    "source": 0,
    "object": 0,
    "value": 1,
    "time_from": 1763400000,
    "time_till": 1764000000,
    "sortfield": "rowscount",
    "sortorder": "DESC",
    "limit": 20
  },
  "id": 31
}
```

(The `rowscount` sort value is documented for `countOutput` together with `groupBy`.) Resolve the top `objectid` values (trigger ids) with `trigger.get` and `triggerids`.

## Triggers

Trigger properties: `value` 0 OK, 1 problem; `state` 0 up to date, 1 unknown; `error` text when the state could not be updated; `status` 0 enabled, 1 disabled; `priority` 0 to 5; `lastchange`.

Triggers in unknown state, with the reason:

```json
{
  "jsonrpc": "2.0",
  "method": "trigger.get",
  "params": {
    "output": ["triggerid", "description", "priority", "value", "state", "error", "lastchange", "status"],
    "selectHosts": ["hostid", "host"],
    "monitored": true,
    "expandDescription": true,
    "filter": { "state": 1 },
    "sortfield": "lastchange",
    "sortorder": "DESC",
    "limit": 200
  },
  "id": 4
}
```

Triggers firing now, most severe first (client-side sort; the `sortfield` list has `priority`):

```json
{
  "jsonrpc": "2.0",
  "method": "trigger.get",
  "params": {
    "output": ["triggerid", "description", "priority", "lastchange"],
    "selectHosts": ["host"],
    "monitored": true,
    "expandDescription": true,
    "filter": { "value": 1 },
    "min_severity": 3,
    "sortfield": "priority",
    "sortorder": "DESC",
    "limit": 100
  },
  "id": 5
}
```

Triggers of a host that depend on unsupported items (the cause of silence):

```json
{
  "jsonrpc": "2.0",
  "method": "trigger.get",
  "params": {
    "output": ["triggerid", "description", "value", "state", "error"],
    "hostids": ["10084"],
    "selectItems": ["itemid", "name", "key_", "state"],
    "monitored": true,
    "expandDescription": true,
    "limit": 200
  },
  "id": 6
}
```

Reading it: group `error` texts the same way as item errors. A trigger whose items are all in state 1 cannot confirm either a problem or a recovery from new data, because items and triggers change state only when new data arrives (item manual). Whether a given expression reports "unknown" depends on its functions; treat "no problem raised" as unproven (own).

## History and trends sanity

First learn the item's value type, retention and update interval (explicit fields; never `extend`, never `lastvalue`):

```json
{
  "jsonrpc": "2.0",
  "method": "item.get",
  "params": {
    "output": ["itemid", "name", "key_", "value_type", "delay", "history", "trends", "state", "status", "lastclock", "error"],
    "itemids": ["42269"]
  },
  "id": 7
}
```

`value_type`: 0 float, 1 character, 2 log, 3 unsigned, 4 text, 5 binary. `history` and `trends` are storage periods (defaults 31d and 365d in the object page; trends apply to numeric types only). A global override in housekeeping can replace these per-item periods (see platform recipes). `lastclock` is shown only for values within the "max history display period" (24 hours by default), so `0` does not mean "never collected".

Count values in a window (density):

```json
{
  "jsonrpc": "2.0",
  "method": "history.get",
  "params": {
    "history": 0,
    "itemids": ["42269"],
    "time_from": 1764000000,
    "time_till": 1764003600,
    "countOutput": true
  },
  "id": 8
}
```

`history` must match the item's `value_type`; the default is 3, so a float item queried without `history` returns nothing and looks like a gap. Compare the count with what the `delay` implies (a 1-minute item should give about 60 an hour; not applicable when `delay` is a macro or has custom intervals).

Read the newest few values (numeric items only):

```json
{
  "jsonrpc": "2.0",
  "method": "history.get",
  "params": {
    "history": 0,
    "itemids": ["42269"],
    "output": ["itemid", "clock", "value"],
    "time_from": 1764000000,
    "sortfield": "clock",
    "sortorder": "DESC",
    "limit": 5
  },
  "id": 9
}
```

Hourly trends:

```json
{
  "jsonrpc": "2.0",
  "method": "trend.get",
  "params": {
    "itemids": ["42269"],
    "output": ["itemid", "clock", "num", "value_min", "value_avg", "value_max"],
    "time_from": 1763400000,
    "time_till": 1764000000,
    "limit": 200
  },
  "id": 10
}
```

`num` is how many values existed in that hour: a low `num` in a run of hours is a collection gap even when averages look normal.

Reading it (own interpretation): no history but trends present means history was housekept before the window you asked for, which is retention, not an outage; no history and no trends inside the retention means no values arrived (return to unsupported items); values present but wrong is a value-path question, handed to `cross-layer-value-trace`. Show the values exactly as the API returns them, without rounding. Print values only for numeric items; for character, log and text items report counts and times.

## How an agent should apply this

- Start from counts: problems by severity, triggers in state 1, then rows for the biggest group only.
- Date the beginning of a failure with internal events when retention allows, and say when retention does not reach back.
- Always pass the item's own `value_type` as `history`; an empty result with the wrong type is a false gap.
- Distinguish retention (history older than the item's `history` period) from collection gaps (missing values inside it) before calling anything an outage.
- Report "nothing found" for empty results and state the window and filters used.
