# STRIDE and Privacy Threat Enumeration

Sources: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats · https://learn.microsoft.com/en-us/windows-hardware/drivers/driversecurity/threat-modeling-for-drivers · https://shostack.org/resources/threat-modeling · https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html · https://linddun.org · https://linddun.org/threat-types/ · https://capec.mitre.org/about/index.html · https://attack.mitre.org/resources/ · Last verified 2026-11-24

## STRIDE: what it is and why it works

STRIDE groups threats into six categories, each attacking a security property: spoofing (authenticity), tampering (integrity), repudiation (non-repudiation), information disclosure (confidentiality), denial of service (availability), elevation of privilege (authorization). Microsoft's threat page says the model exists to help teams ask pointed questions such as "how can an attacker change the authentication data?" and to simplify security conversations. The tool guide compares it to making sure every door and window has a lock before buying an alarm: software meets a predictable set of threats that these six categories can find. The OWASP cheat sheet recommends starting with STRIDE for technical designs.

Definitions as given by Microsoft (paraphrased): spoofing is using another user's authentication information; tampering is malicious modification of data at rest or in transit; repudiation is denying an action when nobody can prove otherwise; information disclosure is exposure to those not meant to see it; denial of service is denying valid users service; elevation of privilege is an unprivileged actor gaining privileged access.

## STRIDE per element (working rule)

The pages fetched do not print a per-element table, so this mapping is the common SDL convention written from general knowledge, **not read from the sources**. Use it to prune the work, not as a law.

| Element type | Usually relevant | Note |
|---|---|---|
| External entity | S, R | You cannot fix the entity, only how you authenticate it and log its actions |
| Process | S, T, R, I, D, E | The richest target; all six apply |
| Data store | T, I, D (and R if it holds the audit log) | Check direct access paths that bypass the app |
| Data flow | T, I, D | Weight by whether it crosses a boundary and which protocol protects it |

## Prompts for web and API systems

- **S**: session fixation, stolen or guessable tokens, unauthenticated internal endpoints, forged webhooks without signature checks, missing service-to-service authentication, unverified OAuth redirect.
- **T**: client-supplied price, role or tenant id trusted by the server; mass assignment of extra fields; unsigned or unversioned messages on a queue; writable build artifacts or config; tampered dependency or image.
- **R**: admin or financial actions without an audit entry; logs that the actor can edit; shared accounts that hide who did it.
- **I**: verbose errors and stack traces, secrets in logs or URLs, list endpoints that skip the tenant filter, backups or exports stored without access control, side channels such as different responses for "user exists".
- **D**: unbounded request bodies, expensive queries or regexes on user input, no rate limit on login or password reset, one tenant able to exhaust a shared pool, queues without backpressure.
- **E**: role checks only in the UI, object access by id without ownership check, admin routes reachable by guessable path, over-privileged service accounts, CI tokens with write access to production.

The Windows driver guide shows a compact way to record this: a table of "vulnerable point, STRIDE threat, scenario" with one concrete scenario per plausible threat. It also points out that threats chain: an elevation of privilege can enable disclosure or denial of service, so list follow-on threats instead of treating rows as independent.

## Writing a good threat

A threat is a sentence a developer can test: actor, action, element or flow, means, impact. Weak: "Information disclosure on the database." Strong: "A signed-in tenant user requests `/exports/{id}` with another tenant's id, so the export endpoint returns that tenant's file." The strong form maps directly to a control (ownership check) and a test (two-user request).

## Privacy: LINDDUN

LINDDUN, from the DistriNet group at KU Leuven, is a privacy-focused counterpart that follows the same principles as STRIDE and starts from the same system model, so the two can run in parallel. Its seven types, as defined on the site:

| Type | Meaning |
|---|---|
| Linking | Connecting data items or actions to learn about a person or group, even without identity |
| Identifying | Learning who someone is through leaks, deduction or inference |
| Non-repudiation | Keeping evidence that removes someone's ability to plausibly deny an action (a privacy threat here, unlike in STRIDE) |
| Detecting | Inferring involvement from observed activity, flows or side effects without reading the data |
| Data disclosure | Collecting, storing, processing or sharing more personal data than necessary |
| Unawareness and unintervenability | Not informing people how data is used or not letting them access or control it |
| Non-compliance | Deviating from standards, regulations or good data-management practice |

Use LINDDUN when the design stores or moves personal data, profiles users, or sends data to third parties. The site offers lean (GO), systematic (PRO) and model-driven (MAESTRO) flavors; for a quick skill pass, walk the seven types across the flows that carry personal data.

## Other techniques, and when to use them

- **Attack trees**: start from an attacker goal and decompose into the steps needed. Shostack's page labels them deprecated for general use because they need security expertise; the driver guide treats them as useful for complex multi-step scenarios. Use one tree for one critical goal (for example "read another tenant's data"), not for the whole system.
- **Kill chains**: walk attacker stages against the model; useful to check detection and response, beyond prevention.
- **CAPEC**: a catalog of common attack patterns, derived from real-world exploits, with mitigation guidance. Use it to phrase and recall attack patterns for a given weakness.
- **MITRE ATT&CK**: a knowledge base of adversary tactics and techniques from real observations; its own page warns against aiming for full coverage or treating the matrix as a complete list. It is mainly for detection and intelligence work; use it when the model needs a "how would we notice this" column.
- **Misuse and abuse cases**: brief stories of how a feature could be used against its purpose; good for business-logic threats that STRIDE words poorly.

OWASP warns against adding techniques just to look thorough: choose by scope.

## Failure modes

- Generic STRIDE dumps with no link to the system (pad the table, find nothing).
- Skipping business-logic abuse because it does not fit a letter.
- Only external attackers; ignore insiders, compromised dependencies and over-privileged automation.
- Treating ATT&CK or CAPEC as a checklist to be exhausted.
- Forgetting privacy because "it is only security".

## How an agent should apply this

- Walk each element and each boundary-crossing flow; prune using the per-element rule but note any deviation.
- Write each threat as a testable sentence with a concrete path; discard or mark not applicable those without one.
- Add chained threats (what an attacker gains after a first success) as separate rows.
- Run the LINDDUN types over flows carrying personal data; flag non-compliance for a human, do not claim legal conclusions.
- Use CAPEC and ATT&CK to name patterns and detection ideas, never as a coverage target.
- Record the existing control next to each threat so gaps are visible.
