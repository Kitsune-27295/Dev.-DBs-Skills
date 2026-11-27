# Sources — Hexagonal Architecture

Every URL below was re-checked on 2026-11-27 (Last verified 2026-11-27). Fetched with WebFetch (Firecrawl had no credits); a small model summarized each page, so quotes are not verbatim.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://alistair.cockburn.us/hexagonal-architecture/ (added) | 200 | Original pattern: HaT report 2005.02 dated 2005-09-04, version 0.9; intent; primary and secondary ports; 2 to 4 ports typical; critique of layer drawings; inside/outside asymmetry. |
| https://jmgarridopaz.github.io/content/hexagonalarchitecture.html | 200 | Driver and driven actors, repository vs recipient, "for ...ing" port names, composition root steps, symmetry vs asymmetry, misconceptions, four-step build order, Pryce test types, pros, cons, when to use. |
| https://engsoftmoderna.info/artigos/arquitetura-hexagonal.html | 200 | Inbound and outbound port wording, inner and outer hexagon, domain independence, library example. |
| https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html | 200 (machine translation, English prevails) | Intent, applicability, DDD fit, testability, complexity, maintenance overhead, latency; Python Lambda sample structure. |
| https://github.com/aws-samples/aws-lambda-domain-model-sample | not fetched (linked from the AWS page) | Referenced only through the AWS page. |
| https://reflectoring.io/spring-hexagonal/ | 200 | Use cases, input and output ports, command validation, worth-it analysis. |
| https://github.com/jmgarridopaz/bluezone | 200 | Driver adapters, driven ports, adapter selection by properties file. GPL-3.0: ideas only. |
| https://github.com/emedina/hexagonal-spring-ref-app | 200 | Module layout, ArchUnit Hexagonal 1.0.0 rule list, in-memory repositories. MIT. |
| https://github.com/cod3rcursos/arq-hexagonal-simplificada | 200 | Two-module TypeScript example (core, adapters); no licence visible. |
| https://netflixtechblog.com/ready-for-changes-with-hexagonal-architecture-b315ec967749 | 403 (also curl) | Nothing adopted. |
| https://www.baeldung.com/hexagonal-architecture-ddd-spring | 403 (also curl) | Nothing adopted. |

## Reading limits

- Summaries came from a small model reading page text, not the raw pages. Code in the repositories was not read, only README-level descriptions.
- Scripts or data files: this skill has none; nothing was run.
- Third-party skill text: none reused. All wording is the skill author's own.

## Claims not adopted as fact

- Netflix numbers (a data-source swap in 2 hours, about 3000 specs in 100 s) and its three-layer test split: page unreachable.
- Baeldung claims (aggregate root invariants, manual domain-service wiring, swapping persistence and REST for CLI): page unreachable.
- The earlier draft's claim that the Medina project returns errors as `Either` values, and that the BlueZone README states fare rules: not visible on the pages read.
- The earlier draft's statement that Hombergs accepts framework annotations on use-case services and defers mapping strategies to his book: not visible in the page read.
- The earlier draft's attribution to Garrido of "the use case implements the driver port": Garrido defines the driver port as the API; the use-case-implements-port reading is Hombergs.
- Any measured benefit or cost of the pattern: every source argues costs without measurement.
- The earlier draft's section on one specific repository's folder layout: removed as project-internal.
