# Package by Layer vs Feature vs Component: Trade-offs

Sources: https://milanjovanovic.tech/blog/clean-architecture-the-missing-chapter · https://medium.com/@akintopbas96/spring-boot-code-structure-package-by-layer-vs-package-by-feature-5331a0c911fe (blocked: 403 / Cloudflare challenge, not read) · https://github.com/drveillard/software-architecture/blob/main/docs/vertical-slice-architecture.md (link list only) · Last verified 2026-11-23

## Reading status
Only the Jovanovic article was read in full. The Medium post could not be fetched (403, also blocked via curl). The GitHub page is a curated link list that names Simon Brown's "Package by component and architecturally-aligned testing" without summarizing it. Everything below comes from Jovanovic.

## Thesis
Clean Architecture governs dependency direction, not folder shape: the circles are levels of policy with dependencies pointing inward.

## The three schemes
| Scheme | Structure | Strength | Weakness |
|---|---|---|---|
| Layer | `Web`, `Business`, `Data` projects | Familiar | One feature spans three projects (breaks Common Closure Principle); `public` types let controllers bypass services and hit repositories; hides business intent; maintenance means project-hopping; ends as a ball of mud despite separate projects |
| Feature | folder per feature holding command, handler, validator, repository, view model (e.g. `Policies/RenewPolicy`) | Intent visible, related code together, easy navigation; linked to vertical slices | Best for many small independent features with little shared code |
| Component | coarse unit per business capability, one public interface, services and repositories hidden | No layer bypass, real encapsulation, visible capability, easy later extraction; close to a modular-monolith module | More upfront thinking about boundaries |
Author's recommendation: start with components, organize features inside each.

## Example shape (C#, paraphrased)
```
public interface IPoliciesComponent { Task RenewPolicyAsync(...); }
internal sealed class PoliciesComponent : IPoliciesComponent { ... }  // delegates to a handler
internal interface IPolicyRepository { }                              // only the component sees it
```
Controllers depend on `IPoliciesComponent` only.

## Decision rules
- Many tiny independent features, little sharing: feature folders.
- Clear business capabilities, need for encapsulation or later extraction: components with feature folders inside.
- Layers as the top-level split: avoid.

## How an agent should apply this
- Never propose a top-level layer split for a new codebase; group by capability.
- Make the component interface the only public type; mark implementations internal (or the language equivalent).
- Do not claim details of the Medium post; flag it as unread.
- If a feature needs another feature's data, route through the owning component's interface.
