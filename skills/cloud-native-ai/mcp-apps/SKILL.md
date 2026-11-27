---
name: mcp-apps
description: "Build, review or debug an MCP App, an interactive UI attached to an MCP tool, from the public ext-apps specification (SEP-1865): a ui:// HTML resource with mime type text/html;profile=mcp-app, rendered in a sandboxed iframe under a declared CSP, talking to the host over a JSON-RPC postMessage bridge. Covers tool linkage, capability negotiation with text-only fallback, bridge lifecycle, the untrusted-view security model, single-file packaging, testing, and spec status (stable 2026-01-26 versus draft). Not for generic server-side input and auth rules (never-trust-the-client, authn-authz-guard) or ordinary web apps. Use when adding a UI to an MCP tool, reviewing an MCP App for security, or debugging one that does not render."
---

# MCP Apps (public specification)

One idea: an MCP App is an ordinary MCP **tool plus a predeclared `ui://` HTML resource**; the host fetches the HTML, renders it in a **sandboxed iframe** under a CSP built from what the resource declares, and the page and host exchange **JSON-RPC over `postMessage`**. The page is **untrusted client code**: every call it makes is just another request your server must validate and authorize, and the tool must still work as plain text when no UI is supported. Sources and claims: [references/sources.md](references/sources.md).

**Spec status (verify before relying on it).** MCP Apps is an optional **extension** to MCP, identifier `io.modelcontextprotocol/ui`. The specification text (SEP-1865) is **Stable at version 2026-01-26**; a **draft** continues to evolve beyond it (this skill was checked against both on 2026-11-27). The SDK `@modelcontextprotocol/ext-apps` was at 2.0.4 on npm that day (Node 20+; it peers on the 2.x `@modelcontextprotocol/core`, `client` and `server` packages and on `zod` 4.2+; the wire protocol is documented as unchanged between 1.x and 2.x). Host support varies by client and is tracked in a community-maintained matrix. Pin the spec version you target and re-check the draft before using anything marked draft-only here. Details: [spec status and versions](references/spec-status-and-versions.md).

Boundaries: `never-trust-the-client` owns the rule that business rules and secrets live on the server; `authn-authz-guard` owns login, tokens and access decisions; `validator-input-parser` owns parsing untrusted input; `error-handling-problem-details` owns the error contract. This skill applies them to the app surface and does not restate them.

---

## 1. When to build one, and when not

Build when a text answer is weak: exploring data, a form with many interdependent options, rich media, live monitoring, a multi-step approval flow. Skip it when a plain tool result or a normal web page would do; the public docs themselves note a regular web app can be simpler if you do not need tight integration with the conversation. Decide the **text-only behavior first**: the tool returns a meaningful `content` array whether or not a UI renders.

## 2. The two halves: resource and tool

**UI resource** (served through the normal resource calls):

| Field | Rule |
|---|---|
| `uri` | MUST start with `ui://`; the path after it is yours (for example `ui://reports/dashboard.html`) |
| `mimeType` | MUST be `text/html;profile=mcp-app` |
| content | `text` (HTML string) or `blob` (base64); MUST be a valid HTML5 document |
| `_meta.ui` | `csp`, `permissions`, `domain`, `prefersBorder` (see section 5) |

**Tool linkage**: the tool's `_meta.ui.resourceUri` points at the resource; `_meta.ui.visibility` is `["model","app"]` by default, `["app"]` hides the tool from the model (UI-only actions such as refresh or save), `["model"]` blocks the app from calling it. The older flat `_meta["ui/resourceUri"]` key is deprecated: use the nested form. The resource must exist on the same server; the host reads it with `resources/read` and may prefetch and cache it, so keep the **template static and the data in tool results**.

```ts
// SDK helpers (@modelcontextprotocol/ext-apps/server); shape per the public build guide
registerAppTool(server, "get-report", {
  description: "Show the sales report",
  inputSchema: { region: z.string() },
  _meta: { ui: { resourceUri: "ui://reports/dashboard.html" } },
}, async ({ region }) => ({
  content: [{ type: "text", text: summaryFor(region) }],   // fallback and model context
  structuredContent: dataFor(region),                       // for the UI only
}));
registerAppResource(server, "ui://reports/dashboard.html", "ui://reports/dashboard.html",
  { mimeType: RESOURCE_MIME_TYPE }, async () => ({ contents: [{
    uri: "ui://reports/dashboard.html", mimeType: RESOURCE_MIME_TYPE, text: html }] }));
```

Result split (spec best practice): `content` = text for the model and text-only hosts; `structuredContent` = data shaped for the UI, not added to model context; `_meta` = extra data not meant for the model. Reference: [resource and tool linkage](references/ui-resource-and-tool-linkage.md).

## 3. Negotiate, then degrade gracefully

A host advertises support in `initialize` under `capabilities.extensions["io.modelcontextprotocol/ui"].mimeTypes`. Servers SHOULD check it before registering UI-enabled tools and SHOULD give every UI tool a text-only fallback; they MAY register different tool variants per host. If the host does not support the extension the tool simply behaves as a normal tool.

## 4. The bridge: what the page does

Transport is JSON-RPC 2.0 over `postMessage`. The SDK's `App` class is a convenience, not a requirement (the protocol can be spoken directly). Lifecycle: the page sends `ui/initialize`, then `ui/notifications/initialized`; the host MUST NOT send anything before that. Then `ui/notifications/tool-input` (arguments), optional streamed `tool-input-partial`, and `tool-result` or `tool-cancelled`. The page can call server tools (`tools/call`), read resources, log, ask the host to open a link, send a message to the conversation, update the model context, and request a display mode. Before teardown the host sends `ui/resource-teardown`: stop timers and flush state. Reference: [host bridge protocol](references/host-bridge-protocol.md).

Rules: never block on the bridge (show a loading state, handle `tool-cancelled`); treat partial input as a hint only; check the host's `availableDisplayModes` before requesting fullscreen; adopt host theme variables with fallbacks of your own; report size changes so a flexible container fits.

## 5. Security model

1. **The iframe is a trust boundary.** The host renders the view cross-origin and sandboxed; the page cannot touch the host DOM, cookies or storage, and all communication is mediated `postMessage`. Hosts log and may block messages or ask the user.
2. **CSP is deny-by-default and declarative.** With no `csp`, the host applies a restrictive policy (no external connections, only inline script and style, `self` and `data:` images). Declare only what you need: `connectDomains` (fetch, XHR, WebSocket), `resourceDomains` (scripts, styles, images, fonts, media), `frameDomains`, `baseUriDomains`. The host MUST NOT allow undeclared origins. Prefer bundling everything inline over allowing a CDN.
3. **`permissions`** (camera, microphone, geolocation, clipboard write) are requests; the host MAY ignore them, so feature-detect and degrade.
4. **Treat every app-originated call as hostile input.** `visibility: ["app"]` hides a tool from the model; it is not authentication. Re-check identity, ownership and input on the server for every tool call, whoever made it (`authn-authz-guard`, `validator-input-parser`, `never-trust-the-client`). No secrets, tokens or business rules in the HTML or the bundle.
5. **Return errors as results**, with `isError: true` and a safe message, not stack traces (`error-handling-problem-details`).
6. **Do not use the UI for consent.** A button in the view is not user approval for a destructive action; keep confirmation on the host or in the model flow.
7. Residual risks the spec names: misleading UI (social engineering) and resource exhaustion by the view.

Reference: [sandbox, CSP and security](references/sandbox-csp-and-security.md).

## 6. Package, serve, test

- Build the UI into **one self-contained HTML file** (a single-file bundler plugin is the documented path) so default CSP works; if you must load external assets, declare their origins.
- Serve the server over a streamable HTTP endpoint (or the transport your host supports); read the built HTML in the resource handler.
- Test in a reference host first (the ext-apps repository ships a basic host) and then in a real host; hosted clients need a reachable HTTPS URL, so use a tunnel during development.
- Verify: renders in the host, tool-result arrives, an app-initiated tool call round-trips, CSP blocks an undeclared origin, text-only fallback works with the extension disabled, theme changes apply, teardown stops timers.

Reference: [build, package, test and fallback](references/build-package-test-and-fallback.md).

## 7. Anti-patterns

| Smell | Fix |
|---|---|
| Tool is useless without the UI | Meaningful `content` for every UI tool |
| Authorization decided in the page | Server-side checks on every call |
| `connectDomains` wildcards or unneeded CDNs | Declare exact origins; bundle inline |
| Data baked into the HTML template | Keep template static; data in `structuredContent` |
| Relying on `permissions` being granted | Feature-detect; show a degraded state |
| Using draft-only features without a check | Confirm the draft section and host support |
| Timers or listeners after teardown | Stop work in the teardown handler |

## Quick Decision Checklist

1. Does the use case need UI, and does the tool work without it?
2. Spec version pinned (stable 2026-01-26 or named draft section)?
3. Resource `ui://`, mime `text/html;profile=mcp-app`, valid HTML5; tool `_meta.ui.resourceUri` set?
4. Visibility chosen for each tool (model, app, both)?
5. CSP minimal, exact origins, assets bundled; permissions feature-detected?
6. Server re-validates and re-authorizes every call; no secrets in the bundle?
7. Capability check plus text-only fallback implemented?
8. Lifecycle handled: initialize, input, result, cancel, teardown, resize?
9. Tested in a reference host and a real host, including CSP and fallback?

## Deep references

- [Spec status and versions](references/spec-status-and-versions.md) — read first: stable versus draft, version numbers, what changed, licensing note.
- [Resource and tool linkage](references/ui-resource-and-tool-linkage.md) — read when declaring resources, tools, visibility and result shapes.
- [Host bridge protocol](references/host-bridge-protocol.md) — read when writing the page or reviewing messages and lifecycle.
- [Sandbox, CSP and security](references/sandbox-csp-and-security.md) — read when setting CSP, permissions or reviewing threat handling.
- [Build, package, test and fallback](references/build-package-test-and-fallback.md) — read when scaffolding, bundling, testing or degrading.
- [Trigger evals](references/trigger-evals.md) — read when tuning or checking the description.
- [Sources](references/sources.md) — URL statuses and claims not adopted.
