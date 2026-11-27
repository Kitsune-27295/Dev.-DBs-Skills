# Trigger Evals

Last verified 2026-11-27 (prompts written by the author; not run against a host).

Should trigger `zabbix-diagnostics`:
1. "Half our SNMP hosts show no data since Monday. Can you check Zabbix through the API and tell me why?"
2. "Is the proxy at the branch site healthy? Check lastaccess and version compatibility."
3. "Someone changed a macro on a host last week. Who, and what type of macro is it (without showing the value)?"

Near misses:
1. "Our Zabbix PostgreSQL database is bloated and slow" -> `database-audit`, then `postgres-diagnostics`.
2. "My API client keeps retrying Zabbix calls in a tight loop" -> `circuit-breaker-retry-telemetry`.
3. "Create a new Zabbix host and a trigger through the API" -> not this skill (write methods are out of scope; hand over as a proposal).
