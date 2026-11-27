# Security audit: report and issue drafts

Last verified 2026-11-27. No external source: the structure below is this skill's own convention.

Format of the deliverable of `security-audit`. Read it after the audit and before writing the report.

## Report contents

1. **Cover:** title "Security Audit Report: <project name>", date, audited scope, method note (how each class was mapped to the detected stack).
2. **Executive summary:** findings per severity, a donut chart by severity, a bar chart by category. Suggested palette: critical `#B91C1C`, high `#EA580C`, medium `#D97706`, low `#2563EB`, strength `#059669`.
3. **Strengths** (what is protected, with evidence) and **weaknesses** (the central risks).
4. **Detailed findings** per category: severity chip, `file:line`, description.
5. **Prioritized recommendations** (P1, P2, P3...).
6. **Issues for the tracker**, last section: the full text of one issue per actionable finding, each inside a delimited block (`--- ISSUE n ---` ... `--- END ISSUE n ---`).

## One issue

- Title `[Security] <short description of the flaw>`
- Suggested labels: `security` plus the severity
- Problem and why it is exploitable
- Evidence: `file:line` with snippet
- Impact
- Suggested fix
- Acceptance criteria (a verifiable checklist)

Group trivial related findings into one issue (for example several secret defaults on one theme) so the tracker is not spammed.

## Producing a PDF (when a PDF is requested; Markdown is the fallback)

- Install nothing globally: use an isolated environment (a Python venv with `reportlab` and `matplotlib`, or the stack's equivalent; headless browser, wkhtmltopdf or pandoc are fine for HTML to PDF).
- Keep the generator script next to the report so it can be rebuilt.
- Verify the file: page count, charts rendered, tables legible (rasterize the pages when possible) and fix visual defects before delivering.
- A4, margins about 2 cm, header and footer with the report name and page number.

Deliver the report, the findings list in chat (file by file, line by line) and the path of every generated file.
