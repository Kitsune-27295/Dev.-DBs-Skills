# Trigger evals: pragmatic-solid-and-ssot

Last verified 2026-11-27. Prompts a description should (or should not) fire on.

## Should trigger
1. "Review this PR: every service got an `IFoo` with exactly one implementation. Is that SOLID?" Expected: this skill.
2. "Does my `ReadOnlyList` subclass break Liskov because `add` throws?" Expected: this skill.
3. "How do I split the pricing logic from the file reading so I can test it without mocks?" Expected: this skill.

## Near-miss (should not trigger)
1. "These two validators look identical; should I merge them or keep both?" Expected: `ssot-and-dry`.
2. "I have three near-copies of a helper and a boolean flag keeps growing; extract or not?" Expected: `kiss-yagni-aha`.
3. "Explain how to wire dependencies in one composition root." Expected: `dependency-inversion-composition-root`.
