# Web MVC, SPAs and the Two Strands of MVC

Sources: https://developer.mozilla.org/en-US/docs/Glossary/MVC · https://engsoftmoderna.info/cap7.html · Last verified 2026-11-27

## Two strands (Valente)

- **Classic MVC** (1970s-80s): desktop GUIs; view observes model; one long-lived process.
- **Web MVC** (early 2000s: Spring, Rails, Django, CakePHP): the View is the HTML page, a Controller processes each request and generates a new View as the response, the Model persists to a database. It closely resembles a three-tier system, which is why people confuse MVC with tiers. Historically MVC was often used *inside* the interface tier of a three-tier system.

Shared invariant: the Model never depends on View or Controller.

## MDN's web-oriented definitions

- **Model**: data and business logic; states what the app contains; notifies view (sometimes controller) on change.
- **View**: layout and display.
- **Controller**: routes commands to model and view; holds logic that updates either in response to input.
- Two flows: (1) input -> controller -> model -> updated data -> view; (2) a display-only change (re-sort by price) where the controller updates the view directly without touching the model.
- On the web, model is often a database (server MySQL or client IndexedDB), controller is HTML/JS code, view is HTML/CSS.
- Evolution: early web did server-side MVC with full-page returns; now client-side stores and the Fetch API allow partial updates. AngularJS and Ember are MVC-style, each differently. Related: MVVM, MVP, MVW ("whatever").

## SPAs (Valente's Vue example)

Traditional apps round-trip per action and return a page. A single-page app loads HTML, CSS and JS once, updates in place and talks to the server asynchronously (Gmail's inbox is the example). In the temperature counter (starts at 60, button increments), the View and Controller sit in the template markup, the Model is a JS object with an increment method, and the framework propagates model changes to the view via **two-way data binding**.

Implication (my inference): in an SPA the MVC triad lives in the browser, and the server often becomes a JSON model service; you may have MVC twice (client and server) with different meanings of "controller".

## Where each concern lives

| Concern | Web MVC (server) | SPA |
|---|---|---|
| Routing and request parsing | Controller | Router plus client controller/handlers |
| Business rules | Model (server) | Server model for authority; client may duplicate for UX only |
| Rendering | Template as View | Component templates |
| Presentation state (sort, open tab) | Request/session | Client state, not the domain model |

## Failure modes

- Treating the client model as authoritative; rules must still be enforced server-side.
- Controllers that grow into service layers with SQL and rendering mixed together.
- Double-implemented validation that drifts between client and server.
- Calling a three-tier split "MVC" and then arguing about folder names.

## Example: request cycle (my sketch)

```
POST /notes  -> NotesController.create(req)
   cmd = parse(req.body)              // controller: translate input
   note = NoteModel.create(cmd)       // model: rules + persistence
   return render("note.html", note)   // view: HTML only
```

## How an agent should apply this

- Identify the strand (server request/response or client reactive) before suggesting structure.
- Keep controllers thin: parse, call model, choose view; push rules to the model.
- Keep sort/filter/open-state in the view layer or a presentation model, not the domain.
- In SPAs, enforce authority and validation on the server and treat the client model as a cache.
- If a UI framework offers two-way binding, still keep domain rules out of bound view objects.
