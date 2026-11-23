# Replay Semantics: External Effects, Reversal and Code Changes

Sources: https://martinfowler.com/eaaDev/EventSourcing.html · Last verified 2026-11-23

Fowler's 2005 write-up is the deepest treatment of what happens when you replay or change history. Core rule: every domain change is initiated by an event object, the log is ordered, and state is derivable from it.

## What the log buys
- Complete rebuild: drop state, replay from empty.
- Temporal query: replay up to a time or event for past state (timelines can branch like version control).
- Event replay: fix a wrong past event by reversing later events, applying the corrected one, replaying the rest; also handles out-of-order asynchronous messages.
- Snapshots shorten recovery: load a snapshot, replay newer events. Either the log or the state DB can be the system of record because each can rebuild the other.

## Reversal
Difference events ("add 10") reverse trivially; absolute events ("set to 110") need prior values stored in the event. Reversal is an optimisation, since rebuilding from a snapshot always works.

## External updates during replay
Downstream systems cannot tell a replay from real processing. Wrap them in a gateway that is silent in replay mode; domain code calls the gateway unconditionally and never knows. Alternative: buffer notifications and release them on a schedule.

## External queries during replay
Replays need the answers seen at the time. Options: query the external system by historical date (if reliable), keep its change history, or have the gateway log each response against the current event and return the logged value in replay. Interactions that both query and change external state are the hardest.

## Code changes
- New feature: add and reprocess old events, usually with gateways off.
- Bug fix: fix and reprocess; external effects need the delta between buggy and correct outcomes, possibly via retroactive events.
- Temporal business rules: select strategy objects by date in the domain model; bitemporal "apply the old rule as it was, then as it is" cases get messy, avoid unless needed.

## Structuring handlers
Processing logic (the business rule) is separate from selection logic (which rule runs for which event). Putting selection in polymorphic event objects avoids a type switch; if events are code-free DTOs, map by naming convention or configuration. Passing the whole event keeps signatures stable but couples domain logic to the event type.

## When Fowler says to use it
Audit and support (see exactly what a user did), debugging and testing (replay production events into a test environment before an upgrade), and as the foundation for Parallel Models and Retroactive Events, which are hard to retrofit, so decide early. Drawback: recording every change as an event feels unnatural to many developers and forces design around external systems.

## Sketch: replay-safe gateway
```ts
class EmailGateway {
  constructor(private replay: ReplayFlag, private client: Mailer) {}
  send(msg: Mail) { if (this.replay.active) return; this.client.send(msg); }
}
class PriceGateway {          // external query: record on live, serve on replay
  async quote(ev: EventId, sku: string) {
    return this.replay.active ? this.log.get(ev, sku)
                              : this.log.put(ev, sku, await this.api.quote(sku));
  }
}
```

## How an agent should apply this
- Route every external side effect through a gateway with a replay switch before writing the first replay.
- Record external query responses in the event or an adjacent log so replays are deterministic.
- Store prior values in events where reversal or retroactive correction is plausible.
- Keep time-dependent business rules selectable by date in the model, not hard-coded.
- Rehearse a full rebuild into a scratch environment before every release that changes event handling.
