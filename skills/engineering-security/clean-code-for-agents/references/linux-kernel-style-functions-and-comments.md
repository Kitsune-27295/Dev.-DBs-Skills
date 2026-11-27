# Linux Kernel Coding Style: Functions, Naming, Exits

Sources: https://docs.kernel.org/process/coding-style.html (chapters 1, 4, 6, 7, 8, 16, 22 read; chapter 8 is summarized in the comments file) · Last verified 2026-11-27

License note: the kernel documentation is under the GPL; this file paraphrases and quotes at most a few words. The guide is written for C kernel code, so each rule is tagged as transferable or C-specific.

## What the guide says (paraphrased)

**Indentation depth (ch. 1).** Its rationale for wide indents is that deep nesting becomes uncomfortable, and it says that needing more than three indentation levels means the code should be fixed. Also: no several statements on one line, no tricky expressions, no multiple assignments per line. The 8-character tab itself is a C/kernel convention; the nesting warning transfers.

**Naming (ch. 4).** Global names must be descriptive (a counting function should read as "count active users", not an abbreviation). Local names should be short and to the point: a loop counter is fine as `i`, a temporary as `tmp`. Encoding the type into the name (Hungarian notation) is called pointless because the compiler knows types. If you fear mixing up local names, the function has grown too big. Length of a name should follow the length of its scope.

**Function size (ch. 6).** Functions should be short, do one thing, and fit one or two screens. The allowed length is inversely related to complexity and nesting: a long but flat case-statement may be long; a complex function should stay within limits. The guide sets **no line count**, only "one or two screenfuls" (it cites 80x24). Use helper functions with descriptive names.

**Local variable count (ch. 6), exact limit as stated:** they "shouldn't exceed 5-10". Above that, rethink and split. Rationale given: humans track about seven things.

**Centralized exiting (ch. 7).** When a function has several exit points that share cleanup, a `goto` to a named label avoids duplicated cleanup and nesting; with no cleanup, return directly. Name the label for what it does (`out_free_buffer`), not `err1`. Watch the one-label bug where cleanup assumes something was allocated. C-specific mechanism; the principle (one cleanup path, no duplicated cleanup) maps to `try/finally`, `defer`, context managers, RAII.

**Return conventions (ch. 16).** A function named as a command returns an error code; one named as a predicate returns a boolean "succeeded". Mixing the two causes hard bugs. Transferable idea: name and return type must agree (`is_valid` returns bool, `parse_x` signals failure).

**Crashing (ch. 22).** The guide discourages halting the whole system and prefers a warning with recovery. Transferable as: do not abort a process for a recoverable condition; reserve crashes for corruption.

## Comments (ch. 8): pointer only

Chapter 8 is read and merged into [comments-why-not-what.md](comments-why-not-what.md), the single home for comment rules (kernel position: contract at the head of a function, never the mechanism; Google position: why). Their disagreement and its resolution are decided there.

## Example: flat control flow and one cleanup path

```python
def import_file(path):
    f = open(path)
    try:
        rows = parse(f)
        if not rows:
            return 0          # early exit, nothing to clean beyond f
        return store(rows)
    finally:
        f.close()             # single cleanup path
```

## How an agent should apply this

- Keep functions to what a reader sees at once; the kernel's numbers (FN-02) are a heuristic for C kernel code, not a law elsewhere.
- Long flat dispatch is acceptable; long nested logic is not. Judge by nesting and branching, not raw lines.
- Give local names short, scope-appropriate names; give widely used names descriptive ones; never add type prefixes.
- Express cleanup once (`finally`, `defer`, `with`), never duplicated on each return path.
- Make a name's grammar match its return value: commands signal failure, predicates return booleans.
- For comments, follow the comments file (CM rules).
