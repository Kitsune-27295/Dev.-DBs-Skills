# Spring Modulith: Events, Publication Registry and Module Testing

Sources: https://docs.spring.io/spring-modulith/reference/events.html · https://docs.spring.io/spring-modulith/reference/testing.html (v2.2.0) · Last verified 2026-11-27

## Events between modules
- Prefer domain events over cross-module bean calls. Publishing is synchronous and inside the business transaction by default: simple consistency, but a failing listener rolls everything back.
- `@Async @TransactionalEventListener` decouples but loses events on a crash.
- `@ApplicationModuleListener` is the page's shortcut for an async listener running in its own transaction after commit (the exact composed annotations are inferred from its examples).

## Event publication registry
An entry per listener is written in the business transaction; completed on success, left incomplete on failure for retry.
| Status | Meaning |
|---|---|
| PUBLISHED / PROCESSING | stored / claimed |
| COMPLETED / FAILED | done / threw or went stale |
| RESUBMITTED | pending again after a retry |
| ABANDONED (2.2) | given up via an `AbandonPolicy` |
- A staleness monitor marks stuck publications FAILED (disabled when durations are zero).
- Resubmit via `FailedEventPublications` / `IncompleteEventPublications` with batch size, min age and filters; `abandon-after-attempts` defaults to -1 (off).
- Completion modes (property `spring.modulith.events.completion-mode`, since 1.3): UPDATE (default), DELETE, ARCHIVE (copy to an archive, readable via `CompletedEventPublications`). Starters for JPA, JDBC, MongoDB (replica set), Neo4j.
- `@Externalized("target::key")` (key may be a SpEL expression) sends events to Kafka, AMQP, JMS or a Spring Messaging channel. Outbox externalization (since 2.1) uses the Namastack or JobRunr starter with `spring.modulith.events.externalization.mode=outbox`.
- This is the Spring analogue of the outbox/inbox in the Grzybek implementation.

## Testing
- `@ApplicationModuleTest` bootstraps only the module's slice. Modes: STANDALONE (default), DIRECT_DEPENDENCIES, ALL_DEPENDENCIES.
- Beans from other modules that are missing: mock them (`@MockitoBean`); many mocks signal coupling, so replace them with events.
- `@ModuleSlicing` combines with Boot slices such as `@DataJpaTest`.
- `Scenario` API: stimulus (`publish` or `stimulate`), optional customization (`waitAtMost`), expected outcome (event or state change), terminal op (`toArriveAndVerify`, `notToArrive`). The stimulus always runs in a new transaction whose changes are never rolled back, so clean up with the `andCleanup` methods; `notToArrive` waits the full timeout.
- `spring-modulith-junit` (since 1.3) runs only tests for changed modules and their dependents; it falls back to a full run from an IDE, on build-file or classpath-resource changes, or when no changes are detected (`spring.modulith.test.on-no-changes=skip-all` skips instead). In CI set `spring.modulith.test.reference-commit`.

## Example
```java
@ApplicationModuleTest
class OrderTests {
  @Test void completes(Scenario s) {
    s.publish(new OrderPlaced(id)).andWaitForEventOfType(OrderCompleted.class).toArriveAndVerify(e -> {});
  }
}
```

## How an agent should apply this
- Default inter-module integration to `@ApplicationModuleListener` backed by the registry.
- Configure resubmission and a staleness policy before production; failed events otherwise sit silently.
- Choose a completion mode deliberately (ARCHIVE to keep history, DELETE for volume).
- Reliability theory for outbox and inbox: `saga-transactional-outbox-pattern`.
- Test each module in STANDALONE and treat mock growth as a design smell.
- Use Scenario for async flows instead of sleeps.
