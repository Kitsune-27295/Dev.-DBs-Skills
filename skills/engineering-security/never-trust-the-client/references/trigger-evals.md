# Trigger evals

Should trigger (`never-trust-the-client`):
1. "The checkout computes the discount in React and posts the final total. Fix it."
2. "We found VITE_OPENAI_KEY in the built bundle. What now?"
3. "Plan limits are only checked by hiding the button; make the server enforce them."

Near misses (another skill):
1. "Audit this whole vibe-coded repo for the top SaaS flaws, change nothing." -> `security-audit`
2. "Which Supabase tables are readable by anon, and is the DB port open?" -> `database-exposure`
3. "Design refresh-token rotation and per-object permission checks." -> `authn-authz-guard`
