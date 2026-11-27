# Sources: Microkernel / Plug-in Architecture

Every URL below was re-fetched on 2026-11-27 with WebFetch (Firecrawl had no credits).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://quality.arc42.org/approaches/plugin-architecture | 200 OK | Intent, mechanism, isolation dial, four failure modes, verification recipe (compliance suite, chaos plugin, 100 load/unload cycles, p99 alert at 10 percent), use and skip rules, neighbors, battery-driver example |
| https://csse6400.uqcloud.net/handouts/microkernel.pdf | 200 OK, PDF (dated 9 March 2026, last updated 2023-03-04); the fetch summarizer could not read it, so the text was extracted locally and read | Four elements, Independent Plug-in, Standard Interface and Domain Standard Interface principles, payroll example and `adjustPay` interface, technical vs domain partitioning, distributed microkernel, REST/RMI contracts, plug-in databases, adapter plug-ins |
| https://github.com/ahmedhammad97/Software-Architecture-Patterns-Notes | 200 OK; personal notes repository (secondary) | Registry requirement, plug-in communication options, dependency concern; ratings are an image and not read |
| https://software-architecture-guild.com/guide/architecture/fundamentals/architecture-styles/ | 200 OK | Microkernel grouped under monolithic styles, ideal for customizable product platforms, warning on plug-in dependency management |

## Reading limits

- The Hammad ratings comparison is an image; no rating is adopted.
- Whether the Hammad notes derive from Richards's booklet was not confirmed from the page text.
- The code sketches are my own and were not executed.

## Claims not adopted as fact

- Microkernel as the "limiting case where even built-in features are plugins" attributed to Richards and POSA (earlier draft): not on the pages read.
- Extension hooks and marketplaces as arc42 neighbor approaches (earlier draft): not listed on the page.
- ServiceLoader and Python entry points as arc42 mechanisms (earlier draft): the page names none; they stay as general practice.
- High evolutionary-design ratings and lower scalability for single-process hosts (earlier draft): the ratings were not readable.
- Sandbox examples (child process, WASM, container), memory caps and per-call timeouts: the skill's own advice, not sourced.
