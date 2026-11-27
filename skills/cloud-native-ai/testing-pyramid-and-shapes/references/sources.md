# Sources — Testing Pyramid and Shapes

Every URL below was re-checked on 2026-11-27 (first authored 2026-11-22).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Ham Vocke and Martin Fowler, "The Practical Test Pyramid" (dated 2018-02-26), https://martinfowler.com/articles/practical-test-pyramid.html | 200 OK, 2026-11-27 (summarizing fetch, two passes) | Layers, solitary/sociable, stubs vs mocks, in-memory database risk, consumer-driven contracts with Pact, WireMock stub, E2E flakiness, subcutaneous tests, central QA team anti-pattern, the two anti-duplication rules, DAMP and Rule of Three, stage placement by speed and scope, Mike Cohn credited, ice-cream cone |
| Martin Fowler, "On the Diverse And Fantastical Shapes of Testing" (dated 2021-06-02), https://martinfowler.com/articles/2021-test-shapes.html | 200 OK, 2026-11-27 | Jay Fields coined solitary/sociable, Beck's meaning of unit test, honeycomb "unit" equals solitary so the debate is moot, Searls on boundaries over percentages |
| Kent C. Dodds, "Write tests. Not too many. Mostly integration." (page byline 2019-07-13), https://kentcdodds.com/blog/write-tests | 200 OK, 2026-11-27 | Trophy levels (static, unit, integration, end to end), Rauch quote (post of 2016-12-10), mock less, no implementation details, coverage mandate a bad idea, invented ~70% figure |
| André Schaffer and Rickard Dybeck, "Testing of Microservices", Spotify Engineering (2018-01-11), https://engineering.atspotify.com/2018/01/testing-of-microservices | 200 OK, 2026-11-27 (added 2026-11-27) | Primary source of the honeycomb: integration tests the bulk, implementation-detail tests fewer, integrated tests fewest and ideally none |
| Naina Garg, "The Test Pyramid Is Outdated", https://medium.com/@tonainagarg/the-test-pyramid-is-outdated-heres-what-replaced-it-f9795e5f2615 | HTTP 403 on 2026-11-22 and 2026-11-27 | Not read; not used |

## Reading limits

- All pages were read through summarizing fetches; quotes are paraphrased or short.
- The Spotify post was read only as a summary; whether it also covers contract tests was not confirmed.
- The Medium article was never read.
- No scripts, SQL or data files are in this skill.

## Claims not adopted as fact

- "Hourglass" as an anti-pattern: absent from the Fowler articles read; removed.
- "Test allocation ratios": no source gives percentages; the old description's claim is removed. Dodds's 70% is self-described as invented.
- Spring Cloud Contract: not mentioned in the article; removed.
- Fowler's 2021 text does not attribute the two shape pictures to Dodds or Spotify; the Spotify attribution rests on the Spotify post.
- The mapping of shape to architecture (domain engine, web app, service fleet) is this skill's synthesis; Dodds ties his trophy to front-end tooling.
- Adoption figures and "risk-based testing" claims from the unread Medium article.
