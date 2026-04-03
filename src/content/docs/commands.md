---
title: Commands
description: Reusable task instructions—lightweight markdown files that encode repeatable steps for specific tasks, invoked with a slash or `@` symbol in your IDE.
---

# Commands: Reusable Task Instructions

Commands are lightweight markdown files that encode repeatable instructions for specific tasks. Unlike skills, which are standardized across platforms, commands are simple prompt templates that you invoke with a `/` (or `@` symbol for some IDEs) to execute a predefined sequence of steps against an artifact.

In factory engineering, artifacts such as user stories, specifications, product requirements documents, and user journeys move through the software factory. Commands define how to process those artifacts. The power move is **slash-command at-artifact**: e.g. `/write-spec @docs/user-stories/submit-sales-order` runs the write-spec command against that user story. The command provides the instructions, the artifact provides the target, and the agent does the work.

## Why Project-Scoped Commands Matter for Factory Engineering

Like skills, commands must live in your project repository and evolve with your codebase. When commands are stored at the project level, they are versioned with your code, reviewed in pull requests, and automatically available to every team member on clone.

**Invocation rule:** The slash name is the **filename without `.md`** (e.g. `write-spec.md` → `/write-spec`). Always use **slash-command at-artifact** to run a command against a specific artifact.

## Example command file

Commands are markdown files. The slash name is the filename without `.md` (e.g. `write-design.md` → `/write-design`). This is a convention shared across IDEs; folder locations vary (see table below). Because commands are shared via symlinks, keep them **IDE-agnostic**: do not rely on `$ARGUMENTS` or other placeholders, since not all IDEs support them. Instead, write the command so it **states what the user will supply** (e.g. a user story or design document, by link or by name) and **instructs the LLM to stop and prompt the user** if that input is missing. That pattern works consistently in every IDE. Below is an example showing this pattern plus location, purpose, structure, and a short checklist.

**Example (`.claude/commands/write-design.md`):**

```markdown
# Write Design Document

The user will supply a user story or design document, either by link or by name. If no user story or design document is supplied, then stop and prompt the user. Create a new design document or update the existing one using the following instructions.

## Location

- **Path:** `docs/designs/`
- **Filename:** Descriptive kebab-case ending in `-design.md`.

## Purpose

Design documents capture: user story and scope, domain definitions, technical approach and data sources, gaps and recommendations, test cases, acceptance criteria. They are planning artifacts; reference user stories and scenarios, not implementation.

## Contents

Include:
1. Title and user story
2. Data model and validation rules
3. Data model diagrams
4. Test cases driven by acceptance criteria
5. OpenAPI endpoint specifications
6. References

## Structure

Use the recommended template in the [documentation-spec](../../skills/documentation-spec/SKILL.md) skill.
```

---

## Creating Commands Iteratively

**1. Do the task once with the agent.** Pick a concrete artifact (e.g. a user story) and tell the agent what you want (e.g. "Write a technical spec for this story"). Work through the result—fix gaps, adjust structure, clarify wording—until the output is what you want. Do not compromise on quality.

**2. Capture the process as a command.** Ask the agent to create a command file in `.claude/commands/` that encodes the instructions you just followed. The command should state what the user supplies (e.g. a user story or design doc) and tell the LLM to stop and prompt if that input is missing. Use the [recommended pattern](#example-command-file): location, purpose, contents, structure. Instruct the LLM to save the file (e.g. `write-spec.md` → `/write-spec`).

**3. Run the command against an artifact.** Invoke **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`). Do not hand-hold; let the command stand on its own. Note where the output is wrong, vague, or inconsistent with how you refined it in step 1.

**4. Refine the command.** For each shortcoming, ask: *Which part of the command allowed this?* Update the command text—add constraints, examples, or explicit structure (e.g. "Include…", "Do not…", "Use the template in…"). Commit the change.

**5. Repeat steps 3 and 4.** Re-run the command on the same or a different artifact. Keep tightening instructions until the command produces the desired result without extra guidance. When it does, that command is ready for the team.

**6. Add more commands the same way.** For each new repeatable task (e.g. implementation plan, code review), do the task once, capture it as a command, then iterate by running and refining until the command is reliable.

From here, every team member uses **slash-command at-artifact** (e.g. `/write-spec @docs/stories/submit-sales-order.md`). For multi-step orchestration, see the Workflows page.

## The Symlink Approach

Both **commands** and **workflows** are stored in `.claude/commands/`. Each IDE looks in a different folder. Use symlinks so that one canonical location works everywhere.

**Option A — Use the factory-engineering skill:** Install with `npx openskills install factoryengineering/skills`, then ask your agent to create symlinks for your selected IDEs. The skill sets up symlinks for **commands/workflows** (`.claude/commands/`) and **skills** (`.claude/skills/`) in one go (or use `--type commands` to do only commands). The agent can **detect** which IDEs you have (e.g. run the script with `--detect`), confirm with you, then create symlinks. If a target folder already exists (e.g. `.cursor/commands`), the skill will **offer to copy** its contents into the canonical folder and then replace it with a symlink (`--copy-existing`). On **Windows**, use the skill’s PowerShell script (`Setup-Symlinks.ps1`).

**Option B — Create symlinks manually for each IDE:** Run these from your **repository root**. The symlink target `../.claude/commands` is resolved relative to the link’s directory (e.g. `.cursor/`), so it correctly points at the repo’s `.claude/commands/`.

```bash
# Cursor
mkdir -p .cursor
ln -s ../.claude/commands .cursor/commands

# Windsurf
mkdir -p .windsurf
ln -s ../.claude/commands .windsurf/workflows

# Kilo Code
mkdir -p .kilocode
ln -s ../.claude/commands .kilocode/workflows

# Antigravity
mkdir -p .agent
ln -s ../.claude/commands .agent/workflows
```

Commit the symlinks so every team member gets the correct structure on clone.

**GitHub Copilot (VS Code)** uses prompt files (`.prompt.md`) with different naming and optional frontmatter, so commands cannot be shared via symlinks. Use a **sync** step instead; the **factory-engineering** skill includes sync instructions and a batch script (see [GitHub Copilot (VS Code)](#github-copilot-vs-code) below).

Stored in `.claude/commands/`, this file is available as `/write-design` in Claude Code and Cursor; with symlinks, the same file is used by Windsurf, Kilo Code, and Antigravity. Invoke with **slash-command at-artifact** (e.g. `/write-design @docs/user-stories/billing-email.md`).

## IDE-by-IDE Reference

### Claude Code

**Folder location:** `.claude/commands/` (project) or `~/.claude/commands/` (global)

**Invocation:** `/command-name` — the filename without `.md` is the slash command (e.g. `write-spec.md` → `/write-spec`). Prefer `/command-name` for the command; the `@` symbol in **slash-command at-artifact** refers to the *artifact*, not the command.

Claude Code stores commands as markdown files; each file becomes a slash command. **Use the [recommended pattern](#example-command-file):** state in the command what the user will supply and instruct the LLM to stop and prompt if it’s missing. Do not rely on `$ARGUMENTS`—commands are shared via symlinks and not all IDEs support it. See [Example command file](#example-command-file) above for structure.

**Usage in Claude Code:**

```
/write-spec @submit-sales-order
```

📖 [Claude Code Slash Commands Documentation](https://code.claude.com/docs/en/slash-commands)

---

### Cursor

**Folder location:** `.cursor/commands/` (project) or `~/.cursor/commands/` (global)

**Invocation:** `/command-name` — filename without `.md` becomes the slash command. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`). Follow the [recommended pattern](#example-command-file) (state what the user supplies; stop and prompt if missing). Do not rely on `$ARGUMENTS`—commands are shared via symlinks and not all IDEs support it. See [Example command file](#example-command-file) above for structure.

**Usage in Cursor:**

```
/write-spec @submit-sales-order
```

Since Cursor uses `.cursor/commands/` and we're storing our canonical commands in `.claude/commands/`, create a symlink:

```bash
ln -s ../.claude/commands .cursor/commands
```

**Built-in commands (v3.0):** Cursor 3 added `/worktree` (creates an isolated git worktree so agents work without conflicts) and `/best-of-n` (runs the same prompt across multiple models in parallel worktrees and compares results). These are built-in commands, not user-defined — your custom commands in `.cursor/commands/` continue to work alongside them.

📖 [Cursor Custom Commands Documentation](https://docs.cursor.com/chat/custom-commands)

---

### Windsurf

**Folder location:** `.windsurf/workflows/` (project) or `~/.windsurf/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

Windsurf calls them workflows—note that this is different from workflows in the factory engineering sense. In Windsurf, these are simply the storage mechanism for reusable command instructions. Windsurf workflows are markdown files that define a sequence of steps for Cascade to follow. With the symlink, the same file as in [Example command file](#example-command-file) is used.

**Usage in Windsurf:**

```
/write-spec @submit-sales-order
```

Create a symlink to use your canonical commands folder:

```bash
ln -s ../.claude/commands .windsurf/workflows
```

📖 [Windsurf Workflows Documentation](https://docs.windsurf.com/windsurf/cascade/workflows)

---

### Kilo Code

**Folder location:** `.kilocode/workflows/` (project) or `~/.kilocode/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

Kilo Code calls them workflows—again, this is Kilo Code's storage mechanism for commands, not factory engineering workflows. Kilo Code workflows are markdown files that define a sequence of steps. With the symlink, the same file as in [Example command file](#example-command-file) is used.

**Usage in Kilo Code:**

```
/write-spec @submit-sales-order
```

Use the symlink from the setup above so `.kilocode/workflows` points to `.claude/commands`.

📖 [Kilo Code Workflows Documentation](https://kilo.ai/docs/features/slash-commands/workflows)

---

### Antigravity

**Folder location:** `.agent/workflows/` (project) or `~/.gemini/antigravity/skills/` (global skills; workflows are in `.agent/workflows/`)

**Invocation:** `/workflow-name` — Antigravity treats files in `.agent/workflows/` as workflows. With the symlink, your `.claude/commands/` files appear there. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`).

Create the symlink from the setup above: `mkdir -p .agent` then `ln -s ../.claude/commands .agent/workflows`. Without the symlink, you would have to maintain a separate copy of commands in `.agent/workflows/`.

---

### GitHub Copilot (VS Code)

**Folder location:** `.github/prompts/` (default workspace location). Additional folders can be listed in the `chat.promptFilesLocations` setting.

**Invocation:** Type `/` in the Chat view, then the prompt name (filename without `.prompt.md`). For example, `write-spec.prompt.md` → `/write-spec`. You can then add an artifact with `@artifact-name` (e.g. `/write-spec @submit-sales-order`).

**Format:** Prompt files use the `.prompt.md` extension (not plain `.md`). They support optional YAML frontmatter (`description`, `agent`, `tools`, etc.). See [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files) (VS Code 1.100+, April 2025).

**Syncing commands for Copilot:** Copilot expects `.prompt.md` files and optional frontmatter, so the same `.claude/commands/*.md` files cannot be used directly. Keep canonical commands in `.claude/commands/*.md` and **sync** them into `.github/prompts/` when you add or change commands.

**Use the factory-engineering skill** for sync (workflow, frontmatter rules, and batch script):

```bash
npx openskills install factoryengineering/skills
```

Then:

1. **When you add or change commands**, ask your agent to sync commands to Copilot, or run the skill’s bundled script from repo root (the skill documents the exact command).
2. **Commit** the generated `.github/prompts/*.prompt.md` files so everyone on the team gets slash commands in VS Code.

Avoid maintaining `.github/prompts/` by hand so the canonical source stays `.claude/commands/`.
