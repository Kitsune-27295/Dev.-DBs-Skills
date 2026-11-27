# Trigger evals

Last verified 2026-11-27 (mental test of the description; no runtime trigger run).

Should trigger `oss-deep-audit`:

1. "Is this GitHub library safe to adopt in our service? Here is the repo URL."
2. "Explain how this unfamiliar open-source project works internally before we copy its approach."
3. "Compare these two OSS projects and tell me which to build on."

Near misses (expected skill):

1. "Audit my own SaaS app for IDOR and leaked keys." -> `security-audit`
2. "Reverse engineer this shipped Electron app and explain the feature." -> REA (`reverse-engineer-anything`), not this skill
3. "Which version range and lockfile policy should we use for this dependency?" -> `dependency-management-and-versioning`
