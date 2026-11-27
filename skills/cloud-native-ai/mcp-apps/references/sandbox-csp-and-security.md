# Sandbox, CSP and Security

Sources: https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx · https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/draft/apps.mdx · https://modelcontextprotocol.io/extensions/apps/overview · https://apps.extensions.modelcontextprotocol.io/api/documents/Patterns.html · Last verified 2026-11-24

Boundary: authentication, authorization, input parsing and the error contract belong to `authn-authz-guard`, `validator-input-parser`, `never-trust-the-client` and `error-handling-problem-details`. Here: what the spec guarantees, what it leaves to you, and how to apply those skills to an MCP App.

## Threat model named by the spec

A malicious server delivers harmful HTML; a compromised view tries to escape the sandbox; a view attempts unauthorized tool execution; a view exfiltrates host data; a view performs phishing or social engineering. Other stated risks: misleading content inside the frame, and CPU or memory abuse.

## What the host must do (stable and draft agree)

- Render the view in a **sandboxed iframe**; if the host is a web page, the frame's origin differs from the host's, with `allow-scripts` and `allow-same-origin` set (stable text mandates a proxy frame; the draft states the requirements generically and says the document in the frame must be served by infrastructure the host controls, so CSP is delivered as HTTP headers and cannot be set by a third-party server).
- Build and enforce **CSP from the declared metadata**, block undeclared domains, apply `frame-src 'none'`, `base-uri 'self'` and `object-src 'none'` unless declared otherwise, and never loosen beyond what was declared.
- Validate incoming messages, reject malformed ones, log view-initiated calls, optionally hash and review templates, warn users about external domain access.
- Only forward non-`ui/` messages to the server; may ask the user for approval.

## Default policy when `csp` is omitted

`default-src 'none'`; `script-src` and `style-src` allow `'self'` and inline; images and media allow `'self'` and `data:`; `connect-src 'none'`. So: inline bundle works, any network call or external asset fails until declared.

## Declaring access (least privilege)

| Need | Field | Maps to |
|---|---|---|
| fetch, XHR, WebSocket to an API | `connectDomains` | `connect-src` |
| scripts, styles, images, fonts, media from a CDN | `resourceDomains` | `script-src`, `style-src`, `img-src`, `font-src`, `media-src` |
| embed a player or a nested frame | `frameDomains` | `frame-src` |
| a different `<base>` | `baseUriDomains` | `base-uri` |
| camera, microphone, geolocation, clipboard write | `permissions` | iframe `allow` (Permissions Policy) |
| stable origin for CORS or OAuth | `domain` | host-specific format |

Rules: list exact origins; avoid wildcards (the spec allows wildcard subdomains for `resourceDomains`, which widens trust); include a localhost origin only in development builds; CORS is enforced by the API you call, so an API that allowlists origins needs `domain` and a host that supports it. If the host narrows your declaration (see `hostCapabilities.sandbox`), the feature will fail: handle it.

## The page is untrusted code, from your server's point of view

The server cannot know whether a `tools/call` came from your page, a modified page or a script a user injected in dev tools; the host only mediates. Therefore:

1. **Authenticate and authorize per call** on the server using the connection's credentials, not anything the page supplies (`authn-authz-guard`). `visibility: ["app"]` limits listing and routing; it does not prove who is calling or what they may do.
2. **Parse and validate every argument** against a schema with size and depth limits; reject unknown fields (`validator-input-parser`). Page-side validation is only UX.
3. **Keep business rules on the server**: prices, limits, permissions, state transitions (`never-trust-the-client`). The page may display; it must not decide.
4. **No secrets in the bundle, the template or `structuredContent`.** Anything in HTML or results is readable by the user and by the model. Use server-side credentials or short-lived, narrowly scoped tokens when a view must call an external API directly.
5. **Idempotency and confirmation for side effects**: an app button may fire twice or be replayed; require confirmation outside the frame (host or model flow) for destructive actions, and make writes idempotent.
6. **Errors**: return `isError: true` with a safe, structured message; log details server-side (`error-handling-problem-details`).
7. **Prompt-injection surface**: `ui/message` and `ui/update-model-context` feed text into the conversation. Content the page forwards from untrusted data can carry instructions; treat page-originated text as untrusted input on the model side, and do not forward raw third-party content as if it were the user's words.
8. **Resource limits**: bound tool result sizes, polling rates and payloads on the server; hosts may impose limits too (the draft recommends some for app-provided tools).

## Host-mediated powers to treat as requests

`ui/open-link` (the host may deny or ask the user), `ui/message` (may need consent), `ui/download-file` (draft; confirmation and filename sanitization), permissions (may be ignored), display mode (may differ). Design every flow so that denial leaves the user in a coherent state.

## Social engineering inside the frame

The sandbox does not stop a view from drawing a fake login or fake system message. The spec expects hosts to mark the boundary of sandboxed UI. As an author: never ask for credentials or payment details inside the view; use the host's own authorization flow.

## How an agent should apply this

- Start with the default CSP; add the minimum exact origins; prefer an inline bundle to CDNs.
- For each tool the page can call, write down who may call it and what the server checks; add a test that calls it directly, bypassing the UI.
- Grep the bundle and results for secrets, tokens and business rules before shipping.
- Treat `permissions` and `domain` as best effort; feature-detect and degrade.
- Review draft-only powers (downloads, app-provided tools) as separate risks; skip them when the host does not document confirmation behavior.
