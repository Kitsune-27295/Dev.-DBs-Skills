# Instruction Size Budget and Safe Shortening

Sources: Local operating practice (private notes, summarised; not a public URL) · Last verified 2026-11-23

Always-loaded instruction files are paid for on every turn of every session, so their size is a standing token cost, not a one-off.

## The budget

- Applies to files loaded unconditionally: the global and project memory/instruction files, agent-instruction files, and rule files **without** a path-scoping header.
- Keep each under about **4 KB**.
- Rule files that declare `paths:` load on demand, so the limit does not apply to them.
- Keep the instruction itself in the always-loaded file; move rationale, incident history, enumerations and long procedures into a linked doc, leaving a trigger sentence and a link.
- **Never delete a rule to save space.**

## Safe-shortening procedure

1. **Inventory read-only.** List every always-loaded file with its size in bytes (`len(text.encode())`, not by eye; preserve line endings).
2. **Draft in a scratch location** and show old size, new size and the diff before applying.
3. **Grep for citations first.** Other files, hooks, tests, doctor checks and eval fixtures cite "section 2" or "item 5" or a heading. Keep every heading and every item number valid. Compress wording in place; put the full text in a linked detail page using the same sections and numbers. Delete an item only if it is last in its section and nothing cites it.
4. **Apply to every mirror.** Parallel copies (e.g. two agent directories) are often real copies, not links; check, edit both, confirm with a directory diff.
5. **Re-index and test.** If a search index covers the file, re-index and run the project's retrieval tests and drift report, then the project's lint and doctor.
6. **If retrieval regresses, restore wording.** The words a cut removed are often common ("how", "only", "container") yet load-bearing for retrieval. Restore them and re-run.
7. **Never edit expected answers, floors or baselines** to make a test pass; a baseline is rewritten only by its own command in a reviewed change. Record a regression caused by corpus growth as a documented known failure; never widen an eval's expected answers with a page that does not answer the question.
8. **Governed projects:** use the project's own mechanism for deliberate change (for a kit lock, record only the files touched; a full lock silently accepts unrelated drift).
9. **Report what ran and what did not.**

## Sweeps and scope

- When a cost fix is requested, sweep sibling projects for the same pattern, skipping dependency folders, VCS internals, worktrees, snapshots and archives. Use a scripted directory walk; shell `find` with unquoted exclusion globs can expand in the cwd and silently return nothing.
- A finding outside the scope the user named (another project, a read-only repo, something another team owns) is **reported with evidence, not edited**.

## Example: measuring

```python
for p in files:
    n = len(open(p, "rb").read())
    print(f"{n:6d} B  {'OVER' if n > 4096 else 'ok'}  {p}")
```

## Failure modes

- Shortening by deleting items that tests or docs cite.
- Editing one mirror only, so the next sync reintroduces the long text.
- Fixing a failing retrieval test by loosening it.
- Treating the budget as a goal in itself and losing rules.

## How an agent should apply this

- Before creating or editing an always-loaded file, check its byte size against the budget.
- Move detail out, not rules out; keep headings and numbering stable.
- Grep citations before moving text; run the project's checks after.
- Edit all mirrors and templates; report out-of-scope findings instead of fixing them.
