# Traditional N-Layer vs Clean Architecture (.NET guide)

Sources: https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures · Last verified 2026-11-27 (English edition; page metadata updated 2026-07-08)

## Project-level progression
1. **All-in-one:** one project, separation only by folders (Models/Views/Controllers/Data/Services). As it grows, UI concerns scatter across folders, business logic splits between Models and Services, and nothing says who may depend on whom: spaghetti code.
2. **Multi-project N-layer (UI, BLL, DAL):** UI talks only to BLL; BLL reaches persistence only via DAL; UI never calls DAL. Still one deployable unit. The guide stresses a layered app is often deployed to a single tier.
3. **Clean/Onion/Hexagonal:** the guide treats these as one family reached by applying dependency inversion plus DDD.

## The key defect of classic layering
Compile-time dependencies run UI -> BLL -> DAL, so the most important code (BLL) depends on data-access details and often on a database existing. Testing business logic then needs a test database. The guide's fix is dependency inversion, not more layers.

## Clean architecture structure
Owned by `clean-architecture` (`dotnet-layout-and-composition-root.md`): Application Core, Infrastructure, UI and the composition root. Result: Core unit-tests in isolation, Infrastructure gets integration tests, implementations swap easily.

## Side-by-side
| Aspect | Classic N-layer | Clean |
|---|---|---|
| Who owns the persistence interface | DAL | Application Core |
| BLL/Core depends on DB code | yes | no |
| Business test setup | often needs a DB | fakes of Core interfaces |
| Cost | lowest ceremony | extra abstractions, composition root |

## Monolith notes from the same page
Scaling and redeploy costs of a monolith, and when to split, are owned by `monolithic-architecture` (`monolith-structure-deployment-and-comparison.md`).

## Example (own sketch)
```
// Core
interface OrderRepository { Order find(Id id); void save(Order o); }
class PlaceOrder { PlaceOrder(OrderRepository r) {...} }
// Infrastructure
class SqlOrderRepository implements OrderRepository {...}
// UI composition root: new PlaceOrder(new SqlOrderRepository(db))
```

## How an agent should apply this
- Default for small CRUD: multi-project N-layer with strict direction; for non-trivial domains recommend inverting the BLL/DAL edge.
- When a user's BLL tests need a database, name this as the symptom and suggest repository interfaces owned by the business layer.
- Keep layers distinct from tiers: multi-project does not imply multiple deployables.
- Limit references to Infrastructure types to the composition root.
- Reject all-in-one folder layouts past toy size.
