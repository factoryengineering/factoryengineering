---
name: factory-engineering-symlinks
description: Sets up IDE symlinks so commands and workflows in .claude/commands/ are available in Cursor, Windsurf, KiloCode, and Antigravity. Use when the user wants to configure slash-command symlinks for factory engineering, set up .cursor/commands or .windsurf/workflows from .claude/commands, or unify command folders across IDEs. Install with npx openskills; then instruct the agent to create symlinks for the user's selected IDEs.
---

# Factory Engineering Symlinks

Canonical commands and workflows live in **`.claude/commands/`**. Each IDE looks in a different folder. This skill creates symlinks so one folder works everywhere.

**Supported IDEs:** Cursor (`.cursor/commands`), Windsurf (`.windsurf/workflows`), KiloCode (`.kilocode/workflows`), Antigravity (`.agent/workflows`). GitHub Copilot uses `.github/prompts/` and a different format—use the **factory-engineering-sync-copilot-prompts** skill instead of symlinks.

---

## Installation

User installs this skill with OpenSkills, then asks the agent to set up symlinks:

```bash
npx openskills install michaellperry/factoryengineering
```

After installation, instruct the agent to create symlinks for their selected IDEs (see Workflow below).

---

## Workflow for the Agent

1. **Ensure canonical folder exists.** From the repository root, ensure `.claude/commands` exists (create with `mkdir -p .claude/commands` if needed).

2. **Determine which IDEs to support.**
   - If the user specified one or more IDEs (e.g. "just Cursor" or "Cursor and Windsurf"), use that list.
   - If no IDE was specified, **detect** IDEs by checking for these directories in the repo root:
     - **Cursor:** `.cursor` (or `.cursor/commands`)
     - **Windsurf:** `.windsurf` (or `.windsurf/workflows`)
     - **KiloCode:** `.kilocode` (or `.kilocode/workflows`)
     - **Antigravity:** `.agent` (or `.agent/workflows`)
   - If you detected IDEs, **confirm with the user** before proceeding: list the detected IDEs and ask them to confirm which should get symlinks (or all). Proceed only after they confirm.

3. **Check for existing target folders.** For each selected IDE, the symlink target is:
   - Cursor: `.cursor/commands`
   - Windsurf: `.windsurf/workflows`
   - KiloCode: `.kilocode/workflows`
   - Antigravity: `.agent/workflows`
   If that path already exists and is **not** already a symlink to `.claude/commands`, then:
   - **Inform the user** that the target folder already exists and may contain existing command or workflow files.
   - **Offer** to copy the existing files into `.claude/commands` and then replace the folder with a symlink so everything is unified. If the user agrees, run the script with the option that copies existing contents (see Scripts below).

4. **Create symlinks.** Run the bundled Bash or PowerShell script from the **repository root** with the selected IDEs. On Windows (PowerShell), use `scripts/Setup-Symlinks.ps1`; otherwise use `scripts/setup-symlinks.sh`. Pass the chosen IDEs explicitly (e.g. `cursor`, `windsurf`, `kilocode`, `antigravity`). If the script reports that a target already exists, return to step 3 and offer the copy-existing option.

5. **Commit.** Recommend committing the new or updated symlinks (and any new files under `.claude/commands`) so the team gets the same structure on clone.

---

## Scripts

Scripts live in the skill’s `scripts/` folder. Run them from the **repository root** (or pass the repo root as the first argument where supported).

### Bash: `scripts/setup-symlinks.sh`

- **Detect only (no changes):**  
  `bash path/to/skill/scripts/setup-symlinks.sh --detect`  
  Prints detected IDEs (one per line). Use this to confirm with the user before creating symlinks.

- **Create symlinks:**  
  `bash path/to/skill/scripts/setup-symlinks.sh --ide cursor [--ide windsurf] [--ide kilocode] [--ide antigravity]`  
  Or: `--ide cursor,windsurf,kilocode,antigravity`.  
  Creates `.claude/commands` if missing, then creates each symlink. If a target path already exists and is a real directory (not a symlink), the script exits with a message and does not overwrite.

- **Copy existing into canonical, then symlink:**  
  `bash path/to/skill/scripts/setup-symlinks.sh --ide cursor [--ide ...] --copy-existing`  
  For each given IDE whose target is an existing directory, copies its contents into `.claude/commands`, then removes the target and creates the symlink. Use only after the user has agreed to merge existing commands into `.claude/commands`.

- **Repo root:** If not run from repo root, pass it:  
  `bash path/to/skill/scripts/setup-symlinks.sh --repo-root /path/to/repo --ide cursor`

### PowerShell: `scripts/Setup-Symlinks.ps1`

Same behavior as the Bash script:

- **Detect:** `.\scripts\Setup-Symlinks.ps1 -Detect`
- **Create symlinks:** `.\scripts\Setup-Symlinks.ps1 -Ide cursor,windsurf,kilocode,antigravity`
- **Copy existing then symlink:** `.\scripts\Setup-Symlinks.ps1 -Ide cursor -CopyExisting`
- **Repo root:** `-RepoRoot C:\path\to\repo`

---

## Symlink Mapping (reference)

| IDE        | Target (symlink)     | Points to           |
|-----------|----------------------|---------------------|
| Cursor    | `.cursor/commands`   | `../.claude/commands` |
| Windsurf  | `.windsurf/workflows`| `../.claude/commands` |
| KiloCode  | `.kilocode/workflows`| `../.claude/commands` |
| Antigravity | `.agent/workflows` | `../.claude/commands` |

Antigravity requires `.agent` to exist before creating the `workflows` symlink; the scripts create it when needed.

---

## Reference

- **Commands and folder locations:** See project docs `src/content/docs/commands.md`.
- **Workflows and symlink setup:** See project docs `src/content/docs/workflows.md`.
