---
name: factory-engineering-symlinks
description: Sets up IDE symlinks so commands, workflows, and skills in .claude/commands/ and .claude/skills/ are available in Cursor, Windsurf, KiloCode, and Antigravity. Use when the user wants to configure symlinks for factory engineering, set up .cursor/commands or .windsurf/workflows from .claude/commands, set up .cursor/skills from .claude/skills, or unify command and skill folders across IDEs. Install with npx openskills; then instruct the agent to create symlinks for the user's selected IDEs.
---

# Factory Engineering Symlinks

Canonical **commands and workflows** live in **`.claude/commands/`**. Canonical **skills** live in **`.claude/skills/`**. Each IDE looks in different folders. This skill creates symlinks so one folder of each type works everywhere.

**Supported IDEs:** Cursor, Windsurf, KiloCode, Antigravity (see mapping tables below). **GitHub Copilot:** for commands it uses `.github/prompts/` and a different format—use the **factory-engineering-sync-copilot-prompts** skill instead of symlinks. For skills, Copilot already reads `.claude/skills/` directly, so no symlink is needed.

---

## Installation

User installs this skill with OpenSkills, then asks the agent to set up symlinks:

```bash
npx openskills install michaellperry/factoryengineering
```

After installation, instruct the agent to create symlinks for their selected IDEs (see Workflow below).

---

## Workflow for the Agent

1. **Ensure canonical folders exist.** From the repository root, ensure `.claude/commands` and `.claude/skills` exist (create with `mkdir -p .claude/commands .claude/skills` if needed). The script will create them when creating symlinks if you omit this step.

2. **Determine which IDEs to support.**
   - If the user specified one or more IDEs (e.g. "just Cursor" or "Cursor and Windsurf"), use that list.
   - If no IDE was specified, **detect** IDEs by running the script with `--detect` (Bash) or `-Detect` (PowerShell). The script checks for `.cursor`, `.windsurf`, `.kilocode`, and `.agent` in the repo root.
   - If you detected IDEs, **confirm with the user** before proceeding: list the detected IDEs and ask them to confirm which should get symlinks (or all). Proceed only after they confirm.

3. **Check for existing target folders.** For each selected IDE, symlink targets are (depending on type):
   - **Commands/workflows:** `.cursor/commands`, `.windsurf/workflows`, `.kilocode/workflows`, `.agent/workflows` → `.claude/commands`
   - **Skills:** `.cursor/skills`, `.windsurf/skills`, `.kilocode/skills`, `.agent/skills` → `.claude/skills`
   If any target path already exists and is **not** already a symlink to the corresponding canonical folder:
   - **Inform the user** that the target folder already exists and may contain existing files.
   - **Offer** to copy the existing files into the canonical folder and then replace the target with a symlink. If the user agrees, run the script with `--copy-existing` (Bash) or `-CopyExisting` (PowerShell).

4. **Create symlinks.** Run the bundled Bash or PowerShell script from the **repository root** with the selected IDEs. On Windows (PowerShell), use `scripts/Setup-Symlinks.ps1`; otherwise use `scripts/setup-symlinks.sh`. Pass the chosen IDEs (e.g. `cursor`, `windsurf`, `kilocode`, `antigravity`). Use `--type all` (or default) to set up both commands and skills; use `--type commands` or `--type skills` to set up only one. If the script reports that a target already exists, return to step 3 and offer the copy-existing option.

5. **Commit.** Recommend committing the new or updated symlinks (and any new files under `.claude/commands` or `.claude/skills`) so the team gets the same structure on clone.

---

## Scripts

Scripts live in the skill’s `scripts/` folder. Run them from the **repository root** (or pass the repo root where supported).

### Bash: `scripts/setup-symlinks.sh`

- **Detect only (no changes):**  
  `bash path/to/skill/scripts/setup-symlinks.sh --detect`  
  Prints detected IDEs (one per line). Use this to confirm with the user before creating symlinks.

- **Create symlinks:**  
  `bash path/to/skill/scripts/setup-symlinks.sh [--type commands|skills|all] --ide cursor [--ide windsurf] ...`  
  Or: `--ide cursor,windsurf,kilocode,antigravity`. Default `--type all` sets up both commands and skills. Creates `.claude/commands` and/or `.claude/skills` if missing. If a target path already exists and is a real directory (not a symlink), the script exits with a message and does not overwrite.

- **Copy existing into canonical, then symlink:**  
  `bash path/to/skill/scripts/setup-symlinks.sh --ide cursor [--ide ...] --copy-existing`  
  For each given IDE whose target is an existing directory, copies its contents into the canonical folder, then removes the target and creates the symlink. Use only after the user has agreed to merge.

- **Repo root:** If not run from repo root:  
  `bash path/to/skill/scripts/setup-symlinks.sh --repo-root /path/to/repo --ide cursor`

### PowerShell: `scripts/Setup-Symlinks.ps1`

Same behavior as the Bash script:

- **Detect:** `.\scripts\Setup-Symlinks.ps1 -Detect`
- **Create symlinks:** `.\scripts\Setup-Symlinks.ps1 [-Type commands|skills|all] -Ide cursor,windsurf,kilocode,antigravity` (default `-Type all`)
- **Copy existing then symlink:** `.\scripts\Setup-Symlinks.ps1 -Ide cursor -CopyExisting`
- **Repo root:** `-RepoRoot C:\path\to\repo`

---

## Symlink Mapping (reference)

**Commands and workflows** (canonical: `.claude/commands/`):

| IDE        | Target (symlink)     | Points to           |
|-----------|----------------------|---------------------|
| Cursor    | `.cursor/commands`   | `../.claude/commands` |
| Windsurf  | `.windsurf/workflows`| `../.claude/commands` |
| KiloCode  | `.kilocode/workflows`| `../.claude/commands` |
| Antigravity | `.agent/workflows` | `../.claude/commands` |

**Skills** (canonical: `.claude/skills/`):

| IDE        | Target (symlink) | Points to          |
|-----------|------------------|--------------------|
| Cursor    | `.cursor/skills` | `../.claude/skills` |
| Windsurf  | `.windsurf/skills` | `../.claude/skills` |
| KiloCode  | `.kilocode/skills` | `../.claude/skills` |
| Antigravity | `.agent/skills` | `../.claude/skills` |

Antigravity requires `.agent` to exist before creating symlinks; the scripts create it when needed. GitHub Copilot reads `.claude/skills/` directly and uses `.github/prompts/` for commands (see sync-copilot-prompts skill)—no symlinks for Copilot.

---

## Reference

- **Commands and folder locations:** See project docs `src/content/docs/commands.md`.
- **Skills and folder locations:** See project docs `src/content/docs/skills.md`.
- **Workflows and symlink setup:** See project docs `src/content/docs/workflows.md`.
