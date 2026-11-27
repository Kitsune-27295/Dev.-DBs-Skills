# C4 as Docs-as-Code: the architecture-docs Pipeline

Sources: https://github.com/milanm/architecture-docs · Last verified 2026-11-23

## What the repository demonstrates

An example documentation set combining the **arc42** template with the **C4 model**, with the model defined in **Structurizr DSL** and prose in **AsciiDoc**. License Apache-2.0.

## Layout

- `src/docs/structurizr/`: `structurizr.dsl`, properties, generated PlantUML.
- `src/docs/asciidoc/`: `index.adoc` including one file per arc42 section under `sections/` (for example `01_introduction_and_goals.adoc`).
- `docker-compose.yml`, `docToolchainConfig.groovy`, `build/docs`, `images`, and GitHub workflows (the README mentions deploy to GitHub Pages and to Confluence; the exact folder is ambiguous in the README).

## Pipeline

1. Model the system once in the Structurizr DSL.
2. Structurizr CLI exports PlantUML diagrams (run through Docker Compose).
3. Asciidoctor builds HTML from the AsciiDoc sources and embeds the diagrams.
4. Serve locally with Nginx or publish through CI.

## Caveat on arc42 to C4 mapping

The existing skill states a mapping (context to C1, building blocks to C2/C3, runtime to dynamic, deployment to C4 deployment). The README itself does not spell that mapping out; it shows one file per arc42 section and one DSL model. Treat the mapping as a sound convention (inference), not as something the repo documents.

## Why model-as-code helps

One model feeds many views, so renaming a container updates every diagram; diagrams are reviewable as text diffs; regeneration in CI stops drift. Trade-offs: toolchain setup (Docker, Java-based CLI), layout control is weaker than hand-drawn diagrams, and the DSL is one more thing to learn.

## Example: minimal Structurizr DSL (own sketch)

```
workspace {
  model {
    user = person "Customer"
    shop = softwareSystem "Shop" {
      api = container "Orders API" "Handles orders" "Node.js"
      db  = container "Orders DB" "Stores orders" "PostgreSQL"
      api -> db "Reads/writes" "SQL"
    }
    user -> api "Places orders" "HTTPS"
  }
  views { container shop { include * autolayout lr } }
}
```

## How an agent should apply this

- Prefer a text model (Structurizr DSL or equivalent) over drawn images when the user wants maintainable diagrams.
- Keep model, sections and generated output in separate folders; commit sources, not generated artifacts, unless publishing needs them.
- Add a CI job that regenerates diagrams and fails on DSL errors.
- Reference diagrams from the matching arc42 section instead of duplicating text.
- State clearly which mapping choices are conventions rather than repo-documented facts.
