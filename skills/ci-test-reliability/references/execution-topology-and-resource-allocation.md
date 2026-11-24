# Execution Topology and Resource Allocation

Sources: https://vitest.dev/guide/parallelism · https://vitest.dev/guide/improving-performance · https://vitest.dev/guide/cli · https://jestjs.io/docs/cli · https://pytest-xdist.readthedocs.io/en/stable/distribution.html · https://docs.pytest.org/en/stable/how-to/tmp_path.html · https://nodejs.org/api/test.html · https://nodejs.org/api/net.html · https://nodejs.org/api/fs.html · https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations · https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency · https://martinfowler.com/articles/nonDeterminism.html · Last verified 2026-11-24

## Why topology comes first

A test that is correct alone can fail only when something else runs beside it. "Something else" has four layers, and each layer isolates different things. Most CI flakes are a mismatch between the layer a developer imagined and the layer that actually ran.

## What each layer isolates (from the docs)

**Vitest.** Test files run in parallel across workers by default; each file gets its own isolated environment. The default `forks` pool runs each file in a child process; `threads` uses worker threads. Inside one file, tests run sequentially unless marked `concurrent`, and concurrent tests share one worker (they only help when tests await something). With `test.concurrent`, `beforeAll`/`afterAll` still run once per group but `beforeEach`/`afterEach` run per test and may overlap. `maxWorkers` and `fileParallelism` control file-level parallelism; the docs name a shared database that cannot handle concurrent access as a reason to turn file parallelism off. `--shard=<index>/<count>` runs one slice of the suite. Per-file isolation can be turned off for speed (`isolate: false`), but then files in one worker share module state, so tests must not depend on a clean module graph.

**Jest.** `--maxWorkers` sizes the worker pool (a percentage is accepted), `--runInBand` (alias `-i`) runs everything serially in the current process, and `--shard=<index>/<count>` selects a slice. `--detectOpenHandles` helps find what keeps the process alive and implies serial running with a large slowdown, so use it for investigation only; `--forceExit` is described as an escape hatch that hides unreleased resources.

**pytest-xdist.** `-n N` / `-n auto` starts worker processes. `--dist load` hands tests to any free worker with no ordering guarantee; `loadscope` keeps a module or class together; `loadfile` keeps a file together; `loadgroup` keeps tests with the same `xdist_group` mark together; `worksteal` rebalances. Grouping is the right tool when a set of tests shares an expensive or non-shareable fixture. `tmp_path` is unique per test, and under xdist each worker's base temp directory is placed under one per-run directory.

**node:test.** By default each matching file runs in its own child process, limited by `--test-concurrency`. With isolation disabled all files are imported into one process and top-level tests run with concurrency one, so global state set in one file can leak into another.

**GitHub Actions.** Matrix jobs run as separate jobs; `max-parallel` caps simultaneous cells; `fail-fast` cancels the rest after a failure; `continue-on-error` can make an experimental cell non-blocking. `concurrency: group` allows one running job or workflow per group, replaces a pending one by default, and cancels a running one only with `cancel-in-progress: true` (group names are case-insensitive). Use these to serialize access to a genuinely shared external environment, not to hide test-side races.

## What no layer isolates

Process or worker isolation does **not** isolate: TCP/UDP ports on the host, predictable file paths, the system temp directory, databases and queues, environment inherited by child processes, container-level state, or another job running on the same self-hosted machine. Those need allocation discipline.

## Atomic allocation

The problem with "find a free one, then claim it" is the gap between the two steps. Let the owner of the resource do both at once.

```ts
// Node: the OS picks the port; read it only after 'listening'.
const server = net.createServer(handler);
await new Promise<void>(r => server.listen(0, '127.0.0.1', r));
const { port } = server.address() as net.AddressInfo;
```

Node's docs say that omitting the port or passing `0` makes the OS assign an arbitrary unused port, readable through `server.address().port` after the `listening` event. Python's `socket.bind(("127.0.0.1", 0))` follows the same OS convention (general knowledge, not read from a source for this skill).

Temporary directories:

```ts
// The prefix must end with the platform separator to create *inside* a directory.
const dir = await fs.mkdtemp(path.join(os.tmpdir(), "case-"));
// register cleanup now, not later
cleanup.push(() => fs.rm(dir, { recursive: true, force: true, maxRetries: 5, retryDelay: 50 }));
```

Node's `mkdtemp` appends six random characters to the prefix, so the prefix needs a trailing separator when a directory inside another is intended. In pytest, prefer the `tmp_path` fixture (unique per test) over hand-made paths. Note pytest keeps the last three base temp directories by default and clears a directory passed to `--basetemp` blindly before each run: never point `--basetemp` at a directory that holds anything else.

## Decision rules

| Situation | Choose |
|---|---|
| Files need a port, path or name | Per-test ephemeral allocation (bind to 0, `mkdtemp`, unique namespace) |
| A test needs a heavy fixture that cannot be duplicated | Group those tests onto one worker (`loadgroup`, a Vitest project, or a dedicated lane) |
| One shared service all tests mutate | A per-worker instance or unique per-test namespace; serialize only if neither is possible |
| Different jobs would collide on an external environment | Actions `concurrency` group on that job |
| Suspected leak between files | Run with the CI worker count and with isolation enabled; do not conclude from a single-process run |
| Test relies on a clean module graph | Keep per-file isolation on |

## Anti-patterns

- Serializing the whole suite because one fixture lacks isolation.
- A sequential block inside one file used to "protect" a host resource from other files.
- Hard-coded ports "that are rarely used".
- A scan for a free port followed by a later bind.
- Calling an exists-check before creating a path that must be new.
- Setting `--basetemp` to a shared directory.
- Treating a green single-worker run as proof of CI safety.

## How an agent should apply this

- Open the runner config and workflow; write down worker count, pool type, isolation, shard and matrix before reasoning about a failure.
- For each acquired resource, fill in owner, allocator, readiness signal, cleanup and quiescence signal; if any cell is empty, that is the bug.
- Replace fixed ports and shared paths with OS-allocated ones; keep expected-value literals untouched.
- Narrow serialization to the proven shared resource (group, project or concurrency group), and say what it protects.
- Validate with independent processes run concurrently when cross-process isolation is the claim.
