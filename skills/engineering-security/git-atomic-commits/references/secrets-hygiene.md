# Secrets Hygiene: Keeping Credentials Out of Git History

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html · https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History · Last verified 2026-11-27

Scope: only what concerns committing and leaking secrets. Broader exposure audits live in `security-audit` and `database-exposure`; environment config rollout in `migrations-and-environments`.

## Core facts (OWASP)

- Many organizations still hardcode secrets in source, config files and config-management tools in plaintext. Source control then replicates them to every clone, fork, CI cache and backup.
- Secrets must not be baked into images or passed via Docker `ENV`/`ARG` (they leak with the image definition); deliver them at runtime from a secrets store, preferably via mounted volumes or in-memory delivery rather than env vars that any process can read and that appear in logs/dumps.
- Secret types to watch: API keys, connection strings, SSH/private keys, session tokens, cloud credentials.

## Prevention: detect before the commit

OWASP: move detection left, at the developer level (IDE, test cycle, **pre-commit hook**) so secrets never enter a commit/PR. Yelp detect-secrets is named as a mature option. Running more than one scanner and re-evaluating tools over time is the author's inference, not re-read on the page.

Practical layers (mostly inference beyond OWASP):
1. `.gitignore` for `.env`, `*.pem`, key stores, dumps, local config; commit `.env.example` with fake values.
2. Pre-commit hook running a scanner on the staged diff.
3. CI secret scan as a second net (hooks can be skipped).
4. Review `git diff --cached` for strings that look like keys, long random tokens, URLs with credentials.
5. Least privilege: scoped, short-lived credentials limit the blast radius of any slip.

## Response when a secret was committed

OWASP incident order: **revoke, rotate, delete, log**.

| Step | Action |
|---|---|
| 1 Revoke | De-authorize the credential at the provider immediately |
| 2 Rotate | Issue a replacement (automated where possible), update the secret store, not the repo |
| 3 Delete | Remove it from code, logs and artifacts |
| 4 Log/inspect | Check access logs: who used it, when; record when it was last rotated |

Key points: restarting an app or finishing a CI run does not revoke stolen credentials; they stay valid until lease expiry or explicit revocation. Treat any secret that reached a remote as compromised, public or not.

## History purge: optional, after rotation

OWASP notes you can squash exposure commits to a point before the secret was introduced, but this rewrites history and breaks links to existing commits, and deletion follows revocation/rotation. It gives no step-by-step procedure. Pro Git says `filter-branch` can remove a file everywhere (`--tree-filter 'rm -f passwords.txt'`), is no longer recommended, and points to `git-filter-repo` (usage details: not read from source).

Safe approach:
1. Rotate first. The purge never un-leaks the value (forks, clones, caches, PR refs may retain it).
2. If still unpushed: `git rebase -i` and edit/drop the offending commit, or `git commit --amend` for the last one; check `git reflog` expiry if you must remove local traces.
3. If pushed: purging requires rewriting shared history and force-pushing every affected branch, which needs explicit user approval and coordination (everyone re-clones or rebases); hosting providers may also need to purge cached views.
4. Add the file pattern to `.gitignore` and a scanner rule so it does not recur.

```
# unpushed, secret in the last commit only
git rm --cached .env           # untrack; the file stays on disk
git commit --amend --no-edit   # only after the user agrees to amend
```

## Failure modes

- Deleting the secret in a later commit: it remains in history and reflog.
- Purging history but not rotating: attackers already have it.
- Putting secrets in commit messages, branch names or PR descriptions (replicated too).
- Relying on a pre-commit hook alone: `--no-verify` and fresh clones skip it; keep CI scanning.
- Assuming a private repo is safe: access widens over time.

## How an agent should apply this

- Before any commit, scan the staged diff for credentials and never stage `.env`, key files or dumps; stage by path/hunk, not `git add -A`.
- If a secret is found in the staged diff: unstage it, tell the user, suggest moving it to the secret store; do not commit "to fix later".
- If a secret already reached a commit: tell the user to revoke and rotate first, then offer a purge plan; do not rewrite pushed history without explicit approval.
- Recommend a pre-commit scanner plus CI scan; do not disable hooks (`--no-verify`).
- Never echo a found secret in full in chat, logs or messages; refer to file and line.
- For exposure beyond git (databases, buckets, endpoints) hand off to `database-exposure` or `security-audit`.
