---
name: microkernel-plugin-architecture
description: "Let independent teams or third parties extend a product without changing its core: a minimal core system, plug-ins behind one versioned extension-point contract, and a registry, with isolation chosen by trust level. Covers the four elements, the independent-plug-in and standard-interface principles, compliance and chaos testing, lifecycle and unload leaks. Not for swapping infrastructure behind ports (see hexagonal-architecture), a few fixed variants (a Strategy fits) or breaking a system into services (microservices-architecture). Use when designing or reviewing a plug-in or extension system, an IDE/CI/CMS/agent-tool host, per-customer rule variants, or deciding how isolated untrusted plug-ins must be."
---

# Microkernel / Plug-in Architecture

One idea: separate a **minimal, stable Core System** (the microkernel that owns only the base happy-path workflow or host lifecycle) from **volatile, specialized, or third-party behaviors packaged as independent Plug-ins** that connect to the Core exclusively through **standard, versioned Extension-Point Interfaces** and a **Plug-in Registry**. Sources, retrieved statuses and claims not adopted: [references/sources.md](references/sources.md).

## Vocabulary (UQ CSSE6400 and arc42; the isolation dial is arc42's)

| Term | Meaning | Test sentence |
|---|---|---|
| Core System (Microkernel) | minimal host engine implementing only the base operational path and extension lifecycle (e.g., IDE text buffer, payroll base loop, CLI/agent harness) | "contains zero customer-specific, region-specific, or volatile feature branches" |
| Extension Point / Plug-in Interface | the formal, versioned contract (interface, abstract SPI, or event/IPC protocol) declared and owned by the Core System | "same standard contract for every plug-in of that category" |
| Plug-in Component | an independent, self-contained module implementing an Extension Point to add, swap, or customize behavior without modifying the Core | "can be added, upgraded, or removed without recompiling the Core System" |
| Plug-in Registry | the catalog/discovery mechanism (for example a map, a manifest or directory scan, or a runtime registration call; arc42 says plug-ins register at startup or runtime) that tracks available plug-ins and how the Core invokes them | "the only place where discovered plug-ins are bound to extension points" |
| Isolation Dial | the runtime boundary between Core and Plug-ins: **In-process** (fastest, shared memory), **Loader/Module isolation** (separate dependency trees), or **Subprocess/WASM/Container Sandbox** (fault & security containment) | "higher isolation prevents crashes and supply-chain malice at the cost of serialization latency" |

## 1. Core architectural principles and invariants

1. **The Independent Plug-in Principle:** Plug-ins must be **mutually independent**. Plug-in A must never import, call, or depend on the presence or execution order of Plug-in B. If two plug-ins need to coordinate, they must do so through the Core System's documented extension points or event bus.
2. **The Standard Interface Principle:** The Core System must never contain `if (plugin.name === 'SpecialVendor')` branches or custom adapters per plug-in. Every plug-in of a given capability must implement the **exact same standard Plug-in Interface** owned by the Core.
3. **One-way knowledge:** the Core knows the contract, never the concrete plug-ins. Adding a plug-in needs **zero source changes** to the Core (the open-closed idea at architecture scale: `open-closed-principle`).
4. **Treat the Plug-in Interface as an immutable public product:** Once external teams or third parties build against an extension point, a breaking change strands the ecosystem. Version contracts explicitly (`v1`, `v2`), support capability negotiation, and deprecate with adapters rather than mutating signatures in place.
5. **Turn the Isolation Dial to match trust and blast radius:**
   - Trusted first-party plug-ins: in-process modules/packages registered at startup.
   - Third-party / untrusted plug-ins: run in a sandboxed subprocess (the skill's examples: a child process, a WASM runtime or a restricted container) with explicit permissions, timeouts and memory caps (own advice) so a buggy or malicious plug-in cannot crash or compromise the host. Timeout, retry and breaker mechanics: `circuit-breaker-retry-telemetry`.
6. **Private plug-in data:** the Core passes data in; a plug-in that needs persistence owns its own store and never reads or writes the Core's tables (UQ).

## 2. Building order

1. **Strip the Core System to its irreducible minimum:** Identify the invariant happy path or host lifecycle versus the volatile rules (e.g., tax jurisdictions, file parsers, linter rules, payment gateways, agent tools).
2. **Design the Extension-Point Contract & Lifecycle:** Define `register()`, `initialize(context)`, `execute(input)`, and `dispose()` (cleanup of timers, file handles, and memory on unload), plus the error/timeout semantics.
3. **Write the plug-in compliance test suite first:** Build a shared contract test suite that any plug-in implementation must pass to prove it honors the extension point, handles bad inputs, and cleans up resources on unload.
4. **Implement the Registry and Discovery gate:** Ensure the Core completes plug-in registration and validation **before** serving traffic or invoking extension points (preventing startup race conditions).
5. **Build the first 2 real Plug-ins + 1 Chaos Plug-in:** Verify the contract against two genuinely different plug-ins and one chaos test plug-in (throws exceptions, hangs past timeout, returns malformed payloads) to prove the Core survives misbehaving extensions.

## 3. Testing strategy

| Component | Test | Uses |
|---|---|---|
| Core System + Registry | unit / host test | fake/stub plug-ins + **Chaos Plug-in** (verifies host survives plug-in crashes, timeouts, and registration races) |
| Extension-Point Contract | shared compliance test suite | run against every first-party and third-party plug-in before release |
| Individual Plug-in | isolated unit / integration test | mocks or instantiates only the Core extension-point context; never loads other plug-ins |
| Unload / Hot-Reload Lifecycle | resource-leak test | repeatedly loads, invokes, and unloads a plug-in while asserting zero leaked handles, listeners, or threads |

## 4. When it earns its keep

- **Worth it:** Products with open or growing extension ecosystems (IDEs, browsers, CI runners, CMSs, CLI/AI agent tool harnesses), enterprise systems with volatile per-customer or per-jurisdiction business rules (payroll, insurance underwriting, tax engines, device drivers), and applications requiring customer-specific customization without forking the core codebase.
- **Not worth it:** Applications with a small, fixed set of known variants (2-3 variants that rarely change). Designing, versioning, documenting, and sandboxing a public plug-in API is permanent maintenance overhead that a simple Strategy pattern or polymorphism inside a regular module handles at 1/10th the cost.

## Mistakes to catch

- **Cross-plug-in dependencies:** Plug-in A importing a helper or state directly from Plug-in B — turning independent plug-ins into a coupled monolith that cannot be loaded or upgraded separately.
- **Bloated Core ("Fat Microkernel"):** Leaving half of the volatile business rules inside the Core System and adding special-case hooks for individual plug-ins.
- **Running untrusted third-party plug-ins in-process with host privileges:** one compromised plug-in becomes a supply-chain incident (arc42). Supply-chain controls: `software-supply-chain-security`.
- **No timeout or circuit breaker around plug-in calls:** a slow synchronous plug-in can stall the whole pipeline (`circuit-breaker-retry-telemetry`).
- **Leaking handles across reload/unload cycles:** Failing to enforce a `dispose()` contract so hot-reloading plug-ins leaks event listeners, memory, or child processes until the host OOMs.

## Quick Decision Checklist

- [ ] Do the plug-ins stay mutually independent, with no plug-in importing or depending on another?
- [ ] Does every plug-in implement the same standard interface, with no per-plug-in branches in the Core?
- [ ] Can a new plug-in be added with zero source changes to the Core?
- [ ] Is the plug-in interface versioned and treated as an immutable public contract?
- [ ] Is isolation matched to trust: untrusted plug-ins sandboxed with permissions, timeouts and memory caps?
- [ ] Is every plug-in call guarded by a timeout or breaker, and dispose() enforced on unload?
- [ ] Do plug-ins keep state in their own store, never the Core's tables?
- [ ] Do I need an open plug-in ecosystem, or would a simple Strategy pattern do for 2-3 variants?

## Deep references

- [Microkernel principles, partitioning and extensions](references/microkernel-principles-and-partitioning.md) — read when designing the core/plug-in contract, registry, per-domain interfaces or distributed plug-ins.
- [Plugin isolation, failure modes and verification](references/plugin-isolation-failure-modes-and-verification.md) — read when choosing isolation level or writing plugin tests and guards.
- [references/trigger-evals.md](references/trigger-evals.md): should-trigger and near-miss prompts. Read when tuning the description.
- [references/sources.md](references/sources.md): URLs, retrieved statuses, reading limits, claims not adopted.
