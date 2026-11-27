# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Our IoT backend keeps row-locking the devices table; we have 2M devices each with its own state. Should each device be an Orleans grain?"
2. "Review this Akka actor: it calls a blocking SQL driver inside onMessage and its mailbox keeps growing."
3. "Ticket sales spike 50x for ten minutes and the database melts even with a cache. Would space-based architecture with processing units help?"

## Near-misses (other skill)
1. "Should we pick microservices or a modular monolith for a 6-person team?" -> `architecture-decision-trees-tradeoffs`
2. "Design a Kafka topic layout with consumers and event-carried state transfer." -> `event-driven-architecture`
3. "Split writes and reads so list screens do not query every aggregate." -> `cqrs-pattern`
