# Trigger evals: hexagonal-architecture

Last verified 2026-11-27 (mental test of the description against these six prompts).

## Should trigger

1. "Add a CLI command that publishes a note; our use cases must not know about the terminal." Expected: hexagonal-architecture.
2. "Our service class opens a SQLite connection directly. How do I move that behind a port and test it with a fake?" Expected: hexagonal-architecture.
3. "Is it worth adding ports and adapters to this small admin app with one database?" Expected: hexagonal-architecture.

## Near misses

1. "Explain the Dependency Rule across entities, use cases and frameworks circles." Expected: clean-architecture.
2. "Constructor vs setter injection, and where should the container be built?" Expected: dependency-inversion-composition-root.
3. "Should I organize folders by feature slice instead of by layer?" Expected: vertical-slice-architecture.
