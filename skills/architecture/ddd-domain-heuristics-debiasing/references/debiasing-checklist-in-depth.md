# Debiasing Decisions Toolkit in Depth

Sources: https://github.com/ddd-crew/debiasing-decisions-toolkit · Last verified 2026-11-27

Premise (as stated by the toolkit): awareness of bias does not counter it; structured interventions embedded in the workflow do. It cites Morewedge et al. (targeted training reduces bias effect) and Soll, Milkman & Payne (HBR 2015, five-step framework) and extends that to software design and architecture. Treat these as the toolkit's claims, not independently verified. License CC BY-SA 4.0 (attribution to Evelyn van Kelle and Kenny Baas-Schwegler; adaptations share alike). The Adams et al. Nature 2021 paper appears only in the toolkit's references list.

## The five steps and their questions

1. **Be Decision-Ready.** Are we deciding under emotional stress? Is "keep the current state" winning only because thinking is costly? Has cognitive load made doing nothing the easiest path?
2. **Broaden the Frame.** Did we consider removing something, not only adding? Unconventional uses of existing tools? Ask what a "service/manager/handler" actually knows and does.
3. **Seek Independent Advice.** Do views come from independent sources or one opinion repeated? Were opposing views seriously weighed? Is this confidence in our own expertise? What would we ask if a junior proposed it?
4. **Test Your Assumptions.** Are we accepting it because of who/what proposed it (AI, senior architect, vendor)? What problem was it designed for and do we have it? What is the plan for when (not if) it fails?
5. **Establish Simple Rules.** Is it a two-way door (reversible)? If yes, delegate instead of seeking consensus. Did effort match irreversibility? Did the group check together?

## The ten biases and their counter-moves

| Bias | What it looks like in architecture | Counter (step) |
|---|---|---|
| Myopic Misery | Rushing a fix during an incident | Postpone non-urgent choices (1) |
| Status Quo Bias | "We have always used X" | Weigh alternatives explicitly (1) |
| Additive Bias | New layer/service instead of deleting code | Ask what can be removed (2) |
| Functional Fixedness | Golden hammer | Ask what the parts could do (2) |
| Overconfidence | Estimates and expertise trusted too much | Seek opposing views (3) |
| Correlation Neglect | Five blog posts echoing one source | Verify independence (3) |
| Authority Bias | Deferring to architect, vendor or AI output | Judge on merit (3, 4) |
| Illusion of Control | No failure plan | Design for failure (4) |
| Law of Triviality | Hours on naming, minutes on database choice | Match time to reversibility (5) |
| False Consensus | "Everyone agrees" without asking | Make dissent safe (5) |

The counter column is derived from the checklist questions (the toolkit page does not give an explicit counter-measure table).

## Using it in an ADR

The toolkit ships a condensed checklist meant to be pasted into the Decision section of an ADR; each checkbox carries its bias tag. Run it as a team, inside an existing ritual (ADR review, design session, retro). It does not prescribe timings.

```markdown
## Debiasing check (team, before Accepted)
- [ ] Are we in a state to decide today? (Myopic Misery, Status Quo)
- [ ] Did we consider removing instead of adding? (Additive Bias)
- [ ] Are sources independent? (Correlation Neglect)
- [ ] Is this accepted on merit, not on who said it? (Authority Bias)
- [ ] What happens when it fails? (Illusion of Control)
- [ ] Two-way door? Time spent proportional? (Law of Triviality)
```

Pair with `adr-architecture` for ADR structure.

## Failure modes
- Ticking boxes alone: the toolkit stresses collective checking.
- Using it for every trivial choice: step 5 says reversible decisions should be delegated.
- Treating the list as proof of a good decision; it only reduces known biases.

## How an agent should apply this

- When asked to justify a design, first run steps 2 and 4 on your own proposal: include a removal option and a failure plan.
- Flag Authority Bias toward your own output: state assumptions the reader should test.
- Classify decisions as one-way or two-way doors before recommending process weight.
- Offer the pasted ADR snippet rather than lecturing about biases.
- Check source independence when citing multiple references.
