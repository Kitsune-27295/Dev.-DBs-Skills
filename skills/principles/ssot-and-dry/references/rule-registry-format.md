# Rule Registry Format

Sources: this pack's own registries (`skill-orchestrator`, `clean-code-for-agents`), which follow the single-owner rule of this skill · Last verified 2026-11-27

A registry makes the single-owner rule checkable: every rule has one row, and every other file cites the row instead of restating the rule. This file owns the method; each registry keeps only its own legend (source tags, local columns).

## Row fields

- **Id**: a stable short code. Other files cite it and never copy the rule.
- **Canonical rule**: one sentence.
- **Owner**: the one file that holds the full discussion.
- **Other sources**: where else the rule appears.
- **Agreement**: `agree` (sources say the same), `agree (one lineage)` (several sources descend from one book, so the agreement is not independent evidence), `partial` (same principle, different detail), `conflict` (name the decision that settles it), `own design` (the pack author's synthesis, no source states it).
- **Confidence**: high when a primary source states it or independent sources agree; medium when it rests on one official source plus inference or on several secondary sources; low when it is a claim or opinion.

## Maintenance rule

Changing a rule means editing the owner file and its row, nothing else. A rule that needs a second explanation elsewhere gets a link to its id.

## How an agent should apply this

- Write the registry row first; write the owner text second; cite the id everywhere else.
- Keep the field definitions here and put only legends that differ (source tags, enforcement columns) in the registry itself.
- When two registries repeat these definitions, cut the copies and point here.
