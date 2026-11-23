# Micro Frontends: Integration Approaches and Trade-offs

Sources: https://martinfowler.com/articles/micro-frontends.html · Last verified 2026-11-23

## Definition and benefits
Independently deliverable frontend applications composed into a whole. Benefits: incremental upgrades of legacy UI, small decoupled codebases aligned to bounded contexts, independent deployment pipelines, autonomous teams owning a vertical slice (often a page). Running example: a food-delivery site (browse, order, profile) with a **container application** owning header, nav, auth and mount decisions.

## Approaches
| Approach | How | Verdict |
|---|---|---|
| Server-side template composition | server stitches HTML fragments/includes; fragments can come from different servers | simple, stack-agnostic |
| Build-time integration | publish packages, container bundles them | discouraged: lockstep releases defeat independent deployment |
| Iframes | each app in a frame | strong style and global isolation; hard routing, deep links, responsiveness |
| Run-time JavaScript | container loads bundles by script tag; each exposes global render/unmount, called per route | most flexible, the authors' default |
| Run-time Web Components | each defines a custom element | good if you prefer browser standards over a custom contract |

## Implementation notes from the example
The container does not depend on the micro frontends; it fetches each bundle's asset manifest, injects the script, and calls render/unmount. Each app has its own `index.html` for standalone development. Routing carries parameters between apps via a shared history object. React/ReactDOM are externalized and loaded from a shared host (about half the bundle size). Hosting: S3 plus CloudFront, a bucket per app, per-app pipelines, Terraform for core infrastructure.

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
