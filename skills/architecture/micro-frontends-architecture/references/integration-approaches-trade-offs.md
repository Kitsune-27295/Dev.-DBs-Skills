# Micro Frontends: Integration Approaches and Trade-offs

Sources: https://martinfowler.com/articles/micro-frontends.html · Last verified 2026-11-27

## Definition and benefits
Cam Jackson (19 June 2019): independently deliverable frontend applications composed into a whole. Benefits: incremental upgrades of legacy UI, small decoupled codebases aligned to bounded contexts, independent deployment pipelines, autonomous teams owning a vertical slice (often a page). Running example: a food-delivery site (browse, order, profile) with a **container application** owning header, nav, auth and mount decisions.

## Approaches
| Approach | How | Verdict |
|---|---|---|
| Server-side template composition | server stitches HTML fragments/includes; fragments can come from different servers | not novel and simple; counts as micro frontends if the split follows domain concepts |
| Build-time integration | publish packages, container bundles them | discouraged: lockstep releases defeat independent deployment |
| Iframes | each app in a frame | easy isolation, less flexible; hard routing, history, deep links, responsiveness |
| Run-time JavaScript | container loads bundles by script tag; each exposes global render/unmount, called per route | most flexible, the authors' default |
| Run-time Web Components | each defines a custom element | good if you prefer browser standards over a custom contract |

## Implementation notes from the example
The container does not depend on the micro frontends; it fetches each bundle's asset manifest, injects the script, and calls render/unmount. Each app has its own `index.html` for standalone development. Routing carries parameters between apps via a shared history object. React and ReactDOM were about half of the compiled bundle and are externalized to a shared host (the article gives no measured saving). Hosting: AWS S3 plus CloudFront, a bucket and a CI pipeline per app, core infrastructure in a central Terraform repository.

## Downsides
Duplicated dependencies and payload size (per-page bundles also give implicit code splitting); dev-versus-prod environment gaps, especially global CSS; more repos, pipelines and servers, so governance and automation must exist first.

## Failure modes
Build-time coupling reintroduced quietly; the container learning each app's internals; shared state creeping in.

## How an agent should apply this
- Default to run-time JS (or Web Components if standards matter); reject build-time package composition.
- Use iframes only when isolation outweighs routing/UX costs (e.g. untrusted third-party content; inference).
- Keep the container thin: routing, auth, layout, mount; no business logic.
- Require a standalone mode per app and a manifest-based loading contract.
- Warn about operational overhead before recommending this to small teams.
