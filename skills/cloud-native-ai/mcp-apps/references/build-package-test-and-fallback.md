# Build, Package, Test and Fallback

Sources: https://modelcontextprotocol.io/extensions/apps/build · https://modelcontextprotocol.io/extensions/apps/overview · https://github.com/modelcontextprotocol/ext-apps · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx · https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html · Last verified 2026-11-24

## Project shape (public build guide)

A typical project separates server and UI: a server file that registers the tool and serves the resource, an HTML entry file, a UI script, a bundler config, and a build script that emits one HTML file. Prerequisites: Node.js 20 or newer, familiarity with MCP tools and resources, and the TypeScript MCP SDK. Install the SDK package plus the MCP SDK; the guide's dev tooling is TypeScript, Vite and a single-file plugin, plus an HTTP framework for the endpoint. Any bundler works if you declare external origins in CSP.

## Packaging decision

| Option | Pros | Cons |
|---|---|---|
| One self-contained HTML (inline JS and CSS) | Works under the default CSP; one file to serve and cache; easy to review | Larger resource; no per-asset caching |
| External assets from declared origins | Smaller HTML; shared CDN caching | Needs `resourceDomains`; more trust; offline and CSP failures |
| Remote embed of a full web app | Not supported by the MVP content type | Deferred in the spec; do not plan on it |

Default to the single file. Keep the built HTML below any size limit your host documents (limits vary by host; the spec text sets none in the parts read).

## Server skeleton (shape, not a full file)

```ts
const resourceUri = "ui://get-time/mcp-app.html";
registerAppTool(server, "get-time",
  { title: "Get Time", description: "Server time", inputSchema: {}, _meta: { ui: { resourceUri } } },
  async () => ({ content: [{ type: "text", text: new Date().toISOString() }] }));
registerAppResource(server, resourceUri, resourceUri, { mimeType: RESOURCE_MIME_TYPE },
  async () => ({ contents: [{ uri: resourceUri, mimeType: RESOURCE_MIME_TYPE,
                              text: await readBuiltHtml() }] }));
```

Page skeleton: create the SDK `App` object, call `connect()`, set `ontoolresult` to fill the UI, and use `callServerTool` for user actions. Remember each call is a round trip through the host, so design for latency and failure.

## Capability check and variants

```ts
const ui = getUiCapability(clientCapabilities);      // SDK helper from the server entry
const supported = ui?.mimeTypes?.includes(RESOURCE_MIME_TYPE);
registerTool(supported ? withUi(def) : def);         // same name, with or without _meta.ui
```

The spec says servers SHOULD provide text-only fallback for all UI tools, MAY register different variants per host, and tools MUST return meaningful content even when a UI is available.

## Testing ladder

1. **Unit-test the tool** with no host: the `content` text and `structuredContent` are correct; invalid input is rejected; authorization is enforced when called directly.
2. **Reference host**: the ext-apps repository includes a basic host example. Point it at your server's URL, call the tool, and verify render, theme, resize, an app-initiated tool call and teardown.
3. **Real host**: hosted clients need a URL they can reach; the build guide uses a tunnel to expose a local server and adds it as a custom connector (availability depends on the client's plan). Re-test CSP here, since hosts may be stricter than the reference host.
4. **Negative checks**: fetch an undeclared origin (must be blocked); deny a permission; cancel the tool mid-run; close the view during a pending call; disable the extension and confirm the tool still answers in text.
5. **Accessibility and theme**: light and dark, narrow container, keyboard navigation.

Debugging hints (this skill's inference from the lifecycle): a blank frame usually means a CSP block, a missing or wrong mime type, an invalid HTML document, or a `resourceUri` that does not match a registered resource; a frame that never fills means the page never sent `ui/initialize` or ignored `tool-result`; calls failing only for the model or only for the app point to `visibility`.

## Fallback design

- Server: always a useful `content` string; avoid information only the UI shows.
- Page: if the bridge never initializes or a capability is denied, show a minimal state and, where the host allows, update the model context so the model knows the UI is degraded.
- Host variance: some hosts render only inline; request fullscreen only when listed; do not rely on streaming partial input.
- Errors: map failures to `isError` results; the model should be able to explain them.

## Migration and tooling notes

The repository documents a migration path from older SDK versions and from earlier community formats, and ships agent skills for scaffolding; treat them as helpers and re-verify output against the spec text. Examples in the repository (maps, charts, PDF viewer, forms, a QR generator) are useful patterns but not normative.

## How an agent should apply this

- Scaffold with a single-file bundle, one resource, one tool, then a text-only test before any UI polish.
- Write the capability check and fallback in the first version, not later.
- Run the negative checks listed above and record results with the host and SDK versions.
- Keep build output deterministic and the template free of per-user data.
- When a host behaves differently from the spec text, record the host name, version and the observed difference, and keep the spec-compliant path.
