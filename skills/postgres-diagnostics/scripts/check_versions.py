#!/usr/bin/env python3
"""Check that the per-version script folders of a diagnostics skill stay in step. Standard library only; reads files, writes nothing.

    python scripts/check_versions.py <references dir> <folder prefix> <doc file> [<doc file> ...]

Example (from the skill folder): python scripts/check_versions.py references pg references/README.md

Every folder of <references dir> whose name starts with <folder prefix> is one version. The check fails when
  - a file exists in one version folder and not in another, unless a doc names it under a heading about differences or changes;
  - a file differs between versions (ignoring the leading `-- Target` comment lines), unless a doc names it there.
Only sections whose heading contains "differ" or "change" count, so listing a file in an index is not enough: the difference
between versions is always written down where a reader looks for it. Exit code 1 on failure.
"""

from __future__ import annotations

import pathlib
import re
import sys


def body(path: pathlib.Path) -> str:
    lines = path.read_text(encoding="utf-8").splitlines()
    while lines and lines[0].startswith("-- Target"):
        lines.pop(0)
    return "\n".join(lines)


def difference_sections(text: str) -> str:
    """Text of the Markdown sections whose heading mentions differences or changes."""
    parts = re.split(r"(?m)^(#{1,6} .*)$", text)
    kept = [parts[i + 1] for i in range(1, len(parts) - 1, 2) if re.search(r"differ|change", parts[i], re.I)]
    return "\n".join(kept)


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print(__doc__)
        return 2
    root, prefix, docs = pathlib.Path(argv[0]), argv[1], [pathlib.Path(p) for p in argv[2:]]
    folders = sorted(p for p in root.iterdir() if p.is_dir() and p.name.startswith(prefix))
    if len(folders) < 2:
        print(f"FAILED: fewer than two folders starting with {prefix!r} in {root}")
        return 1
    doc_text = "\n".join(difference_sections(p.read_text(encoding="utf-8")) for p in docs)
    files = {f.name: {p.relative_to(f).as_posix() for p in f.rglob("*.sql")} for f in folders}
    every = set().union(*files.values())
    problems: list[str] = []
    for rel in sorted(every):
        present = [f for f in folders if rel in files[f.name]]
        named = rel in doc_text or pathlib.PurePosixPath(rel).name in doc_text
        if len(present) != len(folders) and not named:
            problems.append(f"{rel}: only in {', '.join(f.name for f in present)}, and no doc names it")
            continue
        bodies = {body(f / rel) for f in present}
        if len(bodies) > 1 and not named:
            problems.append(f"{rel}: differs between versions, and no doc names it")
    for line in problems:
        print(f"  [FAIL] {line}")
    print(f"{'OK' if not problems else 'FAILED'}: {len(every)} file(s) across {len(folders)} version folder(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
