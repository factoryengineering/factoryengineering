#!/usr/bin/env python3
"""Sync .claude/commands/*.md to .github/prompts/*.prompt.md for GitHub Copilot (VS Code).

Reads each command file, wraps the body with minimal Copilot frontmatter, and writes
the corresponding .prompt.md file so slash commands work in VS Code Chat.

Usage:
    python sync_copilot_prompts.py [REPO_ROOT]

Run from repo root, or pass REPO_ROOT. Default: current working directory.

Example:
    python .claude/skills/factory-engineering/scripts/sync_copilot_prompts.py
    python scripts/sync_copilot_prompts.py /path/to/my-project
"""

import re
import sys
from pathlib import Path


def slug_to_description(slug: str) -> str:
    """Turn a command slug like 'write-spec' into a short description."""
    return slug.replace("-", " ").strip().capitalize() + " command"


def extract_body_and_description(content: str, fallback_slug: str) -> tuple[str, str]:
    """
    Use content as body. If it has YAML frontmatter, use its description if present;
    otherwise derive description from first line or slug.
    """
    body = content.strip()
    description = slug_to_description(fallback_slug)

    if body.startswith("---"):
        match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)", body, re.DOTALL)
        if match:
            front_block, rest = match.group(1), match.group(2)
            body = rest.strip()
            # Optional: extract description from existing frontmatter
            desc_match = re.search(r"^description:\s*['\"]?(.+?)['\"]?\s*$", front_block, re.MULTILINE)
            if desc_match:
                description = desc_match.group(1).strip()
    if body and not description.endswith("command"):
        first_line = body.split("\n")[0].strip()
        if first_line and len(first_line) < 120:
            description = first_line

    return body, description


def sync_commands_to_prompts(repo_root: Path) -> None:
    commands_dir = repo_root / ".claude" / "commands"
    prompts_dir = repo_root / ".github" / "prompts"

    if not commands_dir.is_dir():
        print(f"Commands directory not found: {commands_dir}", file=sys.stderr)
        sys.exit(1)

    prompts_dir.mkdir(parents=True, exist_ok=True)

    command_files = sorted(commands_dir.glob("*.md"))
    if not command_files:
        print(f"No .md files in {commands_dir}", file=sys.stderr)
        return

    for path in command_files:
        slug = path.stem
        content = path.read_text(encoding="utf-8")
        body, description = extract_body_and_description(content, slug)

        frontmatter = f"""---
description: '{description.replace("'", "''")}'
agent: 'agent'
---
"""
        out_path = prompts_dir / f"{slug}.prompt.md"
        out_path.write_text(frontmatter + body + "\n", encoding="utf-8")
        print(f"  {path.relative_to(repo_root)} -> {out_path.relative_to(repo_root)}")

    print(f"Synced {len(command_files)} command(s) to {prompts_dir.relative_to(repo_root)}")


def main() -> None:
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    repo_root = repo_root.resolve()
    sync_commands_to_prompts(repo_root)


if __name__ == "__main__":
    main()
