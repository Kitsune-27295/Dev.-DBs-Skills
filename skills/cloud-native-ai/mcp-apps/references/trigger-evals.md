# Trigger Evals

Last verified 2026-11-27. Three prompts that should load this skill and three near-misses that belong elsewhere.

## Should trigger

1. "Add an interactive chart to my MCP tool so it renders inside the chat." Expected: `mcp-apps`.
2. "My MCP App shows a blank frame in the host; the resource is served." Expected: `mcp-apps`.
3. "Review this MCP App: its `connectDomains` has a wildcard and the page decides who may delete." Expected: `mcp-apps`, with the server rules pointing to `never-trust-the-client` and `authn-authz-guard`.

## Near-miss (should not trigger)

1. "Write login and token checks for my REST API." Expected: `authn-authz-guard`.
2. "Validate and parse JSON bodies coming from the browser." Expected: `validator-input-parser`.
3. "Build a React dashboard served from my own domain." Expected: no MCP skill; an ordinary web app.
