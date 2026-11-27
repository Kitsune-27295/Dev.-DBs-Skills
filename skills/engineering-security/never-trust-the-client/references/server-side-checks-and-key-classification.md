# Server-side checks and key classification

Sources: video chapter "Por que você não deve confiar no usuário" (13:26-20:32, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "3. Nunca confie no cliente" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## Framing

"Client" means everything on the user's side: browser, app, bundle. The video's rule of thumb: run the backend as if the front end did not exist. Front-end validation depends on the user's good manners; the server decides. The speaker adds that AI-generated apps often treat the backend as a bare database and leave rules on the client (his observation, not measured).

## Own examples

```text
// Client sends { plan: "pro", price: 1 }   -> reject: price is not an input
// Server: price = catalog.lookup(plan); charge(price)
```

Rotation: a key that has already been bundled must be treated as leaked even if removed now.
