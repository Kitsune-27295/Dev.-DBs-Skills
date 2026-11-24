# Sources — CI Test Reliability

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://vitest.dev/guide/parallelism | 200 OK | File vs test parallelism, `forks`/`threads` pools, `maxWorkers`, `fileParallelism`, `test.concurrent` semantics and hook behavior |
| https://vitest.dev/guide/improving-performance | 200 OK | Test isolation default and the consequences of `isolate: false` (shared module state per worker) |
| https://vitest.dev/guide/cli | 200 OK | `--shard=<index>/<count>` semantics |
| https://vitest.dev/guide/common-errors | 200 OK | `TZ` and `process.chdir()` limits in the threads pool; use `forks` or set before workers start |
| https://vitest.dev/guide/mocking/timers | 200 OK | Fake timers, automatic advancing by `waitFor`/`expect.poll`, tick modes |
| https://vitest.dev/api/vi | 200 OK | `stubEnv`/`unstubAllEnvs`, `stubGlobal`/`unstubAllGlobals`, `restoreAllMocks`, `useFakeTimers`/`useRealTimers`, `waitFor` defaults |
| https://vitest.dev/config/retry | 200 OK | Retry `count`/`delay`/`condition`, defaults, per-test override |
| https://vitest.dev/config/testtimeout | 200 OK | Default test timeout (5 s Node) |
| https://vitest.dev/config/hooktimeout | 200 OK | Default hook timeout (10 s Node) |
| https://vitest.dev/guide/ | 200 OK | Read, nothing adopted beyond installation context |
| https://vitest.dev/guide/mocking/ | 200 OK | Fetched; no additional claim adopted |
| https://jestjs.io/docs/timer-mocks | 200 OK | Fake timer API, `runOnlyPendingTimers` vs `runAllTimers`, timer limit, `useRealTimers` |
| https://jestjs.io/docs/cli | 200 OK | `--runInBand`, `--maxWorkers`, `--shard`, `--detectOpenHandles`, `--forceExit`, `--testTimeout` |
| https://docs.pytest.org/en/stable/how-to/tmp_path.html | 200 OK | `tmp_path` per-test directories, `--basetemp` warning, xdist base temp handling, retention |
| https://docs.pytest.org/en/stable/how-to/fixtures.html | 200 OK | Yield-fixture teardown order, safe teardowns |
| https://pytest-xdist.readthedocs.io/en/stable/distribution.html | 200 OK | `-n`, `--dist` modes (`load`, `loadscope`, `loadfile`, `loadgroup`, `worksteal`), `xdist_group` |
| https://nodejs.org/api/test.html | 200 OK | Process-per-file isolation vs none, `--test-concurrency`, `mock.timers`, `waitFor`, experimental tag filter, randomize flag |
| https://nodejs.org/api/net.html | 200 OK | `listen` with port 0 assigns an unused port, read after `listening` |
| https://nodejs.org/api/fs.html | 200 OK | `mkdtemp` prefix/separator rule, `rm` `maxRetries`/`retryDelay` for busy-file errors |
| https://nodejs.org/api/process.html | 200 OK | Windows: env names case-insensitive, `SIGTERM` unsupported, signal emulation limits |
| https://nodejs.org/api/child_process.html | 200 OK | Windows env case-insensitivity note, `.bat`/`.cmd` spawning rules |
| https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs | 200 OK (redirected to https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations) | Matrix, `include`/`exclude`, `fail-fast`, `continue-on-error`, `max-parallel` |
| https://docs.github.com/en/actions/using-jobs/using-concurrency | 200 OK (redirected to https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency) | Concurrency groups, `cancel-in-progress`, pending replacement, case-insensitive group names |
| https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions | 200 OK (redirected to https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax) | Job `timeout-minutes` default 360, positive integer; step-level timeout |
| https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html | 200 OK | Flaky definition, reported rates, mitigations (re-run, 3-in-a-row flaky marker, auto-quarantine) and their costs |
| https://testing.googleblog.com/2017/04/where-do-our-flaky-tests-come-from.html | 200 OK | Flakiness vs test size, RAM and binary size, tool correlations (Google corpus) |
| https://testing.googleblog.com/2020/12/test-flakiness-one-of-main-challenges.html | 200 OK | Four-component taxonomy of flakiness causes, hermetic environments |
| https://testing.googleblog.com/2008/04/tott-avoiding-flaky-tests.html | 404 (guessed slug from the 2020 post's reference list; not read) | Nothing adopted |
| https://martinfowler.com/articles/nonDeterminism.html | 200 OK | Quarantine advice and limits, isolation, no bare sleeps (callback or polling), clock wrapping, remote test doubles, resource leaks |
| Third-party skill on CI test reliability (local project skill) | Read for ideas, no text reused; license not verified | Idea checklist only: topology layers, resource ownership, lane budgets, masking list; all content here rewritten from the public sources above |

## Reading limits

- Pages were fetched as HTML and converted to text; interactive examples and tabs were not executed. Vitest pages reflect the version served on 2026-11-24 (the `retry` object form is annotated as 4.1.0+); older versions may differ.
- Windows file-system behaviors (busy-file errors, case sensitivity, timestamp granularity, path and line-ending conventions) are marked **[known]** or **[inferred]** in the Windows reference because no OS documentation was fetched for them; only Node's own statements about Windows were read.
- Python `socket.bind` to port 0 is stated as general knowledge; Python socket docs were not fetched.
- Google figures come from one company's corpus and from 2016 and 2017 posts; they are priors, not universal rates.
- Jest and pytest pages were read for the specific flags and fixtures named; other options were not reviewed.

## Claims not adopted as fact

- Percentages and counts from Google posts are reported only as "reported by the authors".
- A commenter's triage argument on the 2020 post is attributed as a reader's view, not Google policy.
- Fowler's numeric quarantine limits (eight tests, one week) are his examples, not standards.
- The claim that a retry makes a test reliable, or that serial runs are a neutral cost, is not adopted from any source.
- The Node tag filter is documented as experimental; it is not recommended as a stable mechanism.
