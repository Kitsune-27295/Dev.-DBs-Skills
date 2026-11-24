---
name: setup-pre-commit
description: Set up Husky pre-commit hooks with lint-staged (Prettier), type checking, and tests in the current repo. Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing.
---

# Setup Pre-Commit Hooks

Provenance and local changes: [references/sources.md](references/sources.md).

## 1. What this sets up

- **Husky** pre-commit hook
- **lint-staged** running Prettier on all staged files
- **Prettier** config (if missing)
- **typecheck** and **test** scripts in the pre-commit hook

## 2. Steps

### 2.1 Detect package manager

Check for `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun). Use whichever is present. Default to npm if unclear.

### 2.2 Install dependencies

Tell the user the three packages and the manager you will use, then install as devDependencies:

```
husky lint-staged prettier
```

### 2.3 Initialize Husky

```bash
npx husky init
```

This creates `.husky/` dir and adds `prepare: "husky"` to package.json. Check the existing `package.json` first: do not overwrite an existing `prepare` script or an existing `.husky/pre-commit`; merge and tell the user.

### 2.4 Create `.husky/pre-commit`

Write this file (no shebang needed for Husky v9+):

```
npx lint-staged
npm run typecheck
npm run test
```

**Adapt**: Replace `npm` with detected package manager. If repo has no `typecheck` or `test` script in package.json, omit those lines and tell the user.

### 2.5 Create `.lintstagedrc`

```json
{
  "*": "prettier --ignore-unknown --write"
}
```

### 2.6 Create `.prettierrc` (if missing)

Only create if no Prettier config exists. Use these defaults:

```json
{
  "useTabs": false,
  "tabWidth": 2,
  "printWidth": 80,
  "singleQuote": false,
  "trailingComma": "es5",
  "semi": true,
  "arrowParens": "always"
}
```

### 2.7 Verify

- [ ] `.husky/pre-commit` exists and is executable
- [ ] `.lintstagedrc` exists
- [ ] `prepare` script in package.json is `"husky"`
- [ ] `prettier` config exists
- [ ] Run `npx lint-staged` to verify it works

### 2.8 Commit (only with the user's OK)

List the files you changed or created and ask whether to commit them. If the user agrees, stage only those files and commit with message: `Add pre-commit hooks (husky + lint-staged + prettier)`. Never use `--no-verify`.

This runs through the new pre-commit hooks: a good smoke test that everything works. If the user wants to commit themselves, skip this step.

## 3. Notes

- Husky v9+ doesn't need shebangs in hook files
- `prettier --ignore-unknown` skips files Prettier can't parse (images, etc.)
- The pre-commit runs lint-staged first (fast, staged-only), then full typecheck and tests
- A slow full test suite at commit time hurts flow; if it takes more than a few seconds, suggest moving tests to CI or a pre-push hook

## Quick Decision Checklist

- [ ] Package manager detected; existing hooks and `prepare` script preserved
- [ ] `typecheck`/`test` lines only if those scripts exist
- [ ] Prettier config created only if missing
- [ ] `npx lint-staged` ran
- [ ] Commit made only after the user agreed

## Deep references

- [references/sources.md](references/sources.md) — upstream source, license, local changes

## Related skills in this pack

- `git-atomic-commits` for what a good commit looks like once the hook runs.
- `verification-loop` and `testing-pyramid-and-shapes` for deciding what belongs in the commit-time test run.
- `git-guardrails-claude-code` to stop the agent from bypassing or force-pushing around hooks.
