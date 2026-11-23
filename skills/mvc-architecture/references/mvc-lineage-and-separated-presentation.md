# MVC Lineage and Separated Presentation

Sources: https://martinfowler.com/eaaDev/uiArchs.html · https://martinfowler.com/eaaCatalog/modelViewController.html · https://engsoftmoderna.info/cap7.html · Last verified 2026-11-23

## What MVC actually is

Fowler frames MVC as two principles more than a class diagram:

1. **Separated Presentation**: domain objects know nothing about the UI; presentation code reads and drives the domain.
2. **Observer Synchronization**: presentation state stays in sync with the model through change notifications.

The PoEAA catalog entry gives the one-line definition (splitting UI interaction into three roles) and dates the origin to Reenskaug's Smalltalk work in the late 1970s. Fowler calls MVC one of the most quoted and most misquoted patterns. Valente adds that many Smalltalk versions never separated View from Controller, so "view plus controllers" was often one interface component: MVC = (View + Controllers) + Model.

## Roles (Valente's concrete examples)

- **Model**: domain data and methods that change it; no knowledge of View or Controller.
- **View**: windows, buttons, lists, anything shown.
- **Controller**: interprets input events and then either asks the Model to change state or asks the View to change appearance (a "+" calculator key hits the Model; a "Dark UI" button hits the View).

## Event flow

1. User acts. 2. Controller captures the event. 3. Controller calls the Model (or the View for presentation-only changes). 4. Model changes state. 5. The observing View refreshes.
The dependency arrow points one way: interface depends on Model, Model never on interface.

## Why it earned its place (Valente, Fowler and Beck's view)

- Specialisation: UI developers and domain developers work apart.
- Multiple views of one model (hours and minutes stored once, drawn as analog and digital clock).
- Testability: non-visual objects test without a screen.

## Fowler's comparison of GUI styles (running ice-cream form example)

| Style | Where logic lives | Weakness |
|---|---|---|
| Forms and Controls (VB, Delphi style) | Event handlers in the form; three copies of data: record, session, screen state | Logic tangled with widgets |
| Smalltalk MVC | Domain in model, widget pairs of view and controller | Observer flow is hard to trace from code; view logic such as colour has no obvious home |
| VisualWorks Application Model | Intermediate application model with value holders and change notification | Letting it poke widgets directly fed the move to MVP |
| MVP | Presenter coordinates model and widgets | Variants differ in how much the view does |
| Presentation Model (also MVVM) | Intermediate model holds view state and behaviour | Small mapping to widgets stays untested |

Where to put view-only logic: a custom control, or an intermediate Presentation Model (Fowler's suggestion).

## Failure modes

- Fat model that imports UI types (breaks Separated Presentation).
- Controller holding business rules, so a second UI must copy them.
- Treating "MVC" as a folder layout without the dependency direction.
- Hidden observer chains that nobody can trace.

## Example: the invariant in four lines (my sketch)

```
model.items.push(x)              // model: no import of view or controller
view.render(model.items)         // view: reads model, no business rules
controller.onAdd = e => model.add(parse(e))   // controller: translate, delegate
```

## How an agent should apply this

- Check the dependency arrow first: model imports nothing UI; view imports model types only to read.
- Put rules in the model, input translation in the controller, formatting in the view.
- For view-only state (sort order, collapsed panel), keep it out of the domain model: controller-to-view, or a presentation model.
- When a bug report says "MVC", ask which strand (classic observer or request/response web) is in play before editing.
