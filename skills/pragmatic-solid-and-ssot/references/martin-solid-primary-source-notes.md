# Martin's SOLID Posts: What They Actually Say

Sources: https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html · https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html · https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html · Last verified 2026-11-23

Anchored to the SOLID table in SKILL.md section 3. The SRP slug on the site is spelled `SingleReponsibilityPrinciple` (missing "s"); this is the working URL.

## "SOLID Relevance" (2020)

Written in reply to a manager who argued microservices make OCP less important, that LSP matters less with less inheritance, and that developers should "just write simple code" (a view attributed to Dan North). Martin's thesis: software is still sequence, selection and iteration, so the principles still apply. Per principle:

- **SRP:** group code that changes for the same reasons, separate code that changes for different ones (business rules vs GUI, SQL vs protocol). A tangled microservice is still tangled.
- **OCP:** modules extendable without modification; example is device independence (disk, printer, screen, pipe behind one abstraction instead of scattered conditionals). Separating abstract policy from concrete detail confines the damage of a requirement change.
- **LSP:** concerns subtyping, not inheritance; duck types are subtypes of an implied interface. If an implementation confuses callers, `if`/`switch` checks multiply at call sites.
- **ISP:** keep interfaces small so clients do not depend on what they do not use. Strongest in compiled, statically typed languages (he lists Java, C#, C++, Go, Swift) because an unused method can still force recompile and redeploy; dynamic languages are less but not wholly immune (he cites Maven/Leiningen as evidence).
- **DIP:** source dependencies point at abstractions, especially across architectural boundaries, keeping business logic free of SQL, validation and formatting concerns.

His closing point: simplicity needs principles; "just be simple" gives no guidance.

## SRP post (2014)

Traces the idea to Parnas (1972, modules around design decisions likely to change), Dijkstra (separation of concerns) and Constantine's coupling/cohesion. Definition: one reason to change. He resolves "what is a reason?" by tying it to people: code is not responsible for fixes, programmers answer to stakeholders. The `Employee` example: `calculatePay` (CFO), `reportHours` (COO/auditors), `save` (CTO/DBAs). "This principle is about people." Alternate wording: gather what changes for the same reasons, separate what changes for different ones. Why it matters: changing one stakeholder's feature should not break another's.

## OCP post (2014)

Contrasts Meyer's 1988 "open and closed" (compiled library, approved baseline) with Martin's version: extend behavior without modifying the system, so new features ship as new code (new jar/dll/gem) with old code untouched. Shotgun Surgery is the counter-state. Evidence offered: plugin-extended tools (IDEs, Vim, TextMate, Minecraft). Mechanism: OO separation of policy from detail and inverting dependencies that cross significant boundaries, so "the system doesn't know about the plugins; the plugins know about the system".

## Where the SKILL.md wording needs care (my own reading)

- The SRP quote in SKILL.md ("responsible to one, and only one, actor") is the later formulation; this 2014 post's literal text is "one reason to change" with the people/stakeholder explanation.
- None of the three posts says "do not create single-implementation interfaces". The anti-ceremony stance in SKILL.md is the skill's own pragmatic rule, supported by `codebase-design` and the Harvard handbook; see `interface-considered-harmful-reading.md`.
- OCP in the post is about architecture-scale plugin boundaries, not speculative factories inside one module.

## How an agent should apply this

- When splitting a module for SRP, name the actors/stakeholders first; split only along actor lines.
- Treat OCP as a boundary decision (is this a plugin-style extension point worth having?), not a per-class habit.
- Use LSP as a smell test: if callers need `instanceof` or `NotImplemented`, the abstraction is wrong.
- Apply ISP hardest in statically compiled, separately deployed code; in a script or dynamically typed app, a fat object costs less.
- Use DIP at architectural boundaries (domain to DB/HTTP), not for stdlib or pure helpers.
