# Harvard Kempner Handbook: Design Principles for Research Code

Sources: https://handbook.eng.kempnerinstitute.harvard.edu/s2_swe_for_research/software_design_principles.html · Last verified 2026-11-27

A Python-flavored chapter (section 6, subsections 6.1 to 6.13) that presents principles as defaults to be applied with judgment. It anchors SKILL.md section 4.

## What the page covers

- **Fundamentals (6.1):** KISS, DRY (one authoritative version of each piece of logic; example: one `standardize` function), YAGNI, separation of concerns (split loading, computing, plotting), single responsibility, clarity over cleverness.
- **Modularity (6.2):** high cohesion, low coupling, information hiding. Following Parnas, draw boundaries around decisions likely to change, such as file formats (example: hide CSV reading behind `load_dataset`).
- **Testability (6.3):** pure functions; separate computation from I/O with a thin wrapper (`mean` pure vs `mean_from_file`); inject dependencies so tests can substitute doubles; avoid hidden global mutable state.
- **Extensibility (6.4):** parameterize constants, apply Open/Closed, pass behavior as a function (a light Strategy, e.g. passing `mse` or `mae` into `evaluate`), do not over-generalize before a second real use case.
- **Patterns (6.5):** use patterns only when they remove real pain; in Python plain functions often suffice; a name-to-class factory in one place is fine.
- **Dependencies (6.6):** Dependency Inversion with a thin adapter around volatile third-party libraries (`Storage` protocol, `S3Storage`, `FakeStorage`), library calls kept at the edges (ports and adapters).
- **Docs and decisions (6.7):** docstring is the interface contract; hard-to-document code often does too much; record significant decisions in ADRs.
- **Refactoring (6.8):** start simple, small steps under tests, treat smells as prompts not proof, separate refactor commits from behavior commits.
- **Functional vs OO (6.10):** neither universally better; default to functions plus simple data containers (`dataclass`) and avoid deep inheritance.
- **APIs and CLIs (6.11):** small public surface (`__all__`, leading underscore), specific error messages, thin CLI parsing with an importable `run()`.
- **Layers (6.12):** entry, orchestration, core, infrastructure; dependencies point toward a stable core that is free of I/O and UI; do not over-layer small scripts.

## Mapping to the skill, with corrections

| SKILL.md section 4 claim | What the page says |
|---|---|
| Pure core, thin I/O wrapper | Yes (6.3, 6.12); the page frames it as a testability rule and a "can the core run in a notebook?" test |
| Composition over inheritance | Not named; the page says avoid deep inheritance and default to functions plus data containers (6.10). Treat "composition over inheritance" as the skill's wording, supported only in spirit |
| Fail fast | Not named; the nearest is clear, specific errors (6.11, `split_dataset` raising `ValueError`) |
| KISS | Named (6.1) |

## Worked shape (my own sketch)

```python
def summarize(rows: list[dict]) -> dict:        # pure core
    return {"n": len(rows), "mean": sum(r["x"] for r in rows) / len(rows)}

def run(path: str, load=read_csv, write=print): # thin shell, I/O injected
    write(summarize(load(path)))
```

## Failure modes

- Over-layering a 100-line script (the page warns against it).
- Wrapping a stable stdlib module in an adapter "for DIP".
- Building a pattern (factory, strategy class) where a function parameter suffices.

## How an agent should apply this

- Default to functions and dataclasses; add classes only for state with lifecycle.
- Wrap volatile third-party libraries in one thin adapter and fake it in tests; do not wrap stable ones.
- Keep CLI/HTTP entry points thin and put logic in an importable function.
- Validate inputs at the boundary and raise specific errors with the offending value.
- Cite the page for KISS, pure core and DIP; do not cite it for "composition over inheritance" or "fail fast" by name.
