# Toggle Taxonomy and Lifecycle

Sources: https://martinfowler.com/articles/feature-toggles.html · Last verified 2026-11-23

## Vocabulary (Pete Hodgson on martinfowler.com)

Feature toggles (flags, bits) change behavior without changing code, letting alternative paths ship in one deployable. **Toggle point** = where code branches. **Toggle router** = what decides (an in-memory map up to a distributed system with a UI). **Toggle configuration** = settings the router reads. **Toggle context** = request or user data (cookie, header) for per-request decisions.

## Categories along two axes

Longevity (how long it exists) and dynamism (how often its decision changes).

- **Release:** hides unfinished code so teams can do trunk-based development and separate deploy from release. Days to weeks (product-driven ones longer). Decisions static per release; changing one by releasing is acceptable.
- **Experiment:** cohort assignment per user, consistent for that user. Highly dynamic routing, but configuration should stay fixed because mid-run changes can invalidate the statistics. Hours to weeks.
- **Ops:** operator control (disable a costly feature under load, back off during an incident). Mostly short-lived; long-lived "kill switches" behave like manual circuit breakers. Must change quickly without a release.
- **Permission:** premium tiers, alpha/beta, internal staff first ("Champagne Brunch"). Can live years; always per-request by identity.
- **Canary release:** a use of release toggles; a small consistently assigned random cohort (about 1% by user ID modulo), compare business metrics against the rest, then expand.

| Question | Points to |
|---|---|
| Does it depend on who the user is, permanently? | Permission |
| Is the goal a measured comparison? | Experiment (freeze config) |
| Is it an emergency lever? | Ops (runtime, no deploy) |
| Is it unfinished or risky code being shipped dark? | Release (short, remove soon) |

## Configuration options and trade-offs

Hardcoded (redeploy) → env var/CLI (restart) → config file (redeploy) → app DB with admin UI (fleet-consistent, UI to build) → distributed KV like ZooKeeper, etcd, Consul (dynamic, propagates to every node). Fowler's preference: **static configuration in source control**, promoted through the delivery pipeline, because artifacts stay consistent across environments, past releases can be rebuilt, and testing burden shrinks. Distinguish **dynamic routing** (decision changes per request) from **dynamic configuration** (the settings change at runtime); experiments need the first without the second.

Environment-specific overrides conflict with promoting identical artifacts. Per-request overrides (cookie, query parameter, header) let testers use features in production without affecting others; the risk is user tampering, mitigated by signing.

## Working with a flagged system

- Expose toggle state through a metadata endpoint (like build/version info).
- Use structured config with description, owner and expiry per toggle; descriptions matter most when non-developers manage them.
- Manage each category differently; owner and config home change when the category changes.
- **Testing:** each release candidate in on and off states, but not every combination. Test the expected production config, the fallback config (new toggles off), sometimes all-on. Convention: off = legacy, on = new.

## Debt control

Toggles add abstractions, conditional logic and testing burden. Practices from the article: a removal task in the backlog when a release toggle is created; expiration dates; time bombs that fail tests or refuse startup after expiry; a cap on total toggles (add one, remove one). Knight Capital is cited as a warning of costly flag mismanagement.

## Example: structured toggle registry (our format)

```yaml
new-checkout:
  category: release
  owner: payments-team
  description: Single-page checkout, hidden until QA sign-off
  default: false
  expires: 2027-01-31
  removal_ticket: PAY-412
```

## Failure modes

Zombie flags past expiry; changing experiment config mid-run; ops toggle that needs a deploy to flip; permission toggle mistaken for authorization; all-on combination never tested; unreadable flag keys with no owner.

## How an agent should apply this

- Ask "which category?" before adding a flag and record category, owner, expiry in the registry.
- Pick config home by dynamism: file for release, runtime store for ops/permission, experiment platform for cohorts.
- Create the removal task in the same change that introduces a release toggle; add an expiry check.
- Add tests for production config and all-off fallback; keep "off" equal to legacy behavior.
- When a flag reaches 100% and is stable, delete the old path, the config and the vendor entry together.
