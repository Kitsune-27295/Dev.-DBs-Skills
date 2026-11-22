---
name: diataxis-documentation-architecture
description: Use when structuring, writing, auditing, or refactoring technical documentation using Daniele Procida's Diátaxis framework — organizing documentation into the 4 distinct user-need quadrants (Tutorials, How-to Guides, Reference, Explanation) mapped across Action vs Cognition and Acquisition (Study) vs Application (Work). Gives the Diátaxis Compass, quadrant rules, and anti-contamination fixes.
---

# Diátaxis (Technical Documentation Information Architecture)

One idea: documentation rots and confuses readers when a single page tries to teach a beginner, solve an advanced task, list every CLI flag, and debate design philosophy all at once — fix it by separating documentation into **four distinct quadrants** (**Tutorials**, **How-to Guides**, **Reference**, **Explanation**) defined by two axes of user need: **Action vs. Cognition** and **Acquisition (Study) vs. Application (Work)**. Sources and their claims: [references/sources.md](references/sources.md).

## The Diátaxis Map & Compass (Daniele Procida)

| Quadrant | Axis 1: Mode | Axis 2: Context | User's Question | Real-World Analogy |
|---|---|---|---|---|
| **1. Tutorials** | Practical (**Action**) | **Study** (Acquisition of skill) | *"I am new — can you take me by the hand through a safe lesson so I gain confidence?"* | A driving lesson with an instructor |
| **2. How-to Guides** | Practical (**Action**) | **Work** (Application to a goal) | *"I already know the basics — what steps solve this specific real-world problem?"* | A recipe for a dish or a GPS route from A to B |
| **3. Reference** | Theoretical (**Cognition**) | **Work** (Application while coding) | *"What are the exact facts, flags, signatures, error codes, and constraints?"* | An encyclopedia map or dictionary entry |
| **4. Explanation** | Theoretical (**Cognition**) | **Study** (Acquisition of understanding) | *"Why was it designed this way, what are the trade-offs, and how do the concepts connect?"* | A book on culinary history or architectural theory |

### Using the Diátaxis Compass (When unsure where a section belongs)
Ask two questions about the sentence or page you are writing:
1. **Does this inform the reader's *Action* (steps to do) or *Cognition* (knowledge/thinking)?**
2. **Does it serve their *Acquisition/Study* (learning) or their *Application/Work* (getting a job done)?**
   - Action + Study $\to$ **Tutorial**
   - Action + Work $\to$ **How-to Guide**
   - Cognition + Work $\to$ **Reference**
   - Cognition + Study $\to$ **Explanation**

## Strict Rules per Quadrant (Preventing Quadrant Contamination)

### 1. Tutorials (Learning-Oriented Lessons)
- **The author is responsible for the learner's safety and guaranteed success:** Every command must produce a concrete, visible, repeatable result on the first try.
- **No branching choices or edge-case alternatives:** Never write *"You can also use Postgres, MySQL, or SQLite here, or pass `--flag-x`..."* inside a Tutorial. Pick one paved path and guide the learner straight through it.
- **Teach through doing, not lecturing:** Keep conceptual explanations out of the tutorial; link to an **Explanation** page at the end instead.

### 2. How-to Guides (Goal-Oriented Recipes)
- **Assume competence and start from a clear real-world goal:** Title it *"How to configure zero-downtime webhook retries"*, never *"Webhook configuration"*.
- **Focus strictly on the steps to achieve the outcome:** Omit beginner onboarding lessons (that's a **Tutorial**) and omit exhaustive lists of every possible parameter (link to **Reference**).
- **Allow real-world conditional branching:** Unlike a tutorial, a How-to Guide addresses real work environments (*"If deploying behind a VPC proxy, set X; otherwise set Y"*).

### 3. Reference (Information-Oriented Facts)
- **Austerity, neutrality, and structural consistency:** Reference pages describe the machinery as it is — CLI commands, API endpoints, configuration schemas, error codes, limits, and defaults.
- **Mirror the structure of the codebase/API:** Organize Reference in the same hierarchy as the product's modules, commands, or packages so a developer at work can look up a symbol in 5 seconds.
- **Never instruct or philosophize:** Do not embed multi-step workflow narratives or long design justifications inside a Reference table; link out to How-to Guides and Explanations.

### 4. Explanation (Understanding-Oriented Discussion)
- **Answer "Why?", explore trade-offs, alternatives, and background context:** This is where architectural overview, design rationale, historical context, and ADRs (`adr-architecture`) live.
- **No step-by-step instructions or exhaustive API tables:** An Explanation can be read away from the keyboard (on a train or before reviewing a system).

## Iterative Workflow (How to apply Diátaxis without a big-bang rewrite)

1. **Do not create 4 empty top-level folders and freeze:** Procida warns against top-down structural paralysis. Start from the piece of documentation you are editing right now.
2. **Apply the Compass to one page:** Identify which single quadrant the page *wants* to be.
3. **Extract contaminating blocks:**
   - If a **Tutorial** has a 500-word architectural digression in the middle, cut that block into an **Explanation** page and leave a 1-line link.
   - If a **How-to Guide** has a 40-row parameter table, move the table to **Reference** and link to it.
4. **Surface the four quadrants at the top level once content exists:** Organize your `README.md` or docs sidebar clearly around:
   - `Tutorials` (Getting Started / First Steps)
   - `How-to Guides` (Task & Operations Playbooks)
   - `Reference` (CLI, API, Configuration, Schemas)
   - `Explanation` (Architecture, Concepts, ADRs)

## Verification checklist for any documentation PR

| Check | Failure symptom | Fix |
|---|---|---|
| Tutorial vs. How-to confusion | A "Tutorial" that assumes existing setup and jumps straight into an advanced edge case, or a "How-to" that spends 3 pages teaching basic installation | Split beginner lesson (`tutorials/`) from specific task recipe (`how-to/`) |
| Reference polluted with tutorial steps | An API/CLI reference page where the only way to find a flag's default value is reading a 10-paragraph story | Extract a clean, scannable Reference table with types, defaults, and constraints |
| Explanation hiding inside a Tutorial | A newcomer trying to run their first command is hit with 6 paragraphs explaining why the engine uses SQLite FTS5 instead of BM25 | Move the "Why" to `explanation/` |
| Vague headings | Headings like `Webhooks` or `Database` that don't signal which quadrant the page belongs to | Name by quadrant: `Tutorial: Build your first webhook`, `How to rotate webhook secrets`, `Webhook payload reference`, `Why webhooks use at-least-once delivery` |
