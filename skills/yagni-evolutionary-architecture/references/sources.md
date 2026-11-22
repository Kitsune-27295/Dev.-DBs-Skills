# Sources for the yagni-evolutionary-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize Martin Fowler's essays on YAGNI and evolutionary design, marking empirical statistics and timing estimates as practitioner claims (`*claim*`).

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Martin Fowler, "Yagni" (2015-05-26), https://martinfowler.com/bliki/Yagni.html | Origin from Kent Beck & Chet Hendrickson (C3 project); definition of **presumptive feature**; the **4 YAGNI costs** (**Build**, **Delay**, **Carry**, **Repair**); *"imagine the refactoring"* heuristic; critical boundary that **YAGNI applies to speculative features/abstractions, never to effort that makes code easier to modify** (testing, CI, refactoring); Kohavi et al. stat and availability-bias note. |
| 2 | Martin Fowler, "Is Design Dead?" (May 2004 / XP 2000), https://www.martinfowler.com/articles/designDead.html | Contrast between planned Big Design Up Front, ad-hoc "code and fix" entropy, and XP **Evolutionary Design**; flattening the software change curve via **Enabling Practices** (**Testing**, **Continuous Integration**, **Refactoring**); Kent Beck's 4 rules of Simple Design; introducing patterns incrementally; **Reversibility** (Enrico Zaninotto) and **The Will to Design** (watching whether obsolete code gets deleted); choosing a modest starting architecture without over-investing. |
| 3 | Martin Fowler, "Design Stamina Hypothesis" (2007-06-20), https://martinfowler.com/bliki/DesignStaminaHypothesis.html | Cumulative delivery vs. time trade-off between good design and no-design; the **Design Payoff Line** above which neglecting design yields illusory speed gains; framing Technical Debt against the Design Payoff Line. |
| 4 | Martin Fowler, "Sacrificial Architecture" (2014-10-20), https://martinfowler.com/bliki/SacrificialArchitecture.html | Designing systems expecting replacement as load/requirements shift by orders of magnitude (eBay 1995→1997→2002 case); Jeff Dean's rule of thumb; why **sacrificial architecture still demands clean internal modularity** (and usually favors a **monolith** over microservices); avoiding amortization/accounting lock-in; sacrificing individual modules as a system matures. |

## Notes on Claims & Citations

- **Empirical & Judgment Claims (`*claim*`):**
  - Source 1 cites **Kohavi et al.** (*ExP Think Week 2009* at Microsoft) reporting that roughly **only ⅓** of evaluated deployed features improved the metrics they targeted (**⅔** did not) (`*claim*`).
  - Source 3 explicitly classifies the **Design Stamina Hypothesis** as an unproved conjecture/axiom and states Fowler's judgment that the **Design Payoff Line** is much lower than many assume — **"weeks not months"** (`*claim*`).
  - Source 4 cites **Jeff Dean** (*Google WSDM 2009 Keynote*): *"design for ~10X growth, but plan to rewrite before ~100X"* (`*claim*`), as a practitioner rule of thumb rather than a universal law.
