---
title: Cursor
description: Complete factory engineering guide for Cursor — skills, commands, agents, and workflow orchestration.
---

# Cursor

Cursor is an AI-native code editor built on VS Code. It supports the Agent Skills standard with both its own `.cursor/` folder and `.claude/` compatibility, custom slash commands, subagents with async delegation, and a Plugins marketplace. The Agents Window (v3.0, April 2026) adds parallel agent execution across repos and worktrees.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes — reads `.agents/skills/`, `.cursor/skills/`, and compatibility folders

| Scope | Path |
|-------|------|
| Project | `.agents/skills/`, `.cursor/skills/` |
| Project (compatibility) | `.claude/skills/`, `.codex/skills/` |
| Global | `~/.agents/skills/`, `~/.cursor/skills/` |
| Global (compatibility) | `~/.claude/skills/`, `~/.codex/skills/` |

Cursor reads `.agents/skills/` directly, so **no copy or symlink is needed** for the canonical location. Cursor also reads the `.claude/skills/` mirror kept for Claude Code; keep that mirror exact so both copies match. Skills are loaded when they match your request, based on the `description` field in each `SKILL.md` frontmatter. Skills in nested folders (for example `apps/web/.cursor/skills/`) surface only when the agent works in that folder.

**Plugins (v2.5, February 2026):** Cursor's Plugins system integrates skills as first-class plugin components. The [Cursor Marketplace](https://cursor.com/marketplace) distributes plugin packages that bundle skills alongside subagents, MCP servers, hooks, and rules into one-click installs (browse the marketplace or run `/add-plugin`). Skills installed via plugins follow the same `SKILL.md` format and discovery mechanism — the plugin system supplements the folder convention, it does not replace it. Project-scoped skills committed to `.agents/skills/` continue to work unchanged alongside plugin-delivered skills.

📖 [Cursor Agent Skills Documentation](https://cursor.com/docs/skills) · [Cursor Marketplace](https://cursor.com/marketplace)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.agents/skills/{command-name}/SKILL.md` (canonical; read directly)

**Invocation:** `/command-name`. Use **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`). Follow the recommended pattern (state what the user supplies; stop and prompt if missing). Do not rely on `$ARGUMENTS`. Commands are shared across IDEs, and not all IDEs support it.

Author commands as skills with `disable-model-invocation: true` (see [Commands](/commands#example-command)). Cursor reads them from `.agents/skills/`, so no sharing step is needed. Cursor's built-in `/migrate-to-skills` command converts legacy `.cursor/commands/*.md` files into skills with the same property; move the results into `.agents/skills/`.

**Usage:**

```
/write-spec @docs/user-stories/submit-sales-order.md
```

**Built-in commands (v3.0):** Cursor 3 added `/worktree` (creates an isolated git worktree so agents work without conflicts) and `/best-of-n` (runs the same prompt across multiple models in parallel worktrees and compares results). These are built-in commands. Your command skills continue to work alongside them.

📖 [Cursor Skills Documentation](https://cursor.com/docs/skills)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Subagents + Plugins

**Storage location:** `.cursor/agents/` (project); `~/.cursor/agents/` (global)

Cursor reintroduced agent support in v2.4 (January 2026) with **subagents** — independent agents that handle discrete parts of a parent agent's task. Each subagent runs in its own context with configurable prompts, tool access, and model selection.

**Built-in subagents:** Cursor ships built-in subagents for codebase research and for running terminal commands.

**Custom subagents** are Markdown files with YAML frontmatter stored in `.cursor/agents/` (project-scoped) or `~/.cursor/agents/` (global). Frontmatter fields include `name`, `description`, `model` (`inherit`, `fast`, or a specific model ID), and `readonly`. Cursor also reads Claude Code agents from `.claude/agents/` (and `.codex/agents/`); when names collide, the `.cursor/agents/` definition wins.

**Async subagents (v2.5):** Subagents can run asynchronously — the parent continues working while subagents execute in the background. Subagents can also spawn their own subagents, creating a tree of coordinated work.

**Plugins (v2.5):** The [Cursor Marketplace](https://cursor.com/marketplace) packages skills, subagents, MCP servers, hooks, and rules into one-click installs.

**Agents Window (v3.0, April 2026):** A standalone workspace for running many agents in parallel across repos, worktrees, cloud environments, and SSH hosts. New commands include `/worktree` and `/best-of-n`. **Design Mode** lets you annotate UI elements in the browser to give agents precise visual feedback.

**Memory:** Instruct agents via `.cursor/rules` or `AGENTS.md` to read from a markdown file at the start of work and append learnings at the end.

📖 [Cursor Subagents Documentation](https://cursor.com/docs/subagents) · [Cursor Changelog](https://cursor.com/changelog)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Yes

Invoke a workflow with **slash-workflow at-artifact** (e.g. `/tdd-cycle @docs/specs/order-validation.md`). Store the workflow as a command skill in `.agents/skills/`. The parent agent reads it and delegates each step to the named subagents in `.cursor/agents/` (or `.claude/agents/`). Cursor delegates when a prompt names a subagent by `/name` or in plain language, and subagents can run asynchronously and spawn their own subagents (v2.5+).

**Test delegation.** Forum reports show the parent agent sometimes ignores an explicit subagent request and does the work itself. Add an orchestration rule to every workflow ("Never write tests yourself; always delegate to tdd-test-writer") and verify in a clean session that each step reaches the named subagent.

**Other ways Cursor runs agents in parallel:**

- The **Agents Window** (v3.0, April 2026) runs many agents in parallel across repos, worktrees, cloud environments, and SSH hosts.
- **Projects** (beta, September 2026) add a coordinator agent that plans long-running work and hands tasks to parallel agents, running on Cloud Agents by default.

📖 [Cursor Subagents Documentation](https://cursor.com/docs/subagents) · [Cursor Agents Window](https://cursor.com/changelog/3-0) · [Cursor Projects](https://cursor.com/changelog/projects)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Cursor Agent Skills Documentation](https://cursor.com/docs/skills)
- [Cursor Marketplace](https://cursor.com/marketplace)
- [Cursor Commands Documentation](https://cursor.com/docs/context/commands)
- [Cursor Subagents Documentation](https://cursor.com/docs/subagents)
- [Cursor Changelog](https://cursor.com/changelog)
