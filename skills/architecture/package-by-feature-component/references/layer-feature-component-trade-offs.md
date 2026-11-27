# Package by Layer vs Feature vs Component: Trade-offs

Sources: https://milanjovanovic.tech/blog/clean-architecture-the-missing-chapter (read in full) · Last verified 2026-11-27

## Reading status
Only the Jovanovic article was read. The Medium comparison post returned 403 and the GitHub link list gives titles without content (see `sources.md`). Simon Brown's own "package by component" article was not reachable, so his view is known here only through Jovanovic.

## What the article argues
- Clean Architecture's circles describe the direction of dependencies, not folder shape.
- **Layer** (Web, Business, Data): familiar, but one feature spans several projects, `public` types let a controller reach a repository directly, the tree hides business intent, and a ball of mud still results.
- **Feature:** one namespace per feature holding command, handler, validator, repository and view model; good navigation, best when features are many, small and independent.
- **Component:** a cohesive capability behind a well-defined interface, coarser than a feature; only the interface is public, so nothing can bypass it. Close to a modular-monolith module.
- Recommendation: start with one project and components, with feature folders inside each; add architecture tests when more control is needed.

## Decision rules (judgment built on the article)
| Situation | Pick |
|---|---|
| Many tiny features, little shared code | Feature folders |
| Capability with several entry points, or a boundary worth protecting | Component, features inside |
| Need to extract a service later | Component (its interface is already the seam) |
| Top-level split by layer | Avoid |

## Example shape (C#, paraphrased)
```
public interface IPoliciesComponent { Task RenewPolicyAsync(...); }
internal sealed class PoliciesComponent : IPoliciesComponent { }
internal interface IPolicyRepository { }
```
Controllers depend on `IPoliciesComponent` only.

## How an agent should apply this
- Group a new codebase by capability, never by layer at the top level.
- Make the component interface the only public type.
- If a feature needs another's data, go through the owning component's interface.
- Say that the Medium post and Simon Brown's original were not read.
