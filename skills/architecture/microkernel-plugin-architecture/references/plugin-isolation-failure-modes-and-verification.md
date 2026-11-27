# Plugin Isolation, Failure Modes and Verification

Sources: https://quality.arc42.org/approaches/plugin-architecture · Last verified 2026-11-27

## Intent and mechanism (arc42 Quality Guide)
Let independent teams or third parties extend behavior without changing or redeploying the core. The core defines a stable extension point (API, interface or event bus). Plugins register at startup or at runtime and the host invokes them through the shared contract. Discovery details such as ServiceLoader or entry points are common practice, not stated by arc42. The page also calls the style Add-in Architecture or Microkernel.

## Isolation as a dial
| Level | Gives | Costs |
|---|---|---|
| In-process | Fastest calls | Plugin has host privileges and can crash it |
| Classloader/module isolation | Avoids dependency conflicts | Some overhead; still same process |
| Subprocess / sandbox | Contains crashes and malicious code | Highest latency (IPC, serialization) |

Choose the lowest level the trust model allows: first-party plugins in-process; marketplace or customer-supplied code sandboxed (inference from the dial plus the supply-chain warning).

## Failure modes (named by the source)
1. Breaking API change strands the ecosystem; core upgrades stall until plugins catch up.
2. Leaks of memory, handles or threads across unload cycles slowly destabilise the host.
3. Extension point invoked before registration completes, so behavior silently depends on startup timing.
4. Unsandboxed plugin = host privileges = supply-chain incident if compromised.
Also: a slow synchronous plugin can stall the whole pipeline.

## Verification recipe
- Shared compliance test suite per extension point; every plugin must pass before release.
- Chaos plugin that throws and hangs: host and other plugins must keep serving.
- 100 consecutive load/unload cycles with flat memory and handle counts (the source's figure).
- Track per-plugin p99 invocation time; alert when a plugin adds over 10 percent to request latency (the source's figure).

## When to use and skip
- Use when the set of capabilities varies or is unknown: third-party extensions, per-customer feature combinations, hardware drivers (the source's example: five battery providers behind one contract).
- Skip when the extension set is small and fixed: the permanent public API costs more than a few known variants. Once third parties build against it, the core team maintains a public product (versioning, deprecation windows, compatibility suites).

## Neighboring approaches
- Externalized business rules: declarative where plugins are imperative code.
- Hexagonal architecture: ports swap infrastructure behind core-owned interfaces (`hexagonal-architecture`); plugins open the feature set.
- Sidecar: extends out of process at deployment time, needs no design-time extension points.

## Sketch: guarded invocation
```ts
async function callPlugin(p: Plugin, input: Input) {
  const t = withTimeout(p.handle(input), 200);   // hang guard
  try { return await t; }
  catch (e) { metrics.inc("plugin_fail", p.id); breaker.record(p.id); return fallback(input); }
}
// registration completes (ready=true) before the first call is allowed
```

## How an agent should apply this
- Decide the isolation level from the trust model before writing the loader.
- Add timeouts, error containment and a circuit breaker around every plugin call.
- Gate startup: no extension point is invoked until registration finishes.
- Version the extension API explicitly and write a compliance suite plus a chaos plugin at the same time as the first real plugin.
- Refuse the pattern if fewer than a handful of variants exist and none come from outside the team.
