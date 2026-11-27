# UI Resource and Tool Linkage

Sources: https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx · https://modelcontextprotocol.io/extensions/apps/build · https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html · Last verified 2026-11-24

## Why predeclare the UI

The spec chose **predeclared resources** over embedding HTML in each tool result. Reasons it gives: the host can prefetch and review the template before the tool runs, presentation (template, cacheable) is separated from data (tool result), and all UI resources are enumerable and inspectable, which supports security review (hashing, allow and block lists). The cost is one more registration step for the server author.

## The resource

Declared like any MCP resource, with conventions:

```json
{
  "uri": "ui://reports/dashboard.html",
  "name": "sales_dashboard",
  "description": "Interactive sales dashboard",
  "mimeType": "text/html;profile=mcp-app"
}
```

`resources/read` returns `contents[]` with the same `uri`, `mimeType`, and either `text` or base64 `blob`, plus optional `_meta.ui`:

- `csp`: `connectDomains`, `resourceDomains`, `frameDomains`, `baseUriDomains` (all optional; omitted means locked down).
- `permissions`: `camera`, `microphone`, `geolocation`, `clipboardWrite` (each `{}`); a request the host MAY honor.
- `domain`: a dedicated sandbox origin; its format is **host-dependent** (consult each host's docs). Useful when an upstream API allowlists origins or an OAuth callback needs a stable origin.
- `prefersBorder`: boolean; set it explicitly because host defaults differ.

Servers MAY omit UI-only resources from `resources/list` and its change notifications, because discovery happens through the tool metadata. In the stable text the metadata lives on the content item; the draft also allows the listing entry (content item wins when both exist). The public patterns page advises setting `csp` and `domain` on the returned content items, not in the registration helper's config.

## The tool

```json
{
  "name": "get_report",
  "description": "Show the sales report for a region",
  "inputSchema": { "type": "object", "properties": { "region": { "type": "string" } } },
  "_meta": { "ui": { "resourceUri": "ui://reports/dashboard.html", "visibility": ["model", "app"] } }
}
```

Behavior: with a supporting host, the tool's result is rendered through the referenced resource; otherwise it is a normal tool. The host reads the resource with `resources/read`, and may prefetch and cache it. The flat key `_meta["ui/resourceUri"]` is deprecated (spec says it would be removed before GA); use `_meta.ui.resourceUri`.

## Visibility

| `visibility` | Model sees tool | App can call it |
|---|---|---|
| omitted or `["model","app"]` | yes | yes |
| `["app"]` | no (host MUST NOT list it to the agent) | yes, same server connection only; cross-server calls blocked |
| `["model"]` | yes | no (host MUST reject app calls) |

Use `["app"]` for refresh, pagination, polling and save actions so the model does not see UI plumbing. This is a **visibility** control for the model's tool list and for routing; it is not an authorization mechanism (see the security reference).

## Result shape

- `content`: text for the model and for text-only hosts; **always meaningful**.
- `structuredContent`: data optimized for rendering; per the spec best practice it is not added to model context.
- `_meta`: extra values (timestamps, a view identifier) not meant for the model.
- Errors: return `isError: true` with content so the model and the page both see a normal failure.

```ts
return {
  content: [{ type: "text", text: "Q3 sales: EMEA 4.2M, APAC 3.1M" }],
  structuredContent: { rows: [...], generatedAt: "2026-11-24T10:00:00Z" },
  _meta: { viewId: crypto.randomUUID() },
};
```

## Large or binary data (public patterns page)

Two approaches are documented: chunk through an app-only tool that returns base64 pieces with offset, byte count, total and a more-flag, or return a base64 `blob` from a resource and read it through the bridge with `resources/read`. Both keep big payloads out of model context. Chunk size and limits are your design; the page suggests pieces around 500 KB as an example, not a rule.

## How an agent should apply this

- Declare one resource per distinct view; keep HTML static and data in results.
- Use the nested `_meta.ui` form and set `prefersBorder` explicitly.
- Mark UI-only tools `["app"]`, then add server-side authorization to them anyway.
- Always fill `content` with a usable summary; treat `structuredContent` as UI-only data and keep secrets out of all three channels.
- Put per-response CSP and domain on the content item, and keep a static default for host review only if you target the draft.
