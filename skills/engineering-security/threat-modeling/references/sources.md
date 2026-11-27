# Sources: Threat Modeling

Last verified 2026-11-27. All pages fetched with WebFetch (model-written summaries or page text), all answered 200 OK.

| Source | What it contributed |
|---|---|
| https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html | Four-question process, DFDs with trust boundaries, STRIDE as a starting point for technical designs (used for illustration, other approaches listed), likelihood x impact caveats (hard to estimate, ignores fix effort), mitigate/eliminate/transfer/accept attributed to Shostack, validation questions, living model, team pitfalls |
| https://owasp.org/www-project-threat-modeling/ | Project hub only (leaders, related tools such as Threat Dragon and PyTM); no Manifesto text |
| https://www.threatmodelingmanifesto.org/ | Definition, five values, four principles, five patterns, four anti-patterns |
| https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats | STRIDE category definitions and the pointed questions it prompts; no per-element table |
| https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-getting-started | Diagram, identify, mitigate, validate; DFD notation; trust boundaries; status values (Not Started, Needs Investigation, Mitigated, Not Applicable); two-meeting rhythm; assets as optional entry point |
| https://learn.microsoft.com/en-us/windows-hardware/drivers/driversecurity/threat-modeling-for-drivers (page updated 2026-06 per its metadata) | DFD symbols, STRIDE scenario table, chained threats, threat trees and outlines, fast-path outline, DREAD (legacy scoring) |
| https://shostack.org/resources/threat-modeling | Four Question Framework; recommended: kill chains, STRIDE, DFDs, message sequence diagrams; deprecated: attack trees, DREAD, OCTAVE, Trike |
| https://linddun.org | Free privacy framework from DistriNet, KU Leuven, first published 2010; flavors GO, PRO, MAESTRO (MAESTRO page says more info coming); follows STRIDE principles and shares its system model |
| https://linddun.org/threat-types/ | Seven threat type definitions |
| https://capec.mitre.org/about/index.html | CAPEC as a catalog of attack patterns with mitigation guidance, established by DHS in 2007; the page does not link it to CWE or ATT&CK |
| https://attack.mitre.org/resources/ | ATT&CK as observed adversary tactics and techniques; cautions against chasing full coverage |

## Reading limits

- Summaries, not raw HTML; facts not stated were not adopted.
- Firecrawl has no credits; WebFetch was the reader. Third-party skills were not used as text sources.
- https://linddun.org/threats/ was not re-fetched (it only links to the type pages).

## Claims not adopted as fact

- STRIDE-per-element table: no fetched page prints it; the mapping is the common SDL convention from general knowledge, labeled as such.
- Boundary-placement rules, the threat-sentence format, the likelihood/impact/effort scheme, update triggers, and "accept needs owner, reason, review date" are this skill's own.
- "OWASP suggests an overview plus detail diagrams", "OWASP says a whiteboard is fine", "OWASP asks for mitigations to become requirements", "OWASP warns against technique padding", and "Shostack describes CVSS as severity scoring": not found on the pages read this round; removed or relabeled as the skill's own.
- Anti-patterns "one-and-done", "padding" and "compliance theater" are this skill's; the Manifesto lists four.
- DREAD: Shostack labels it deprecated while the Microsoft driver guide still teaches it; the skill follows Shostack for defaults.
