# Abstraction Timing: Metz, Dodds and Fowler's YAGNI

Sources: https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction · https://kentcdodds.com/blog/aha-programming · https://martinfowler.com/bliki/Yagni.html · https://martinfowler.com/bliki/RuleOfThree.html (404 at retrieval; not read) · Last verified 2026-11-23

## Metz: how a wrong abstraction grows

Written after her RailsConf 2014 talk where she said duplication is far cheaper than the wrong abstraction. The sequence she describes:

1. A programmer spots duplication, extracts and names it, and moves on.
2. Time passes; a new requirement almost fits.
3. A second programmer, feeling obliged to keep the abstraction, adds a parameter and a conditional.
4. Repeat until the code is incomprehensible; someone inherits it.

Why it survives: sunk cost. Existing code looks proven and necessary, and the more convoluted it is, the harder it is to discard. Recovery ("the fastest way forward is back"): re-inline the abstraction into every caller, use each caller's parameters to decide what part it needs, delete the rest, then re-extract from current requirements if a clean shared piece emerges. Signal: you keep passing parameters and adding conditional paths through shared code.

Note: SKILL.md's recovery list has the same steps; the new detail here is the sunk-cost mechanism and the observation that callers that "shared" code often run quite different code once inlined.

## Dodds: AHA

- Dodds credits Cher Scarlett with the acronym (Avoid Hasty Abstractions) and adopts Metz's principle.
- He criticizes both dogmas: DRY (quoted as every piece of knowledge having a single authoritative representation) and WET ("write everything twice", a Rule-of-Three variant). Neither is a hard rule.
- Personal cases: one bug needing fixes in eight copy-pasted places (duplication hurts), and an AngularJS pseudo-inheritance helper reused in far more than three places that was still the wrong abstraction (so reuse count alone does not justify abstraction).
- Optimize for change: future requirements are unknown, so early abstractions get bent with conditionals and loops until the helper becomes "the whole application". Duplication first reveals what actually varies.
- He used a copy-paste detector (jsinspect) in a consulting review to see abstraction opportunities.

## Fowler: YAGNI (2015)

- YAGNI targets **presumptive features**, capability for a need that has not arrived. Four costs: build, delay, carry (extra complexity slows every later change), repair (built before understanding matured). He cites Kohavi et al.: roughly a third of carefully analysed features moved their target metric, so a presumptive feature has at least about a two-in-three chance of being unused.
- Abstractions for hypothetical variants are suspect; an abstraction that makes current code harder to read is presumed guilty. Unused extension points often end up in the way (Jeremy Miller, quoted).
- What YAGNI does **not** cover: refactoring and making code easy to change, enabling practices (self-testing code, continuous delivery), code health, and zero-complexity forward-looking choices (his example: message lookup tables that ease later translation). YAGNI depends on malleable code.
- Caveat: skipping something occasionally makes a later change costly; those cases are memorable (availability bias) but rarer than the savings.
- Rule of Three: the bliki page returned 404, so no claim is taken from it. The rule's attribution is in the existing `sources.md`.

## Decision rules

- Use when: you see the second copy (note it), the third (consider extracting) and all three share an actor and reason to change.
- Avoid when: copies are only similar in shape, a requirement is still moving, or the abstraction already needs mode flags.
- Exception: duplication of a business rule (tax, pricing, auth check) is risky even at two copies; extract earlier (see `dry-knowledge-duplication-taxonomy.md`).

## Example: re-inline then re-extract (pseudo-code)

```
# before: shared helper with growing flags
send_notice(user, kind, skip_dedupe=False, as_admin=False)

# step 1: inline per caller, delete unused branches
billing:  render(invoice_tpl); email(user, body)
security: render(alert_tpl);   email(user, body); log(user)

# step 2 (later, if a stable shared piece shows): extract only email+log
```

## How an agent should apply this

- Count callers and name each caller's reason to change before extracting; refuse extraction on unnamed reasons.
- If a helper gains a boolean flag, propose inlining instead of another branch.
- Distinguish presumptive features (reject) from enabling refactors (accept) when citing YAGNI.
- Keep the first two copies adjacent and mark them with a short comment so the third is spotted.
- State explicitly when you choose duplication, so reviewers see it as a decision.
