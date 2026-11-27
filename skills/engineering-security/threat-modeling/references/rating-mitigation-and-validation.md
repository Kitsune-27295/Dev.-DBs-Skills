# Rating, Mitigation and Validation

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html · https://shostack.org/resources/threat-modeling · https://www.threatmodelingmanifesto.org/ · https://learn.microsoft.com/en-us/windows-hardware/drivers/driversecurity/threat-modeling-for-drivers · https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-getting-started · https://owasp.org/www-project-threat-modeling/ · Last verified 2026-11-27

## Rating threats

The OWASP cheat sheet says that in theory threats are ranked by likelihood times impact, but both values are hard to estimate and the approach ignores the effort needed to fix, so some practitioners add fix effort. Shostack's page labels DREAD, OCTAVE, Trike and attack trees deprecated (DREAD scores risk rather than finding threats). Microsoft's older driver guide still teaches DREAD (five 1 to 10 scores averaged), which shows why teams still meet it; treat it as a legacy option.

Practical scheme for an agent (this skill's synthesis, not a standard):

| Field | Values | Rule |
|---|---|---|
| Likelihood | low / medium / high | Consider attacker access (anonymous vs insider), skill needed, whether it is automatable, existing controls |
| Impact | low / medium / high | Consider data class, number of users or tenants affected, money, safety, regulatory exposure |
| Fix effort | small / medium / large | Used only to order equal-risk items |
| Reason | one sentence | Required; a rating without a reason is a guess |

Order by risk, then by effort. Do not convert to fake decimals. For a concrete flaw found later, hand over to `vulnerability-triage` (CVSS, SSVC, OWASP risk rating), which rates an instance, not a design threat.

## Responding to a threat

Shostack's page lists four responses: mitigate, eliminate the feature that creates the threat, transfer to someone better positioned, or accept. OWASP adds that transfer does not reduce likelihood or impact, so the residual controls and risk owner must be documented. Prefer elimination when the feature is optional (no data stored means nothing to leak), mitigation when it is core, transfer only with a named counterpart and evidence (provider documentation, contract), acceptance only with a named owner, a reason and a review date (this last constraint is the skill's own rule).

Turning each mitigation into an actionable requirement is this skill's practice. Example row:

| Threat | Response | Requirement | Test |
|---|---|---|---|
| T-07 tenant id in export body trusted | Mitigate | Server derives tenant from the session and rejects mismatches | Two-tenant integration test: tenant B requests tenant A's export, expects 403 |

## Validating (question 4)

Shostack's fourth question says to check the model, each threat, and the tests that detect problems. OWASP adds stakeholder review: is the DFD accurate, were all threats found, does each have an agreed response, do mitigations bring risk to an acceptable level, is the model documented with restricted access, and can mitigations be tested. Microsoft's walkthrough shows a two-meeting rhythm: one to align on the diagram (a missing component surfaced within minutes), a second to review threats and sign off, then check the model into source control. It also records threat status values worth borrowing: not started, needs investigation, mitigated, not applicable.

Agent-side checks, all read-only: compare each element and flow to routes, handlers, config and infrastructure files; search for the code that implements each claimed control; confirm a test exists or flag its absence; list anything that cannot be verified from the repository.

## Keeping the model alive

The OWASP cheat sheet says the model should not be a one-time exercise; it should be maintained alongside the system and be a normal SDLC step. The Manifesto frames the same idea as values: ongoing understanding over a one-time snapshot, continuous refinement over a single deliverable, finding and fixing design flaws over compliance, doing over discussing. Principles to carry over: analyze early and often, in manageable chunks that fit how the team works, and produce results stakeholders find valuable; conversation builds shared understanding and documents record it.

Update triggers (skill rule): new boundary, store, role, dependency or data class; an incident or audit finding that the model missed; a hosting or identity change; a mitigation that is removed or weakened. Make the model diff part of the pull request.

## Team and process pitfalls (from OWASP: knowledge gaps, time pressure, poor communication; remedies include security involvement, training, tooling, cross-team workshops)

- Knowledge gaps (developers without security training miss threats): involve a security reviewer and rotate who leads.
- Time pressure: use the fast path and chunk the work by change.
- Poor communication between development, security and others: run a short joint session over the diagram.

The Manifesto's anti-patterns apply here too: hero threat modeler, admiration for the problem, over-focus, perfect representation.

## Failure modes

- Threat table without owners, so nothing happens.
- Ratings with no reason; changing a rating to make a ticket disappear.
- Acceptance with no expiry; the risk is forgotten.
- Mitigation described as "validate input" with no place in the code.
- Model approved once, then the design changes and nobody reopens it.

## How an agent should apply this

- Rate with low/medium/high plus a one-line reason and fix effort; never invent numeric precision.
- Give each threat exactly one response and one owner; accept only with owner, reason and review date.
- Convert each mitigation into a requirement with acceptance criteria and a test where feasible; reference the file where the control lives.
- Validate against code, list unverified claims, and ask a second human viewpoint before sign-off.
- Store the model as text beside the code and propose the update triggers in the output.
- For a concrete finding, switch to `vulnerability-triage` instead of rerating the design threat.
