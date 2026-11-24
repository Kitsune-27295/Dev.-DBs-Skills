# Sources — MCP Apps (public specification)

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [ext-apps repository (GitHub)](https://github.com/modelcontextprotocol/ext-apps) | 200 OK (read through a page-to-markdown fetch tool that returns a model-written extract) | Repository layout, stable and draft spec locations, SDK package subpaths, Node 20+, host list, examples, bundled agent skills |
| [Specification 2026-01-26 (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx) | 200 OK; downloaded (59,181 bytes) and read directly | Normative stable text: extension id, resource format, `_meta.ui`, visibility, bridge messages, lifecycle, sandbox proxy, CSP defaults, capability negotiation, security section |
| [Specification draft (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx) | 200 OK; downloaded (97,689 bytes); read the changed sections (resource metadata location, rendering, download, request-teardown, app-provided tools, security), not every line | Draft-only features and differences from stable |
| [MCP docs — MCP Apps overview](https://modelcontextprotocol.io/extensions/apps/overview) | 200 OK (extract caveat) | Why not a plain web app, how it works, when to use, security summary, client support, framework notes |
| [MCP docs — Build an MCP App](https://modelcontextprotocol.io/extensions/apps/build) | 200 OK (extract caveat) | Prerequisites, project layout, bundling, server and UI code shape, testing with a reference host and a tunnel |
| [MCP Apps API docs — Patterns](https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html) | 200 OK (extract caveat) | CSP and CORS configuration, app-only tools, polling, large data, host styling, display modes, error and degradation patterns |
| [npm registry — @modelcontextprotocol/ext-apps (latest)](https://registry.npmjs.org/@modelcontextprotocol/ext-apps/latest) | 200 OK; JSON read directly | Latest version 2.0.4, MIT in package metadata, Node >=20, peer dependencies |
| [ext-apps RELEASES.md](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/RELEASES.md) | 200 OK; only the head was read | Historical release notes only (an early 0.3.0 entry); no current claims taken |
| [ext-apps LICENSE and package.json (raw)](https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/LICENSE) | 200 OK | MIT-to-Apache-2.0 licensing transition text; repository package version 2.1.0 at read time |
| [MCP docs — client matrix](https://modelcontextprotocol.io/extensions/client-matrix) | HTTP 200 on a header check; content not read | Existence only; support claims are not taken from it |
| Built-in skill for MCP App development shipped with a third-party product | Known to exist; opened only far enough to confirm its subject; no content used | Nothing adopted; this skill is written from the public sources above |

## Reading limits

- Pages marked "extract caveat" were summarized by the fetch tool; exact field names and behaviors were cross-checked against the raw specification where possible.
- The draft was not read line by line; the diff table in `spec-status-and-versions.md` covers the sections inspected.
- No host was run during authoring, so rendering, CSP enforcement and host differences are not tested here; statements about them come from the specification and docs.

## Claims not adopted as fact

- The list of supporting hosts is taken from the docs overview at the retrieval date and changes; the client matrix is authoritative.
- Draft-only features (download, request-teardown, app-provided tools, listing-level metadata, generic rendering requirements) may change or be dropped.
- Recommended limits in the draft (number of app tools, timeouts, result sizes) are recommendations for hosts, not requirements.
- Debugging hints in `build-package-test-and-fallback.md` are this skill's inferences from the lifecycle, not documented behavior.
- Licensing: sources disagree (MIT, Apache-2.0, transition); no license conclusion is stated here.
