---
name: micro-frontends-architecture
description: Use when evaluating, designing, or reviewing a Micro-Frontends Architecture — decomposing a Frontend Monolith into vertical, business-domain UI slices owned end-to-end by independent teams, choosing an integration strategy (Server-Side Composition, Build-Time, or Run-Time via JS/Module Federation, Web Components, or iframes), or enforcing CSS/state isolation and cross-app communication via routing and DOM events. Gives Cam Jackson & Michael Geers's rules, integration trade-offs, and common "framework anarchy" mistakes.
---

# Micro-Frontends Architecture

One idea: extend the vertical decomposition of microservices all the way to the browser — slice a web application by **business domain (vertical end-to-end features)** rather than horizontal technical layers so **autonomous, cross-functional teams** can develop, test, and **deploy their UI features independently** without coordinating releases in a Frontend Monolith. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Cam Jackson & Michael Geers)

| Term | Meaning | Test sentence |
|---|---|---|
| Frontend Monolith | a single monolithic SPA codebase sitting on top of backend microservices, owned by a separate frontend layer team | "every UI change requires building, testing, and deploying the entire frontend together" |
| Vertical Team / Feature Slice | a cross-functional team that owns a distinct business domain end-to-end, from database/BFF all the way to its UI pages or fragments | "Team Checkout owns the checkout DB, checkout service, and `<checkout-buy>` micro-frontend" |
| Container / App Shell | the thin host application that renders common chrome (header/nav), matches top-level URLs, and mounts the active micro-frontend(s) | "routes and composes; holds zero domain business logic" |
| Page-Level vs. Fragment Composition | **Page-level**: one micro-frontend owns the whole screen per route; **Fragment-level**: a page is composed of UI fragments/Custom Elements from 2+ teams (e.g., Product Page with a `<checkout-buy>` button from Team Checkout) | "prefer page-level splits first; use fragment composition only where domains intersect on one screen" |
| Build-Time vs. Run-Time Integration | **Build-time**: publishing micro-frontends as npm packages requires recompiling the container on every release (violates independent deployment); **Run-time**: container loads each micro-frontend's deployed bundle dynamically in the browser or at the edge server | "if you must redeploy the host container to ship a micro-frontend change, it is not independently deployable" |

## Core architectural rules and invariants

1. **Independent deployability at runtime is mandatory:** Each micro-frontend must have its own CI/CD pipeline that deploys its bundle directly to production without rebuilding or redeploying the Container/Shell or any other micro-frontend. Avoid **Build-Time npm package integration** whenever independent release velocity is the goal.
2. **Choose the simplest integration mechanism that fits the app:**
   - **Server-Side Composition (SSI / Edge includes / Podium / Tailor):** Best for document-centric or SEO-critical pages requiring fast initial HTML paint.
   - **Run-Time JavaScript / Module Federation / ES Modules:** Most flexible for rich SPA transitions where the Container mounts/unmounts micro-frontend entry functions on route changes.
   - **Run-Time Web Components (Custom Elements):** Framework-agnostic contract where **"The DOM is the API"** — parent passes attributes down, child emits standard DOM `CustomEvent`s up.
   - **iframes:** Maximum CSS/JS isolation, but clumsy for responsive layout, deep linking, accessibility, and shared overlays.
3. **Never share runtime application state across micro-frontends:** Do not create a global Redux/Zustand store shared across micro-frontends. Communicate across micro-frontends **only** via:
   - **URL / Routing parameters** (preferred for page-to-page navigation),
   - **HTML attributes / primitive props** passed down from container to child fragment,
   - **Standard DOM `CustomEvent`s** or a tiny, contract-tested address-bar/event bus with primitive payloads.
4. **Isolate CSS and global scope strictly:** Namespace every CSS class by team/micro-frontend prefix (e.g., `.chk-button`), use CSS Modules / CSS-in-JS, or use Shadow DOM so Team A's stylesheet deploy never breaks Team B's layout in production.
5. **Avoid "Framework Anarchy" and bundle bloat:** While micro-frontends *allow* gradual migration from legacy to modern frameworks, never mix React, Vue, Angular, and Svelte in the same app without a strong reason. Standardize on one primary UI stack where possible and externalize shared runtime dependencies (`react`, `react-dom`) via import maps or Module Federation so users don't download 4 megabytes of duplicate framework code.
6. **Govern Shared Component Libraries carefully:** A shared Design System library must contain **only pure visual/dumb UI primitives** (buttons, typography, icons, tokens) with **zero business logic or domain coupling**, versioned cleanly so teams upgrade at their own pace.

## Building order

1. **Slice vertically by business domain, starting at page/route boundaries:** Assign full routes (`/browse`, `/order`, `/profile`) to autonomous vertical teams before attempting fine-grained on-page fragment widgets.
2. **Build the thin Container / App Shell:** Handle top-level navigation, authentication session handoff, and dynamic loading of each micro-frontend's manifest (`asset-manifest.json` / remote entry) with error boundaries if a micro-frontend fails to load.
3. **Define the narrow cross-app contract:** Document allowed URL routes, Custom Element tag names, input attributes, and emitted DOM events.
4. **Connect each micro-frontend to its own BFF / Backend Service:** Each vertical slice talks to its own team's backend API (`bff-pattern`), never directly to another team's internal database or state.

## Testing strategy

| Scope | Test | Uses |
|---|---|---|
| Individual Micro-Frontend | unit & component tests (bulk of suite) | runs inside the team's own repo and CI pipeline in complete isolation |
| Container <-> Micro-Frontend Contract | contract / mount integration test | verifies the micro-frontend exports its expected global entry function or Custom Element tag, accepts contracted props/attributes, and cleans up on unmount |
| Composed Full Application | minimal E2E browser smoke suite (Playwright/Cypress) | verifies top-level routing, authentication handoff, and 1-2 cross-team user journeys in a staging/production-like environment |

## When it earns its keep

- **Worth it:** Large web applications maintained by multiple independent product teams (3+ teams) where a monolithic frontend repository has become a release bottleneck, or legacy multi-year UI migrations (Strangler Fig pattern) where pages/features must be upgraded incrementally without a big-bang rewrite.
- **Not worth it:** Small or medium web apps built by 1-2 teams. Micro-frontends carry a heavy tax in bundle size, build/deploy orchestration, visual consistency governance, and local dev setup — for a single team, a modular SPA monolith (monorepo with workspace packages) gives 90% of the structure at 10% of the cost.

## Mistakes to catch

- **Horizontal slicing ("Header Micro-Frontend", "Sidebar Micro-Frontend", "Table Micro-Frontend"):** Splitting by UI widget rather than business domain forces every business feature to touch 4 repositories. Slice vertically by business capability (`catalog`, `checkout`, `account`).
- **Build-time npm integration masquerading as Micro-Frontends:** Requiring a central host repository to bump `package.json` versions and redeploy whenever a team ships a bug fix — re-creating the monolithic release train.
- **Shared global state store across micro-frontends:** Coupling Team A and Team B to the same in-memory Redux state shape so neither can refactor or deploy independently.
- **Putting business logic inside the shared Design System:** Turning the UI component library into a backdoor monolith where domain rules require coordinated upgrades across all teams.
- **Unbounded bundle duplication (Framework Anarchy):** Shipping three different versions of React, Lodash, and Moment.js on the same page without monitoring payload weight and Core Web Vitals.

## Quick Decision Checklist

- [ ] Is each slice a vertical business domain owned end-to-end, not a horizontal widget?
- [ ] Can each micro-frontend deploy to production without rebuilding the Container or other teams?
- [ ] Have I avoided build-time npm integration where independent release velocity is the goal?
- [ ] Do micro-frontends communicate only via URL, attributes or DOM events, with no shared global state store?
- [ ] Is CSS namespaced or isolated per team?
- [ ] Is one UI stack standardized, with shared runtime dependencies externalized?
- [ ] Does the shared Design System hold only visual primitives with zero business logic?
- [ ] Do 3+ teams justify the overhead, or would a modular SPA monolith do?

## Deep references

- [Integration approaches and trade-offs](references/integration-approaches-trade-offs.md) — choosing how to compose micro frontends
- [Contracts, styling, sharing and testing](references/contracts-styling-sharing-and-testing.md) — cross-team rules once composed
- [Custom Elements, SSI and composite UI](references/custom-elements-ssi-and-composite-ui.md) — standards-based and server-side composition
