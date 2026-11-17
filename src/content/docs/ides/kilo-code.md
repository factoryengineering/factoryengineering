---
title: Kilo Code
description: Complete factory engineering guide for Kilo Code — skills, commands, agents, and subagent orchestration.
---

# Kilo Code

Kilo Code is an open-source (MIT) coding agent that runs as a VS Code extension, a JetBrains plugin, and the Kilo CLI. In 2026 Kilo rebuilt the extension on the Kilo CLI, a fork of OpenCode. The rebuild moved new configuration to `.kilo/` and `kilo.jsonc`, turned workflows into commands, turned modes into Markdown agents, and replaced Orchestrator mode with subagent delegation. Its model gateway gives you access to 500+ models, including Claude, Gemini, and GPT, at the provider's rate with no markup.

**Migrating from the legacy extension:** Existing configuration keeps working. Kilo Code still reads `.kilocode/agents/` and `.kilocode/rules/`, migrates `.kilocode/workflows/` to `.kilo/commands/` on startup, and converts `.kilocodemodes` and `custom_modes.yaml` into agent files. Put new configuration in `.kilo/`.

---

## Skills

**Supports Agent Skills standard:** ✅ Native

| Scope | Path |
|-------|------|
| Project | `.kilo/skills/` |
| Project (compatibility) | `.agents/skills/` (loaded by default), `.claude/skills/` |
| Global | `~/.kilo/skills/` |
| Global (compatibility) | `~/.agents/skills/`, `~/.claude/skills/` |

Kilo Code loads skills from `.agents/skills/` by default, so **no copy or symlink is needed** when your canonical skills live there. The Kilo CLI also loads `.claude/skills/`. The VS Code extension loads `.claude/skills/` only when **Claude Code Compatibility** is enabled in settings.

All skills load into one shared pool. The agent compares each skill's `description` with the current task and loads the relevant skill. Mode-specific skill directories from the legacy extension are no longer supported.

Every loaded skill is also a slash command. Type `/skill-name` to invoke a skill explicitly. When a skill shares its name with a custom command, the command keeps `/name` and the skill appears as `/name:skill`.

📖 [Kilo Code Skills Documentation](https://kilo.ai/docs/customize/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.kilo/commands/` (project) or `~/.config/kilo/commands/` (global)

**Invocation:** `/command-name`. Use **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`).

Kilo Code's documentation still calls these "workflows," but they are slash commands stored as Markdown files. A command file can carry optional frontmatter: `description`, `agent` (which agent runs it), `model`, and `subtask: true` (run it in a subagent session). Kilo Code migrates legacy `.kilocode/workflows/` files to `.kilo/commands/` on startup.

Because every skill is already a slash command, author factory engineering commands as skills (see [Commands](/commands)). Kilo Code picks them up from `.agents/skills/` with no extra sharing step.

📖 [Kilo Code Commands (Workflows) Documentation](https://kilo.ai/docs/customize/workflows)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Agents (formerly modes)

**Storage location:** `.kilo/agents/{agent-name}.md` or `.kilo/agent/{agent-name}.md` (project; legacy `.kilocode/agents/` is still read) or `~/.config/kilo/agents/` (global)

Kilo Code agents are Markdown files with YAML frontmatter. The filename becomes the agent name, and the Markdown body becomes the system prompt. Frontmatter fields include `description`, `mode`, `model`, `permission`, `color`, and `steps`. The `mode` field decides how the agent can be used:

| `mode` | How it is used |
|--------|----------------|
| `primary` | A user-facing agent you select directly (switch with **Tab**). Not available for delegation. |
| `subagent` | Available only for delegation through the `task` tool or an `@agent-name` mention. Runs in its own isolated session. |
| `all` | Both. This is the default for custom agents. |

Define factory engineering specialists (spec writer, test writer, reviewer) as `mode: subagent` so an orchestrating workflow can delegate to them. Define an orchestrator you select by hand as `mode: primary`.

Kilo Code migrates legacy `.kilocodemodes` definitions automatically: `roleDefinition` and `customInstructions` become the prompt, `groups` become `permission`, and `whenToUse` becomes `description`.

**Example agent definition (`.kilo/agents/spec-writer.md`):**

```markdown
---
description: Technical specification writer. Use to transform a user story into a detailed, unambiguous technical spec.
mode: subagent
permission:
  bash: deny
---

You are a technical specification writer.

At the start of each task, read `.claude/agent-memory/spec-writer/MEMORY.md`.
At the end of each task, append your learnings to that file.

Write specs that include a clear feature description, user flows, data model, API contracts, and acceptance criteria.
```

**Memory:** Kilo Code has no native per-agent memory. The instructions in the prompt implement the factory engineering memory pattern. Use `.claude/agent-memory/{agent-name}/MEMORY.md` so the same memory file works with Claude Code's native agent memory.

**Invoking an agent:** Mention it with `@agent-name`, or let a primary agent delegate to it.

📖 [Kilo Code Custom Subagents Documentation](https://kilo.ai/docs/customize/custom-subagents) · [Kilo Code Custom Modes (legacy)](https://kilo.ai/docs/customize/custom-modes)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Full

Primary agents (Code, Plan, Debug) delegate to subagents with the `task` tool. Each subagent runs in an isolated session and returns a result summary to the parent. Subagents run in the foreground or in the background (`background: true`), and several can run in parallel. Kilo Code ships two built-in subagents, `general` and `explore`, alongside any custom `mode: subagent` agents you define.

Orchestrator mode, which delegated with `new_task()`, is deprecated and scheduled for removal. Use subagent delegation instead.

Invoke a factory engineering workflow with **slash-workflow at-artifact** (e.g. `/tdd-cycle @docs/specs/order-validation.md`). The primary agent reads the workflow, then delegates each step to the named subagents in `.kilo/agents/`. **Kilo Swarm** gives the session and its subagents a shared board for coordination, and **Agent Manager** runs parallel sessions in separate worktrees.

📖 [Kilo Code Custom Subagents](https://kilo.ai/docs/customize/custom-subagents) · [Orchestrator Mode (deprecated)](https://kilo.ai/docs/code-with-ai/agents/orchestrator-mode)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Kilo Code Skills Documentation](https://kilo.ai/docs/customize/skills)
- [Kilo Code Commands (Workflows) Documentation](https://kilo.ai/docs/customize/workflows)
- [Kilo Code Custom Subagents Documentation](https://kilo.ai/docs/customize/custom-subagents)
- [Kilo Code Custom Modes Documentation (legacy)](https://kilo.ai/docs/customize/custom-modes)
- [Kilo Code Orchestrator Mode (deprecated)](https://kilo.ai/docs/code-with-ai/agents/orchestrator-mode)
