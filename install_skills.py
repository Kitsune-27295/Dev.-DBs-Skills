#!/usr/bin/env python3
"""Install the skills of this pack into a Claude Code skills folder, on Windows, macOS or Linux. Standard library only.

    python install_skills.py --project [DIR]    # DIR/.claude/skills (DIR defaults to the current folder)
    python install_skills.py --user             # ~/.claude/skills, for every project of this user
    python install_skills.py --target PATH      # any skills folder
    add --dry-run to see what would happen, --force to overwrite a skill that already exists and differs

Existing skills with other names are never touched. A skill that exists and differs is skipped unless you pass --force.
After copying, every installed file is compared with MANIFEST.sha256 of the pack. On Linux and macOS use `python3` if `python`
is not found. Exit code 1 when a file could not be installed or verified.
"""

from __future__ import annotations

import argparse
import hashlib
import pathlib
import shutil
import sys

PACK_DIR = pathlib.Path(__file__).resolve().parent
SOURCE = PACK_DIR / "skills"


def sha(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_hashes(folder: pathlib.Path) -> dict[str, str]:
    return {p.relative_to(folder).as_posix(): sha(p) for p in sorted(folder.rglob("*")) if p.is_file()}


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Install the skills of this pack.")
    where = parser.add_mutually_exclusive_group(required=True)
    where.add_argument("--project", nargs="?", const=".", metavar="DIR", help="install into DIR/.claude/skills")
    where.add_argument("--user", action="store_true", help="install into ~/.claude/skills")
    where.add_argument("--target", metavar="PATH", help="install into this skills folder")
    parser.add_argument("--dry-run", action="store_true", help="show what would happen, change nothing")
    parser.add_argument("--force", action="store_true", help="overwrite a skill that exists and differs")
    return parser.parse_args(argv)


def destination(args: argparse.Namespace) -> pathlib.Path:
    if args.user:
        return pathlib.Path.home() / ".claude" / "skills"
    if args.target:
        return pathlib.Path(args.target).expanduser()
    return pathlib.Path(args.project).expanduser() / ".claude" / "skills"


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if not SOURCE.is_dir():
        print(f"FAILED: {SOURCE} not found: run this script from the unzipped pack folder")
        return 1
    target = destination(args).resolve()
    problems: list[str] = []
    skipped: set[str] = set()
    installed = 0
    for skill in sorted(p for p in SOURCE.iterdir() if p.is_dir() and (p / "SKILL.md").is_file()):
        dest = target / skill.name
        if dest.exists() and tree_hashes(dest) == tree_hashes(skill):
            print(f"  up to date  {skill.name}")
            continue
        if dest.exists() and not args.force:
            print(f"  SKIPPED     {skill.name}: exists and differs (use --force to overwrite)")
            skipped.add(skill.name)
            continue
        print(f"  {'would install' if args.dry_run else 'install'}  {skill.name}{' (overwrite)' if dest.exists() else ''}")
        if args.dry_run:
            continue
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(skill, dest)
        installed += 1
    if not args.dry_run:
        manifest = PACK_DIR / "MANIFEST.sha256"
        for line in manifest.read_text(encoding="utf-8").splitlines() if manifest.is_file() else []:
            digest, _, name = line.partition("  ")
            if not name.startswith("skills/") or name.split("/")[1] in skipped:
                continue
            copy = target / name[len("skills/"):]
            if copy.is_file() and sha(copy) != digest:
                problems.append(f"{name}: differs from the pack after copying")
    for line in problems:
        print(f"  [FAIL] {line}")
    print(f"{'DRY RUN' if args.dry_run else 'OK' if not problems else 'FAILED'}: {installed} skill(s) installed into {target}")
    if not args.dry_run:
        print("Restart Claude Code so the skills load.")
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
