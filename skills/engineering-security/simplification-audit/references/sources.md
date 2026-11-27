# Sources — Simplification Audit

Every URL below was re-fetched on 2026-11-27 (earlier check: 2026-11-24). Statuses are HTTP codes from the fetch; content was then read as extracted text.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Martin Fowler — Yagni](https://martinfowler.com/bliki/Yagni.html) | 200 OK, re-read 2026-11-27 | Presumptive features, the four costs (build, delay, carry, repair), the cited two-in-three failure odds, what YAGNI does not apply to, link to refactoring. |
| [Refactoring Guru — Dead Code](https://refactoring.guru/refactoring/smells/dead-code) | 404 again on 2026-11-27 (the URL in the brief) | Not read at this address. |
| [Refactoring Guru — Dead Code (canonical variant)](https://refactoring.guru/smells/dead-code) | 200 OK on 2026-11-27 (variant without `/refactoring/`) | Signs, reasons, treatments (delete, Inline Class, Collapse Hierarchy, Remove Parameter), IDE advice. |
| [Hyrum's Law](https://www.hyrumslaw.com) | 200 OK, re-read 2026-11-27 | The law's statement and the "implicit interface" implications for changes and removals. |
| [Martin Fowler — Parallel Change](https://martinfowler.com/bliki/ParallelChange.html) | 200 OK, re-read 2026-11-27 | Expand, migrate, contract; when it applies; the dependence on consumer cooperation and the warning about skipping contract. Recipe now owned by `parallel-change-expand-contract`. |
| [Martin Fowler — Refactoring (bliki)](https://martinfowler.com/bliki/Refactoring.html) | 404 again on 2026-11-27 | Not read at this address. |
| [refactoring.com](https://refactoring.com/) | 200 OK, re-read 2026-11-27 | Definition of refactoring: behavior-preserving structure change in small steps with frequent testing. |
| [Martin Fowler — Branch by Abstraction](https://martinfowler.com/bliki/BranchByAbstraction.html) | 200 OK, re-read 2026-11-27 | Gradual replacement behind an interface, five steps; now owned by `parallel-change-expand-contract`, kept here only as the removal route pointer. |
| [Software Engineering at Google — Deprecation (ch. 15)](https://abseil.io/resources/swe-book/html/ch15.html) | 200 OK, re-read 2026-11-27 (confirmed: temporary turn-off tests, renaming implementation-only symbols, global test suite as oracle) | Code as liability, advisory vs compulsory deprecation, warnings, owners, measuring usage (static, runtime, tests, probing), backsliding prevention. |

## Ideas-only source (no text reused)

- Third-party skill read for ideas, no text reused (a "find simplifications" skill from a third-party harness; license not confirmed, no path cited): contributed the question-style discovery prompts (complete effect path, distinctions that change a consumer's action, smaller explicit behavior, authoritative value, composition versus policy, full maintenance cost), the consumer-evidence rule, the candidate record with rejected alternatives and strongest reason to retain, domain-split delegation, and the requirement that a survey is not permission to implement. Wording and structure here are original.

## Reading limits

- Pages were read as extracted text on 2026-11-27 (curl plus text extraction, not rendered). Fowler's "Yagni" says the odds are at least two in three that a presumptive feature is unnecessary, citing Kohavi et al. (only a third of features at a large software company improved their target metrics); the underlying study was not read.
- No scripts, SQL or data files exist in this skill; nothing was run.
- The Dead Code page did not say when the smell can be ignored; the audit's evidence rules are the skill's own.
- The book chapter was summarized, not read verbatim end to end.
- Wikipedia and vendor pages were not used for this skill.

## Claims not adopted as fact

- "At least two in three presumptive features are unnecessary" is Fowler's extrapolation from a study of metric improvement, repeated here only as a reported figure. An earlier draft called it a study of "unnecessary" features; corrected 2026-11-27.
- That a good IDE finds all dead code: only static, in-project references; dynamic and external consumers need the search and runtime methods in the skill.
- Any specific count of removable items from third-party material: not transferred.
- Brownouts and renames as probes are practices described in the deprecation chapter for a large organization; their cost-benefit in a small project is untested here.
