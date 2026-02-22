---
name: factory-engineering
description: Configures factory engineering across IDEs. Sets up symlinks so .claude/commands and .claude/skills are available where each IDE expects them (Cursor and GitHub Copilot read .claude/skills directly; Windsurf, KiloCode, and Antigravity need symlinks for skills; Cursor and others need symlinks for commands). Syncs .claude/commands to GitHub Copilot prompt files (.github/prompts/*.prompt.md) for VS Code. Use when configuring slash commands or skills across IDEs, setting up .cursor/commands or .windsurf/workflows from .claude/commands, syncing commands for Copilot, or unifying command and skill folders.
---

# Factory Engineering

One skill for configuring commands, workflows, and skills across IDEs. Canonical locations: **`.claude/commands/`** (commands and workflows), **`.claude/skills/`** (skills).

**Installation:** `npx openskills install michaellperry/factoryengineering`. Then ask the agent to set up symlinks or sync Copilot prompts as needed.

---

## When to use

- **Symlinks:** User wants slash commands or skills to work in Cursor, Windsurf, KiloCode, or Antigravity from a single canonical folder. Each IDE looks in a different path; symlinks point those paths to `.claude/commands` and (where needed) `.claude/skills`. Cursor and GitHub Copilot read `.claude/skills/` directly—no skills symlink for them; the script creates skill symlinks only for Windsurf, KiloCode, and Antigravity.
- **Sync Copilot prompts:** User uses GitHub Copilot (VS Code) and wants `/command-name` in Chat. Copilot uses `.github/prompts/*.prompt.md`, not `.claude/commands/*.md`. Sync converts commands to prompt files.

For Copilot commands, use sync (symlinks do not apply).

---

## Symlinks

Workflow, script options, and mapping tables: **[symlinks.md](symlinks.md)**.

Run scripts from the **repository root**. Bash: `scripts/setup-symlinks.sh`. PowerShell: `scripts/Setup-Symlinks.ps1`. Use `--detect` / `-Detect` to list IDEs before creating symlinks; use `--copy-existing` / `-CopyExisting` to merge existing target folders into the canonical folder first.

---

## Sync commands to GitHub Copilot

Workflow, frontmatter rules, and batch script: **[sync-copilot-prompts.md](sync-copilot-prompts.md)**.

Prompt file spec (fields, variables, tips): **[references/prompt-files-spec.md](references/prompt-files-spec.md)**.

Batch sync from repo root: `python path/to/skill/scripts/sync_copilot_prompts.py [REPO_ROOT]`.

---

## Reference

- Project docs: `src/content/docs/commands.md`, `src/content/docs/skills.md`, `src/content/docs/workflows.md`.
