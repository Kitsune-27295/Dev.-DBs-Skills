# Sources — Error Handling: Problem Details, Result Pipelines & Leak-Safe Responses

Every URL below was checked during skill authoring (2026-11-23).

Note: Firecrawl had no credits left on the authoring date, so pages were read through WebFetch (markdown conversion plus extraction by a small model). Content is paraphrased from those extractions; RFC text was not read verbatim.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.rfc-editor.org/rfc/rfc9457.html | 200 OK (WebFetch) | Media types, five standard members and their rules, extension members and naming, defining problem types, registry (only `about:blank`), multiple-problem guidance, security considerations, changes from RFC 7807 |
| https://fsharpforfunandprofit.com/rop/ | 200 OK (WebFetch) | Landing page: recipe components (bind, Kleisli, map, tee, exception mapping, `&&&`), "not a monad tutorial", caution against extremes. The page is brief, so mechanics come from the extra page below |
| https://fsharpforfunandprofit.com/posts/recipe-part2/ | 200 OK (WebFetch) — one extra in-series page, not in the assignment list | Two-track model, bind, `>=>`, switch, map, tee, tryCatch, doubleMap, plus/`&&&` accumulation, same-error-type rule, adapters-vs-shapes |
| https://github.com/swlaschin/railway-oriented-programming-example | 200 OK (added 2026-11-27, moved from `defensive-domain-modeling`) | Example repo contrasting C# nested error handling with a flat F# two-track pipeline. |
| https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html | 200 OK (WebFetch) | Reconnaissance rationale, global handler objective, generic client response + server log, 4xx vs 5xx, per-stack patterns (Spring, ASP.NET Core, Web API), RFC 7807/9457 reference. The page has no separate "testing" or "what not to leak" sections; those parts of the skill are labeled own synthesis |
| http://www.gotw.ca/gotw/059.htm | 200 OK (curl, HTML stripped) (added 2026-11-24) | Basic, strong and no-throw exception-safety guarantees as summarized from Abrahams |
| https://en.wikipedia.org/wiki/Exception_safety | 200 OK (curl) (added 2026-11-24) | Guarantee levels and the invariant view |
| https://erlang.org/download/armstrong_thesis_2003.pdf | 200 OK (PDF, text extracted) (added 2026-11-24) | "Let some other process fix the error", let it crash, error versus exception |
| https://www.erlang.org/doc/system/sup_princ.html | 200 OK (curl) (added 2026-11-24) | Supervisor responsibilities, restart strategy and intensity |
| https://en.wikipedia.org/wiki/Design_by_contract | 200 OK (curl) (added 2026-11-24) | Contract vocabulary (pre, post, invariant). Meyer's paper at https://se.inf.ethz.ch/~meyer/publications/computer/contract.pdf returned 200 but is a scanned image, not text-read |
| Third-party skill read for ideas, no text reused (added 2026-11-24) | local, license not visible | Idea list: recovery owner, guarantees, logging is not recovery, typed failures, visible reporting |

Note (added 2026-11-24): gotw.ca over https failed to connect; the http variant worked. Sutter's and Meyer's books were not read.
