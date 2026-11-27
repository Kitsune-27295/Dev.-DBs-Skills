# Chain of Responsibility and Message Filter

Sources: https://refactoring.guru/design-patterns/chain-of-responsibility, https://www.enterpriseintegrationpatterns.com/patterns/messaging/Filter.html (the `MessageFilter.html` slug returned 404) · Last verified 2026-11-23

## Chain of Responsibility

Intent: pass a request along handlers; each processes it or forwards it.

Motivating example in the article: an ordering system must authenticate users, allow admins full access, then gained input sanitization, brute-force protection and caching. Checks run in sequence and a failed check stops the rest. As checks multiplied, the code became tangled; changing one could break others, and reusing some checks elsewhere meant duplicating code.

Solution: each check becomes a handler object with one method; handlers are linked; each can process, pass, or stop. All share one interface so chains compose at run time without coupling the client to concrete classes. A chain can also be built from a branch of an object tree (the GUI help example: F1 bubbles from button to panel to dialog until one shows help).

### Implementation steps (from the article)

1. Declare the handler interface; pass data as one request object.
2. Optionally an abstract base holding `next` and forwarding by default; immutable unless chains change at run time.
3. Concrete handlers decide to process and/or pass.
4. Client builds chains, or obtains them from configuration-driven factories.
5. Trigger any handler in the chain.
6. Handle dynamic outcomes: single-link chains, early stops, requests that reach the end unhandled.

```
class Handler:
    next = None
    def handle(req):
        if next: return next.handle(req)
        return None

class AuthHandler(Handler):
    def handle(req):
        if not req.user: return Response(401)      # stop
        return super().handle(req)                 # pass on
```

### Trade-offs

Pros: control over order; separates invokers from executors (SRP); add handlers without changing clients (OCP). Con: some requests may end unhandled.

### Comparisons

| Pattern | Difference from CoR |
|---|---|
| Decorator | Similar recursive composition; decorators extend behavior consistently and cannot break the flow, handlers may do arbitrary work and stop it |
| Command | Handlers can be Commands, or the request can be a Command run across contexts |
| Mediator | Routes communication through a central object |
| Observer | Receivers subscribe dynamically; all receive |
| Composite | Often combined: a leaf passes a request up through parents |

## Message Filter

Problem: a company sends price changes and promotions to large customers, but each wants only certain items. How does a component avoid receiving unwanted messages?

Solution: a Message Filter, a router with a single output channel; matching messages pass, others are discarded. As a pipeline stage it sits in the messaging system, unlike a Selective Consumer inside an endpoint. Router comparison and broker bindings (RabbitMQ) are owned by `router-front-controller-routing` (`eip-message-routing-patterns.md`).

Related: Content-Based Router, Selective Consumer, Pub-Sub Channel, Recipient List, Dead Letter Channel.

Not on the page (so not asserted): discard handling, stateful filters. Reasoning of my own: a stateful filter (de-duplication) needs a bounded memory and a clear key.

## Chain vs filter vs router

| Need | Use |
|---|---|
| Several ordered cross-cutting steps on one request | Chain / middleware |
| Drop what a consumer should not see | Message Filter |
| Pick exactly one destination | Router (`router-front-controller-routing`) |
| Transform stream stages | `pipes-and-filters-pattern` |

## Failure modes

- Handler order implicit in registration across many files.
- Handlers that both decide and execute heavy business logic.
- Filters that silently discard, hiding lost data.
- Chains with no terminal.

## How an agent should apply this

- Define one handler interface and build chains in one composition root.
- Write each handler with a single stop condition and test it alone.
- Give discards a visible fate (metric or dead letter).
- Add a terminal handler and a test that an unmatched request gets a defined response.
- Pick a decorator, not CoR, if no step may block the flow.
