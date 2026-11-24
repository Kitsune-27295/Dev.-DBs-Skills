# Read-Only Method Catalog

Sources: https://www.zabbix.com/documentation/7.0/en/manual/api, https://www.zabbix.com/documentation/7.0/en/manual/api/reference_commentary and the 7.0 method and object pages named in the table · Last verified 2026-11-24 (Zabbix 7.0, parameters compared with 8.0)

Every method below is a `.get` method (or a documented read-like helper) whose page was read. Request shape (from the API overview): HTTP POST to `api_jsonrpc.php` in the frontend directory, `Content-Type` of `application/json-rpc`, `application/json` or `application/jsonrequest`, body with `jsonrpc` "2.0", `method`, `params` and `id`. Credentials go in the `Authorization: Bearer <token>` header. Example host in this skill: `https://zabbix.example.com/api_jsonrpc.php`.

## Parameters every `get` method accepts

From the reference commentary: `countOutput` (return only the number of records), `editable` (only objects the user may write; default false), `excludeSearch`, `filter` (exact match on object properties; not supported for properties of data type text), `limit`, `output` (list of property names or `extend`; the object id is always returned), `preservekeys`, `search` (case-insensitive substring on string and text properties), `searchByAny`, `searchWildcardsEnabled`, `sortfield`, `sortorder` (`ASC` or `DESC`), `startSearch`. Each method documents which `sortfield` values it accepts. All values come back as strings or arrays. A `query`-typed parameter (such as `output` or a `select...` parameter) accepts an array of property names, so a subselect can be limited to chosen fields.

## Methods used by this skill

| Method | Purpose here | Parameters used (all read on the method page) | Notes |
|---|---|---|---|
| `apiinfo.version` | version of the API, equal to the Zabbix version | `params` is an empty array | unauthenticated only; call it without a token |
| `user.checkAuthentication` | confirm a token works and learn the user type | `token` (API token), or `sessionid` plus `extend` (false to avoid prolonging the session) | returns user properties and `type` (1 User, 2 Admin, 3 Super admin); the token travels in the body, so never log the body |
| `user.login` / `user.logout` | session login and its mandatory logout | login takes `username`, `password` and optional `userData` | prefer a token; pair every login with a logout or session records accumulate; login must be called without the `auth` parameter |
| `host.get` | hosts, interfaces, proxy assignment, macro names | `hostids`, `proxyids`, `groupids`, `monitored_hosts`, `with_monitored_items`, `selectInterfaces`, `selectMacros`, `selectParentTemplates`, `filter`, `search`, `limit`, `output` | host properties used: `host`, `name`, `status` (0 enabled, 1 disabled), `monitored_by` (0 server, 1 proxy, 2 proxy group), `proxyid`, `maintenance_status`, `active_available` |
| `hostinterface.get` | interface availability and error | `hostids`, `interfaceids`, `limit`, `output` | interface `available` 0 unknown, 1 available, 2 unavailable; `error`, `errors_from`, `disable_until` |
| `item.get` | items, their state and error, history and trend periods | `hostids`, `proxyids`, `monitored`, `filter`, `search`, `selectHosts`, `selectDiscoveryRule`, `limit`, `sortfield` (`itemid`, `name`, `key_`, `delay`, `history`, `trends`, `type`, `status`), `countOutput`, `output` | item `state` 0 normal, 1 not supported; `status` 0 enabled, 1 disabled; `error` text; `lastclock`; `value_type` 0 float, 1 character, 2 log, 3 unsigned, 4 text, 5 binary; `flags` 0 plain, 4 discovered |
| `usermacro.get` | host and global macros | `hostids`, `groupids`, `globalmacro` (flag for global macros), `sortfield` (`macro`), `output` | macro `type` 0 text, 1 secret, 2 vault secret; never list `value` in `output` |
| `trigger.get` | triggers, state, error | `hostids`, `itemids`, `monitored`, `active`, `only_true`, `min_severity`, `lastChangeSince`, `lastChangeTill`, `expandDescription`, `filter`, `sortfield` (`triggerid`, `description`, `status`, `priority`, `lastchange`, `hostname`), `limit`, `output` | trigger `value` 0 OK, 1 problem; `state` 0 up to date, 1 unknown; `status` 0 enabled; `priority` 0 to 5 |
| `problem.get` | current problems and recently resolved ones | `hostids`, `groupids`, `severities`, `recent`, `suppressed`, `acknowledged`, `time_from`, `time_till`, `eventid_from`, `sortfield` (`eventid`), `limit`, `output` | only unresolved problems unless `recent` is true; older resolved ones need `event.get` |
| `event.get` | events, including problems resolved long ago | `hostids`, `groupids`, `objectids`, `source`, `object`, `value`, `severities`, `time_from`, `time_till`, `eventid_from`, `limit`, `output` | page notes events of a deleted entity may remain until housekeeping removes them |
| `history.get` | raw values of one item | `history` (value type to read), `itemids`, `hostids`, `time_from`, `time_till`, `sortfield` (`itemid`, `clock`, `ns`), `sortorder`, `limit`, `countOutput`, `output` | default `history` is 3 (unsigned): pass the item's `value_type`; data of a deleted entity may remain until housekeeping runs |
| `trend.get` | hourly aggregates | `itemids`, `time_from`, `time_till`, `limit`, `countOutput`, `output` | trend properties `clock`, `num`, `value_min`, `value_avg`, `value_max` |
| `proxy.get` | proxies and their state | `proxyids`, `proxy_groupids`, `selectHosts` and `selectAssignedHosts` (support `count`), `sortfield` (`proxyid`, `name`, `operating_mode`), `output` | proxy `state` 0 unknown, 1 offline, 2 online; `lastaccess`; `version`; `compatibility`; `operating_mode` 0 active, 1 passive |
| `housekeeping.get` | the housekeeping settings object | only `output` | returns one object (not an array) |
| `auditlog.get` | who changed what | `auditids`, `userids`, `time_from`, `time_till`, `filter`, `sortfield` (`auditid`, `userid`, `clock`), `sortorder`, `limit`, `output` | available to the Super admin user type only; `details` is a JSON text of changes |
| `role.get` | what an API role may do | `roleids`, `selectRules`, `output` | use only to confirm the role of the dedicated user, if the role itself may call it |

## What not to request

| Method and property | Why |
|---|---|
| `usermacro.get` with `value` or `output: "extend"` | returns the macro value for text and vault types; a secret macro's value is write-only, but the others are not |
| `item.get` or `host.get` with `output: "extend"` | item rows carry `password`, `ssl_key_password`, `username`; host rows carry `ipmi_password`; the manual does not mark those item and host properties write-only |
| `item.get` `lastvalue` for text or log items | the last value can contain anything the source sent |
| `host.get` or `hostinterface.get` with `details` | the interface details object carries SNMP `community` and security passphrases |
| `history.get` on character, log and text types without a reason | values are source data |
| `auditlog.get` `details` in bulk | old and new values of changed properties |

## Wildcard allow list and what it covers

The role page documents wildcards for the API methods list (`dashboard.*`, `*`, `*.export` as examples). A list of `*.get` therefore allows every get method, which includes `user.get`, `token.get` and `auditlog.get` for a role of the right type. A tighter list names exactly the methods of the table. `apiinfo.version` needs no permission because it is called unauthenticated.

## How an agent should apply this

- Choose the method from the table, copy its parameter names exactly, and do not add parameters from memory; an unverified name must not appear in a request.
- Build `output` from an explicit list on every call; use the properties named in the table.
- Remember that `filter` cannot match text-typed properties; filter on integer states (`state`, `status`, `value`) and group by text on the client.
- When a method is missing from your role, report "method not allowed for this role" and stop; do not switch to a more powerful credential.
- When the version is not 7.0 or 8.0, say the catalog is unverified for it and expect field differences (for example proxy objects differ between major versions).
