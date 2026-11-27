# Threats and CI Hardening Controls

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html ; https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions ; https://github.com/ossf/package-manager-best-practices/blob/main/published/npm.md
Last verified 2026-11-25

## How the sources group the problem

The OWASP cheat sheet sorts threats by stage: source code (malicious or vulnerable code entering the repository, building from unauthorized branches), build environment (cache poisoning, privileged build accounts, publishing artifacts built from untrusted sources), dependencies (vulnerable or compromised direct and transitive ones) and deployment (privileged CI/CD accounts, misconfiguration, deploying compromised binaries). Use the stage as a map: a control that protects one stage rarely protects another.

The named classes in this skill (confusion, typosquatting, install scripts, abandoned packages) are all dependency-stage problems; the fetched sources do not define them one by one, so the descriptions in SKILL.md are this skill's own summary.

## Controls and what each really buys

| Control | Buys | Does not buy |
|---|---|---|
| Lockfile plus read-only install in CI | Reproducible installs; tampered artifacts rejected by hash (npm guide) | Protection from a malicious version you pinned on purpose |
| Disabling install scripts | Removes a code-execution point at install | Malicious code that runs when the package is imported. The npm guide fetched does not mention this flag; check the current docs of your package manager before relying on it |
| Registry signature check (`npm audit signatures`, npm CLI 8.15.0 or later per the guide) | Detects registry-level tampering | User-level signing; the guide says npm has none |
| Platform-generated provenance | Ties an artifact to a build run (see `slsa-and-provenance.md`) | Proof the source was benign |
| Pinning actions to a full commit SHA | Attacker would need a SHA-1 collision; tags can be moved | Safety of the code at that commit |
| Read-only default token, raise per job | Smaller blast radius if a token leaks | Injection itself |
| Environment variable instead of inline expression | Untrusted text cannot rewrite the script | Logic bugs in the script |
| No untrusted checkout under `pull_request_target` or `workflow_run` | Keeps secrets away from fork code | Needed triggers still require review |
| Short-lived federated credentials | No long-lived cloud secret to steal | Stolen runner session during its lifetime |

The GitHub guide also describes workflow dependency lockfiles as a stronger option than SHA pinning where a repository can adopt them; treat that as a direction to check, not a given.

## Example: injectable step and its fix

Risky: a step whose shell line contains the pull request title expression directly. Safer: pass the title in an `env:` entry and use the quoted shell variable `"$PR_TITLE"` in the script. The first lets a crafted title become commands; the second keeps it as data.

## Reviewing dependency updates

An update bot opens many small diffs. A reviewer should look at version jump, changed install hooks, new transitive packages, maintainer change, and release-notes mismatch. The npm guide notes reproducible installs let a team test an update before accepting it, with a delay setting in the update bot as an example.

## How an agent should apply this

1. Classify any finding by stage before proposing a fix.
2. Propose the smallest control that closes the path; say what it does not cover.
3. In workflow files, check token permissions, action pins, untrusted interpolation and risky triggers, in that order.
4. Do not run installs of unknown packages with credentials in the environment.
5. Report package-manager flags as "verify against current docs" when this file does not state them.
