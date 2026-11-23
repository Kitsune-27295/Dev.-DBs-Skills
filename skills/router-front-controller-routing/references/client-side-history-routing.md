# Client-Side Routing with the History API

Sources: https://developer.mozilla.org/en-us/docs/Web/API/History_API/Working_with_the_History_API · Last verified 2026-11-23

## Problem

In a single-page app, a click handler prevents the page load, fetches content and updates the DOM. The browser sees no new page, so Back skips the app's states and returns to whatever preceded the SPA. `pushState()`, `replaceState()` and the `popstate` event let the app create history entries and learn when the user moves to one.

The `History` interface has navigation methods (`back`, `forward`, `go`) and modification methods (`pushState`, `replaceState`). The MDN guide covers only the modification pair.

## The three calls

`history.pushState(state, "", url)`
- `state`: any serializable object stored with the entry; delivered as `event.state`.
- title: unused; always pass `""`.
- `url`: shown in the address bar and used as `Referer` for the page's later requests; must be same-origin.

`history.replaceState(state, "", url)`: same arguments, updates the current entry instead of adding one.

`popstate` fires when the user navigates to an entry (Back/Forward). The handler re-renders from `event.state`.

## Correct flow

```js
// 1. seed the first entry (page load creates it without state)
history.replaceState({ view: "home" }, "", location.href);

// 2. in-app navigation
async function go(path) {
  const data = await load(path);
  render(data);
  history.pushState(data, "", path);
}

// 3. Back/Forward
addEventListener("popstate", e => { if (e.state) render(e.state); });
```

The guide's example fetches `creatures/<name>.json`, renders it, then pushes state with the same JSON; the initial page state is built from the DOM and stored with `replaceState`.

## Gotchas

- The initial entry has no state, so `popstate` cannot restore it until `replaceState` seeds one.
- Not serializable state (functions, DOM nodes) fails.
- Do not render from the URL alone if the state is richer (inferred): decide whether state is the source of truth or the URL is, and re-fetch from the URL when `event.state` is null.
- Server must serve the app shell for deep-link URLs (inferred; not in the guide).
- Calling `pushState` does not trigger `popstate`; you render yourself.
- Not covered by the MDN page: scroll restoration, detailed back/forward/go behavior.

## Decision rules

- Use `pushState` for navigations the user would expect Back to undo; use `replaceState` for corrections (redirects, normalizing the URL, seeding state).
- Prefer small state (an id or route params) over full payloads (inferred), so stale data is not restored.
- Use a mature router library unless you need to understand or minimally implement one.

## How an agent should apply this

- Seed history on load with `replaceState` before registering `popstate`.
- Always render after data loads, then `pushState`, so failed loads leave no bad entry.
- Keep `state` serializable and minimal; handle `event.state === null` by deriving the view from `location`.
- Confirm deep links work on refresh via server fallback.
- Keep the route table in one module; do not scatter URL strings across components.
