# Sources — Verification Loop

Every URL below was checked during skill authoring (2026-11-24). Pages were read with a fetch tool that summarizes the page; statuses are real. Statements marked "this skill's synthesis" in the references are own inferences, not claims of the sources.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.anthropic.com/research/building-effective-agents | 200 OK | Evaluator-optimizer workflow and when it fits; stopping conditions such as a maximum number of iterations; ground truth from the environment at each step; sandbox testing because errors compound. Page notes some tooling has changed since its publication. |
| https://code.claude.com/docs/en/best-practices | 200 OK | Give the agent a pass/fail check; ask for evidence (command and output); fresh-subagent review that did not see the reasoning; read-only reviewer enforced by tool limits; Stop-hook block limit; "skip style" warning for reviewers; runtime verification catches what tests miss. |
| https://scrumguides.org/scrum-guide.html | 200 OK | Definition of Done as a formal state work must reach; work that does not meet it does not count toward the increment. |
| https://google.github.io/eng-practices/review/reviewer/looking-for.html | 200 OK | Reviewers ask whether tests would fail when the code breaks and whether they can give false positives; tests are code to maintain. |
| https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html | 200 OK (only the first ~100,000 characters of the page were read, mostly reader comments after the post) | A useful test is a fast, reliable signal that points to the cause; slow flaky suites lengthen feedback loops. |
| https://martinfowler.com/bliki/TestCoverage.html | 200 OK | Coverage shows untested code, not test quality; tests without assertions inflate it; targets invite gaming. |
| https://martinfowler.com/bliki/SelfTestingCode.html | 200 OK | A self-testing suite catches new bugs soon after they appear, which is what makes changes safe. |
| https://en.wikipedia.org/wiki/Mutation_testing | 200 OK | Mutants, killed versus survived, mutation score, equivalent-mutant problem. |
| https://en.wikipedia.org/wiki/Test_oracle | 200 OK | Oracle kinds (specified, derived, implicit, human) and their pitfalls. |
| https://en.wikipedia.org/wiki/Verification_and_validation | 200 OK | Verification versus validation; independent V&V as a disinterested third party. |
| https://www.nasa.gov/ivv-overview/ | 200 OK | IEEE's three independence parameters (technical, managerial, financial) as cited by NASA IV&V; added value of independence. |
| https://sre.google/sre-book/postmortem-culture/ | 200 OK | Postmortems are reviewed for completeness of data, impact and root cause; the unreviewed-postmortem remark. It does not say reviewers must be independent of the incident team. |
| https://en.wikipedia.org/wiki/Independent_verification_and_validation | 404 (page does not exist under this title; the Verification_and_validation page above was used instead) | Nothing. |
| https://testing.googleblog.com/2008/10/testing-on-toilet-test-behavior-not.html | 404 (guessed slug, not a real page) | Nothing; not used. |
| https://martinfowler.com/bliki/TestingLanguage.html | 200 OK but off-topic (acceptance-test languages) | Nothing; not used. |
| Third-party skill read for ideas, no text reused (closed-loop verification harness with numbered acceptance criteria, evidence rows, fresh-context read-only verifier, retry cap; MIT license) | Read locally (private install) | Idea: acceptance IDs tied to evidence rows; the maker is not the grader; lane-based ceremony. Own wording and structure throughout. |
| Third-party skill read for ideas, no text reused (shared loop-engineering reference: verifier, hard cap, budget, no-progress detection, human escalation; MIT license) | Read locally (private install) | Idea: layered termination exits with a verifier plus at least one safety exit. Own wording throughout. |
| Third-party skill read for ideas, no text reused (verification-before-completion: no completion claim without fresh evidence; MIT license) | Read locally (private install) | Idea: evidence before claims; revert-the-fix proof for regression tests. Own wording throughout. |
