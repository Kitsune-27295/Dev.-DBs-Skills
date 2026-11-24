# Rule Conflicts and Resolutions

Sources: https://grugbrain.dev/ · https://github.com/joshuadavidthomas/agent-skills/blob/main/grug-brained-dev/SKILL.md · https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29 · https://github.com/victorcorcos/clean-code · https://github.com/tahsinature/coding-principles · https://refactoring.guru/refactoring/smells · Last verified 2026-11-24

Real duplications are resolved to one canonical statement and one owner; coincidental agreements are noted as such (method: `ssot-and-dry`). Ousterhout's deep-module idea is cited as endorsed by the Grug essay's reading list (it names *A Philosophy of Software Design*); the book itself was not read for this file, so that part is labeled as background knowledge, not read from source. Sources covered by other files (Google, kernel, Power of 10, TigerStyle, comments) are cross-referenced only.

## Part A: Duplications (moved)

Agreements among sources (KISS, YAGNI, SRP, DRY, no commented-out code, flag arguments) are recorded once, with owner and agreement status, in [rule-registry.md](rule-registry.md). Several of those sources descend from the same book, so their agreement is one lineage, not independent confirmation. This file keeps only real conflicts.

## Part B: Real conflicts (ids CF-01 to CF-12)

### CF-01 DRY vs locality of behavior
- G/V/T: extract repeated code into a parameterized function. Grug: simple repetition beats an abstraction with callbacks; keep code near what it affects.
- Distinction: duplicated knowledge (a rule, a constant, a format) vs duplicated shape. V's greeting example merges shape; `ssot-and-dry` insists on knowledge.
- Decision: extract when the copies must change together; otherwise keep local copies. Two copies are fine, three with the same reason to change become a helper. A helper that needs a mode flag or callbacks to serve its callers was extracted too early: split it again.

```python
# Same knowledge: one home
VAT_RATE = 0.23
def gross(net): return net * (1 + VAT_RATE)
# Same shape, different facts: leave both local
def shipping_label(o): return f"{o.name}\n{o.street}"
def invoice_header(o): return f"{o.name}\n{o.street}"   # may diverge
```

### CF-02 Small functions vs deep modules
- G/V: functions small, ideally one thing; V's SRP example splits a short routine into four private methods.
- Ousterhout-style view (background knowledge, not read): prefer modules with a small interface hiding substantial logic; too many tiny pieces raise reader load. Grug agrees in practice: file-hopping and layer toll are costs.
- Decision: split a function when a block has a name, its own inputs and outputs, and can be understood or tested alone, or when it mixes abstraction levels. Do not split a linear 30-line flow only to hit a size target. Prefer a narrow public interface over many small public pieces. Private helpers used once need a reason beyond "it is long".

### CF-03 Prefer polymorphism / DI / value objects (G) vs Grug "no fake abstraction"
- G recommends them as defaults; Grug and the Guru smells (Speculative Generality, Lazy Class) flag them when used early.
- Decision: use a pattern when the variation or invariant already exists (two types, two environments, a repeated validation). One case: plain code, no interface. Owners: `open-closed-principle`, `dependency-inversion-composition-root`, `value-objects-type-invariants`.

### CF-04 Comments
- V says avoid comments and refactor; G allows several comment kinds; Google, kernel and TigerStyle generally ask for why-comments and sometimes more.
- Decision: defer entirely to [comments-why-not-what.md](comments-why-not-what.md), which resolves the what/why, ban and TODO disagreements (CM-01 to CM-06).

### CF-05 Extract named conditions vs expression locality
- V/G: extract complex conditionals into a named function; Grug: name the pieces but a local variable beats a far-away helper.
- Decision: first a named local; a function only if reused or testable on its own.

### CF-06 Refactor-as-you-go vs Chesterton's fence and small steps
- G: boy scout rule (leave it cleaner). Grug: understand why before removal; keep refactors small.
- Decision: clean what you touch, limited to the diff's purpose; investigate before deleting checks that look pointless; never mix a rewrite with a feature.

### CF-07 Early abstraction for testability vs integration-first tests
- G: fast, independent tests, one assert per test; Grug: integration tests at stable seams, mock sparingly.
- Decision: do not add interfaces solely to mock; test at the seam that exists (owner `testing-pyramid-and-shapes`, `tdd`).

### CF-08 Performance vs clarity
- V: write clear code first (Knuth/Beck quotes); Grug: profile first. These agree; combined rule: no obscure micro-optimization without a measurement.

### CF-09 Numeric function-size limits
- Sources: kernel gives screens, 5-10 locals and a 3-level nesting warning, no line count; Power of 10 about 60 lines; TigerStyle 70; the heuristics summaries say "small" with no number.
- Decision: the project's linter or style config wins. Without one, use the numbers only as smell triggers and cite the source and its codebase (kernel, Power of 10 for C safety-critical code, TigerStyle for a Zig database); never present one as universal. Nesting depth and number of branches matter more than raw lines; a long flat dispatch passes, a short deeply nested function does not.

### CF-10 Assertions and defensive checks vs defensive clutter
- Power of 10 and TigerStyle want assertions and checked returns everywhere; the grug-style sources flag defensive wrappers as bloat.
- Decision: validate untrusted input at the boundary and return errors; assert only states that cannot happen; add no check whose failure you cannot name and nobody would observe. Never pad to a count (EB-01 to EB-03).

### CF-11 Stricter rule wins vs project conventions
- One contract system says the stricter rule wins in conflicts; the style guides say the existing code and configured style win.
- Decision: project conventions and configured tools win on style; for safety, the stricter rule wins. Neither means adding process the project does not use (CN-01).

### CF-12 Short scoped names vs no abbreviations
- Kernel: local names short, length follows scope (`i`, `tmp`). TigerStyle and the heuristics summaries: no abbreviations, descriptive names.
- Decision: loop indices and tiny-scope temporaries may be short; anything that crosses a function boundary or lives long gets a full word (NAM-01, NAM-02). Unit suffixes stay (NAM-03).

## How an agent should apply this

- When two rules pull opposite ways, pick the one that reduces total reader effort across the files a change touches, and say so in one line.
- Treat any rule that adds a file, interface or layer as needing evidence of current use.
- Extract only for shared knowledge or a real boundary; otherwise keep code local and plain.
- Keep the public surface narrow and put substantial logic behind it, instead of chasing a function-size number.
- Resolve disagreements with the project's own conventions first, then this table.
