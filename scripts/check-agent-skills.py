#!/usr/bin/env python3
"""Check the shared agent skill catalog in agents/.agents/skills.

Fails when a skill has no provenance entry in agents/skill-sources.json, when its
frontmatter name does not match its folder, or when its Claude Code symlink in
claude/.claude/skills is missing or wrong. With --live it also checks that both
links are stowed into $HOME.

Usage: python3 scripts/check-agent-skills.py [--live]
"""

import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "agents/.agents/skills"
CLAUDE_LINKS = ROOT / "claude/.claude/skills"
SOURCES = ROOT / "agents/skill-sources.json"


def frontmatter_name(skill_md: Path):
    match = re.match(r"^---\r?\n(.*?)\r?\n---", skill_md.read_text(), re.DOTALL)
    if not match:
        return None
    for line in match.group(1).splitlines():
        if line.startswith("name:"):
            return line.split(":", 1)[1].strip().strip("'\"")
    return None


def main() -> int:
    live = "--live" in sys.argv
    errors = []
    sources = json.loads(SOURCES.read_text())["skills"]
    installed = sorted(p.name for p in SKILLS.iterdir() if p.is_dir())

    for name in installed:
        skill_md = SKILLS / name / "SKILL.md"
        if not skill_md.is_file():
            errors.append(f"{name}: SKILL.md is missing")
            continue
        if frontmatter_name(skill_md) != name:
            errors.append(f"{name}: frontmatter name does not match the folder")
        entry = sources.get(name)
        if entry is None:
            errors.append(f"{name}: no entry in agents/skill-sources.json")
        elif entry.get("kind") == "upstream":
            for field in ("source", "path", "revision"):
                if not entry.get(field):
                    errors.append(f"{name}: upstream entry is missing {field}")
        elif entry.get("kind") != "custom":
            errors.append(f"{name}: kind must be upstream or custom")

        link = CLAUDE_LINKS / name
        expected = f"../../../agents/.agents/skills/{name}"
        if not link.is_symlink() or os.readlink(link) != expected:
            errors.append(f"{name}: claude/.claude/skills/{name} must link to {expected}")

        if live:
            for home_link in (Path.home() / ".agents/skills" / name, Path.home() / ".claude/skills" / name):
                if not (home_link.is_symlink() and home_link.resolve() == (SKILLS / name).resolve()):
                    errors.append(f"{name}: {home_link} is not stowed; run stow -t ~ agents claude")

    for name in sources:
        if name not in installed:
            errors.append(f"{name}: listed in agents/skill-sources.json but not installed")
    for link in CLAUDE_LINKS.iterdir():
        if link.name not in installed:
            errors.append(f"claude/.claude/skills/{link.name}: links to no installed skill")

    for error in errors:
        print(f"error: {error}")
    print(f"{len(installed)} skills checked, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
