# Skill Authoring Notes for This Skill

Sources: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf · https://code.claude.com/docs/en/skills · https://platform.claude.com/cookbook/managed-agents-cma-use-skills-from-a-repo · https://www.cubic.dev/blog/claude-code-skills (secondary, low trust) · Local skill-authoring skills (private installs, paraphrased) · Last verified 2026-11-24

What was adopted when writing `oss-deep-audit`, and what to check before editing it.

## 1. Rules from the public sources

| Rule | Source | Applied as |
|---|---|---|
| `SKILL.md` exact name, kebab-case folder, no README inside the skill folder | Anthropic guide | Folder `oss-deep-audit`, no README |
| Frontmatter: `name` and `description` required; description under 1024 characters, states what it does and when to use it; no angle brackets in frontmatter | Anthropic guide | Description about 800 characters with a "Use when" clause and trigger phrases, no angle brackets |
| Description is the routing signal; front-load the key use case | Claude Code docs, cookbook | Opens with the job, then the untrusted-data stance, then triggers |
| Claude Code truncates `description` plus `when_to_use` at 1,536 characters; the guide caps description at 1024 | Claude Code docs, guide | Stay under the stricter 1000 |
| Keep `SKILL.md` short (docs say under 500 lines); move detail to linked files; link every file with a when-to-read hint | Docs, guide | Body is a router plus rules; reference files hold commands, checklists and templates |
| Model and effort keys exist in Claude Code frontmatter but are not portable | Claude Code docs | Omitted on purpose: `name` and `description` only |
| Add negative triggers if a skill over-fires | Guide | Boundary sentence names `security-audit` for own code |
| Test with triggering, functional and comparison prompts; 10-20 queries that should trigger | Guide | Test list in section 3 |
| Repo content can steer the agent; review skills in a repo before running an agent there | Docs, cookbook (cookbook security points are partly the summarizer's inference) | Basis for the untrusted-repo envelope |
| Cubic's numbers on listing budgets and bug rates | Cubic blog | Not used: claims by a secondary source |

## 2. Rules from the local authoring skills (paraphrased)

- **Pointers carry triggers**: the description is a context pointer whose wording decides when the skill fires; one trigger per distinct branch, no synonyms that name the same branch twice. Applied: triggers are audit, dissect, evaluate, compare, plus three user phrasings.
- **Information hierarchy**: in-file steps first, in-file reference second, disclosed reference behind pointers third; push down what only some branches need. Applied: phases and rules in `SKILL.md`, commands, checklists and templates in references.
- **Single source of truth, no duplication**: each meaning lives once. Applied: the report shape lives in the report-templates file, scope tiers and rules live in `SKILL.md`, references point back instead of restating.
- **Completion criteria**: every step ends on a checkable bound. Applied: tier stopping criteria, the closing checklist, "open every cited line once".
- **Positive phrasing**: prompt the target behavior; keep hard prohibitions only as guardrails. Applied: the safety envelope pairs each prohibition with the safe alternative (shallow clone, neutral directory, opt-in sandbox).
- **Trigger/Protocol split and Gate Function** (skill-review lenses): the description carries triggers, the body carries protocol; the evidence table is the gate before any claim enters the report.
- **Template ownership**: one file owns the report structure; others do not restate it.
- **Router body, minimal shape**: one skill, one job, a short entry file with first-hop references; validate with a lightweight local check, not model self-report.
- **Skill-creator loop**: draft, run realistic prompts, review, iterate; descriptions should be slightly assertive because skills under-trigger. Applied through the trigger phrases and the test list.
- **Invocation choice**: model-invoked, because the agent should reach it from natural requests; no `disable-model-invocation`, since the skill is read-only.

## 3. Validation checklist before changing this skill

- Frontmatter has only `name` and `description`; `name` equals the folder; description under 1000 characters, en-US, "Use when" present.
- Every relative link in `SKILL.md` resolves to a non-empty file.
- Triggering tests (examples): should fire on "is this GitHub library safe to adopt", "how does this repo work internally", "compare these two OSS projects before we choose", "audit this dependency's supply chain"; should not fire on "audit my own app's security" (`security-audit`) or "fix this bug in my code" (`diagnosing-bugs`).
- No rule duplicated between `SKILL.md` and a reference.
- The safety envelope still says: read-only, untrusted data, shallow clone outside the project, nothing executed by default.

## How an agent should apply this

- Edit the smallest owning file; keep the five report sections and the three evidence classes stable.
- Re-run the checklist above after any edit, including link resolution.
- Add a reference only when a new topic outgrows its current file.
- Keep frontmatter portable; add model or effort keys only in a local fork, never in the shared pack.
