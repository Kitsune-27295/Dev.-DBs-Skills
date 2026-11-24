# Frontend and Browser Cost

Sources: https://web.dev/articles/vitals · https://web.dev/articles/optimize-lcp · https://web.dev/articles/optimize-inp · https://web.dev/learn/performance · https://developer.chrome.com/docs/devtools/performance · https://developer.chrome.com/docs/devtools/performance/reference · Last verified 2026-11-24

## The three vitals and what they point at

| Metric | Measures | Good (75th percentile) | Usual causes |
|---|---|---|---|
| LCP, Largest Contentful Paint | Loading | 2.5 s or less | Slow server response, late-discovered resource, blocked render |
| INP, Interaction to Next Paint | Responsiveness across the visit | 200 ms or less | Long tasks, heavy event handlers, large DOM |
| CLS, Cumulative Layout Shift | Visual stability | 0.1 or less | Elements without reserved space, late-injected content |

A page passes when it meets the target for all three at the 75th percentile. First Input Delay was replaced by INP.

## LCP: split it into four parts

The LCP guide splits the time into four sequential, non-overlapping parts: time to first byte, resource load delay (until the browser starts fetching the LCP resource), resource load duration, and element render delay. Ideal shares are about 40%, under 10%, about 40%, under 10%. They are only meaningful relative to each other; if LCP is already under 2.5 s the exact split matters less.

Procedure:
1. Get the breakdown from DevTools Insights on a trace, or from the Lighthouse LCP diagnostic.
2. Compute each part's share and compare with the ideal. The part furthest above its ideal is the dominant cost; large shares in either delay are strong signals.
3. The guide orders fixes as: load delay, render delay, load duration, then TTFB (that is, remove waiting before trying to shrink bytes).
4. Re-measure after each change: speeding one part can just move time into another.
5. Confirm the dominant part with real-user data before investing, since the lab breakdown can differ from the field.

## INP: split it into three phases

An interaction's latency is input delay (main thread busy before the handler can run), processing duration (handlers), and presentation delay (until the next frame paints).
- High input delay: reduce startup script evaluation and long tasks, especially during page load.
- High processing: do less in the handler; update the UI first and yield, then do non-visual work (saves, analytics, counting) in a later task; avoid layout thrashing (writing styles then reading layout in the same task).
- High presentation delay: shrink the DOM, defer rendering of off-screen content (`content-visibility`), and avoid rendering large HTML from script in one go.

Diagnose from field data first (which interaction, which page), then reproduce in the lab by performing the flow, including interacting during load when the main thread is busiest. INP improvement is iterative: new features add new slow interactions.

## Using DevTools to find the cost

From the Performance panel documentation:
- Record in a clean profile (incognito) to avoid extensions; apply CPU throttling to approximate a slower device (CPU throttling is relative to your own machine, so it approximates rather than replicates a phone).
- The overview shows FPS, CPU and network. A CPU chart full of color means the page is doing too much work; red in the FPS chart means dropped frames.
- Long tasks appear with a red marker, and the portion beyond 50 ms is shaded. The flame chart's x axis is time and stack depth is the y axis (a flame chart, unlike a sampled flame graph, is a timeline).
- The Call tree shows which root activities cause total work; Bottom-up ranks by self time; "dim third parties" and the ignore list help focus on first-party code.
- The Insights sidebar lists LCP and INP subparts, third-party code and duplicated JavaScript; selecting an insight highlights the events.
- Warnings on layout events can point to forced synchronous layout: changing styles then reading position inside the same frame forces a re-layout every time.
- Prefer compositor-friendly properties (`transform`, `opacity`) for animation.
- Live metrics show vitals as you interact, which finds problems that only appear in specific situations before you record a trace.

## Main-thread work and workers

JavaScript runs mainly on one thread that also handles scripting, parsing and rendering, so long synchronous work delays input. The performance course's web-worker module describes moving expensive computation to a worker (no DOM access, messages via `postMessage`) to keep the main thread free for interaction. Use it for genuinely heavy pure computation, not for small tasks where message overhead dominates.

## Bundle and loading checks

(Own checklist from the measures above, not a quoted standard.)
- Measure what is actually shipped: the built bundle size, per route, compressed.
- Split by route; defer code not needed for the first view; remove duplicated or legacy dependencies the Insights panel reports.
- Make the LCP resource discoverable early (not hidden behind script or CSS) and prioritize it; avoid render-blocking resources on the critical path.
- Reserve space for images, embeds and injected content to prevent layout shifts.
- Budgets for script size and request count are CI-gateable; user-centric metrics (LCP, INP) should still be checked in the field.

## Rendering many nodes

Rendering many rows is both a DOM-size problem (presentation delay) and a repeated-work problem (every state change re-rendering every node). Remedies in order: limit what is rendered (pagination or virtualization), keep identities stable and subscriptions narrow so one change does not invalidate the whole list, defer collapsed content. Viewport-only syntax highlighting is not full virtualization; measure which one you did.

## How an agent should apply this

- Start from field data (or ask for it); reproduce the slow interaction in a throttled lab trace.
- Split LCP into its four parts and INP into its three phases; fix the largest above-ideal part first and re-measure.
- Look for long tasks, forced layout and large DOM before touching bundle size.
- Check accessibility is not regressed by lazy loading or virtualization (`a11y-audit`).
- When the slow value shown is wrong or stale rather than late, hand off to `cross-layer-value-trace`.
