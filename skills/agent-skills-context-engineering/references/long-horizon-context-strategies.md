# Long-Horizon Context Strategies

Sources: https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · Last verified 2026-11-23

## Contents
- Framing
- Static context: prompts, tools, examples
- Retrieval timing: up-front, just-in-time, hybrid
- Three long-horizon techniques and when to pick each
- Failure modes
- How an agent should apply this

## Framing
Context engineering is curating the smallest set of high-signal tokens that makes the desired outcome likely, across everything in the window (prompt, tools, history, retrieved data), repeated on every model call. Reason: recall degrades gradually as context grows ("context rot"); each token spends a finite attention budget. Bigger windows soften but do not remove this, and the decline is a slope, not a cliff.

## Static context
- **System prompt altitude:** avoid both brittle if-else scripts and vague generalities. Use clear sections (XML tags or headers). Start minimal on the strongest model, then add instructions only for observed failures. Minimal is not the same as short.
- **Tools:** self-contained, clearly scoped, error-tolerant, token-efficient outputs. Overlapping tools create ambiguity: if a human cannot say which tool applies, the agent cannot either.
- **Examples:** a few diverse canonical examples beat a long list of edge-case rules.

## Retrieval timing
| Strategy | Mechanism | Strength | Cost |
|---|---|---|---|
| Up-front | load or embed-retrieve before inference | fast | stale or bloated context |
| Just-in-time | keep lightweight handles (paths, queries, links), load with tools at runtime | small context, progressive discovery, folder names and timestamps act as relevance signals | slower, dead-end exploration without guidance |
| Hybrid | pre-load a stable core, explore the rest | speed plus flexibility | needs a clear boundary |

The article cites Claude Code as hybrid: CLAUDE.md files loaded up front, glob and grep for the rest; it suggests hybrid fits less dynamic domains (legal, finance).

## Three long-horizon techniques
1. **Compaction:** summarize a nearly full window and restart from the summary. Keep architectural decisions and unresolved bugs; drop redundant tool output. Tune for recall first, then precision. The lightest form is clearing old tool results. Risk: over-aggressive compaction loses something needed later.
2. **Structured note-taking:** the agent writes durable notes (NOTES.md, to-do list, memory tool files) outside the window and reloads them. Low overhead, good for iterative work with milestones.
3. **Sub-agent isolation:** specialists work in a clean window and return a condensed summary (often 1,000-2,000 tokens); lead agent synthesizes. Strong for parallel research; adds coordination overhead.

Selection rule from the article: compaction for long back-and-forth conversation, notes for milestone-based iteration, multi-agent for parallel exploration. Guiding principle: "do the simplest thing that works."

```
# compaction prompt skeleton (own example)
Summarize for continuation. KEEP: decisions + rationale, open bugs, file paths touched,
next step. DROP: raw tool output, repeated attempts. Then list 3 things to re-verify.
```

## Failure modes
- Tool results piling up until 50k tokens of logs sit in history (clear or summarize).
- Compaction that drops the one constraint a later step needs (mitigate: re-read notes, keep a pinned decisions list).
- JIT exploration with no hints, burning turns on dead ends (add naming conventions and entry-point docs).
- Sub-agents returning raw dumps instead of condensed findings.

## How an agent should apply this
- Start with a minimal prompt, add rules only when a failure is observed and recorded.
- Keep a persistent notes file for any task that will outlive one window; write decisions as they happen.
- Pre-load only the stable core; reference everything else by path and read on demand.
- Delegate wide searches to a sub-agent with an explicit "return under ~1-2k tokens" instruction.
- Clear stale tool results before resorting to full summarization.
