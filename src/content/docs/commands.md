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

Commands are markdown files. The slash name is the filename without `.md` (e.g. `write-design.md` → `/write-design`). This is a convention shared across IDEs; folder locations vary (see table below). Because commands are shared across IDEs (via rsync), keep them **IDE-agnostic**: do not rely on `$ARGUMENTS` or other placeholders, since not all IDEs support them. Instead, write the command so it **states what the user will supply** (e.g. a user story or design document, by link or by name) and **instructs the LLM to stop and prompt the user** if that input is missing. That pattern works consistently in every IDE. Below is an example showing this pattern plus location, purpose, structure, and a short checklist.

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

**1. Do the task once with the agent.** Pick a concrete artifact (e.g. a user story) and tell the agent what you want (e.g. "Write a technical spec for this story"). Work through the result-fix gaps, adjust structure, clarify wording-until the output is what you want. Do not compromise on quality.

**2. Capture the process as a command.** Ask the agent to create a command file in `.claude/commands/` that encodes the instructions you just followed. The command should state what the user supplies (e.g. a user story or design doc) and tell the LLM to stop and prompt if that input is missing. Use the [recommended pattern](#example-command-file): location, purpose, contents, structure. Instruct the LLM to save the file (e.g. `write-spec.md` → `/write-spec`).

**3. Run the command against an artifact.** Invoke **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`). Do not hand-hold; let the command stand on its own. Note where the output is wrong, vague, or inconsistent with how you refined it in step 1.

**4. Refine the command.** For each shortcoming, ask: *Which part of the command allowed this?* Update the command text-add constraints, examples, or explicit structure (e.g. "Include…", "Do not…", "Use the template in…"). Commit the change.

**5. Repeat steps 3 and 4.** Re-run the command on the same or a different artifact. Keep tightening instructions until the command produces the desired result without extra guidance. When it does, that command is ready for the team.

**6. Add more commands the same way.** For each new repeatable task (e.g. implementation plan, code review), do the task once, capture it as a command, then iterate by running and refining until the command is reliable.

From here, every team member uses **slash-command at-artifact** (e.g. `/write-spec @docs/stories/submit-sales-order.md`). For multi-step orchestration, see the Workflows page.

## Sharing Commands Across IDEs

Both **commands** and **workflows** are stored in `.claude/commands/`. Each IDE looks in a different folder. Use one of the strategies below so that one canonical location works everywhere.

### Strategy 1 — Sync with rsync (recommended for most teams)

Keep canonical commands in `.claude/commands/` and use a two-step `rsync` to keep every IDE folder in sync. This works on every OS. The two-step pattern gathers changes from non-canonical locations first, so a developer who edits in `.kilocode/workflows/` does not lose work when the sync runs.

```bash
#!/usr/bin/env bash
# sync-commands.sh — run from repo root

IDE_COMMANDS=(.cursor/commands .windsurf/workflows .kilocode/workflows .agent/workflows)

# Ensure canonical directory exists (first-time setup)
mkdir -p .claude/commands

# Step 1: reverse-sync — gather changes from any IDE location back to canonical
for src in "${IDE_COMMANDS[@]}"; do
  [ -d "$src" ] && rsync -a "$src/" .claude/commands/
done

# Step 2: forward-sync — mirror canonical to all IDE locations
for dest in "${IDE_COMMANDS[@]}"; do
  mkdir -p "$dest"
  rsync -a --delete .claude/commands/ "$dest"/
done
```

**Step 1** is additive (no `--delete`): new or modified files in any IDE folder are copied back to `.claude/commands/`. **Step 2** uses `--delete` so each destination becomes an exact mirror of canonical.

Automate this with a Git hook, file watcher, or CI step so copies never drift. Commit the synced folders.

### Strategy 2 — IDE-Native Locations Only

Store commands directly in each IDE's folder and skip the canonical location. Simple for one or two IDEs, but maintenance grows with IDE count.

**GitHub Copilot (VS Code)** uses prompt files (`.prompt.md`) with different naming and optional frontmatter, so commands cannot be shared via rsync. Copy each command into `.github/prompts/{name}.prompt.md` instead (see [GitHub Copilot](/ides/github-copilot#commands)).

Stored in `.claude/commands/`, this file is available as `/write-design` in Claude Code and Cursor; with rsync, the same file is used by Windsurf, Kilo Code, and Antigravity. Invoke with **slash-command at-artifact** (e.g. `/write-design @docs/user-stories/billing-email.md`).

## IDE-by-IDE Reference

All IDEs support commands, but they use different folder locations, invocation patterns, and terminology. The table below summarizes the key differences. For full setup details, see each IDE's dedicated page.

| IDE | Folder | Invocation | Sharing Required? | Details |
|-----|--------|------------|-------------------|---------|
| [Claude Code](/ides/claude-code) | `.claude/commands/` | `/command-name` | No (canonical location) | [Full setup →](/ides/claude-code#commands) |
| [Cursor](/ides/cursor) | `.cursor/commands/` | `/command-name` | ✅ Yes (copy) | [Full setup →](/ides/cursor#commands) |
| [Windsurf](/ides/windsurf) | `.windsurf/workflows/` | `/workflow-name` | ✅ Yes (copy) | [Full setup →](/ides/windsurf#commands) |
| [Kilo Code](/ides/kilo-code) | `.kilocode/workflows/` | `/workflow-name` | ✅ Yes (copy) | [Full setup →](/ides/kilo-code#commands) |
| [Google Antigravity](/ides/google-antigravity) | `.agent/workflows/` | `/workflow-name` | ✅ Yes (copy) | [Full setup →](/ides/google-antigravity#commands) |
| [GitHub Copilot](/ides/github-copilot) | `.github/prompts/` | `/prompt-name` | Sync | [Full setup →](/ides/github-copilot#commands) |
| [OpenAI Codex](/ides/openai-codex) | `.agents/skills/` (via skills) | `$skill-name` | ⚠️ Needs investigation (use skills) | [Full setup →](/ides/openai-codex#commands) |

**Note:** OpenAI Codex's documented reusable-instruction mechanism is the Agent Skills standard (`$skill-name` invocation from `.agents/skills/`); whether it also supports slash-command markdown files has not been confirmed in official documentation. To share commands with a Codex user today, author them as skills. Windsurf and Kilo Code call their commands "Workflows" — this is their storage mechanism for reusable instructions, not factory engineering workflows. GitHub Copilot uses `.prompt.md` files with different naming and optional frontmatter, so commands require a format-aware copy step. See [GitHub Copilot](/ides/github-copilot#commands) for details.
