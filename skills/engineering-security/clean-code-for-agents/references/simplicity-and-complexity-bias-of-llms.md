# Simplicity and the Complexity Bias of LLMs

Sources: https://grugbrain.dev/ · https://github.com/joshuadavidthomas/agent-skills/blob/main/grug-brained-dev/SKILL.md · https://grugbrain.ai/ (satire tribute page) · https://market.lobehub.com/s/skills/neversight-learn-skills.dev-grug-brain-development (marketplace copy, MIT per its metadata) · Last verified 2026-11-27

Licensing note: the essay states no license (all rights stay with its author); the agent skill repo is MIT. Everything below is paraphrased; no text is reproduced.

## 1. The core claim

The essay's one message is that complexity is the main enemy of a codebase. It arrives through well-meaning additions, and it is felt when a small change breaks something far away. The agent skill adds the LLM-specific observation: a model can produce clean-looking architecture (many boxes, names, files) very fast and at no visible cost, because "average good code" in its training data is often layered. Fluent naming then hides the lack of substance. Treat that as a known bias of the writer (you), not as evidence the design is good.

## 2. Counter-rules for premature abstraction, layers and verbosity

| Bias | Rule | Test before keeping the construct |
|---|---|---|
| Extra layer/manager/provider | Name only what exists today; no "maybe later" seams | Does it trap real, ugly detail, or only forward a call? |
| Interface with one implementation | Do not add it; add it when a second one exists | Who is the second implementation? |
| Helper for one line | Inline it | Does the name tell more than the line? |
| Config option or mode nobody asked for | Say no, or build the 80/20 version | Who sets it, and to what? |
| New folder/file per concept | One concept per file, not one helper per file | Does the split reduce jumps for the reader? |
| Verbose defensive wrappers | Handle failures that can really happen at this boundary | Name the failure and who observes it |
| Dense clever expression | Split into named locals so a debugger can inspect them | Can you print each part? |

The agent skill's own stop questions are a good filter: why does this exist, who touches it, what breaks if it is deleted, would merging files or inlining make it easier, and can a tired reader understand it from one file? If the answer needs fancy vocabulary, suspect the construct.

## 3. When to say no, and "ok, but smaller"

1. Default to declining speculative features, abstractions and settings (essay: refusal is the strongest anti-complexity tool).
2. If you must deliver, deliver 80% of the value with roughly 20% of the code, and say what you left out.
3. Do not build a cathedral when the request was a hut.
4. A pure reaction ("make everything functions", "inline everything") is also a mistake: judge each construct separately (agent skill: no hard pivot).

## 4. Abstraction timing and cut points

Early structure is guesswork. Let the code work first, watch where the seams settle, then cut. A good cut point has a narrow interface and hides real mess behind it, with one reason to change, testable at the seam, and callers that become simpler. A fake one has a fancy name, a single caller, a single implementation, and more places to look. Greenfield work is the riskiest moment: everything looks possible, so draw no boxes until a second use or a real difficulty appears.

```python
# Fake seam: one caller, one implementation, forwards a call.
class EmailSenderProvider:
    def send(self, msg): return smtp.send(msg)

# Real alternative today:
smtp.send(msg)   # extract only when retries or a second transport exist
```

## 5. Locality of behavior vs DRY

The essay prefers code that sits next to what it affects, and tolerates simple repetition over an abstraction built on callbacks. Count the reader's travel cost: if understanding one behavior needs five files, that is a defect (SIM-04). The decision between sharing and repeating is made in CF-01 of [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md); the knowledge test is in `ssot-and-dry`.

## 6. Chesterton's fence and refactoring

Before deleting or rewriting an odd-looking check, find why it exists (git blame, tests, callers). If the reason is gone, remove it; if real, keep it and do not give a small check a grand name. Refactor in small steps with the system working after each one; a large rewrite is the usual way a refactor fails. Over-abstraction is itself a main cause of failed refactors.

## 7. Tests, logs, types (briefly)

Write tests after the shape firms; prefer integration tests at stable seams (CF-07), and for a bug write the reproducing test first. Types are most valuable for discoverability; avoid type-level cleverness for plain tasks. Log major branches with a correlation ID. Detail belongs to `tdd`, `testing-pyramid-and-shapes`, `error-handling-problem-details`.

## 8. When abstraction is justified (link, do not duplicate)

- Second real use and same fact: `ssot-and-dry`, `pragmatic-solid-and-ssot`.
- Variation points that already exist: `open-closed-principle`.
- Timing/YAGNI/AHA arguments: `kiss-yagni-aha`, `yagni-evolutionary-architecture`.
- Structure across modules: `codebase-design`, `layered-refactor`.
- Invariants worth a type: `defensive-domain-modeling`, `value-objects-type-invariants`.
- Review stance: `code-review`.

## How an agent should apply this

- Before adding a file, class, interface, parameter or option, state the concrete thing it hides today; if none, write the plain code.
- Prefer the smallest diff that satisfies the request and list deliberate omissions in one line.
- Inline single-use helpers and one-implementation interfaces you created in the same change.
- Keep related behavior in one readable place; extract only when two real uses share one fact.
- Read the reason for odd code before removing it; refactor in steps that keep tests green.
- Do not use persona or voice tricks in output; use the questions, not the dialect.
