# C4 Abstractions, Levels and Diagram Hygiene

Sources: https://c4model.com/, https://c4model.com/introduction, https://c4model.info/, https://c4model.com/abstractions/container, https://c4model.com/diagrams, https://c4model.com/diagrams/notation · Last verified 2026-11-27

## Five stated pillars

Hierarchical abstractions, hierarchical diagrams (system context, container, component, code), supporting diagrams (system landscape, dynamic, deployment), notation independence, tooling independence.

## What is and is not a container

Containers: server-side web app, client-side web app in a browser, desktop, mobile or console app (including batch processes), serverless function, database, blob or content store, file system, a shell script. Not containers: JARs, assemblies, DLLs and modules; they organize code inside an application.

Rulings from the container page:

- A server app that mostly generates HTML is one container.
- A server-delivered single-page app is two containers: client and server run in separate process spaces and talk over a remote mechanism.
- One Tomcat hosting several web apps still holds several containers; how they are deployed is a separate question.
- Managed services (S3, RDS, Azure SQL, a CDN) are shown as containers, not software systems, because you own the buckets or schemas.
- A Docker container may map to a C4 container, but they are different things.

## Levels

Each level zooms into one element of the level above. System context is the starting point. Code diagrams are usually UML classes, ideally generated, and too detailed for most teams. The diagrams page says you need not use all four levels, only those that add value, and that context plus container suffice for most teams.

## Problems the introduction lists

Within one diagram: unexplained or inconsistent notation, unclear element meaning, missing or unlabeled relationships, vague terms like "business logic", unexplained acronyms, missing technology, mixed abstraction levels. Across a set: inconsistent notation and names, no stated reading order, no clear transition between diagrams. Stated uses: team communication, onboarding, architecture reviews, risk-storming, threat modeling (the method itself: `threat-modeling`).

## How an agent should apply this

- Produce Level 1 and Level 2 by default; add Level 3 only for a named complex container.
- Decide the zoom target explicitly: one diagram per element, never mixed levels.
- Treat databases, queues and managed stores as containers, not lines.
- For dynamic and deployment diagrams, the pages read give only examples (see sources.md): keep to the conventions in `SKILL.md` and say so.
