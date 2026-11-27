# Stamping, Supersede and the Sweep Report

Sources: https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions · https://github.com/joelparkerhenderson/architecture-decision-record · https://adr.github.io/adr-templates/ · https://code.claude.com/docs/en/memory · https://arxiv.org/html/2605.26112 · Last verified 2026-11-24

## Stamp fields

Minimal, attached to each entry (frontmatter or an adjacent line):

| Field | Values | Meaning |
|---|---|---|
| `last_verified` | ISO date | When a check last ran, or "never" if unstamped |
| `confidence` | high / medium / low | high: verified now. medium: unverifiable cheaply, or a preference with no conflict. low: partly drifted, contradicted, or fix not yet confirmed |
| `verified_how` | one word | `ls`, `grep`, `head-request`, `ls-remote`, `user`, `none` |
| `status` | active / superseded / archived | Lifecycle |
| `superseded_by` | id or name | Only when superseded |

Rules:

- Stamping an entry does not change its body. Body edits are limited to **verified-wrong facts**, and the old and new values go in the report.
- A stamp is a statement about the check, not about the claim forever: "verified on this date by this check".
- Unverifiable: keep the prior confidence if it was higher, otherwise medium; still stamp the date so the entry leaves the unverified queue (and say in `verified_how` that no check was possible).
- Do not invent a stamp for an entry you did not check.

## Supersede versus archive versus delete

| Operation | When | Mechanics | Who decides |
|---|---|---|---|
| **Supersede** | A newer entry replaces the claim or decision | Write the new entry; set old `status: superseded`, `superseded_by`; keep old text | Agent proposes, person confirms for decisions; the agent may apply it for a verified environment fact |
| **Archive** | Entry is obsolete but may have history value | Move to an archive location, keep readable and restorable | Person confirms |
| **Delete** | Explicit user request only | Remove, and log it in the report | Person |

The supersede rule comes from decision-record practice. Nygard's original form: a reversed decision is kept, marked superseded or deprecated, and linked to its replacement, because the old decision is still relevant history. A popular ADR repository states the same immutability principle (do not alter; amend or supersede with a new record) but also notes that some teams found mutable, dated updates worked better in practice. This skill takes the strict side for **decisions** and **lessons**, and allows in-place correction only for verified-wrong environment facts, with the change logged. The ADR templates page lists status as a field in Nygard and MADR templates but does not define values; the values above are this skill's.

## Sweep report template

One file per sweep, e.g. `memory/hygiene/2026-11-24.md`. Four questions structure it, adapted from the paper's evolution-oriented framing (what persists, what updated, what is measured, what is auditable); the framing is the paper's idea, the template is own.

```markdown
# Memory hygiene sweep 2026-11-24
Scope: agent memory (full), notes with environment claims (partial: reference/)

## What persists
user 3 · feedback 8 · project 5 · reference 12   (28 entries)

## What updated
- reference/build-script: path scripts/build.sh -> tools/build.sh (verified: ls)

## Scorecard
verified 17 · unverifiable 7 · drifted 3 · propose-archive 1
Delta vs 2026-10-24: drifted +1, verified +2, entries +3

## What is auditable
(every change in this sweep is one line above or below)
- stamped 24 entries (last_verified, confidence)

## Propose archive
- project/old-migration — target branch no longer exists (git ls-remote empty)

## Waiting on you
- Confirm archive of project/old-migration; decide which of two conflicting preferences stands.
```

Why a report and not just stamps: some stores are not under version control (the Claude Code memory docs describe auto memory as machine-local plain files). There the report **is** the audit trail. The drift trend across reports (the delta line) shows whether hygiene is working; a one-time check cannot.

## Scorecard definitions

| Count | Definition |
|---|---|
| verified | A cheap check confirmed the claim now |
| unverifiable | No cheap check, or over budget; the claim is untouched |
| drifted | A check contradicted the claim |
| propose-archive | The whole entry is obsolete and needs a human decision |

`drifted` counts claims, `propose-archive` counts entries; keep the units visible.

## Failure modes

- **Stamp inflation:** stamping everything "high" without a check. Require `verified_how` for high.
- **Silent cleanup:** deleting during the sweep because it is faster. Proposals only.
- **Report as memory:** copying report lines into memory entries. The report is the record; memory stays small (`agent-session-memory`).
- **Rewriting voice:** reformatting entries while stamping. Stamps only.

## How an agent should apply this

- Stamp only entries you checked; use `verified_how` to say how.
- Correct verified-wrong environment facts in place and log old to new; supersede decisions and lessons instead.
- Propose archives with one line of evidence each; wait for confirmation.
- Write exactly one report per sweep with counts and the delta from the previous one.
- Keep a clean separation: what is stored and how sessions write it is `agent-session-memory`; the truth of stored claims is here.
