# Host Bridge Protocol

Sources: https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx · https://modelcontextprotocol.io/extensions/apps/overview · https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html · Last verified 2026-11-24

## Shape of the channel

The page (the spec calls it the **View**) acts like an MCP client; the **Host** acts like an MCP server toward it and proxies to the real server. Messages are JSON-RPC 2.0 over `window.postMessage`. Some methods are core MCP (`tools/call`, `resources/read`, `ping`, `notifications/message`), some are MCP-like (`ui/initialize`), and most are new with a `ui/` prefix. The SDK's `App` class wraps this, but the spec shows a minimal hand-written client, so no SDK is required. Hosts MAY forward any non-`ui/` message from the page to your server, and MAY block or require user approval for some.

## Lifecycle (stable text)

```
Host                              View (iframe)
  |  render iframe with HTML         |
  |<------ ui/initialize ------------|   appCapabilities, appInfo
  |------- result (hostContext) ---->|   theme, styles, displayMode, dimensions, locale...
  |<-- ui/notifications/initialized -|   host MUST NOT send anything before this
  |-- tool-input-partial (0..n) ---->|   optional, best effort, never rely on it
  |-- ui/notifications/tool-input -->|   complete arguments, at most once
  |-- ui/notifications/tool-result ->|   a CallToolResult   (or tool-cancelled)
  |        ... interactive phase ... |
  |-- ui/resource-teardown --------->|   page cleans up and replies
```

The first tool result arrives by notification, so a fresh page needs no extra call to show data. If the tool is canceled, the host MUST send `tool-cancelled` with an optional reason.

## Page-to-host requests

| Method | Purpose | Notes |
|---|---|---|
| `tools/call` | Call a server tool | Only tools whose visibility includes `app`; same connection |
| `resources/read` | Read a resource | Useful for binary blobs |
| `ui/open-link` | Open an external URL | Host decides; may deny (policy, user) |
| `ui/message` | Add a message to the conversation | Host MAY ask user consent; triggers follow-ups |
| `ui/update-model-context` | Set context for future turns | Each call overwrites the last; host may defer to the next user message and keep only the last |
| `ui/request-display-mode` | `inline`, `fullscreen` or `pip` | Check availability first; handle a different resulting mode |
| `notifications/message` | Log to the host | Debugging and telemetry |

Draft-only additions: `ui/download-file` (host-mediated download because the sandbox blocks direct downloads; expect a confirmation), `ui/notifications/request-teardown` (page asks to be closed), and app-provided tools (the page registers tools the host or model can call, with host-side attribution and confirmation rules). Feature-detect before use.

## Host-to-page

- Notifications: `tool-input`, `tool-input-partial`, `tool-result`, `tool-cancelled`, `host-context-changed` (partial updates to merge: theme, display mode, dimensions, safe area).
- `hostContext` fields (all optional): tool info, `theme`, `styles.variables` (a standardized set of CSS custom properties such as `--color-background-primary`, `--font-sans`, `--border-radius-md`), `styles.css.fonts`, `displayMode`, `availableDisplayModes`, `containerDimensions`, `locale`, `timeZone`, `platform`, `deviceCapabilities`, `safeAreaInsets`.
- `hostCapabilities`: whether the host supports opening links, proxying server tools and resources, logging, and which sandbox permissions and CSP domains it approved. **Read these**: your requested CSP or permission may have been narrowed.

## Sizing and display

`containerDimensions` can fix a dimension (fill it) or give a maximum (you control size up to it). For flexible dimensions the page reports its size with `ui/notifications/size-changed` (the SDK does this with a resize observer by default). Declare supported display modes in `appCapabilities.availableDisplayModes`, and only request a mode the host lists.

## Theming

Set your own fallback values for each variable you use, because hosts may pass any subset or none (the spec says spacing is deliberately not standardized). Apply host variables and theme when they arrive and again on each context change; the SDK has helpers and React hooks for that.

## Patterns that worked in the public docs

- Polling: call an app-only tool on an interval, read `structuredContent`, stop in the teardown handler, pause when off-screen.
- Degraded state: when a runtime capability is denied, tell the model through `ui/update-model-context`.
- Big context: update the model context first, then send a short `ui/message`.
- State persistence across re-renders: the docs suggest keying local storage by a view identifier your server returns in the result metadata (this skill's inference: storage inside a sandboxed frame may be unavailable, so wrap access and handle failure).

## Failure modes

- Sending requests before `initialized`; assuming the first message is a result.
- Treating partial input as final; acting on it.
- Ignoring `tool-cancelled` and teardown (leaked timers, lost drafts).
- Requesting fullscreen or a permission without checking the host's answer.
- Trusting incoming messages blindly in a hand-written bridge (the spec's minimal sample does not check the sender; checking that the sender is the parent window and validating message shape is this skill's own advice).

## How an agent should apply this

- Initialize first, render a loading state, then fill from `tool-result`.
- Keep a small state machine: loading, ready, canceled, torn down.
- Read `hostCapabilities` and `hostContext` and adapt; never assume.
- Use app-only tools for UI actions and `ui/message` only for deliberate conversation turns.
- Test the handler for teardown, cancellation and a rejected `ui/open-link`.
