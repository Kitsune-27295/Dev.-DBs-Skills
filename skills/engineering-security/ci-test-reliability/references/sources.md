# Sources — CI Test Reliability

Every URL below was re-fetched during the rebuild on 2026-11-27 (WebFetch; curl for pages whose body the summarizer cut off). Claims were re-checked against the page text.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://vitest.dev/guide/parallelism | 200 OK, re-read | Default `forks` pool, `threads`, `maxWorkers`, `fileParallelism`, `test.concurrent` shares a worker |
| https://vitest.dev/guide/improving-performance | 200 OK, re-read | Isolation on by default; `isolate: false` shares module state |
| https://vitest.dev/guide/cli | 200 OK, re-read | `--shard=<index>/<count>`; not usable with watch mode |
| https://vitest.dev/guide/common-errors | 200 OK, re-read | `TZ` and `process.chdir()` limits in the threads pool |
| https://vitest.dev/guide/mocking/timers | 200 OK, re-read | `waitFor`/`waitUntil` and `expect.poll` advance fake timers |
| https://vitest.dev/api/vi | 200 OK, re-read | `stubEnv`, `stubGlobal` and unstub helpers; `waitFor` defaults 1000 and 50 (stated in code comments only) |
| https://vitest.dev/config/retry | 200 OK, re-read | Default 0; object form marked 4.1.0+ (page shows v5.1.2) |
| https://vitest.dev/config/testtimeout | 200 OK, re-read | 5,000 ms Node, 15,000 ms in browser mode |
| https://vitest.dev/config/hooktimeout | 200 OK, re-read | 10,000 ms Node, 30,000 ms in browser mode |
| https://jestjs.io/docs/timer-mocks | 200 OK, re-read | `runAllTimers` aborts after 100000 timers; `runOnlyPendingTimers`; `useRealTimers` |
| https://jestjs.io/docs/cli | 200 OK, re-read | `--runInBand`, `--maxWorkers`, `--shard`, `--detectOpenHandles`, `--forceExit`, `--testTimeout` (5000) |
| https://docs.pytest.org/en/stable/how-to/tmp_path.html | 200 OK, re-read | `tmp_path`, `--basetemp` is cleared, last 3 base directories kept |
| https://docs.pytest.org/en/stable/how-to/fixtures.html | 200 OK, re-read | Reverse teardown order; one state-changing action per fixture |
| https://pytest-xdist.readthedocs.io/en/stable/distribution.html | 200 OK, re-read | `-n`, `--dist` modes, `xdist_group` |
| https://nodejs.org/api/test.html | 200 OK, first 100,000 characters read; rest checked by grep on the markdown source | Process isolation default, `mock.timers`, `context.waitFor` exists, tag filter (Stability 1.0, v26.2.0), `--test-randomize` (Stability 1.0, v26.1.0) |
| https://nodejs.org/api/cli.html | Markdown source fetched with curl | `--test-concurrency` flag entry |
| https://nodejs.org/api/net.html | 200 OK, re-read | Port 0 and `server.address().port` after `listening` |
| https://nodejs.org/api/fs.html | Page text cut off before the sections; confirmed from the markdown source with curl | `mkdtemp` trailing separator; `rm` `maxRetries` and `retryDelay` for `EBUSY`, `EMFILE`, `ENFILE`, `ENOTEMPTY`, `EPERM` |
| https://nodejs.org/api/process.html | 200 OK, first 100,000 characters read | Env names case-insensitive on Windows; `SIGTERM` unsupported on Windows; kill emulation for `SIGINT`, `SIGTERM`, `SIGKILL` |
| https://nodejs.org/api/child_process.html | 200 OK, first 100,000 characters read | Env case rule; `.bat`/`.cmd` need a shell; `spawn` with `shell` not recommended (DEP0190) |
| https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs | 200 OK (redirects to the how-tos run-job-variations page) | `include`, `exclude`, `fail-fast`, `continue-on-error`, `max-parallel` |
| https://docs.github.com/en/actions/using-jobs/using-concurrency | 200 OK (redirects to the how-tos control-workflow-concurrency page) | Groups, `cancel-in-progress`, pending replacement, case-insensitive names |
| https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax | 200 OK, checked by curl | Job `timeout-minutes` default 360; step `timeout-minutes` max 360, positive integer |
| https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html | 200 OK, body read via curl | Flaky definition; 1.5% runs, almost 16% tests, 84% transitions; 3-in-a-row marker; auto-quarantine can mask a race |
| https://testing.googleblog.com/2017/04/where-do-our-flaky-tests-come-from.html | 200 OK, body read via curl | 0.5%, 1.6% and 14% flaky by size over a week; r2 0.82 (binary size) and 0.76 (RAM) |
| https://testing.googleblog.com/2020/12/test-flakiness-one-of-main-challenges.html | 200 OK, body read via curl | Four-component taxonomy, hermetic environments |
| https://martinfowler.com/articles/nonDeterminism.html | 200 OK, re-read | Quarantine (examples: eight tests, one week), isolation, no bare sleeps, clock wrapping, doubles, pool-of-one leak trick |
| Third-party skill on CI test reliability (local project skill) | Read for ideas, no text reused; license not verified | Idea checklist only |

Dropped: the 2008 Google "avoiding flaky tests" post (404, never read); the Vitest guide and mocking index pages (nothing adopted).

## Reading limits

- Long Node pages were read in part; the cited sections were confirmed from the markdown source. Interactive examples were not run.
- Windows file-system behavior (busy files, case sensitivity, timestamp granularity, paths, line endings) is labeled known or inferred in the Windows reference; no OS documentation was fetched, only Node's own statements.
- Python `socket.bind` to port 0 is general knowledge; Python docs were not fetched.
- Google figures come from one company's corpus (2016 and 2017 posts) and are priors, not universal rates.
- Jest and pytest pages were read only for the flags and fixtures named. This skill has no scripts or data files, so none were skipped.

## Claims not adopted as fact

- Google percentages are reported only as "reported by the authors".
- A reader comment on the 2020 post (triage by real-failure risk) is a reader's view, not Google policy.
- Fowler's numeric quarantine limits are his examples, not standards.
- That a retry makes a test reliable, or that serial runs are a neutral cost, is not adopted from any source.
- Node's tag filter and randomize flags are early-development features; not recommended as stable mechanisms.
- A 256-job matrix limit was not found on the fetched page and is not claimed.
