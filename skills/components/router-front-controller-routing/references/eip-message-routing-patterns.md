# EIP Message Routing Patterns

Sources: https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRoutingIntro.html, https://www.enterpriseintegrationpatterns.com/patterns/messaging/ContentBasedRouter.html · Last verified 2026-11-27

## Frame

A Message Router decouples a message's source from its ultimate destination. The chapter groups routers as **simple** (one inbound channel, one or more outbound), **composed** (simple routers combined into flows) and **architectural** (Message Broker, a hub-and-spoke style built from routers).

## Content-Based Router (CBR)

Problem on the page: an order system validates orders, then checks inventory; with several inventory systems each handling certain items, one logical function is split across physical systems and each message needs the right one.

Solution: inspect message content and put the message on a different channel depending on data in it (field exists, field value, similar tests). Producers send to one channel and do not know destinations.

Maintenance: the router changes often as destinations come and go, so the logic must be easy to change; in advanced cases it becomes a configurable rules engine computing the channel from rules.

Camel sketch (paraphrasing the page): a dead letter channel is the error handler; messages from `direct:in` go through `choice()` on the `type` header: `widget` to `direct:widget`, `gadget` to `direct:gadget`, otherwise `direct:other`. The page lists Message Filter, Dynamic Router, Message Router, Invalid Message Channel, Pipes and Filters, Publish-Subscribe Channel, Routing Slip and Transactional Client as related, without explaining the Message Filter difference.

```
route(msg):
    match msg.header["type"]:
        "widget": send(widgetChannel, msg)
        "gadget": send(gadgetChannel, msg)
        _:        send(otherChannel, msg)   # explicit default
```

## Router vs Message Filter array

| | Content-Based Router | Filters on pub-sub channel |
|---|---|---|
| Direction | Predictive: router picks one channel | Reactive: each consumer decides |
| Control | Full, in one place | Spread across filters |
| Coupling | Router depends on all destinations | No component knows all destinations |
| Adding a consumer | Edit the router | Add a subscriber with its own filter |

Message Filter: the chapter lists it as a router with one output that passes matching messages; its pipeline-stage view belongs to `middleware-interceptor-chain`.

## Other simple routers (summary table from the page)

| Pattern | Consumed | Published | Stateful |
|---|---|---|---|
| Content-Based Router | 1 | 1 | mostly no |
| Message Filter | 1 | 0 or 1 | mostly no |
| Recipient List | 1 | many (incl. 0) | no |
| Splitter | 1 | many | no |
| Aggregator | many | 1 | yes |
| Resequencer | many | many (same count as consumed) | yes |

Dynamic Router: control messages on a control port change routing logic at run time; any router type can be made dynamic. Message Broker is the chapter's architectural pattern: a central hub-and-spoke style built from routers.

## Composed routers

- Parallel: Composed Message Processor (controls its set of sources) and Scatter-Gather (uses pub-sub so any interested component can join).
- Sequential: Routing Slip (path defined up front, like a slip on paper documents) and Process Manager (more flexible, but each step returns to a central component).

## Failure modes

- No default branch: unmatched messages vanish. Add default or Invalid Message Channel.
- Router hardcodes business rules that belong to consumers: it must be redeployed for every change.
- Stateful routers (Aggregator, Resequencer) without timeout or buffer limits (inferred): they hold messages forever.
- Using a CBR when consumers should self-select (inferred): central bottleneck.

## How an agent should apply this

- Start with a CBR when one team owns the destinations; start with filters when consumers are independent.
- Store routing rules as config/rules, and test each rule plus the default.
- Name the outcome for messages matching no rule (default channel or dead letter).
- Choose Routing Slip when the path is known at start, Process Manager when it depends on intermediate results.
- Do not mix transformation into the router; do that in a mapper (`dto-mapper-anti-corruption-layer`).
