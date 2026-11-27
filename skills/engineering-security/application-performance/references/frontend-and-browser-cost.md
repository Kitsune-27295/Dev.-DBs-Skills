# Frontend and Browser Cost

Sources: https://web.dev/articles/vitals · https://web.dev/articles/optimize-lcp · https://web.dev/articles/optimize-inp · https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers · https://developer.chrome.com/docs/devtools/performance · https://developer.chrome.com/docs/devtools/performance/reference · Last verified 2026-11-27

## The three vitals and what they point at

| Metric | Measures | Good (75th percentile) | Usual causes |
|---|---|---|---|
| LCP, Largest Contentful Paint | Loading | 2.5 s or less | Slow server response, late-discovered resource, blocked render |
| INP, Interaction to Next Paint | Responsiveness across the visit | 200 ms or less | Long tasks, heavy event handlers, large DOM |
| CLS, Cumulative Layout Shift | Visual stability | 0.1 or less | Elements without reserved space, late-injected content |

A page passes when it meets the target for all three at the 75th percentile, split by mobile and desktop. INP became a stable Core Web Vital in 2024 and replaced First Input Delay (web.dev, updated 2024-10-31).

## LCP: split it into four parts

The LCP guide splits the time into four sequential, non-overlapping parts: time to first byte, resource load delay (until the browser starts fetching the LCP resource), resource load duration, and element render delay. Ideal shares are about 40%, under 10%, about 40%, under 10%. They are only meaningful relative to each other; if LCP is already under 2.5 s the exact split matters less.

Procedure:
1. Get the breakdown from DevTools Insights on a trace, or from the Lighthouse LCP diagnostic.
2. Compute each part's share and compare with the ideal. The part furthest above its ideal is the dominant cost; large shares in either delay are strong signals.
3. The guide presents fixes in this order, by likely impact and not as a strict rule: eliminate load delay, eliminate render delay, reduce load duration, reduce TTFB (remove waiting before shrinking bytes).
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
- Record in a clean profile (incognito) to avoid extensions; apply CPU throttling to approximate a slower device (the tutorial uses 4x slowdown and suggests 20x for low-end mobile; throttling is relative to your own machine, so it approximates rather than replicates a phone).
- Long tasks carry a red triangle, and the portion beyond 50 ms is shaded red (reference page). The flame chart's x axis is time and its y axis is the call stack (a flame chart, unlike a sampled flame graph, is a timeline).
- The Call tree shows which root activities cause the most work (self vs total time); Bottom-up ranks leaf-level work by self time; "dim 3rd parties" and the ignore list help focus on first-party code.
- The Insights sidebar lists LCP and INP subparts, third-party impact and legacy or duplicated JavaScript; selecting an insight highlights the events. Live metrics show the vitals as you interact and can compare with field data.
- Forced reflow warnings on layout events point to changing styles then reading position in the same task, which forces a re-layout each time.
- Prefer compositor-friendly properties (`transform`, `opacity`) for animation.
- Live metrics show vitals as you interact, which finds problems that only appear in specific situations before you record a trace.

## Main-thread work and workers

Long synchronous script on the main thread delays input and rendering. MDN describes web workers as background threads for processor-intensive work: no DOM access, messages through `postMessage`, data copied (serialized) unless transferred. Use them for genuinely heavy pure computation, not for small tasks where copy and message overhead dominates (that last judgment is mine).

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
