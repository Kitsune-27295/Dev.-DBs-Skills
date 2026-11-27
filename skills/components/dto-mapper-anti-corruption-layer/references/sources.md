# Sources — DTO, Mapper & Anti-Corruption Layer

Every URL below was re-fetched and re-read during the rebuild (2026-11-27). Earlier checks: 2026-11-23 and 2026-11-24.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/eaaCatalog/dataTransferObject.html | 200 OK (WebFetch, 2026-11-27) | DTO purpose (fewer remote calls), serializable, server-side assembler, naming history, 2013-08-11 note on serialization encapsulation |
| https://martinfowler.com/eaaCatalog/mapper.html | 200 OK (WebFetch, 2026-11-27) | One-line definition and the three when-to-use conditions |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer | 200 OK (WebFetch, 2026-11-27; page dated 2026-05-28, updated 2026-11-24) | ACL definition, Evans attribution, considerations, when to use or not, Azure example, async option |
| https://alistair.cockburn.us/hexagonal-architecture/ | 200 OK (WebFetch, 2026-11-27) | Intent, ports and adapters framing |
| Internal integration procedure read for method only | local | Port-first rule and partial-failure handling; no vendor names reused |

## Reading limits
- WebFetch returns a model-produced digest, not raw text; details were kept only where the digest was explicit.
- Mapper mechanics are in PoEAA ch. 18, which was not read.
- Firecrawl had no credits; WebFetch only.
- No scripts or data files in this skill, so nothing was left unverified on that front.

## Claims not adopted as fact
- Mapper implementation guidance (explicit vs auto-mapping, round-trip and golden tests, purity) is the author's inference, labeled as such in the reference files.
- "DTO inside one process is ceremony" is an inference from Fowler's remote-call rationale plus contract-stability and security reasons.
- The partial-failure rules in the vendor reference are a design method, not a published standard.
