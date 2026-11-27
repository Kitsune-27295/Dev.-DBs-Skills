# Sources — MCP Apps (public specification)

Every URL below was checked during skill authoring (2026-11-24; re-fetched and rewritten 2026-11-27).

| Source | Retrieved status (2026-11-27) | What it contributed |
|---|---|---|
| [ext-apps repository (GitHub)](https://github.com/modelcontextprotocol/ext-apps) | 200 OK via WebFetch (model-written extract) | Spec locations, SDK subpaths, Node 20+, peers (2.x MCP SDK packages, zod), host list, four bundled agent skills, Apache badge |
| [Specification 2026-01-26 (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx) | 200 OK; 59,181 bytes (same as before); read directly, key claims grepped | Normative stable text; status header "Stable (2026-01-26)" |
| [Specification draft (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx) | 200 OK; 97,689 bytes (same as before); header "Status: Draft"; changed sections only | Draft-only features and differences |
| [MCP docs - MCP Apps overview](https://modelcontextprotocol.io/extensions/apps/overview) | 200 OK via WebFetch (extract) | Why not a web app, flow, security summary, client list |
| [MCP docs - Build an MCP App](https://modelcontextprotocol.io/extensions/apps/build) | 200 OK via WebFetch (extract) | Node 20+, single-file bundling, server and page code shape, tunnel and basic-host testing |
| [MCP Apps API docs - Patterns](https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html) | 200 OK via WebFetch (extract) | CSP and CORS, app-only tools, polling, 500 KB chunk example, error and storage patterns |
| [npm registry - @modelcontextprotocol/ext-apps (latest)](https://registry.npmjs.org/@modelcontextprotocol/ext-apps/latest) | 200 OK; JSON read directly | Version 2.0.4, MIT, Node >=20, peerDependencies |
| [ext-apps package.json and LICENSE (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/LICENSE) | 200 OK; read directly | Repository package 2.1.0 (MIT field); MIT-to-Apache-2.0 transition text |
| [ext-apps RELEASES.md](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/RELEASES.md) | 200 OK; head only | Historical notes; no current claims taken |
| [MCP docs - extension support matrix](https://modelcontextprotocol.io/extensions/client-matrix) | 200 OK via WebFetch; now read | Matrix is community-maintained; per-cell marks were lost in extraction; describes newer core negotiation wording (`server/discover`) |
| Built-in skill for MCP App development shipped with a third-party product | Not re-opened | Third-party skill read for ideas, no text reused |

## Reading limits

- Corrections found on 2026-11-27: the build-guide versus package-peer mismatch, the corrected `object-src` row, host-list wording; all other checked claims (stable status, extension id, mime type, visibility, teardown, draft-only features, SDK 2.0.4) held.

- Pages marked "extract caveat" were summarized by the fetch tool; exact field names and behaviors were cross-checked against the raw specification where possible.
- The draft was not read line by line; the diff table in `spec-status-and-versions.md` covers the sections inspected.
- No host was run during authoring, so rendering, CSP enforcement and host differences are not tested here; statements about them come from the specification and docs.

## Claims not adopted as fact

- Supporting hosts: the overview and the README list different clients and the matrix marks were not readable; no per-client support claim is adopted.
- The core MCP draft's new extension-declaration mechanism (matrix page) is not verified against the apps spec; the apps spec text still uses `initialize`.
- Draft-only features (download, request-teardown, app-provided tools, listing-level metadata, generic rendering requirements) may change or be dropped.
- Recommended limits in the draft (number of app tools, timeouts, result sizes) are recommendations for hosts, not requirements.
- Debugging hints in `build-package-test-and-fallback.md` are this skill's inferences from the lifecycle, not documented behavior.
- Licensing: sources disagree (npm and package.json MIT, README Apache badge, LICENSE transition text); no license conclusion is stated here.
- Why the build guide still names `@modelcontextprotocol/sdk` while the package peers on 2.x split packages is not explained by any source read.
