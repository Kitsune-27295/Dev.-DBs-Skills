# MVP, Humble View and Testability of the Presentation Layer

Sources: https://martinfowler.com/eaaDev/uiArchs.html · https://engsoftmoderna.info/cap7.html · https://developer.mozilla.org/en-US/docs/Glossary/MVC · Last verified 2026-11-23

## Why variants exist

Classic observer-based MVC makes flow hard to trace and leaves view logic (colour of a negative number, enable/disable) without a home. Fowler's survey shows the variants as different answers to "who updates the widgets, and where does view state live?" The Fowler page notes his descriptions rely on common summaries rather than exhaustive historical study, so read the names as patterns, not as history.

## Variants

| Pattern | Who drives widgets | Testing consequence |
|---|---|---|
| Presentation Model (MVVM family) | Widgets bind to an intermediate model that holds view state and behaviour | Logic testable without UI; a small binding/mapping risk remains in the widgets |
| MVP, Supervising Controller | View handles simple declarative mapping; presenter handles complex cases | Between the two extremes |
| MVP, Passive View | Presenter sets every widget; view has no logic | Removes mapping risk, but needs a test double for the view |
| Application Model (VisualWorks) | Intermediate model with value holders and change events | Letting it update widgets directly is the workaround that motivated MVP |

**Humble View principle**: make the code that is hard to test (widgets, rendering) so thin that it cannot hide bugs, and move decisions to testable objects.

## Choosing

- Heavy view behaviour, binding available: Presentation Model.
- Complex screen logic, weak binding, strong need for tests: Passive View.
- Moderate: Supervising Controller.
- Server-rendered pages: the template is already the humble view; keep logic in controller and model (MDN and Valente describe the web flow this way).

MDN lists MVP, MVVM and MVW as MVC descendants; treat the choice as which side owns view state.

## Failure modes

- A presenter that imports concrete widget classes (cannot be unit tested).
- Presentation Model that reaches for domain persistence directly.
- View containing conditionals that encode business rules ("if total > 100 then hide discount").
- Over-mocking the view in a Passive View design until tests assert only call order.

## Example: presenter with a fake view (my sketch)

```
class CartPresenter {
  constructor(view, cart) {...}
  onAdd(name, qty) {
    this.cart.add(name, qty)               // model rule
    this.view.showTotal(this.cart.total()) // dumb view call
  }
}
// test: fakeView.showTotal = spy; presenter.onAdd("tea", 2); expect(spy).toHaveBeenCalledWith(7.0)
```

## How an agent should apply this

- When asked to make a UI testable, extract decisions into a presenter or presentation model and shrink the view to assignments.
- Name the chosen variant and state who owns view state.
- Test presenters against fake views; test the model without any view; keep a few end-to-end checks for the binding glue.
- Reject business rules inside templates or widget event handlers; move them to the model.
