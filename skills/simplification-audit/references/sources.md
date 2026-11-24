# Sources — Simplification Audit

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Martin Fowler — Yagni](https://martinfowler.com/bliki/Yagni.html) | 200 OK | Presumptive features, the four costs (build, delay, carry, repair), the cited two-in-three failure odds, what YAGNI does not apply to, link to refactoring. |
| [Refactoring Guru — Dead Code](https://refactoring.guru/refactoring/smells/dead-code) | 404 (the URL in the brief) | Not read at this address. |
| [Refactoring Guru — Dead Code (canonical variant)](https://refactoring.guru/smells/dead-code) | 200 OK (variant without `/refactoring/`) | Signs, reasons, treatments (delete, Inline Class, Collapse Hierarchy, Remove Parameter), IDE advice. |
| [Hyrum's Law](https://www.hyrumslaw.com) | 200 OK | The law's statement and the "implicit interface" implications for changes and removals. |
| [Martin Fowler — Parallel Change](https://martinfowler.com/bliki/ParallelChange.html) | 200 OK | Expand, migrate, contract; when it applies; the dependence on consumer cooperation and the warning about skipping contract. |
| [Martin Fowler — Refactoring (bliki)](https://martinfowler.com/bliki/Refactoring.html) | 404 | Not read at this address. |
| [refactoring.com](https://refactoring.com/) | 200 OK | Definition of refactoring: behavior-preserving structure change in small steps with frequent testing. |
| [Martin Fowler — Branch by Abstraction](https://martinfowler.com/bliki/BranchByAbstraction.html) | 200 OK | Gradual replacement behind an interface, five steps. |
| [Software Engineering at Google — Deprecation (ch. 15)](https://abseil.io/resources/swe-book/html/ch15.html) | 200 OK | Code as liability, advisory vs compulsory deprecation, warnings, owners, measuring usage (static, runtime, tests, probing), backsliding prevention. |

## Ideas-only source (no text reused)

- Third-party skill read for ideas, no text reused (a "find simplifications" skill from a third-party harness; license not confirmed, no path cited): contributed the question-style discovery prompts (complete effect path, distinctions that change a consumer's action, smaller explicit behavior, authoritative value, composition versus policy, full maintenance cost), the consumer-evidence rule, the candidate record with rejected alternatives and strongest reason to retain, domain-split delegation, and the requirement that a survey is not permission to implement. Wording and structure here are original.

## Reading limits

- Pages were read through a fetch tool that returns a model-written summary, not raw HTML; wording was paraphrased. The Fowler "Yagni" figure (two in three) is as reported in that summary of the article, which attributes it to a Microsoft study; the underlying study was not read.
- The Dead Code page did not say when the smell can be ignored; the audit's evidence rules are the skill's own.
- The book chapter was summarized, not read verbatim end to end.
- Wikipedia and vendor pages were not used for this skill.

## Claims not adopted as fact

- "At least two in three presumptive features are unnecessary" is Fowler's citation of a third-party study, repeated here only as a reported figure.
- That a good IDE finds all dead code: only static, in-project references; dynamic and external consumers need the search and runtime methods in the skill.
- Any specific count of removable items from third-party material: not transferred.
- Brownouts and renames as probes are practices described in the deprecation chapter for a large organization; their cost-benefit in a small project is untested here.
