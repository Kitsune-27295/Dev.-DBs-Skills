# Sources - Monolithic Architecture

Every URL below was checked during skill authoring (2026-11-27, re-fetched with a web fetch tool; earlier text was a draft).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/bliki/MonolithFirst.html | 200 OK, read in full; article dated 2015-06-03, no revisions shown | Monolith-First thesis, arguments, four evolution paths, counter-argument, experience rule, tentative evidence |
| https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures | 200 OK, read in full (English edition; the earlier draft cited the Portuguese one); metadata updated 2026-07-08 | Monolith definition, all-in-one vs layered, containers, when a monolith is the better choice |
| https://aws.amazon.com/compare/the-difference-between-monolithic-and-microservices-architecture/ | 200 OK, read in full | Comparison dimensions, choice criteria, four-step migration outline |

## Reading limits

- Pages were read through a summarizing fetch tool; table rows and short quotes were checked, long passages were not compared word for word.
- AWS is a vendor page that frames microservices as the destination.

## Claims not adopted as fact

- Stefan Tilkov's view that a team unable to build a good monolith will not build good services: Fowler's page only thanks Tilkov in its acknowledgements; his own article was not read, so the claim was dropped.
- "Scaling a successful but crude system is the better problem to have" and "even experienced architects misplace boundaries in familiar domains": not found on the fetched page.
- The observation that almost all successful microservice stories began as monoliths is Fowler's anecdotal impression, not data.
- Reading the evolution paths as a ranking: Fowler lists them as options, not preferences.
