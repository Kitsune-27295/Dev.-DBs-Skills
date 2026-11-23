# C4 Abstractions, Levels and Diagram Hygiene

Sources: https://c4model.com/, https://c4model.com/introduction, https://c4model.info/, https://c4model.com/abstractions/container (one extra page) · Last verified 2026-11-23

## Five stated pillars

Hierarchical abstractions (software system, container, component, code), hierarchical diagrams (system context, container, component, code), supporting diagrams (system landscape, dynamic, deployment), notation independence, tooling independence. The site also has pages on microservices, queues and topics, notation and a review checklist (index only; those pages were not read).

## Element types

- **Person**: human or otherwise-actor user.
- **Software system**: highest level, delivers value to users, often owned by one team; external systems appear as boxes too.
- **Container**: an application or data store that must be running for the system to work; a runtime boundary, explicitly "not Docker".
- **Component**: a building block inside a container (auth module, card validator).
- **Code**: implementation detail, usually UML class diagrams.

## What is and is not a container (from the container page)

Containers: server-side web app, client-side web app in a browser, desktop app, mobile app, console/batch/scheduled job, serverless function, database schema, blob store or CDN, file system, a single shell script. Not containers: JARs, assemblies, DLLs, modules (they organise code inside an app; usually components).

Rulings: a server app that mostly renders HTML is one container; a substantial SPA makes client and server two containers talking JSON/HTTPS. Managed services such as S3, RDS or a CDN are normally containers because you own the buckets or schemas. Several containers may share one runtime (three web apps in one Tomcat), and deployment is a separate concern.

## Levels

| Level | Shows | Audience | Typical use |
|---|---|---|---|
| 1 System context | persons, systems | technical and non-technical | always |
| 2 Container | adds containers | architects, developers, product | almost always |
| 3 Component | adds components of one container | architects, developers | only if the container is complex |
| 4 Code | class-level | developers | rarely; generate from code |

Scope is cumulative and each diagram zooms into one element of the level above.

## Ad hoc diagram problems the introduction lists

Unexplained colours/shapes/line styles, ambiguous element meaning, missing or unlabelled relationships, generic labels ("business logic"), unexplained acronyms, missing technology, mixed abstraction levels, inconsistent notation across a set, no reading order or clear transitions. Stated goal: raise diagram maturity; use cases: onboarding, reviews, risk-storming, threat modelling.

## Example element and relationship labels

```
Container: "Orders API" [Node.js, REST]  -- "Reads/writes orders" [SQL/TCP] --> Container: "Orders DB" [PostgreSQL]
```

## How an agent should apply this

- Produce Level 1 and Level 2 by default; add Level 3 only for a named complex container.
- Label every element with name, type and technology, and every arrow with purpose and protocol.
- Draw databases, queues and managed stores as containers, not as lines.
- Add a legend whenever shapes or colours carry meaning.
- Decide the zoom target explicitly: one diagram per element, never mixed levels.
