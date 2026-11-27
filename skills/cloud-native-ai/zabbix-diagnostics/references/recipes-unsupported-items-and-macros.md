# Recipes: Unsupported Items and Macros

Sources: https://www.zabbix.com/documentation/7.0/en/manual/api/reference/item/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/item/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/usermacro/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/usermacro/object, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/host/get, https://www.zabbix.com/documentation/7.0/en/manual/api/reference/hostinterface/object, https://www.zabbix.com/documentation/7.0/en/manual/config/items/item · Last verified 2026-11-27 (Zabbix 7.0, parameters compared with 8.0)

Text recipes: JSON-RPC request bodies to send to `https://zabbix.example.com/api_jsonrpc.php` with the header `Authorization: Bearer ${ZABBIX_API_TOKEN}`. They are examples to copy and adapt, not scripts. Ids such as `10084` are placeholders. Parameter names come from the method pages; reading rules are in `safe-use-and-access.md`.

## What "unsupported" means (item manual and object page)

An item becomes **not supported** when its value cannot be retrieved (a connection error, no poller configured for it, partial data). It stays not supported and is still rechecked at its normal interval until it receives new valid data. Items and triggers change state only when new data arrives (triggers with date or `nodata()` functions are recalculated every 30 seconds). In the item object: `state` 0 normal, 1 not supported; `status` 0 enabled, 1 disabled; `error` is the error text for failures updating the value. So "unsupported" is a **state**, and the cause is the `error` text.

## Recipe 1: how many unsupported items (size first)

```json
{
  "jsonrpc": "2.0",
  "method": "item.get",
  "params": {
    "countOutput": true,
    "monitored": true,
    "filter": { "state": 1 }
  },
  "id": 1
}
```

`monitored: true` returns only enabled items on monitored hosts, so disabled hosts and template items do not inflate the number. The result is a string such as `"129"`.

## Recipe 2: the unsupported items with their error, host and last check

```json
{
  "jsonrpc": "2.0",
  "method": "item.get",
  "params": {
    "output": ["itemid", "name", "key_", "type", "flags", "state", "error", "lastclock", "interfaceid"],
    "selectHosts": ["hostid", "host"],
    "monitored": true,
    "filter": { "state": 1 },
    "sortfield": "itemid",
    "limit": 500
  },
  "id": 2
}
```

Why these fields only: item rows can also carry `password` and `ssl_key_password` (not marked write-only in the object page), so `output` is an explicit list and never `extend`. Do not add `lastvalue`.

**Group on the client** (the API has no group-by): key = (host, `error` text). For each group keep the item count, the number of distinct item keys, the smallest and largest `lastclock`, and up to three example keys. A hundred items with one error is one finding. Strip volatile parts of the text (ids, numbers, timestamps) before grouping if the same cause renders slightly different messages (own). `item.get` has no offset parameter on its page, so when the count from recipe 1 exceeds the limit, narrow by `groupids`, `hostids` or `proxyids` and run it once per slice instead of paging blindly.

Reading the groups (own interpretation, each with what it does not prove):

| Error pattern | Usually means | Next check | Does not prove |
|---|---|---|---|
| connection refused, timeout, no route | network or service down, or wrong address in the interface | recipe 5 (interface availability), proxy state | that the service itself is down; the proxy or firewall may be |
| authentication failed, access denied, login failed | credential or macro changed or expired | recipe 4 (macro names), audit log for the host | which side holds the wrong value; do not read the value |
| unknown metric, unsupported item key | key not supported by the agent version or plugin | agent version, template version | that the template is wrong |
| received value is not suitable for the value type | wrong type or preprocessing on the item | the item's `value_type` and preprocessing | the source's fault |
| no data and nothing else | item never received a value, or the collector is stopped | proxy `lastaccess`, `lastclock` of siblings | which component stopped |

## Recipe 3: unsupported items of one host

Same as recipe 2 with `"hostids": ["10084"]` instead of the global scan, and no `limit` change. Use it after recipe 2 points at one host.

## Recipe 4: macros by name and type only

Host-level macros of one host (never include `value`):

```json
{
  "jsonrpc": "2.0",
  "method": "usermacro.get",
  "params": {
    "output": ["hostmacroid", "hostid", "macro", "type", "automatic"],
    "hostids": ["10084"],
    "sortfield": "macro"
  },
  "id": 4
}
```

Global macros:

```json
{
  "jsonrpc": "2.0",
  "method": "usermacro.get",
  "params": {
    "globalmacro": true,
    "output": ["globalmacroid", "macro", "type"],
    "sortfield": "macro"
  },
  "id": 5
}
```

The same through the host, limited to name and type:

```json
{
  "jsonrpc": "2.0",
  "method": "host.get",
  "params": {
    "output": ["hostid", "host"],
    "hostids": ["10084"],
    "selectMacros": ["macro", "type"],
    "selectParentTemplates": ["templateid", "name"]
  },
  "id": 6
}
```

Macro `type`: 0 text, 1 secret text, 2 vault secret. For a vault macro the value is a path or query to the vault, still not to be printed. `automatic` 1 means a discovery rule manages the macro.

What to look for on the client (own): macro names that appear on some hosts of a group but not others (a missing override), names used in the failing items' keys or parameters that have no definition on the host or its templates, and a macro that changed type. Report names and types; say "value not read" explicitly. Whether the value is right is a question for the owner, who can compare it with the account that exists on the monitored system.

## Recipe 5: host and interface availability, and who monitors it

```json
{
  "jsonrpc": "2.0",
  "method": "host.get",
  "params": {
    "output": ["hostid", "host", "name", "status", "monitored_by", "proxyid", "maintenance_status", "active_available"],
    "selectInterfaces": ["interfaceid", "type", "ip", "dns", "port", "available", "error", "errors_from", "disable_until"],
    "monitored_hosts": true,
    "hostids": ["10084"]
  },
  "id": 7
}
```

Do not add `details` to `selectInterfaces`: the SNMP details object holds community strings and passphrases. Interface `available`: 0 unknown, 1 available, 2 unavailable; `error` is the text for an unavailable interface; `errors_from` is when it became unavailable; `disable_until` is the next polling time of an unavailable interface. `active_available` is the availability of the host's active interface (0 unknown, 1 available, 2 not available).

Reading it: an interface unavailable since `errors_from` explains items failing from that moment; an available interface with all items unsupported points at the item level (credentials, keys, permissions), not the network.

## How an agent should apply this

- Run recipe 1 first. A count of zero stops the group with "nothing found" (never "healthy"); a very large count means narrow by group or proxy before reading rows.
- Group by (host, error) on the client, then report the group, the number of items, and the time range from `lastclock`; one group is one finding.
- Cross the top group with recipe 4 and recipe 5 for the same host before naming a cause, and name it as "most likely", with what remains unproven.
- List macros by name and type only; if the cause looks like a stale credential, hand the owner the macro name to check, not its value.
- Never widen `output` to `extend` to "see more"; ask for the specific property you need.
