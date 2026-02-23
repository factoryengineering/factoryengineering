# Symlinks

Canonical **commands and workflows** live in **`.claude/commands/`**. Canonical **skills** live in **`.claude/skills/`**. Each IDE looks in different folders. The scripts create symlinks so one folder of each type works everywhere.

**Supported IDEs:** Cursor, Windsurf, Kilo Code, Antigravity. Cursor and GitHub Copilot read `.claude/skills/` directly—no skills symlink. For Copilot commands use sync (see [sync-copilot-prompts.md](sync-copilot-prompts.md)).

---

## Workflow for the agent

1. **Ensure canonical folders exist.** From the repository root: `mkdir -p .claude/commands .claude/skills` if needed. The script creates them when creating symlinks if omitted.

2. **Determine which IDEs to support.**
   - If the user specified IDEs (e.g. "just Cursor"), use that list.
   - If not, **detect:** run the script with `--detect` (Bash) or `-Detect` (PowerShell). It checks for `.cursor`, `.windsurf`, `.kilocode`, `.agent` in the repo root.
   - If you detected IDEs, **confirm with the user** before proceeding; list them and ask which should get symlinks.

3. **Check for existing target folders.** For each selected IDE:
   - **Commands/workflows:** `.cursor/commands`, `.windsurf/workflows`, `.kilocode/workflows`, `.agent/workflows` → `.claude/commands`
   - **Skills:** `.windsurf/skills`, `.kilocode/skills`, `.agent/skills` → `.claude/skills` (Cursor and Copilot read `.claude/skills/` directly; no skills symlink.)
   If a target exists and is **not** already a symlink to the canonical folder: inform the user and **offer** to copy existing contents into the canonical folder and then replace with a symlink. If they agree, run with `--copy-existing` / `-CopyExisting`.

4. **Create symlinks.** From repo root: Bash `scripts/setup-symlinks.sh` or PowerShell `scripts/Setup-Symlinks.ps1`. Pass IDEs (e.g. `--ide cursor,windsurf` or `-Ide cursor,windsurf`). Use `--type all` (default) for both commands and skills; `--type commands` or `--type skills` for one. If the script reports an existing target, return to step 3.

5. **Commit.** Recommend committing symlinks and any new files under `.claude/commands` or `.claude/skills`.

---

## Scripts

Run from the **repository root** (or pass `--repo-root` / `-RepoRoot`).

### Bash: `scripts/setup-symlinks.sh`

| Goal | Command |
|------|---------|
| Detect only | `bash path/to/skill/scripts/setup-symlinks.sh --detect` |
| Create symlinks | `bash path/to/skill/scripts/setup-symlinks.sh [--type commands\|skills\|all] --ide cursor[,windsurf,...]` |
| Copy existing then symlink | Add `--copy-existing` |
| Non–repo root | `--repo-root /path/to/repo` |

Default `--type all` creates both command and skill symlinks. If a target is an existing directory (not a symlink), the script exits unless `--copy-existing` is used.

### PowerShell: `scripts/Setup-Symlinks.ps1`

| Goal | Command |
|------|---------|
| Detect | `.\scripts\Setup-Symlinks.ps1 -Detect` |
| Create symlinks | `.\scripts\Setup-Symlinks.ps1 [-Type commands\|skills\|all] -Ide cursor,windsurf,kilocode,antigravity` |
| Copy existing then symlink | `-CopyExisting` |
| Repo root | `-RepoRoot C:\path\to\repo` |

---

## Symlink mapping

**Commands and workflows** (canonical: `.claude/commands/`):

| IDE | Target (symlink) | Points to |
|-----|------------------|-----------|
| Cursor | `.cursor/commands` | `../.claude/commands` |
| Windsurf | `.windsurf/workflows` | `../.claude/commands` |
| Kilo Code | `.kilocode/workflows` | `../.claude/commands` |
| Antigravity | `.agent/workflows` | `../.claude/commands` |

**Skills** (canonical: `.claude/skills/`). Cursor and GitHub Copilot read this path directly—no symlink.

| IDE | Target (symlink) | Points to |
|-----|------------------|-----------|
| Windsurf | `.windsurf/skills` | `../.claude/skills` |
| Kilo Code | `.kilocode/skills` | `../.claude/skills` |
| Antigravity | `.agent/skills` | `../.claude/skills` |

Antigravity requires `.agent` to exist; the scripts create it when needed.
