# Sources - Layered refactor

Every URL below was checked during skill authoring (2026-11-27, re-fetched with a web fetch tool; earlier text was a draft).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "4. Separacao de responsabilidades" and its prompt | 200 OK, read; headings and the section's prompt confirmed | Three layers (UI, business rules, data access and external services), six prompt steps, characterization tests, same public names, no new framework, no renames of routes, public props or columns, separate bug list, plan approved first, order (integration tests before separation), separate branch |
| Video "Fundamentos de Engenharia de Software para Vibe Coders", https://www.youtube.com/watch?v=G8SeOH0qerk | Page title only confirmed; channel, date, chapters and transcript could not be read | Nothing is relied on from it any more (see below) |
| https://arxiv.org/abs/2307.03172 "Lost in the Middle: How Language Models Use Long Contexts" | 200 OK, abstract read | Confirms the study is about model recall by position in long inputs, not about project productivity |

## Reading limits

- The handout was read through a summarizing fetch tool.
- No scripts or code in this skill; the example is the skill author's own.

## Claims not adopted as fact

- The video's "Loss in the Middle" analogy for a mid-project productivity dip, the claim that an organized codebase keeps the agent effective longer, and the curve of productivity falling then recovering: not verifiable here, and the study concerns long-context recall, so they were removed.
- The video's explicit rejection of Clean Architecture and its chapter timestamps: the handout does not say this; video unread.
- "Do not run a bug-fix branch in parallel with the refactor": a process claim from the video, kept only as this pack's advice, marked as such.
- Any "better odds, not a guarantee" effect on agent performance: the earlier draft's hedge, with no source.
