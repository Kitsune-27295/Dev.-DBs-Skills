# Trigger evals

Last verified 2026-11-27. Starting points for tuning the description, not laws.

Should trigger:
1. "The subagent says the migration is done and all tests pass. Can I tell the user it's finished?" -> `verification-loop`
2. "Before I say this refactor is fixed, what proof do I need and who should check it?" -> `verification-loop`
3. "My agent loop keeps retrying the same failing check; when should it stop and escalate?" -> `verification-loop`

Near-misses:
1. "Write a failing test first, then make it pass, then refactor." -> `tdd`
2. "Review this diff for style and correctness against our standards." -> `code-review`
3. "The Playwright suite fails intermittently on CI, classify the failures." -> `playwright-qa-orchestrator` (or `ci-test-reliability` for non-browser flakes)
