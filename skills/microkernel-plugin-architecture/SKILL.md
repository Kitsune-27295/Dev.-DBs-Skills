---
name: microkernel-plugin-architecture
description: Use when designing, reviewing, or refactoring a Microkernel (Plug-in) Architecture — separating a minimal Core System from independent Plug-in modules via versioned Extension-Point Contracts and a Plug-in Registry, choosing isolation levels (in-process, classloader/module, subprocess/sandbox), or enforcing the Independent Plug-in Principle. Gives the 4 core elements, contract rules, failure modes, compliance testing, and common mistakes.
---

# Microkernel / Plug-in Architecture

One idea: separate a **minimal, stable Core System** (the microkernel that owns only the base happy-path workflow or host lifecycle) from **volatile, specialized, or third-party behaviors packaged as independent Plug-ins** that connect to the Core exclusively through **standard, versioned Extension-Point Interfaces** and a **Plug-in Registry**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Richards, UQ CSSE6400 & arc42)

| Term | Meaning | Test sentence |
|---|---|---|
| Core System (Microkernel) | minimal host engine implementing only the base operational path and extension lifecycle (e.g., IDE text buffer, payroll base loop, CLI/agent harness) | "contains zero customer-specific, region-specific, or volatile feature branches" |
| Extension Point / Plug-in Interface | the formal, versioned contract (interface, abstract SPI, or event/IPC protocol) declared and owned by the Core System | "same standard contract for every plug-in of that category" |
| Plug-in Component | an independent, self-contained module implementing an Extension Point to add, swap, or customize behavior without modifying the Core | "can be added, upgraded, or removed without recompiling the Core System" |
| Plug-in Registry | the catalog/discovery mechanism (manifest file, directory scan, DI service loader, or runtime hot-plug endpoint) that tracks available plug-ins and how the Core invokes them | "the only place where discovered plug-ins are bound to extension points" |
| Isolation Dial | the runtime boundary between Core and Plug-ins: **In-process** (fastest, shared memory), **Loader/Module isolation** (separate dependency trees), or **Subprocess/WASM/Container Sandbox** (fault & security containment) | "higher isolation prevents crashes and supply-chain malice at the cost of serialization latency" |

## Core architectural principles and invariants

1. **The Independent Plug-in Principle:** Plug-ins must be **mutually independent**. Plug-in A must never import, call, or depend on the presence or execution order of Plug-in B. If two plug-ins need to coordinate, they must do so through the Core System's documented extension points or event bus.
2. **The Standard Interface Principle:** The Core System must never contain `if (plugin.name === 'SpecialVendor')` branches or custom adapters per plug-in. Every plug-in of a given capability must implement the **exact same standard Plug-in Interface** owned by the Core.
3. **One-way knowledge (Core knows the Contract, never the concrete Plug-ins):** The Core System defines the Extension Point interfaces and calls the Registry. Adding a new plug-in must require **zero source changes** to the Core System (Open-Closed Principle at the architectural level).
4. **Treat the Plug-in Interface as an immutable public product:** Once external teams or third parties build against an extension point, a breaking change strands the ecosystem. Version contracts explicitly (`v1`, `v2`), support capability negotiation, and deprecate with adapters rather than mutating signatures in place.
5. **Turn the Isolation Dial to match trust and blast radius:**
   - Trusted first-party plug-ins: in-process modules/packages registered at startup.
   - Third-party / untrusted plug-ins: run in a sandboxed subprocess (e.g., MCP servers over stdio/HTTP, WebWorkers, WASM, or restricted containers) with explicit capability permissions, per-call timeouts, and memory caps so a buggy or malicious plug-in cannot crash or compromise the host.
6. **Private Plug-in Data:** If a plug-in requires persistent state, it must store it in a plug-in-scoped store or pass state through the Core interface — never mutate the Core System's internal database tables directly behind the Core's back.

## Building order

1. **Strip the Core System to its irreducible minimum:** Identify the invariant happy path or host lifecycle versus the volatile rules (e.g., tax jurisdictions, file parsers, linter rules, payment gateways, agent tools).
2. **Design the Extension-Point Contract & Lifecycle:** Define `register()`, `initialize(context)`, `execute(input)`, and `dispose()` (cleanup of timers, file handles, and memory on unload), plus the error/timeout semantics.
3. **Write the Plug-in Compliance Test Suite first:** Build a shared contract test suite that any plug-in implementation must pass to prove it honors the extension point, handles bad inputs, and cleans up resources on unload.
4. **Implement the Registry and Discovery gate:** Ensure the Core completes plug-in registration and validation **before** serving traffic or invoking extension points (preventing startup race conditions).
5. **Build the first 2 real Plug-ins + 1 Chaos Plug-in:** Verify the contract against two genuinely different plug-ins and one chaos test plug-in (throws exceptions, hangs past timeout, returns malformed payloads) to prove the Core survives misbehaving extensions.

## Testing strategy

| Component | Test | Uses |
|---|---|---|
| Core System + Registry | unit / host test | fake/stub plug-ins + **Chaos Plug-in** (verifies host survives plug-in crashes, timeouts, and registration races) |
| Extension-Point Contract | shared compliance test suite | run against every first-party and third-party plug-in before release |
| Individual Plug-in | isolated unit / integration test | mocks or instantiates only the Core extension-point context; never loads other plug-ins |
| Unload / Hot-Reload Lifecycle | resource-leak test | repeatedly loads, invokes, and unloads a plug-in while asserting zero leaked handles, listeners, or threads |

## When it earns its keep

- **Worth it:** Products with open or growing extension ecosystems (IDEs, browsers, CI runners, CMSs, CLI/AI agent tool harnesses), enterprise systems with volatile per-customer or per-jurisdiction business rules (payroll, insurance underwriting, tax engines, device drivers), and applications requiring customer-specific customization without forking the core codebase.
- **Not worth it:** Applications with a small, fixed set of known variants (2-3 variants that rarely change). Designing, versioning, documenting, and sandboxing a public plug-in API is permanent maintenance overhead that a simple Strategy pattern or polymorphism inside a regular module handles at 1/10th the cost.

## Mistakes to catch

- **Cross-plug-in dependencies:** Plug-in A importing a helper or state directly from Plug-in B — turning independent plug-ins into a coupled monolith that cannot be loaded or upgraded separately.
- **Bloated Core ("Fat Microkernel"):** Leaving half of the volatile business rules inside the Core System and adding special-case hooks for individual plug-ins.
- **Running untrusted third-party plug-ins in-process with host privileges:** Allowing an external plug-in full access to `process.env`, filesystem, and network inside the host process — turning one compromised plug-in into a full supply-chain breach (`security-audit`).
- **No timeout or circuit breaker around plug-in calls:** Letting one synchronous plug-in enter an infinite loop or hang on network I/O and freeze the entire Core System.
- **Leaking handles across reload/unload cycles:** Failing to enforce a `dispose()` contract so hot-reloading plug-ins leaks event listeners, memory, or child processes until the host OOMs.

## Quick Decision Checklist

- [ ] Do the plug-ins stay mutually independent, with no plug-in importing or depending on another?
- [ ] Does every plug-in implement the same standard interface, with no per-plug-in branches in the Core?
- [ ] Can a new plug-in be added with zero source changes to the Core?
- [ ] Is the plug-in interface versioned and treated as an immutable public contract?
- [ ] Is isolation matched to trust: untrusted plug-ins sandboxed with permissions, timeouts and memory caps?
- [ ] Is every plug-in call wrapped in a timeout or circuit breaker, with dispose() enforced on unload?
- [ ] Do plug-ins keep state in their own store, never the Core's tables?
- [ ] Do I need an open plug-in ecosystem, or would a simple Strategy pattern do for 2-3 variants?

## Deep references

- [Microkernel principles, partitioning and extensions](references/microkernel-principles-and-partitioning.md) — read when designing the core/plug-in contract, registry, per-domain interfaces or distributed plug-ins.
- [Plugin isolation, failure modes and verification](references/plugin-isolation-failure-modes-and-verification.md) — read when choosing isolation level or writing plugin tests and guards.
