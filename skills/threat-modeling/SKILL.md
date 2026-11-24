---
name: threat-modeling
description: "Build and maintain a lightweight threat model for a system, feature or change: state scope and assumptions, draw a data flow diagram with trust boundaries, enumerate threats per element with STRIDE (plus LINDDUN when personal data is involved), rate them, choose mitigate / eliminate / transfer / accept, turn the result into requirements and tests, validate it against the real code, and keep it living as the design changes. Design-time and review-time; reads code and docs, changes nothing. Use when starting or reshaping a feature, adding an integration, a new trust boundary, new data class or deployment path, asked 'what can go wrong', or before a security audit."
---

# Threat Modeling (design-time security thinking)

One idea: a threat model is a **structured conversation about a picture of the system**, answering four questions (what are we working on, what can go wrong, what are we going to do about it, did we do a good enough job) in a form small enough to finish and cheap enough to redo. Its output is decisions and tests, not a long document. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill works on a **design** (what could go wrong, before or around the code). Auditing existing code for the usual SaaS flaws is `security-audit`; deciding what to do with one concrete scanner or bug report is `vulnerability-triage`; fixing client-trust problems is `never-trust-the-client`; login, session and permission design is `authn-authz-guard`; database exposure is `database-exposure`; untrusted third-party repos are `oss-deep-audit`.

## 1. Decide how much to do

Scale effort to risk; a model that never finishes protects nothing.

| Situation | Effort |
|---|---|
| Copy, styling or internal-only change with no new input, data or boundary | Skip; note "no model change" |
| New endpoint, field, role or integration inside an already-modeled system | Fast path: update the existing diagram, run STRIDE only on the new elements (about 30 to 60 minutes) |
| New service, trust boundary, data class (credentials, payments, personal data), public exposure or third-party dependency | Full pass on the affected scope |
| Whole system never modeled | Start with a one-level overview, then expand only the riskiest flows |

An agent usually cannot see the deployment, the org chart or the business impact. Mark every fact as **observed in code/docs** or **assumed**, and list the assumptions for a human to confirm. Never present a guess about production as a finding.

## 2. Question 1: what are we working on? (scope)

Write a scope block before drawing anything:

- **In scope** (system, feature or change) and **out of scope** (with the reason).
- **Assets**: what an attacker would want (accounts, money, personal data, availability, reputation, the build pipeline).
- **Actors**: anonymous visitor, authenticated user, tenant admin, operator, third-party service, insider, automation.
- **Assumptions**: what is treated as already secure (the platform, the identity provider) and who owns it.

Cloud and managed services shift responsibility; state who owns each control (shared responsibility), or the model silently assumes the provider does everything.

## 3. Draw a data flow diagram with trust boundaries

Use four element types plus boundaries: **external entity** (person or system you do not control), **process** (code that runs), **data store** (database, queue, cache, file, secret store), **data flow** (data moving between them). A **trust boundary** is a line where control, privilege or trust level changes: internet to server, browser to API, service to service across teams, app to database, app to a third party, tenant to tenant.

Rules: every flow crosses or stays inside a boundary and has a direction and a protocol; every store and process has an owner; show where authentication and authorization are enforced; keep one overview plus one detail diagram per risky area (`mermaid` for text diagrams that live beside the code, `c4-model-architecture` for context and container views). Details and a worked example: [references/dfd-and-trust-boundaries.md](references/dfd-and-trust-boundaries.md).

A diagram is good enough when someone who did not draw it can point to the place where an attacker would start.

## 4. Question 2: what can go wrong? (enumerate)

Walk each element and each boundary-crossing flow against STRIDE:

| Letter | Threat | Property attacked | Typical prompt for a web or API system |
|---|---|---|---|
| S | Spoofing | Authenticity | Can someone pose as a user, service or token issuer? Are service-to-service calls authenticated? |
| T | Tampering | Integrity | Can data be changed in transit, at rest, or by a client-supplied field the server trusts? |
| R | Repudiation | Non-repudiation / accountability | Can an actor deny an action? Are security-relevant actions logged with who, what, when? |
| I | Information disclosure | Confidentiality | Can data leak through errors, logs, responses, other tenants, backups, URLs? |
| D | Denial of service | Availability | Can one caller exhaust CPU, memory, connections, quota or a lock? |
| E | Elevation of privilege | Authorization | Can a low-privilege actor reach admin or other tenants' functions? |

Working rule (SDL convention; see the reference): external entities mostly face S and R; processes can face all six; data stores T, I, D (and R when they hold the audit trail); data flows T, I, D. Boundary-crossing flows get the most attention.

Write each threat as one sentence: **actor + action + element + means, so that impact**. For example: "A signed-in user changes the `tenant_id` in the request body of the export endpoint, so another tenant's data is returned." Record the STRIDE letter, the element or flow, and the existing control (if any).

Add **privacy threats** with LINDDUN whenever personal data flows (linking, identifying, non-repudiation, detecting, data disclosure, unawareness, non-compliance). Use CAPEC and MITRE ATT&CK as vocabularies to jog ideas and name attack patterns, never as completeness checklists. Use an attack tree only for one high-value attacker goal. Details: [references/stride-and-privacy-threat-enumeration.md](references/stride-and-privacy-threat-enumeration.md).

Do not paste six generic threats per box. A threat with no concrete path in this system is noise; drop it, or write "considered, not applicable, because ...".

## 5. Rate and prioritize

Use a coarse **likelihood x impact** (low / medium / high) and say why; OWASP notes both are hard to estimate and that fix effort matters, so also note effort. Shostack's resource page labels DREAD deprecated (older Microsoft driver guidance still teaches it). Do not invent numeric precision; for a concrete vulnerability instance, use the methods in `vulnerability-triage`. Prioritize threats that cross a boundary, touch sensitive data, or have no existing control. Details: [references/rating-mitigation-and-validation.md](references/rating-mitigation-and-validation.md).

## 6. Question 3: what are we going to do about it?

Per threat choose one response and write the owner:

| Response | Meaning | Rule |
|---|---|---|
| Mitigate | Add or strengthen a control that reduces likelihood or impact | Name the control and where it lives in the code |
| Eliminate | Remove the feature, data or flow that creates the threat | Cheapest when the feature is optional |
| Transfer | Move responsibility to a party better placed (provider, customer) | Document who holds the residual risk; transfer alone reduces nothing |
| Accept | Keep the risk knowingly | Needs a named owner, the reason, and a review date |

Turn every mitigation into a **checkable requirement** (a ticket with acceptance criteria) and, where possible, a **test** that fails if the control is removed. Fix patterns live in the neighbors: client trust in `never-trust-the-client`, identity and permissions in `authn-authz-guard`, input contracts in `validator-input-parser`, throttling in `rate-limiter-throttler`, error shapes in `error-handling-problem-details`.

## 7. Question 4: did we do a good enough job? (validate)

- The diagram matches what is actually built (check code, config, infrastructure files, not memory).
- Every flow that crosses a boundary has been examined; every threat has a response, an owner and a status.
- Each mitigation has a test, a code reference or a monitoring signal.
- Someone outside the author group reviewed it (developer, operator, security or product), because different viewpoints find different gaps.
- Assumptions were confirmed or are tracked as open items.

## 8. Keep the model living

Store the model beside the code (a Markdown file with a text diagram) and update it when: a boundary, store, role, third party or data class is added; an incident or audit finding exposes a missed threat; a dependency or hosting model changes. Review the diff of the model in the same pull request as the design change. A stale model is worse than none because it gives false comfort.

## 9. Output (keep it short)

1. Scope, assets, actors, assumptions (with confirmed / open marks).
2. Diagram (text) with trust boundaries.
3. Threat table: id, element or flow, STRIDE/LINDDUN, threat sentence, existing control, rating with reason, response, owner, status.
4. Requirements or tickets and the tests they imply.
5. Open questions for humans and the next review trigger.

## 10. Anti-patterns to refuse

- **Hero modeler**: one expert produces a model nobody else understands. Anyone can do it; use varied viewpoints.
- **Admiration for the problem**: a long threat list with no responses. Every threat ends in a decision.
- **Over-focus**: only adversaries, or only assets, or only one technique; lose the big picture.
- **Perfect representation**: seeking one ideal diagram. Several simple views reveal different problems.
- **One-and-done**: a model made once, never updated.
- **Padding**: adding techniques to look thorough. Justify each by scope.
- **Compliance theater**: filling a template instead of finding design flaws.

## Quick Decision Checklist

1. Does this change add input, data, a role, an integration or a boundary? If not, skip and note it.
2. Is scope written, with out-of-scope and assumptions marked as observed or assumed?
3. Does the diagram show every trust boundary and where authn/authz is enforced?
4. Was each element and boundary-crossing flow walked with STRIDE (and LINDDUN for personal data)?
5. Is every threat one concrete sentence, or removed as not applicable with a reason?
6. Does every threat have a response, an owner and a rating with its reason?
7. Does every mitigation have a requirement and, where possible, a test?
8. Were assumptions and the diagram confirmed against code and a second reviewer?
9. Is there a stated trigger for the next update?

## Deep references

- [Sources](references/sources.md) — origin, retrieval status and claims not adopted.
- [DFD and trust boundaries](references/dfd-and-trust-boundaries.md) — read when drawing the diagram: element types, boundary placement, levels of detail, worked web example, fast path.
- [STRIDE and privacy threat enumeration](references/stride-and-privacy-threat-enumeration.md) — read when enumerating: STRIDE per element, web/API prompts, LINDDUN, attack trees, CAPEC and ATT&CK as vocabularies.
- [Rating, mitigation and validation](references/rating-mitigation-and-validation.md) — read when ranking threats, choosing responses, writing requirements and tests, and keeping the model current.
