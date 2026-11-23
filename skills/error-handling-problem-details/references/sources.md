# Sources — Error Handling: Problem Details, Result Pipelines & Leak-Safe Responses

Every URL below was checked during skill authoring (2026-11-23).

Note: Firecrawl had no credits left on the authoring date, so pages were read through WebFetch (markdown conversion plus extraction by a small model). Content is paraphrased from those extractions; RFC text was not read verbatim.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.rfc-editor.org/rfc/rfc9457.html | 200 OK (WebFetch) | Media types, five standard members and their rules, extension members and naming, defining problem types, registry (only `about:blank`), multiple-problem guidance, security considerations, changes from RFC 7807 |
| https://fsharpforfunandprofit.com/rop/ | 200 OK (WebFetch) | Landing page: recipe components (bind, Kleisli, map, tee, exception mapping, `&&&`), "not a monad tutorial", caution against extremes. The page is brief, so mechanics come from the extra page below |
| https://fsharpforfunandprofit.com/posts/recipe-part2/ | 200 OK (WebFetch) — one extra in-series page, not in the assignment list | Two-track model, bind, `>=>`, switch, map, tee, tryCatch, doubleMap, plus/`&&&` accumulation, same-error-type rule, adapters-vs-shapes |
| https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html | 200 OK (WebFetch) | Reconnaissance rationale, global handler objective, generic client response + server log, 4xx vs 5xx, per-stack patterns (Spring, ASP.NET Core, Web API), RFC 7807/9457 reference. The page has no separate "testing" or "what not to leak" sections; those parts of the skill are labelled own synthesis |
