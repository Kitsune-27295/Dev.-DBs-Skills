# Trigger Evals

Last verified 2026-11-27. Three prompts that should load this skill and three near-misses that belong elsewhere.

## Should trigger

1. "The agent keeps opening replies with flattery and ending with a recap, even though the style rule forbids it. Make that enforceable." Expected: `text-quality-gate`.
2. "Write a commit-msg hook that rejects subjects with emoji or filler words." Expected: `text-quality-gate`.
3. "Add a Claude Code hook that blocks writes to docs containing banned phrases." Expected: `text-quality-gate`.

## Near-miss (should not trigger)

1. "Set up Husky and lint-staged to run Prettier on commit." Expected: `setup-pre-commit`.
2. "Block the agent from running force-push and reset --hard." Expected: `git-guardrails-claude-code`.
3. "How should I name variables and write comments in this module?" Expected: `clean-code-for-agents`.
