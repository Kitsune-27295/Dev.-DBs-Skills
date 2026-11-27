# Long-Horizon Context Strategies

Sources: https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · Last verified 2026-11-27

## Contents
- Framing
- Static context: prompts, tools, examples
- Retrieval timing: up-front, just-in-time, hybrid
- Three long-horizon techniques and when to pick each
- Failure modes
- How an agent should apply this

## Framing
Context engineering is curating the smallest set of high-signal tokens that makes the desired outcome likely, across everything in the window (prompt, tools, history, retrieved data), repeated on every model call. Reason: recall degrades as the window fills ("context rot"); the article ties this to every token attending to every other (n squared pairwise relationships) and calls context a finite resource with diminishing marginal returns, an "attention budget". It describes a performance gradient, not a hard cliff.

## Static context
- **System prompt altitude:** avoid both brittle hardcoded logic and vague generalities (the "Goldilocks zone"). Use clear sections (XML tags or Markdown headers). Start with a minimal prompt on the best available model, then add instructions and examples for observed failure modes. Minimal does not mean short.
- **Tools:** self-contained, robust to error, clear about intended use. Bloated or overlapping tool sets are a common failure: if a human cannot say which tool applies, the agent cannot either.
- **Examples:** a set of diverse, canonical examples beats a long list of edge-case rules.

## Retrieval timing
| Strategy | Mechanism | Strength | Cost |
|---|---|---|---|
| Up-front | load or embed-retrieve before inference | fast | stale or bloated context |
| Just-in-time | keep lightweight handles (paths, stored queries, links), load with tools at runtime | small context; folder hierarchy, naming conventions and timestamps act as relevance signals | slower; dead-end exploration without guidance |
| Hybrid | pre-load a stable core, explore the rest | speed plus flexibility | needs a clear boundary |

The article cites Claude Code as hybrid: `CLAUDE.md` files up front, glob and grep for the rest. It says hybrid "might be better suited" to less dynamic content such as legal or finance work, and gives no further reasoning.

## Three long-horizon techniques
1. **Compaction:** summarize a window nearing its limit and restart from the summary. In Claude Code the model preserves architectural decisions, unresolved bugs and implementation details, discards redundant tool output, and continues with the summary plus the five most recently accessed files. Tune the compaction prompt for recall first, then improve precision by removing the superfluous. The lightest form is clearing old tool results. Risk: over-aggressive compaction loses something needed later.
2. **Structured note-taking:** the agent writes durable notes (a notes file, a to-do list, memory-tool files) outside the window and reloads them. Low overhead; the article rates it best for iterative development with clear milestones.
3. **Sub-agent isolation:** specialists work in a clean window, may use tens of thousands of tokens exploring, and return a condensed summary (often 1,000 to 2,000 tokens) to a lead agent. Best for complex research with parallel exploration; adds coordination overhead.

Selection rule from the article: compaction for tasks with extensive back-and-forth, notes for milestone-based iteration, multi-agent for parallel exploration. Guiding principle: "do the simplest thing that works". The article gives no threshold for when to compact and no method for measuring recall or precision; treat any such number as your own calibration.

```
# compaction prompt skeleton (own example)
Summarize for continuation. KEEP: decisions + rationale, open bugs, file paths touched,
next step. DROP: raw tool output, repeated attempts. Then list 3 things to re-verify.
```

## Failure modes
- Tool results piling up until tens of thousands of tokens of logs sit in history (clear or summarize).
- Compaction that drops the one constraint a later step needs (mitigate: re-read notes, keep a pinned decisions list).
- Just-in-time exploration with no hints, burning turns on dead ends (add naming conventions and entry-point docs).
- Sub-agents returning raw dumps instead of condensed findings.

## How an agent should apply this
- Start with a minimal prompt; add rules only when a failure is observed and recorded.
- Keep a persistent notes file for any task that will outlive one window; write decisions as they happen.
- Pre-load only the stable core; reference everything else by path and read on demand.
- Delegate wide searches to a sub-agent with an explicit "return a short summary" instruction (the article's figure is 1,000 to 2,000 tokens).
- Clear stale tool results before resorting to full summarization.
