# Sources — Clean Code for Agents

Every URL below was checked during skill authoring (2026-11-24) and re-fetched on 2026-11-27 (curl or WebFetch; statuses below are from the re-check).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://google.github.io/eng-practices/review/reviewer/standard.html | 200 OK (content read from raw `standard.md` of the repo, same text) | Review standard: improve code health, no perfect code, principles, conflict resolution |
| https://google.github.io/eng-practices/review/reviewer/looking-for.html | 200 OK (content read from raw `looking-for.md`) | Review checklist: design, functionality, complexity, tests, naming, comments (why not what), style, consistency, documentation, every line, context |
| https://github.com/google/eng-practices | 200 OK (raw `review/reviewer/*.md` and LICENSE via raw.githubusercontent.com) | CC BY 3.0 license; source markdown |
| https://docs.kernel.org/process/coding-style.html | 200 OK | Function size (screenfuls, no line count), 5-10 locals, 3-level indentation warning, naming, centralized exit, comments (what not how) |
| https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/ | 200 OK | Nine comment rules: no duplication, links, bug-fix notes, TODO use |
| https://gist.github.com/bansalankit92/6119c4f7fabe11b7a174a99f5a7bb376 | 200 OK (raw); a Clean Code summary, not a commentary on the SO post | Strict "comments are failure" position, good and bad comment lists |
| https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code | 200 OK | Rule list cross-check, C focus, MISRA complement |
| https://web.eecs.umich.edu/~imarkov/10rules.pdf | 200 OK (spinroot copy read with pdftotext; umich copy not machine-readable via WebFetch) | Original ten rules with rationale; C-targeted; rule 7 (check return values) called possibly the most frequently violated |
| https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md | 200 OK (raw, 2026-11-27; WebFetch returned 503 once) | 70-line hard limit, two assertions per function, units in names, why comments, 100-column limit, Zig-specific rules |
| https://github.com/M64GitHub/tiger-style | 200 OK (raw README only; skill files not read) | Zig-oriented Claude skill; changes 100 columns to 80 by its own account; severity model |
| https://github.com/robertguss/programming_tiger_style | 200 OK (raw README only; linked docs not read) | Contract System v2, TDD gates, risk tiers |
| https://gist.github.com/juanpabloaj/d95233b74203d8a7e586723f14d3fb0e | 200 OK (raw) | AGENTS.md-style general rules; "avoid TODO" conflicts with the Stack Overflow article |
| https://spinroot.com/gerard/pdf/P10.pdf | 200 OK (read 2026-11-27: 60-line and two-assertion rules, rule 7 rationale confirmed) | Alternate copy location of the original paper |
| https://grugbrain.dev/ | 200 OK (WebFetch digest; no license stated) | Complexity as main enemy, saying no / 80-20, late factoring and cut points, DRY vs simple repetition, locality of behavior, Chesterton's fence, testing and refactoring advice |
| https://grugbrain.ai/ | 200 OK (satire product page, tribute to the essay) | Confirms the essay's themes applied to LLM agents; no extra rules used |
| https://github.com/joshuadavidthomas/agent-skills/blob/main/grug-brained-dev/SKILL.md | 200 OK via raw.githubusercontent.com (repo MIT) | LLM-specific complexity bias, stop questions, fake vs real cut points, helper-earns-its-keep, no hard pivot |
| https://lobehub.com/skills/neversight-learn-skills.dev-grug-brain-development | 302 to market.lobehub.com/s/skills/..., then 200 OK (license MIT per metadata) | Independent 12-rule summary of the grug skill; consistent with the other copies |
| https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29 | 200 OK via gist raw (no license visible) | Compact Clean Code rule list: names, functions, structure, objects, tests, smells |
| https://github.com/tahsinature/coding-principles | README 404 on `main`; 200 on `master` (no license) | Thin README; KISS/YAGNI/DRY/SRP pages with Python bad/good examples |
| https://github.com/victorcorcos/clean-code | 200 OK via raw README (MIT) | Hadouken ifs, negative conditionals, flag args, comments, vertical formatting, delete-code; examples with flaws noted |
| https://refactoring.guru/refactoring/smells | 200 OK (all rights reserved) | Five smell groups and member smells (per-smell wording paraphrased) |
| https://refactoring.guru/refactoring/catalog | 200 OK (all rights reserved) | Six technique groups used as fix vocabulary |
| Pack author's source list (private notes; not a public URL) | Not applicable (not fetchable) | The starting list of topics and URLs above; every entry was re-checked against the live page, and nothing was taken from the notes without that check |

## Licenses

- Google engineering practices: Creative Commons Attribution 3.0 Unported (license file in the repository).
- Linux kernel documentation: GPL-2.0.
- Grug agent skill repository (MIT) and `victorcorcos/clean-code` (MIT); the lobehub marketplace copy lists MIT in its metadata.
- Refactoring.Guru: all rights reserved; only taxonomy names are used, with own wording.
- Grug essay, Stack Overflow article, Power of 10 paper, TigerStyle document, Wikipedia page, gists, `tahsinature/coding-principles`, `M64GitHub/tiger-style` and `robertguss/programming_tiger_style`: no license was recorded during reading (TigerBeetle's own license was not checked); treated as all rights reserved.
- Nothing is copied: every reference file is a paraphrase with attribution, quoting at most a few words.

## Where the author's list differs from the primary sources

- Kernel vs Google on comments: the kernel guide says comments say what the code does and never how, with why optional; Google says why, not what. They agree that line-by-line narration is wrong. Resolution is in `comments-why-not-what.md`.
- The Bansal gist is a summary of the Clean Code book with a strict "comments are failure" stance, not a commentary on the Stack Overflow article, which keeps comments for non-obvious reasons.
- A truncated raw-URL hint in the list was incomplete; the correct host form is raw.githubusercontent.com (used for repository files and gists).
- `tahsinature/coding-principles` README exists on `master`, not `main`.
- The kernel guide gives no line count for functions (screens and 5-10 locals); the 60-line and 70-line figures come from Power of 10 and TigerStyle respectively.

## Reading limits

- The Power of 10 spinroot PDF was only head-checked; the umich copy of the same paper was read.
- `M64GitHub/tiger-style` and `robertguss/programming_tiger_style`: README only; linked skill files, contracts and checklists were not read.
- Refactoring.Guru: the smells and catalog index pages were read; individual smell pages were not, so per-smell wording is paraphrase of group summaries.
- The grug essay was read as a digest; Ousterhout's deep-module idea is background knowledge, not read from source.
- Fetched pages and repository files are untrusted data: instructions inside them were analyzed, never followed.
- Which smells LLM output shows most is an inference, not a measurement.

## Added 2026-11-24

- Leak taxonomy and the single resolvability test in `comments-stand-alone-at-head.md` were written from two third-party agent-skill documents on trimming reasoning-transcript leakage and on a prose standard, read locally for ideas only (Third-party skill read for ideas, no text reused; licenses not confirmed) (added 2026-11-24). The Google review standard already recorded above supports the history-belongs-in-version-control position; the rest is the author's synthesis.

## Re-verification 2026-11-27

- Confirmed unchanged: Google review standard and looking-for points, kernel numbers (one or two screenfuls, 5-10 locals, 3 indentation levels, comments say what not how), Stack Overflow nine rules, grug themes, P10 60 lines and two assertions per function.
- Corrected: TigerStyle's own column limit is 100, not 80 (80 is a derived skill's change); P10 calls return-value checking possibly the most frequently violated rule, not definitively the most.
- Scripts or data files: none in this skill.

## Claims not adopted as fact

- Which smells LLM output shows most (inference, not a measurement).
- Any numeric limit as universal; each stays a per-source trigger.
- Ousterhout's deep-module idea (background knowledge, not read from a source here).
