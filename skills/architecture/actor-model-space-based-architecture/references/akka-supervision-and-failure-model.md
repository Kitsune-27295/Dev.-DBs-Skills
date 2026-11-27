# Akka Actor Model: Messaging, Supervision and Failure Categories

Sources: https://doc.akka.io/libraries/guide/concepts/akka-actor.html · https://doc.akka.io/libraries/akka-core/current/typed/fault-tolerance.html · https://doc.akka.io/libraries/akka-core/current/typed/mailboxes.html · Last verified 2026-11-27

## The problem the model answers

Distributed components crash without replying, messages get lost, and latency fluctuates. The Akka guide stresses this is true even inside a managed data center and worse in virtualized setups. The actor model is offered as one uniform way to get concurrency, remote communication and clustering without hand-written locks, atomics or networking code.

## Mechanics

- **Encapsulation without locks.** Actors do not expose mutable state; other code can only send them messages. The developer does not reason about memory visibility.
- **Messages, not method calls.** Sending a message does not hand the sender's thread to the receiver. The sender continues immediately, so the reply (if any) must itself be modeled as a message.
- **Cooperative entities.** Actors react to a signal, change state, and signal others; the application moves forward through these chains.
- **One model across libraries.** The same actor abstraction underlies clustering, streams and persistence, so one mental model covers them.

## Two error categories (the key design rule)

| Category | Example | Who handles it | How |
|---|---|---|---|
| Task/domain error | request names a nonexistent user id | the caller | the actor stays healthy and replies with an ordinary error message |
| Internal fault | the service itself broke | the parent actor | supervision decides restart or stop |

Rule: model domain errors as normal reply messages in the protocol; never use supervision for validation failures.

## Supervision hierarchy

- An actor that creates another becomes its parent; the tree is compared to an OS process tree.
- Parent defines a **supervisor strategy** when starting a child: restart for some failure types, stop for others.
- Stopping a parent stops all descendants recursively.
- No silent death: a child either fails (supervisor reacts) or stops (watchers are notified). The page names an actor stuck in an infinite loop as the exception.
- Restarts are transparent: collaborators may keep sending to the same reference while the target restarts.
- Every actor has exactly one responsible manager, its parent.

## Pseudo-code

```
protocol: Withdraw(accountId, amount) -> Reply(Ok | InsufficientFunds | UnknownAccount)

Account actor:
  on Withdraw: if amount > balance -> reply InsufficientFunds   # domain error, no exception
Parent supervisor:
  on child crash(DbConnectionLost) -> restart child
  on child crash(CorruptState)     -> stop child, alert
```

## Strategies and watching (Akka Typed fault-tolerance page)

- Three strategies are described: resume (ignore the failure, take the next message), restart (reinstall the original behavior) and stop (the default when an exception is thrown and no strategy is defined). The page points to `SupervisorStrategy` for the full list and does not mention an escalate directive.
- A parent calls `watch` on a child to learn when it ends. A failed child produces `ChildFailed` (carries the cause, extends `Terminated`). An unhandled `Terminated` makes the parent fail with a death-pact exception that its own supervisor handles. By default only the immediate parent sees the original exception; rethrowing passes it up.

## Mailboxes (Akka Typed mailboxes page)

Mailboxes are unbounded by default. A bounded mailbox can be selected per actor or by configuration; the non-blocking kind sends overflow to dead letters, while other bounded kinds block the sender only when a push timeout is non-zero.

## What the pages do not cover

Delivery guarantees, cross-sender ordering, benchmarks and concrete tuning. The concept guide itself does not mention mailboxes, backpressure, resume or escalate.

## How an agent should apply this

- Separate the protocol's expected failures (reply messages) from faults (supervision) in every actor design.
- Give every actor a clear parent and an explicit restart/stop policy per failure type.
- Never let callers depend on a restart being visible; keep references stable across restarts.
- Model replies as messages; do not write code that blocks a thread waiting for an actor.
- Pick a bounded mailbox or backpressure for any actor that a faster producer can feed.
- Do not claim guarantees (ordering across senders, delivery) that this source does not make.
