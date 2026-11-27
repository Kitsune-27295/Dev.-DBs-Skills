# Safe Migration Procedure

Sources: https://agents.md · https://agentskills.io/specification · https://code.claude.com/docs/en/settings · https://code.claude.com/docs/en/claude-directory · Last verified 2026-11-27

The structure (discover, confirm, write a single new bundle, hand back; never modify sources) is the part worth reusing from a third-party built-in migration skill read for ideas; the wording, templates and verification steps below are original.

## 1. Discovery (read-only)

```
for each known source tool:
    for each known location (user level, then project level if a workspace is open):
        if absent: skip silently
        record: path, kind (instructions | skill | command | subagent | mcp | settings | other),
                level (user | project), size, content hash, names inside (never values of secrets)
```

Rules:

- List directories and parse keys; do not print whole files.
- Project-level discovery happens only if a workspace is actually open; do not scan the disk for repositories.
- Record `hash(source)` now; you will compare after writing.
- Note what the target already has (names of skills, servers, rules) for the clash check.
- Settings files hold permissions and hooks: record that they exist, do not parse them for migration.

## 2. Plan template (show this to the user)

```
Migration plan (nothing has been written yet)

From Tool A (user level)
  MCP servers (3): docs, tracker, db          -> convert (2 clean, 1 needs variable DB_URL)
  Skills (2): release-notes, sql-review        -> copy
  Instructions (1): global instructions        -> convert, 2 lines mention Tool A only (will be listed)
From Tool A (project level, applies to every workspace once migrated)
  Rules (4)                                    -> your choice: include / leave out
Skipped
  Permissions and hooks                        -> not portable; list below
  Auto memory, history                         -> not configuration
Name clashes: tracker (exists in target)       -> will be named toolA-tracker
Bundle: <new name>, at <target bundle location>  (nothing existing is overwritten)
Questions: 1) proceed with all, or exclude some?  2) confirm the bundle name
```

Never put secret values, tokens, or full file contents in the plan. Key names and counts are enough.

## 3. Confirmation

- Ask the two questions in one message and wait.
- Non-interactive run: stop after the plan, write nothing, return the plan as the result.
- Re-confirm if the user changes scope after seeing the plan (for example adds project-level rules).

## 4. The bundle

Layout (names are generic; follow the target tool's own layout for the contents):

```
<bundle>/
  MIGRATION-MANIFEST.json     # what came from where, with hashes
  <target-native files...>    # skills/, rules/ or instruction files, MCP config, as the target expects
  UNDO.md                     # one paragraph: how to remove or disable the bundle
```

Manifest entry:

```json
{ "source": "<tool>:<level>:<relative path>", "source_sha256": "...",
  "dest": "<path inside the bundle>", "class": "clean | lossy | manual",
  "notes": "dropped keys: timeout, trust" }
```

Reversibility:

- Everything the migration creates is inside one new directory (or one set of files named in the manifest). Removing that directory undoes the migration.
- If the target needs registration outside the directory (a settings entry, an enable toggle), record that in `UNDO.md` and do not perform it without confirmation.
- Never edit an existing file in the target or the sources. If a merge is unavoidable, write the proposed merged file inside the bundle and show a diff for the user to apply.

## 5. Secrets

- Discovery output, plan, manifest and hand-back carry names and counts only.
- Convert literal secrets to environment-variable references where the target supports it; list the variables the user must set.
- If a literal must be carried, put it only in a file that stays local, tell the user to keep it out of version control, and still never echo it.
- Never copy credential stores, tokens caches, or history files.
- Transcripts and history are plaintext and may contain secrets from earlier sessions; excluding them also avoids spreading those.

## 6. Verification

```
assert every generated JSON/TOML file parses
for each skill in bundle: frontmatter present; name == folder; 1 <= len(description) <= 1024
assert size caps of the target (instruction size, per-file limits) are met
for each source file: sha256(now) == sha256(at discovery)      # sources untouched
assert set(files in bundle) == set(files in manifest) + {manifest, UNDO}
for each secret-bearing key: confirm the value does not appear in plan, manifest or logs
if target has a "list loaded items" command: run it, compare to plan
```

A failed check blocks the hand-back; fix and re-verify, or report what remains broken.

## 7. Hand-back message

Short, in this order:

1. Migrated: counts and names.
2. Converted with loss: what was lost.
3. Skipped: what and why (permissions, hooks, memory, plugins).
4. Still to do by hand: sign-ins, variables to set, enabling the bundle, restarting the tool.
5. Where the bundle is and how to remove it.

## 8. Writing a migration command for an agent (design notes)

If you are building the import feature itself rather than doing one migration:

- Make discovery a pure function returning an inventory; make planning a second pure function; only the writer touches disk (and only after confirmation).
- Provide a dry-run that prints the plan and writes nothing.
- Keep the table of known locations as data, versioned with a "verified against version X" note, because locations change.
- Test with fixture homes: a fake user directory per source tool containing one of each artifact class, plus a secret placeholder that must never appear in output.
- Property to test: running discovery and writing twice with the same input produces an identical bundle, and the sources' hashes never change.

## How an agent should apply this

- Hash sources at discovery and compare after writing; report the result.
- Show the plan template and wait for the answer before creating any directory.
- Create a single new bundle with a manifest and an undo note; never merge into existing files.
- Keep secrets out of every artifact the user will read; use names and counts.
- Finish with the five-part hand-back, including how to remove the bundle.
