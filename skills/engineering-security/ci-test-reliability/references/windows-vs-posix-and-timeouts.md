# Windows vs POSIX and Timeouts

Sources: https://nodejs.org/api/process.html · https://nodejs.org/api/child_process.html · https://nodejs.org/api/fs.html · https://vitest.dev/config/testtimeout · https://vitest.dev/config/hooktimeout · https://jestjs.io/docs/cli · https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax · https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations · https://testing.googleblog.com/2020/12/test-flakiness-one-of-main-challenges.html · Last verified 2026-11-24

Labels used below: **[read]** = stated in a page fetched for this skill; **[known]** = well-established platform behavior not re-read from a source here; **[inferred]** = this skill's own reasoning.

## Why OS differences cause "flaky" results

A matrix that includes Windows and Linux runs the same test against two operating systems whose file systems, signals, locking and environment rules differ. Google's flake taxonomy lists the OS and hardware as one of four places flakiness originates; an OS-dependent failure is deterministic per OS but looks random to someone who only reads the summary. Always read the failing cell's OS before treating a failure as random.

## Checklist of differences

| Area | Difference | Test-side rule |
|---|---|---|
| Environment variables | Names are case-insensitive on Windows **[read]** (Node process and child_process docs). Passing two keys that differ only by case to a child on Windows can cause issues **[read]**. | Use one canonical casing; never seed `http_proxy` and `HTTP_PROXY` as independent values |
| Signals | Windows does not support signals; Node emulates termination in `process.kill()` and `subprocess.kill()`, and lists `SIGTERM` as unsupported there **[read]** | Do not assert signal delivery or exit-by-signal on Windows; explicit platform skip with reason, or assert on the observable outcome (process gone) |
| Spawning scripts | `.bat` and `.cmd` files cannot be run by `execFile` on Windows without a shell **[read]** | Spawn real executables, or invoke through the documented shell route, quoting names with spaces |
| File removal/rename | Busy-file errors (`EBUSY`, `EPERM`, `ENOTEMPTY`) on Windows when a handle is open or released late **[known]**; Node's recursive `rm` retries those codes via `maxRetries` and `retryDelay`, default 0 retries **[read]** | Close handles and await child exit first; then use a small bounded retry sized to measured contention |
| Path separators | Backslash vs slash, drive letters **[known]** | Build with the path API; compare normalized paths; never embed absolute machine paths in expectations |
| Line endings | CRLF vs LF, especially with VCS autoconversion **[known]** | Normalize when comparing text, or pin the checkout setting; do not read a fixture in a mode that differs per OS |
| Case sensitivity | Typical Linux file systems are case-sensitive, default Windows and macOS are not **[known]** | Do not rely on two files differing only by case; keep import paths exactly cased |
| File timestamps | Granularity differs by file system **[known]** | When the assertion depends on a restored value, read it back instead of trusting the remembered one **[inferred]** |
| Permission bits | POSIX modes have limited meaning on Windows **[known]** | Skip permission-bit assertions on Windows explicitly |
| Temp locations | System temp directory and its length limits differ **[known]** | Always take the base from the OS API, not a literal |

Rule of thumb: prefer an observation that holds on every platform. If a case genuinely cannot, exclude it on that platform with a named reason; weakening the assertion on all platforms to get one cell green is a masking fix.

## Timeouts: know every layer and its default

- **Per test and per hook.** Vitest documents a default test timeout of 5 s and a hook timeout of 10 s in Node (larger in browser mode); `0` disables. Jest has `--testTimeout`. Per-suite or per-test values **override** the global one rather than yielding to it: a literal smaller than the lane's setting silently lowers what CI granted, while on another host the same literal may widen it.
- **Hooks.** Setup and teardown pay the same contention as the test. Raise the hook budget together with the test budget, or the failure moves into `afterEach`.
- **Job.** Actions `timeout-minutes` defaults to 360 and must be a positive integer; step-level `timeout-minutes` also exists **[read]**. Set an explicit job value near the expected duration times a safety factor, so a hang fails in minutes.
- **Matrix.** `fail-fast` cancels in-progress and queued matrix jobs after a failure; consider turning it off when you need the full picture across OSes, and use `max-parallel` to reduce contention on a shared backend **[read]**.
- **Slow lanes.** Process creation, browsers, containers and databases need a larger documented budget in their own lane (a separate project or config), not a global increase.

When the timeout itself is the subject of the test, keep the outer harness wait far larger than the deadline being tested; otherwise load decides which deadline reports first **[inferred]**.

## Example: lane-specific budget

```ts
// vitest.config.ts (projects): one lane per cost profile
export default defineConfig({ test: { projects: [
  { test: { name: "unit", include: ["test/unit/**"], testTimeout: 5_000 } },
  { test: { name: "spawn", include: ["test/spawn/**"], testTimeout: 30_000, hookTimeout: 30_000 } },
]}});
```

A case in the `spawn` lane should not restate a smaller literal unless it documents why.

## Anti-patterns

- A global timeout raise because one lane is slow.
- A per-case timeout below the lane budget with no reason.
- Retries added to a Windows cell for a deterministic path or lock problem.
- Skipping a case on every OS because it fails on one.
- Reading the summary ("1 failed") without the OS of the failing cell.

## How an agent should apply this

- Identify the failing cell's OS first; reproduce on that OS (or a faithful emulation) before editing.
- Fix path, env-casing and line-ending issues in the test; skip only truly platform-specific features, naming the reason.
- Before a retry-on-busy, make sure handles and child processes are closed; then size the retry from measurement.
- Set explicit per-lane test, hook and job timeouts and record the reason next to any value that is not the default.
- Report which OS cells ran; do not claim portability from one host.
