# Spec Status and Versions

Sources: https://github.com/modelcontextprotocol/ext-apps · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx · https://modelcontextprotocol.io/extensions/apps/overview · https://registry.npmjs.org/@modelcontextprotocol/ext-apps/latest · Last verified 2026-11-24

## What the documents are

- **SEP-1865 "MCP Apps: Interactive User Interfaces for MCP"**, Track: Extensions, created 2025-11-21. It builds on SEP-1724 (the extensions capability mechanism). Its motivation names the community project MCP-UI and the Apps SDK for a chat product as inputs; it unifies them into one open standard.
- **Stable version `2026-01-26`**: file `specification/2026-01-26/apps.mdx`, header "Status: Stable (2026-01-26)". Frozen text; the right target for compatibility.
- **Draft**: `specification/draft/apps.mdx`, header "Status: Draft". It is a superset in progress and its text can change.
- Both are inside the ext-apps repository; the repository's `specification/` directory is the normative source, the docs site is explanatory.
- MCP Apps is an **extension**, optional, and negotiated between client and server; reserved names: the `ui://` prefix and the label `io.modelcontextprotocol/ui`.

## Differences observed between stable 2026-01-26 and the draft (read on 2026-11-24)

| Topic | Stable 2026-01-26 | Draft |
|---|---|---|
| Rendering architecture | Requires a sandbox proxy for web hosts (different origin, `allow-scripts` and `allow-same-origin`, proxy-ready and resource-ready notifications) | Defines generic requirements (iframe on a different origin than the host, same sandbox flags, CSP via HTTP headers, document served by the host's own infrastructure); single and double iframe become non-normative examples |
| `_meta.ui` location for resources | On the content item of `resources/read` | May be on the listing entry (`resources/list`), on the content item, or both; content item wins; hosts MUST check both |
| `ui/download-file` (host-mediated download) | Absent | Present, with a user-confirmation recommendation and filename sanitization |
| `ui/notifications/request-teardown` (view asks the host to close it) | Absent | Present; host MAY defer or ignore |
| App-provided tools (page registers tools, host calls them; `tools/list`, `tools/call` Host to App) | Absent | Present, with a security section (attribution, namespacing, confirmation for non-read-only, limits such as about 50 tools, 30 s, 10 MB as recommendations) and a WebMCP interoperability section |
| Default CSP text | Lists no `object-src` line in the default block | Default block adds `object-src 'none'` |

Observation to treat with care: the draft's sample `protocolVersion` strings in its initialize examples read `2025-06-18` in places while the stable sample reads `2026-01-26`; examples are illustrative and may lag the normative text. Check the SDK's constant, not the sample.

## SDK and ecosystem snapshot (2026-11-24)

- npm package `@modelcontextprotocol/ext-apps`: latest 2.0.4 per the registry; repository `main` showed package version 2.1.0 (unreleased or ahead of npm at that moment). Requires Node 20+; peers on the 2.x MCP SDK packages (`core`, `client`, `server`) and `zod`; React optional. The repository states the wire protocol is unchanged between SDK 1.x and 2.x and provides a migration guide.
- SDK subpaths per the repository README: base (the `App` class, `PostMessageTransport`), `/react` (hooks), `/app-bridge` (embed views in a client), `/server` (register tools and resources).
- Host support (docs overview): several clients support it, among them Claude and Claude Desktop, VS Code with a coding assistant, Microsoft 365 Copilot, Goose, Postman, MCPJam; the docs link a client matrix. Support is per client and per feature; the matrix is the source of truth, not this list.
- Licensing: the repo LICENSE file says the MCP project is moving from MIT to Apache-2.0 (new contributions Apache-2.0, some older contributions MIT); `package.json` says MIT; the repository summary text said Apache 2.0. Check before redistributing.
- The repository ships its own agent skills for scaffolding and migrating apps (`create-mcp-app` and others); they are an upstream convenience, not the specification.

## Version-handling rules

1. Say in your design note which spec version you target (`2026-01-26` stable, or "draft, section X, checked on <date>").
2. Prefer stable-only features; for a draft-only feature (download, request-teardown, app-provided tools, listing-level `_meta.ui`) feature-detect host support and keep a fallback.
3. Re-read the draft's changed sections when the SDK minor version changes.
4. Do not assume a host implements the whole spec: check `hostCapabilities` at runtime.

## How an agent should apply this

- Open the stable spec and the draft diff before designing; cite the section for each behavior you rely on.
- Mark draft-only items in code comments and tests so they can be removed or updated.
- Record SDK version and host versions tested in the project's README or ADR.
- If a claim in a blog or sample contradicts the spec text, the spec text wins; say so in the decision record.
