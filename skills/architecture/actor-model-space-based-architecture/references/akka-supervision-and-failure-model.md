# Akka Actor Model: Messaging, Supervision and Failure Categories

Sources: https://doc.akka.io/libraries/guide/concepts/akka-actor.html · Last verified 2026-11-23

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

## What the page does not cover

It does not discuss mailbox mechanics, backpressure, delivery guarantees, benchmarks or concrete APIs. Anything about bounded mailboxes in the skill comes from general practice, not this page.

## How an agent should apply this

- Separate the protocol's expected failures (reply messages) from faults (supervision) in every actor design.
- Give every actor a clear parent and an explicit restart/stop policy per failure type.
- Never let callers depend on a restart being visible; keep references stable across restarts.
- Model replies as messages; do not write code that blocks a thread waiting for an actor.
- Do not claim guarantees (ordering across senders, delivery) that this source does not make.
