# Redundancy Review: Keeping a Skill Pack Free of Needless Repetition

Sources: this pack's own review of 131 skills (2026-11-27: detector run, then eight cluster reviewers, 71 decisions); the single-owner rule in `ssot-and-dry`; the admission checklist in `agent-skills-context-engineering` · Last verified 2026-11-27

A pack stays small and trustworthy when each rule has one owner. This file is the procedure for finding and removing repetition, and the guard that keeps it from coming back. It is the owner of the procedure; `ssot-and-dry` owns the principle.

## 1. Two passes, because repetition has two forms

| Pass | Finds | Tool |
|---|---|---|
| Deterministic | A paragraph copied across skills, a reference that restates its own SKILL.md, a near-verbatim file | `python check_skills.py --redundancy [folder]` (no model, free) |
| Reading | The same rule in different words, two skills with one job, a reference that retells a source another skill already retells | A reviewer (agent or human) that reads the texts |

Run the deterministic pass first and hand its findings to the reviewer; never skip the reading pass because the script is quiet. In the 2026 run the script found 3 real cases among 3,759 paragraphs, while the reviewers found 71 decisions: most repetition is paraphrase.

Scores: 55% overlap of a paragraph is reported for review; 90% or more fails the check (a copy, not a rule written twice). Sources and trigger-eval files, front matter, tables, code, headings, checklists and link lists are ignored on purpose.

## 2. What counts

Redundant: the same rule, definition, procedure, checklist or reference file in two places with no added purpose.
Not redundant: a one-line pointer plus a link; one topic seen from a different decision (choose, audit, fix); the standard sections every skill carries (Quick Decision Checklist, Deep references, sources); a rule stated in one sentence so a skill still works when installed alone.

Patterns seen in practice:
- A reference that retells its own SKILL.md steps (the most common: the hit is inside one skill).
- Two skills summarizing the same public article or table in separate reference files.
- A specification table (frontmatter fields, limits) pasted into several skills instead of one owner.
- Boilerplate copied between registries or templates, with only the rules differing.
- A skill whose sections all duplicate neighbors after the cuts (merge or delete candidate).

## 3. Reviewer protocol

1. Scope a cluster of 10 to 20 skills that share a domain, plus the descriptions of all other skills (cross-cluster overlap shows there).
2. For each skill read SKILL.md fully; list its reference files with their first heading; read a reference fully only when overlap is plausible.
3. For every candidate find the owner and open the owner's text; do not assume it holds the content.
4. Decide with one of: `trim-section`, `replace-with-link`, `delete-reference`, `merge-skill-into`, `delete-skill`. Prefer the lightest action that removes the copy. A skill-level action needs both skills' unique content listed and a reason one cannot serve alone.
5. Write each decision as data: affected skill and file, the heading or rule, the owner skill and file, two short quotes (at most 25 words each), `unique_content_to_move` (or none), the risk (links, backtick mentions, catalog rows), confidence. Cap at 25 decisions, strongest first; do not pad.
6. Residual-value test: after the cuts, would the skill still hold a distinct decision procedure? If not, escalate to a merge or deletion proposal instead of leaving a hollow skill.
7. Upstream or licensed text (a vendor pack kept as is) can be an owner but is never edited, merged or deleted.

## 4. Applying decisions

- Move first, cut second: copy any unique content into the owner, then replace the copy with a one-line pointer.
- Fix every inbound link, Deep references entry, `sources.md` row and backtick mention; remove a catalog row and a plugin entry when a whole skill goes.
- Re-run `python check_skills.py skills` and `--redundancy`; the number of findings must go down, and no link may break.
- Record in the owner's `references/sources.md` anything the removed copy cited that is not already there.
- Commit by decision group so a wrong cut can be reverted alone.

## 5. Keeping it from coming back

- Before writing a rule, search the pack for its owner (`python check_skills.py --redundancy` after drafting; `grep` the key terms before).
- A new skill passes the admission check and names its neighbors and what each keeps.
- The pre-publish checklist includes the redundancy pass; a near-verbatim copy fails the check.

## How an agent should apply this

- Run the script, then review by cluster; apply only decisions whose owner text you opened.
- Prefer a pointer to a deletion, and a deletion to a merge, unless the residual-value test says otherwise.
- Never edit upstream or licensed text to remove overlap; cut the copy that is yours.
- Report what moved, what was cut, what the finding count was before and after.
