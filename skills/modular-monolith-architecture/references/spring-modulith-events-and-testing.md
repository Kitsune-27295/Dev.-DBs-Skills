# Spring Modulith: Events, Publication Registry and Module Testing

Sources: https://docs.spring.io/spring-modulith/reference/events.html · https://docs.spring.io/spring-modulith/reference/testing.html (v2.2.0) · Last verified 2026-11-23

## Events between modules
- Prefer domain events over cross-module bean calls. Publishing is synchronous and inside the business transaction by default: simple consistency, but a failing listener rolls everything back.
- `@Async @TransactionalEventListener` decouples but loses events on a crash.
- `@ApplicationModuleListener` (recommended) = async + new transaction + after-commit listener.

## Event publication registry
An entry per listener is written in the business transaction; completed on success, left incomplete on failure for retry.
| Status | Meaning |
|---|---|
| PUBLISHED / PROCESSING | stored / claimed |
| COMPLETED / FAILED | done / threw or went stale |
| RESUBMITTED | retried |
| ABANDONED (2.2) | given up via an `AbandonPolicy` |
- A staleness monitor marks stuck publications FAILED (disabled when durations are zero).
- Resubmit via `FailedEventPublications` / `IncompleteEventPublications` with batch size, min age and filters; `abandon-after-attempts` defaults to -1 (off).
- Completion modes: UPDATE (default), DELETE, ARCHIVE. Starters for JPA, JDBC, MongoDB (replica set), Neo4j.
- `@Externalized("target::key")` sends events to Kafka, AMQP or JMS; outbox mode is available through additional starters; serialize-externalization preserves order during resubmission.
- This is the Spring analogue of the outbox/inbox in the Grzybek implementation.

## Testing
- `@ApplicationModuleTest` bootstraps only the module's slice. Modes: STANDALONE (default), DIRECT_DEPENDENCIES, ALL_DEPENDENCIES.
- Beans from other modules that are missing: mock them (`@MockitoBean`); many mocks signal coupling, so replace them with events.
- `@ModuleSlicing` combines with Boot slices such as `@DataJpaTest`.
- `Scenario` API: stimulus (`publish` or `stimulate`), optional customization (timeouts), expected outcome (event or state change), terminal op (`toArriveAndVerify`, `notToArrive`). The stimulus runs in a new transaction, so clean up data yourself; `notToArrive` waits the full timeout.
- `PublishedEvents`/`AssertablePublishedEvents` assert published events.
- `spring-modulith-junit` runs only tests for changed modules and their dependents; it falls back to a full run from an IDE or on build-file or classpath-resource changes.

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
- Choose a completion mode deliberately (ARCHIVE for audit, DELETE for volume).
- Test each module in STANDALONE and treat mock growth as a design smell.
- Use Scenario for async flows instead of sleeps.
