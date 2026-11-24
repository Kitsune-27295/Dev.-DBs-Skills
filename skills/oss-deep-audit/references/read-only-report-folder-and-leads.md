# Read-Only Report Folder, Unapplied Patches and Unverified Leads

Sources: https://www.gradeworkinggroup.org/ (certainty graded separately from conclusions) · an own-style vault-audit skill read for ideas, no text reused · Last verified 2026-11-24

## The idea
An audit changes nothing in the thing audited. Everything it produces lands in one dated report folder outside the audited tree, and anything that would change code is delivered as a patch that is never applied.

## Layout (own design)
```
audit-<repo>-<date>/
  report.md            the five sections of SKILL.md section 6
  evidence.md          the ledger (Observation / Inference / Gap)
  patches/             one unified diff per suggested change, never applied
  unverified-leads.md  hypotheses with the check that would settle each
```

## Rules
- Write only inside the report folder. If a fix looks safe, still write `patches/NN-name.diff`; the owner applies it.
- A lead is a hypothesis you could not verify (a suspicious pattern with no traced path, a claim in docs with no matching code found). It goes in `unverified-leads.md` with the file, why it looked wrong, and the exact check that would confirm it. It never appears under Findings and never moves a verdict.
- Promote a lead to a finding only after you have read the code path and can cite `path:line`; then mark it promoted in the leads file.
- Leads are not Gaps: a Gap names evidence that static reading cannot give; a lead is something a further read might still settle.
- Doubt about whether a file is the owner's work: treat it as theirs and do not touch it.

## How an agent should apply this
- Create the report folder first; write nothing else anywhere.
- Keep findings strictly verified; park the rest as leads with a settling check.
- Offer patches as files; never run `git apply`.
