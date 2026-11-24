# Sources — Layered refactor

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter "Organizando seu código em gavetas" (20:32-24:07) | Page 200 OK; transcript read in full (local export) | The three "drawers" (screen, business rules, data and external services), "not Clean Architecture", the productivity-sag-in-the-middle argument, what the prompt does (map, behavior tests, small steps, tests after each step) and the rule of no bug fixing and no parallel branches during the refactor |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "4. Separação de responsabilidades" and its prompt | Page 200 OK; handout read in full (local export) | The six numbered steps, characterization tests, "same public names", no new framework, no renames of routes, public props or columns, bug list kept separate, plan approved before step 1 |

## Claims and caveats

- The video attributes the mid-project productivity dip to a study it calls "Loss in the Middle" (the published work is usually titled "Lost in the Middle" and concerns language-model recall of information in long contexts). The video applies it by analogy to whole projects. SKILL.md already notes this distinction; the study itself was not opened here, so its content is from general knowledge, not read from source.
- The curve of productivity falling then recovering, and the claim that few people "survive" the middle, are the speaker's anecdotal claims.
- "Better odds, not a guarantee" in SKILL.md is the skill author's hedge, consistent with the video's own "not 100%".
- The handout prompt introduces the term characterization tests; the video says "tests of today's behavior". Same idea.
- The video's "do not run a bug-fix branch in parallel" is a process claim from experience; no external source.
- No external pages are cited for this topic.
