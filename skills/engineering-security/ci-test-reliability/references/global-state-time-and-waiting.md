# Global State, Time and Waiting

Sources: https://vitest.dev/api/vi · https://vitest.dev/guide/mocking/timers · https://vitest.dev/guide/common-errors · https://jestjs.io/docs/timer-mocks · https://nodejs.org/api/test.html · https://docs.pytest.org/en/stable/how-to/fixtures.html · https://martinfowler.com/articles/nonDeterminism.html · Last verified 2026-11-27

## Global state is a shared resource

Anything process-wide is shared by every test in that process: `process.env`, the working directory, locale and time zone, fake timers, module mocks and registries, `globalThis`, global `fetch`, console hooks. Fowler names lack of isolation as a common and frustrating cause of non-determinism, and offers two routes: rebuild the starting state from scratch for each test (preferred), or make each test clean up after itself.

Vitest provides restore helpers that remember the original on first use: `vi.stubEnv` pairs with `vi.unstubAllEnvs`, `vi.stubGlobal` with `vi.unstubAllGlobals`, and `vi.restoreAllMocks` (or the `restoreMocks` option) restores spied methods. The docs note that assigning to `process.env` or `globalThis` directly works but is not undone by the unstub helpers. pytest's equivalent is a `yield` fixture or `monkeypatch`: teardown code placed after the `yield` runs after the test, in reverse order of fixture setup.

Worker model matters. Vitest's common-errors page documents that setting `process.env.TZ` inside a test has no effect on `Date` in the threads-based pools because Node applies `TZ` only when the main thread sets it, and that `process.chdir()` is not available in the threads pool. The documented remedies are to set the zone before workers start (shell, config file, global setup) or use the `forks` pool. Treat this as a general warning: a global that "works" in one pool may silently do nothing, or leak, in another.

Pattern for unavoidable mutation:

```ts
const hadKey = Object.hasOwn(process.env, "API_URL");
const prev = process.env.API_URL;
process.env.API_URL = "http://127.0.0.1:" + port;
cleanup.push(() => { hadKey ? (process.env.API_URL = prev) : delete process.env.API_URL; });
```

Capture presence as well as value: restoring `undefined` as the string `"undefined"` is a classic leak.

## Time

Fowler: few things are more non-deterministic than the system clock, so wrap it behind something replaceable and use a frozen, seeded stub in tests; he also warns that a shared clock stub is itself a way to break isolation, so each test must re-initialize it. He suggests a static check that forbids direct clock calls in code under test, and running tests around midnight and month end to catch "same day" assumptions.

Fake timers: Vitest (`vi.useFakeTimers`, `vi.advanceTimersByTime`, `vi.runAllTimers`, `vi.setSystemTime`) and Jest (`jest.useFakeTimers`, `advanceTimersByTime`, `runOnlyPendingTimers`, `useRealTimers`) replace the timer functions and `Date`; Node's test runner offers `mock.timers` with `enable({ apis: [...] })`, `tick()` and `reset()`. Mechanics to remember:

- Always restore real timers in cleanup (`vi.useRealTimers()` / `jest.useRealTimers()` / `mock.timers.reset()`); a leaked fake timer turns the next test's wait into a hang.
- `runAllTimers` loops forever on a self-rescheduling timer (Jest aborts after a limit); use `runOnlyPendingTimers` or `advanceTimersByTime` there.
- In Vitest, `vi.waitFor` and `vi.waitUntil` advance fake timers while they poll, and tick modes (`interval`, `nextTimerAsync`) can make fake time advance on its own; the docs warn that state that lives for a limited time may vanish before the assertion with the second mode. Pick the mode deliberately.

Use real time only when elapsed time is the product behavior, and then give a wide tolerance and a large outer bound.

## Random and network

Seed randomness and print the seed so a failing run can be replayed. Fowler also notes that stubbing a random generator to a fixed value can expose collision bugs (random temp file names that are never cleaned up). For remote services, use a test double you control; Fowler points out that a live system may be unstable or load-sensitive, and that tests hitting it may add load nobody expected.

## Waiting for asynchronous work

Fowler: never use a bare sleep. It is either too long (slow suite) or, eventually, too short (false failure). Two tactics:

1. **Callback or event** from the service when it finishes: no wasted time, still keep a high timeout in case the signal never comes.
2. **Polling** with a small interval and a large wait limit: the interval bounds dead time, and the limit can be generous so that it only fires when something is really wrong. Use a dedicated exception type for a test timeout, keep limits in constants or environment settings, and consider aborting the suite when the limit is reached.

Tool support: Vitest `vi.waitFor(fn, { timeout, interval })` retries until the callback stops throwing (defaults 1000 ms and 50 ms per the docs read); `node:test` has `context.waitFor(condition)`; for others write a 10-line helper. Barriers (deferred promises) let you place two operations at a known overlap point.

```ts
const ready = Promise.withResolvers<void>();
child.stdout.on("data", d => d.includes("listening") && ready.resolve());
await ready.promise;              // event, not sleep(500)
```

## Dispose to quiescence

Register cleanup at acquisition. A complete teardown stops new callbacks, detaches listeners, restores global hooks, terminates owned work and **awaits** the completion signal (child `exit`, server `close`, worker termination). pytest runs yield-fixture teardown in reverse order; its documentation also warns that ordering alone does not guarantee a safe cleanup and recommends keeping each fixture's teardown independent ("safe teardowns"). Jest's `--detectOpenHandles` exists because unreleased resources keep the process alive; `--forceExit` hides them.

## Anti-patterns

- Restoring a global only in the happy path.
- `await sleep(...)` between action and assertion.
- Real timers left fake after a failure.
- Calling `server.close()` without waiting for its callback, then reusing the port.
- Asserting scheduler order that is not product behavior.
- Literal wait limits scattered across files.

## How an agent should apply this

- List every global the test touches; prefer injection, otherwise stub with the runner's restore helper and add an `afterEach` fallback.
- Replace each sleep with an event, handshake or bounded poll; name what is awaited in the failure message.
- Freeze or inject the clock; assert on injected time, not on elapsed real time.
- Check that the global actually takes effect in the configured pool (time zone, `cwd`).
- Make teardown await completion, and prove it by running the next test immediately after.
