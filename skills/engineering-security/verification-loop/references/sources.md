# Sources — Verification Loop

Every URL below was re-fetched during the rebuild on 2026-11-27 (WebFetch). Pages were read through a fetch tool that summarizes the page; statuses are real. Statements marked "this skill's synthesis" in the references are own inferences, not claims of the sources.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.anthropic.com/research/building-effective-agents | 200 OK, re-read | Evaluator-optimizer workflow; stopping conditions such as a maximum number of iterations; ground truth from the environment at each step; sandbox testing |
| https://code.claude.com/docs/en/best-practices | 200 OK, re-read | Give the agent a pass/fail check; ask for evidence (command and output); `/code-review` runs in a fresh subagent that never saw the conversation; custom reviewer limited to read-only tools, enforced by the harness; Stop hook blocks and ends the turn after eight consecutive blocks by default (`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` raises it); "skip style" warning; `/verify` runs the app to catch what tests miss (added 2026-11-27) |
| https://scrumguides.org/scrum-guide.html | 200 OK, re-read | Work that does not meet the Definition of Done cannot be released or presented and returns to the backlog |
| https://google.github.io/eng-practices/review/reviewer/looking-for.html | 200 OK, re-read | Reviewers ask whether tests will fail when the code is broken and whether they start giving false positives |
| https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html | 200 OK; only comments and the first 100,000 characters were captured, article body not confirmed | Nothing adopted; no longer cited by any reference |
| https://martinfowler.com/bliki/TestCoverage.html | 200 OK, re-read | Coverage finds untested code, not test quality; assertion-free tests inflate it; targets invite gaming |
| https://martinfowler.com/bliki/SelfTestingCode.html | 200 OK, re-read | Self-testing code catches a bug soon after it appears, so recent changes are the suspects |
| https://en.wikipedia.org/wiki/Mutation_testing | 200 OK, re-read | Mutants, killed versus survived, score as killed over total, equivalent mutants |
| https://en.wikipedia.org/wiki/Test_oracle | 200 OK, re-read | Specified, derived, implicit and human oracles and their pitfalls |
| https://en.wikipedia.org/wiki/Verification_and_validation | 200 OK, re-read | Verification versus validation; independent V&V by a disinterested third party; terms are not used consistently |
| https://www.nasa.gov/ivv-overview/ | 200 OK, re-read | IEEE technical, managerial and financial independence; value of independence |
| https://sre.google/sre-book/postmortem-culture/ | 200 OK, re-read | "An unreviewed postmortem might as well never have existed"; review criteria. It does not require reviewers to be independent of the incident team |
| Third-party skills on closed-loop verification, loop engineering and verification-before-completion (MIT, private install) | Read for ideas, no text reused | Acceptance IDs tied to evidence rows; maker is not the grader; layered termination exits; revert-the-fix proof |

Dropped: Wikipedia "Independent verification and validation" (404); the Google 2008 "test behavior not implementation" post (404, guessed slug); the Fowler "TestingLanguage" page (off-topic).

## Reading limits

- Pages were read through a summarizing fetch tool; quotes are from its output, not the raw HTML. The Google 2015 post body was not captured.
- Lane names, the default of 3 rounds per AC, the 6 and 10 task-round caps and the L0 to L3 independence levels are this skill's own defaults, not figures from any source.
- No scripts or data files exist in this skill.

## Claims not adopted as fact

- That an independent verifier always catches what the maker missed: sources show independence adds value, not a guarantee.
- That mutation score or coverage proves test quality: sources say they are signals only.
- Any rate or threshold for retry caps beyond the "maximum number of iterations" principle.
