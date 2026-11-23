# Spring Modulith: Module Structure, Visibility and Verification

Sources: https://docs.spring.io/spring-modulith/reference/index.html · https://docs.spring.io/spring-modulith/reference/fundamentals.html (v2.2.0) · Last verified 2026-11-23

## Module model
A module has a provided interface (Spring beans and events it publishes), internals others must not touch, and a required interface (beans it uses, events it listens to, config properties). Build the model with `ApplicationModules.of(Application.class)`; exclude packages with ArchUnit predicates.

## Detection
- **Simple**: each direct sub-package of the `@SpringBootApplication` package is a module; package-private types hide internals; public types are API.
- **Advanced** (module has sub-packages): the base package is the API; sub-packages (e.g. `internal`) are off limits. Types the API depends on must be public, so the compiler cannot catch illegal references to them; that is what verification is for.
- **Nested modules** (1.3+): `@ApplicationModule` in a sub-package's `package-info`; reachable only from the parent and nested siblings; nested code may use parent internals.
- Detection can be limited to explicitly annotated packages (`spring.modulith.detection-strategy=explicitly-annotated`).

## Controlling dependencies
- `@ApplicationModule(allowedDependencies = "order")` restricts what a module may reference.
- `@NamedInterface("spi")` exposes extra packages. Syntax: `"order"` base only; `"order :: spi"` that interface; `"order :: *"` all named interfaces but not base; `"order :: **"` base plus all.
- `@ApplicationModule(type = OPEN)` lets others reach internals; meant for gradual migration of legacy code; in a fully modular app it signals poor structure.
- `@Modulithic` sets `systemName`, `sharedModules`, `additionalPackages`.

## Verification
`modules.verify()` enforces: only the API is referenced, internals unreachable (unless open), `allowedDependencies` honored. The detailed rules live on the verification page, which was not read here.

## Example
```java
@ApplicationModule(allowedDependencies = {"order", "catalog :: spi"})
package example.inventory;
// test: ApplicationModules.of(Application.class).verify();
```

## How an agent should apply this
- Put `verify()` in a unit test from day one; it is the boundary guard.
- Keep modules simple; use named interfaces only for deliberate SPIs.
- Declare `allowedDependencies` for modules that must stay decoupled, so a new import fails the build.
- Use OPEN only as a temporary migration marker with a removal task.
- Remember the API's dependent types must be public; review them manually.
