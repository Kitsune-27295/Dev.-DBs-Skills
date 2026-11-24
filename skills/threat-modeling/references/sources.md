# Sources — Threat Modeling

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html | 200 OK (read through a page-to-markdown fetch tool) | Four-question process mapped to four steps, DFD advice, trust boundaries as attack points, STRIDE as default for technical designs, likelihood x impact caveats, mitigate/eliminate/transfer/accept, validation questions, living model, team pitfalls |
| https://owasp.org/www-project-threat-modeling/ | 200 OK; project landing page only | Confirms the project hub, its leaders and the list of related resources; it does not itself state the Manifesto values |
| https://www.threatmodelingmanifesto.org/ | 200 OK | Definition, five values, four principles, five patterns, four anti-patterns |
| https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats | 200 OK | STRIDE category definitions and the pointed questions it is meant to prompt |
| https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-getting-started | 200 OK | Diagram, identify, mitigate, validate process; DFD notation; trust boundaries; threat status values; two-meeting rhythm; assets as an optional entry point |
| https://learn.microsoft.com/en-us/windows-hardware/drivers/driversecurity/threat-modeling-for-drivers | 200 OK (not in the brief; added as a primary example of a DFD, STRIDE table, threat tree and fast path) | Vulnerable point / STRIDE / scenario table, chained threats, threat trees and outlines, fast-path outline, DREAD description (legacy) |
| https://shostack.org/resources/threat-modeling | 200 OK | Four Question Framework, method recommendations (DFD, STRIDE, kill chains) and deprecations (attack trees, DREAD, OCTAVE, Trike), when and who |
| https://linddun.org | 200 OK | What LINDDUN is, flavors (GO, PRO, MAESTRO), relation to STRIDE and DFDs |
| https://linddun.org/threats/ | 200 OK, but the page only links to the threat types and does not define them | Not used for definitions |
| https://linddun.org/threat-types/ | 200 OK | Definitions of the seven LINDDUN threat types |
| https://capec.mitre.org/about/index.html | 200 OK | CAPEC as a catalog of attack patterns derived from real exploits, with mitigation guidance; the page does not explain its link to CWE or ATT&CK |
| https://attack.mitre.org/resources/ | 200 OK | ATT&CK as a knowledge base of adversary tactics and techniques; cautions against full-coverage and matrix-as-complete-list thinking; page does not discuss threat modeling directly |
| Local plugin skills on threat modeling | Third-party skill read for ideas (titles and descriptions only), no text reused; plugin license visible as "Proprietary" | Only confirmed that the topic was a gap; no wording or structure taken |

## Reading limits

- Pages were read through a fetch tool that returns a model-written summary, not raw HTML. Facts below the level of what the summaries stated were not adopted.
- The Firecrawl service was unavailable for credit reasons, so the primary reader was the fetch tool plus plain HTTP.
- The Manifesto text is the site's current wording as summarized; quotes are avoided on purpose.

## Claims not adopted as fact

- **STRIDE-per-element table** (which letters apply to which DFD element type): not found on the pages fetched. The mapping in `SKILL.md` and the enumeration reference is the common SDL convention written from general knowledge and labeled as such.
- **Boundary-placement rules** (control, privilege, network zone, tenant, build and run) and the **threat-sentence format** are this skill's synthesis from the sources' general advice, not quotations.
- **Likelihood/impact/effort scheme** is a synthesis based on the OWASP caveats; no source prescribes it.
- **Differences between sources**: Shostack's page labels attack trees and DREAD deprecated; the Microsoft driver guide still teaches DREAD and threat trees. The skill follows OWASP and Shostack for defaults and keeps trees as a narrow tool.
- **Acceptance needs owner, reason and review date** and the **update triggers** are this skill's own rules.
