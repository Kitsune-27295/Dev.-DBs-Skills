# C4 as Docs-as-Code: One Example Pipeline

Sources: https://github.com/milanm/architecture-docs · Last verified 2026-11-27

## What the repository shows

An example documentation set that uses arc42 for structure and the C4 model for views, with the model in Structurizr DSL and prose in AsciiDoc. License: Apache-2.0.

## Layout

- `src/docs/structurizr/`: the DSL file, properties and generated PlantUML.
- `src/docs/asciidoc/`: an index that includes one file per arc42 section under `sections/`.
- Also `docker-compose.yml`, `docToolchainConfig.groovy`, `build/docs`, `images`, and workflows (GitHub Pages and a Confluence deploy). The README's directory tree and the actual workflow folder disagree, so the tree may be stale.

## Pipeline

1. Model the system once in Structurizr DSL.
2. Structurizr CLI exports PlantUML (run via Docker Compose).
3. Asciidoctor builds HTML from the AsciiDoc and embeds the diagrams.
4. Serve locally with Nginx or publish through CI.

## Not documented by the repo

The README does not map arc42 sections to C4 levels. The mapping used in this pack lives in `arc42-api-contracts-architecture`; treat it as a convention, not as something this repo states.

## Why model-as-code helps (reasoning, not a repo claim)

One model can feed many views, so a rename propagates; text diffs make diagrams reviewable; regeneration in CI limits drift. Costs: toolchain setup, weaker layout control, one more language to learn.

## Example: minimal Structurizr DSL (own sketch, not run)

```
workspace {
  model {
    user = person "Customer"
    shop = softwareSystem "Shop" {
      api = container "Orders API" "Handles orders" "Node.js"
      db  = container "Orders DB" "Stores orders" "PostgreSQL"
      api -> db "Reads and writes" "SQL"
    }
    user -> api "Places orders" "HTTPS"
  }
  views { container shop { include * autolayout lr } }
}
```

## How an agent should apply this

- Prefer a text model over drawn images when maintainable diagrams are wanted.
- Keep model, prose and generated output in separate folders; commit sources, not generated files, unless publishing needs them.
- Add a CI step that regenerates diagrams and fails on DSL errors.
- Reference diagrams from the matching arc42 section instead of duplicating text.
