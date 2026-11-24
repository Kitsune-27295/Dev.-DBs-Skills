# Resolve Before Asking

Sources: a third-party MIT skill (resolve-before-asking) read for ideas, no text reused · https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md (MIT) · Last verified 2026-11-24

## The rule
Never spend the user's attention on a question your tools can answer. Asking is the last step of a search chain, not a shortcut around it. This extends `SKILL.md` ("finding facts is your job") from environment facts to identity and relationship questions ("who is X", "what does this term mean here").

## The chain (stop at the first clear answer)
1. Think from what is already in context.
2. Search the local knowledge base or repository and read the top hit in full, not the snippet.
3. Query whatever other sources are mounted (issue tracker, mail or meeting notes, logs).
4. Follow links, history and references around the entity.
5. Search the web only after the above, then record what you found so it is not looked up twice.
6. Only then ask, and ask with a hypothesis.

## Asking with a hypothesis
State what you searched and what you found, including partial signals, then ask a confirmable question: not "who is X?" but "Is X the billing contact at Acme, based on three invoice threads?". This fits the grilling format: put your best guess in the recommended-answer line so a "yes" settles it.

## Confidence
Clear answer (several consistent signals, or a filled field): do not ask. Sparse or contradictory signals: ask, lead with the best guess, and state the contradiction. No placeholder such as "to be filled" survives: resolve it now or record it as an open question.

## How an agent should apply this
- Before each round, remove questions answerable by search.
- For each question you do ask, log the chain you ran in one line.
