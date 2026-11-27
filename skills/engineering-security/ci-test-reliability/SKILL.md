---
name: ci-test-reliability
description: "Make tests pass for the right reasons in CI instead of by luck on a quiet workstation: model parallel workers, shards and jobs sharing a host; allocate ports and temp directories atomically; restore global state; control time, randomness and network; wait on state, not sleeps; tear down to quiescence; handle Windows vs POSIX; budget timeouts per lane; treat retries as a diagnostic; quarantine with an expiry; reject masking fixes. Not for choosing test shapes (`testing-pyramid-and-shapes`), real-database route tests (`integration-tests`), Playwright retries (`playwright-qa-orchestrator`) or races in application code (`race-condition-fix`). Use when CI fails intermittently, when tests touch ports, files, clocks, processes or globals, or when someone proposes retries, serial runs or quarantine."
---

# CI Test Reliability

One idea: a test is reliable only if its result depends on the code under test and nothing else, including under the **real** CI topology (parallel workers, shards, shared hosts, other OSes). Fix the cause (shared resource, uncontrolled input, unsynchronized wait), never the symptom (a bigger timeout, a retry, a serial run). Sources and claims: [references/sources.md](references/sources.md).

Boundaries (one owner per rule): the golden rule "never delete, skip or loosen a test to make it pass" is `integration-tests`; the reproduce-and-bisect loop is `diagnosing-bugs`; proof that a fix worked is `verification-loop`. Other neighbors are in the description. This skill owns test-side isolation, determinism and CI configuration.

---

## 1. Model the execution topology first

Assume these layers can overlap unless the active configuration proves otherwise:

| Layer | Examples of the knob | What it isolates |
|---|---|---|
| Tests inside one file | Vitest `test.concurrent`, `describe.concurrent`; `node:test` concurrency option | Nothing: same process, same globals |
| Files in separate workers | Vitest `pool` (`forks` = child processes, `threads` = worker threads), `maxWorkers`, `fileParallelism`; Jest `--maxWorkers`; pytest-xdist `-n`; `node:test` `--test-concurrency` | Module state and `process` globals (per process), **not** ports, paths, databases, env of the host |
| Shards | Vitest `--shard=i/n`, Jest `--shard=i/n` | Split one suite over processes or machines; says nothing about shared resources |
| Jobs and matrix cells | Actions `strategy.matrix`, `max-parallel`, `concurrency` groups | Separate runners, but self-hosted or reused services may still be shared |

Rules:

1. Read the real runner config and the workflow before judging a test. "Passes alone" is not evidence.
2. For every resource a test acquires, name its **owner**, its **atomic allocator**, its **readiness signal**, its **registered cleanup** and its **quiescence signal**.
3. Narrow the exclusive scope or change the allocation before serializing anything. A "sequential" block inside one file cannot protect a host resource from another file, process or job.
4. Rebuilding state from scratch beats cleaning up after yourself, and keeps tests orderable and parallelizable (Fowler).

Details and per-tool knobs: [execution topology and resource allocation](references/execution-topology-and-resource-allocation.md).

## 2. Allocate resources atomically

Check-then-use is a race. Ask the owner for a fresh resource instead.

| Resource | Do | Reject |
|---|---|---|
| TCP port | Bind to port `0` and read the assigned port after `listening` (Node: `server.address().port`) | Scanning for a free port and binding it later; a hard-coded port |
| Temp directory | One private directory per test (`mkdtemp`, pytest `tmp_path`); add the platform separator to the prefix | Predictable shared paths such as a fixed folder in the system temp dir |
| Shared database, queue, bucket | Unique per-test namespace (schema, prefix, key) or a per-worker instance | One shared namespace "cleaned" by whoever runs last |
| Files that must not pre-exist | Exclusive creation | Exists-check then write |
| Recorded identifiers vs live addresses | Translate inside the fixture | Forcing the live resource onto the recorded value |

## 3. Contain process-global state

Treat `process.env`, working directory, locale and time zone, fake timers, module mocks, registries, console hooks, `globalThis` and global `fetch` interception as exclusive mutable resources.

- Prefer injection over mutating a global. When mutation is unavoidable: capture whether the value was absent or present, restore exactly that, register the restore immediately, and keep an `afterEach` fallback. Use the runner's own restore helpers (`vi.stubEnv` + `vi.unstubAllEnvs`, `vi.stubGlobal` + `vi.unstubAllGlobals`, pytest `monkeypatch`).
- A time-zone or `cwd` change may not take effect in a thread-based pool; set it before workers start or use the process-per-file pool.

## 4. Take control of time, randomness and the network

- **Clock:** wrap the system clock or use fake timers and always restore real timers. Never let an assertion depend on "now" or on a real elapsed duration.
- **Random:** seed it and log the seed; when hunting a flake, replay the same seed. Stubbing a generator to a constant can also expose collisions.
- **Network:** a flaky or live remote is replaced by a test double you control; loopback fixtures only on ephemeral ports (section 2).

Details: [global state, time and waiting](references/global-state-time-and-waiting.md).

## 5. Synchronize on state, never on sleeps

A fixed sleep is guesswork that is too long on a quiet host and too short on a busy one.

1. Prefer a callback, event, promise or handshake from the thing you wait for.
2. Otherwise poll a condition with a small interval and a **generous** upper bound (`vi.waitFor` / `vi.waitUntil`, `node:test` `waitFor`, an equivalent helper). The bound is only a safety net, not part of correctness.
3. Name the failure as a test timeout, and keep wait limits in one shared constant or environment variable.
4. Use barriers or deferred promises to force a race to overlap; repeating a test is not a race test.

## 6. Dispose to quiescence

Register cleanup right after acquisition so a failed assertion still releases the resource. Teardown must stop new work, detach listeners, restore globals, terminate owned work **and wait** for the completion signal (child exit, server `close` callback, worker termination). Calling `close()`, `abort()` or `kill()` without awaiting that signal is incomplete: the leftover can break the next test. Run teardown in reverse order of setup and keep each cleanup independent.

## 7. Windows and POSIX are different hosts

Check each of these before calling a test portable (details and what was read vs inferred: [Windows vs POSIX and timeouts](references/windows-vs-posix-and-timeouts.md)):

- Environment variable names are case-insensitive on Windows (Node docs): two keys differing only by case collapse into one.
- Signals: Windows has no termination by signal; Node only emulates it in `process.kill()` and `subprocess.kill()`, and lists `SIGTERM` as unsupported there. A test that relies on signal delivery needs an explicit platform skip with the reason.
- File locks and handles: removal or rename can fail with busy-file errors on Windows; Node's recursive `rm` has `maxRetries` / `retryDelay` for `EBUSY`, `EPERM`, `ENOTEMPTY` and similar. Use a bounded retry sized to what you measured, and close handles first.
- Paths, separators, line endings and case-sensitive file names differ; build paths with the path API, compare normalized forms, and read expected files in a mode that does not depend on `\r\n`.

Prefer an assertion that holds on every platform; when impossible, exclude that case on that platform explicitly rather than weakening it everywhere.

## 8. Budget timeouts per lane

- Know every layer's default: per-test timeout, hook timeout, job `timeout-minutes` (Actions default 360), step timeout.
- A per-suite or per-case timeout **overrides** the lane's global value; a literal below the lane budget lowers what CI granted. Give setup and teardown hooks the same budget increase as the test.
- A slow lane (process spawn, browser, database) gets its own documented budget, not a global increase.
- When a timeout is the subject, keep the outer wait far larger than the deadline tested.
- Put a `timeout-minutes` on every job so a hang fails fast instead of consuming six hours.

## 9. Retries are a diagnostic, not a fix

A retry that turns red to green proves the test is non-deterministic; it does not make it deterministic. Allowed uses: (a) measuring flake rate on purpose, (b) a documented transient external boundary (real third-party API) with a narrow error condition, (c) a short, expiring bridge while the owner fixes the cause. Every retry must be visible in the report (never counted as a clean pass) and must name the error class it covers. Playwright retry configuration lives in `playwright-qa-orchestrator`.

## 10. Quarantine with an expiry

Move a confirmed non-deterministic test out of the gating suite into a separate suite so healthy tests keep their signal. Quarantine is a work queue, not a graveyard: owner, ticket, reproduction note, and an expiry (a numeric cap on quarantined tests or a time limit such as one week, both Fowler's suggestions). Quarantined tests still run somewhere, and a test that hits its expiry is fixed or deleted with justification. Automated quarantine can hide a real race in the product (Google Testing Blog), so read the failure before parking it. Never use quarantine to skip a test that fails deterministically (`integration-tests` golden rule).

## 11. Fixes that merely mask flakiness

Reject these as root-cause fixes: a longer timeout with no named awaited state; a sleep before an assertion or cleanup; blanket retries; serializing the whole suite; swallowing an error or unhandled rejection; weakening or deleting an assertion; normalizing unstable output until it matches; force-exiting the runner over leaked handles; re-running the pipeline until green. Each one's reasoning is in [retries, quarantine and masking fixes](references/retries-quarantine-and-masking-fixes.md). Restoring a budget the lane already granted, or sizing a bounded retry to measured contention, is not masking because it names the awaited work.

## 12. Prove the fix (and report honestly)

- Reproduce first: run the suite or file under the CI worker count, shard, order and OS, then loop it (`diagnosing-bugs`). Triage by component (test, runner, system under test, OS or hardware): [flake triage and evidence](references/flake-triage-and-evidence.md).
- For a race, show overlap with a barrier. For ports, paths or processes, run independent test processes concurrently. For teardown, show the resource is gone after the test.
- Stress runs supplement a deterministic regression, never replace it.
- Report exact commands and observed results (`verification-loop`). Never describe retries, skips or pending CI as a pass.

---

## Quick Decision Checklist

- [ ] I read the runner config and workflow, and can state how many processes, shards and jobs overlap.
- [ ] Every port, directory, namespace and file is allocated by its owner, per test, atomically.
- [ ] Every global I touch is restored exactly, with cleanup registered at acquisition.
- [ ] Clock, randomness and remote services are controlled; the seed is logged.
- [ ] No fixed sleep stands in for a readiness signal; waits are bounded by a named constant.
- [ ] Teardown awaits child exit, server close and worker termination.
- [ ] Windows differences (env case, signals, file locks, paths, line endings) are handled or explicitly skipped.
- [ ] Timeouts are set per lane; hooks scale with tests; every job has `timeout-minutes`.
- [ ] Retries and quarantine are visible, narrow and have an owner and an expiry.
- [ ] None of the masking fixes in section 11 is presented as the root-cause fix.
- [ ] Evidence comes from commands run in this session, not from memory.

## Deep references

- [Execution topology and resource allocation](references/execution-topology-and-resource-allocation.md) — read when choosing worker, shard or job settings, or when a test acquires a port, directory or shared service.
- [Global state, time and waiting](references/global-state-time-and-waiting.md) — read when a test mutates env, timers or globals, uses the clock, or waits for async work.
- [Windows vs POSIX and timeouts](references/windows-vs-posix-and-timeouts.md) — read when a suite fails on one OS only, or when setting per-lane and per-job timeouts.
- [Retries, quarantine and masking fixes](references/retries-quarantine-and-masking-fixes.md) — read before enabling retries, parking a test, or reviewing a "fix" for a flake.
- [Flake triage and evidence](references/flake-triage-and-evidence.md) — read when investigating an existing intermittent failure and deciding what proof to show.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description or checking that this skill, not a neighbor, should fire.
- [Sources](references/sources.md) — every URL used, its retrieved status, and claims not adopted as fact.
