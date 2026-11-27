# GitHub Rendering, Copilot Workflow, and `mmdc` Validation

Sources: https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams · https://docs.github.com/en/copilot/tutorials/copilot-cookbook/communicate-effectively/creating-diagrams · https://github.com/mermaid-js/mermaid-cli · Last verified 2026-11-27

## GitHub rendering
- Mermaid renders in Issues, Discussions, pull requests, wikis and Markdown files when placed in a fenced block with the `mermaid` identifier. GitHub also renders `geojson`, `topojson` and `stl` fences.
- To learn GitHub's Mermaid version, create a `mermaid` block containing only `info`. Use this before relying on recent syntax (`-beta` types, v11.x/v12.x features).
- Documented limitation: errors may appear if a third-party Mermaid plugin runs alongside GitHub's own rendering.
- The page does not list which diagram types or config options GitHub supports; the version check is the evidence path.

## Copilot Chat cookbook workflow (Gantt example)
The cookbook asks Copilot Chat for a Gantt diagram and pastes the result inside a ```` ```mermaid ```` fence. Take-aways:
1. Give concrete details (phases, durations, date range) in the prompt.
2. Responses are non-deterministic; always re-check the output.
3. The fence is required for rendering.
4. The page's own example prompt contains a date inconsistency (an August 2025 start with a January 2025 end), a reminder to verify generated dates against requirements. The generated chart used `dateFormat`, `axisFormat`, `section`, and `name :id, start, 42d` task lines.

## `mmdc` (mermaid-cli)
Install: `npm install -g @mermaid-js/mermaid-cli`, local install with `./node_modules/.bin/mmdc -h`, or one-shot `npx -p @mermaid-js/mermaid-cli mmdc -h`. Docker image: `minlag/mermaid-cli` (mount a folder to `/data`; Podman needs `--userns keep-id` and the `:z` volume suffix). Homebrew is no longer supported.

| Task | Command |
|---|---|
| Render | `mmdc -i input.mmd -o output.svg` |
| Dark transparent PNG | `mmdc -i input.mmd -o output.png -t dark -b transparent` |
| stdin | `... \| mmdc --input -` |
| Markdown transform | `mmdc -i readme.template.md -o readme.md` (each mermaid block becomes an SVG reference; `accTitle`/`accDescr` become alt text and title) |
| Custom CSS | `--cssFile file.css` (named in the README; its behavior is not detailed there) |
| Output size | `--size` (named in the README example; effects per diagram type are not documented there) |
| Icon packs | `--iconPacks @iconify-json/logos` or `--iconPacksAndUrls logos#<url or file://>` |
| All flags | `mmdc -h` |

Docker: `docker run --rm -v /path/to/diagrams:/data minlag/mermaid-cli -i diagram.mmd`. The repository also ships a `puppeteer-config.json`; the README read did not describe it. Node API: `import { run } from "@mermaid-js/mermaid-cli"; await run("input.mmd", "output.svg");` and it is not covered by semver.

## Validation implications (own reasoning)
- A successful `mmdc` run proves the CLI's bundled Mermaid version can parse the diagram, not that GitHub's version can. Run the `info` check on the target host when version-sensitive syntax is used.
- `mmdc` renders through a headless browser (inference; the README read does not say so): on locked-down CI prefer the Docker image.
- Markdown-transform mode validates every fence in one pass, which is the cheapest way to check a docs folder.

## Failure modes
- Declaring a diagram "valid" after only reading it.
- Trusting model-generated syntax without a render (non-deterministic output).
- Third-party Mermaid browser plugin conflicting with GitHub's renderer.

## How an agent should apply this
- Prefer `npx -p @mermaid-js/mermaid-cli mmdc -i file.mmd -o out.svg` and report the exit status and any error text (exit codes are not documented in the README); if Node is unavailable say that only the manual checklist ran.
- For GitHub-bound diagrams, avoid features newer than what the `info` block reports, or tell the user to run it.
- When asking Copilot or another model for a diagram, supply exact entities and dates, then verify them against the source.
- Use markdown-transform mode to validate all fences in a document at once.
- Keep generated SVG/PNG out of the repo unless asked; the `.mmd` or fence is the source of truth.
