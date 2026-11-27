# Trigger evals

Last verified 2026-11-27

Should trigger `fundamentals-audit`:

1. "I built my SaaS with an AI tool. Before I change anything, tell me what is wrong with it."
2. "I have five fix prompts from a course. Which should I run first on this repo?"
3. "What safety rules should I follow before letting an agent run these fix prompts?"

Near misses (expected owner in parentheses):

1. "Two requests buy the last item at once and stock goes negative. Fix it." (`race-condition-fix`)
2. "Check my Postgres for public tables, missing backups and slow queries." (`database-audit`)
3. "Do a full security review of this API against the OWASP list." (`security-audit`)
