---
title: Cursor
description: Complete factory engineering guide for Cursor — skills, commands, agents, and workflow orchestration.
---

# Cursor

Cursor is an AI-native code editor built on VS Code. It supports the Agent Skills standard with both its own `.cursor/` folder and `.claude/` compatibility, custom slash commands, subagents with async delegation, and a Plugins marketplace. The Agents Window (v3.0, April 2026) adds parallel agent execution across repos and worktrees.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes — primary `.cursor/skills/`, compatibility `.claude/skills/`

| Scope | Path |
|-------|------|
| Project (primary) | `.cursor/skills/` |
| Project (compatibility) | `.claude/skills/` |
| Global (primary) | `~/.cursor/skills/` |
| Global (compatibility) | `~/.claude/skills/` |

Cursor looks for skills in `.cursor/skills/` first, then in `.claude/skills/` for compatibility — similar to GitHub Copilot. If you use `.claude/skills/` as your canonical location, **no symlink is needed**; Cursor will find your skills automatically. Skills are loaded when they match your request, based on the `description` field in each `SKILL.md` frontmatter.

**Plugins (March 2026):** Cursor's Plugins system integrates skills as first-class plugin components. The [Cursor Marketplace](https://cursor.com/marketplace) distributes plugin packages that bundle skills alongside subagents, MCP servers, hooks, and rules into one-click installs. Skills installed via plugins follow the same `SKILL.md` format and discovery mechanism — the plugin system supplements the folder convention, it does not replace it. Project-scoped skills committed to `.claude/skills/` continue to work unchanged alongside plugin-delivered skills.

📖 [Cursor Agent Skills Documentation](https://cursor.com/docs/skills) · [Cursor Marketplace](https://cursor.com/marketplace)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.cursor/commands/` (project) or `~/.cursor/commands/` (global)

**Invocation:** `/command-name` — filename without `.md` becomes the slash command. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`). Follow the recommended pattern (state what the user supplies; stop and prompt if missing). Do not rely on `$ARGUMENTS` — commands are shared via symlinks and not all IDEs support it.

**Usage:**

```
/write-spec @submit-sales-order
```

Since Cursor uses `.cursor/commands/` and the canonical commands live in `.claude/commands/`, create a symlink:

```bash
ln -s ../.claude/commands .cursor/commands
```

**Built-in commands (v3.0):** Cursor 3 added `/worktree` (creates an isolated git worktree so agents work without conflicts) and `/best-of-n` (runs the same prompt across multiple models in parallel worktrees and compares results). These are built-in commands, not user-defined — your custom commands in `.cursor/commands/` continue to work alongside them.

📖 [Cursor Custom Commands Documentation](https://docs.cursor.com/chat/custom-commands)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Subagents + Plugins

**Storage location:** `.cursor/agents/` (project); `~/.cursor/agents/` (global)

Cursor reintroduced agent support in v2.4 (January 2026) with **subagents** — independent agents that handle discrete parts of a parent agent's task. Each subagent runs in its own context with configurable prompts, tool access, and model selection.

**Built-in subagents:** Explore (codebase navigation), Bash (shell commands), and Browser (browser interactions).

**Custom subagents** are Markdown files with YAML frontmatter stored in `.cursor/agents/` (project-scoped) or `~/.cursor/agents/` (global). Frontmatter fields include `name`, `description`, `model` (inherit, fast, or a specific model ID), `readonly`, and `is_background`.

**Async subagents (v2.5):** Subagents can run asynchronously — the parent continues working while subagents execute in the background. Subagents can also spawn their own subagents, creating a tree of coordinated work.

**Plugins (v2.5):** The [Cursor Marketplace](https://cursor.com/marketplace) packages skills, subagents, MCP servers, hooks, and rules into one-click installs.

**Agents Window (v3.0, April 2026):** A standalone workspace for running many agents in parallel across repos, worktrees, and cloud environments. Agent Tabs display multiple chats side-by-side in a grid. New commands include `/worktree` and `/best-of-n`. **Design Mode** lets you annotate UI elements in the browser to give agents precise visual feedback.

**Memory:** Instruct agents via `.cursor/rules` or `AGENTS.md` to read from a markdown file at the start of work and append learnings at the end.

📖 [Cursor Subagents Documentation](https://cursor.com/docs/subagents) · [Cursor Changelog](https://cursor.com/changelog)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial

Cursor's Agents Window (v3.0, April 2026) lets you run many agents in parallel across repos, worktrees, and cloud environments. A parent agent can delegate work to custom subagents defined in `.cursor/agents/`, and subagents can spawn their own subagents (v2.5+), creating a tree of coordinated work.

However, Cursor does not have a dedicated orchestrator that reads a workflow document and delegates to named specialists based on its contents. The delegation is ad-hoc — the parent agent decides how to split work based on its prompt, not by following a structured workflow file. You can approximate workflow-driven orchestration by writing detailed instructions in a command file and relying on the parent agent to follow them, but there is no enforcement layer.

**Closest pattern:** Write a command in `.cursor/commands/` that describes phases and specialist subagents. Invoke it with `/command-name @artifact`. The parent agent reads the command and delegates to subagents, but routing logic depends on the model's interpretation rather than a built-in orchestration engine.

📖 [Cursor Subagents Documentation](https://cursor.com/docs/subagents) · [Cursor Agents Window](https://cursor.com/changelog/3-0)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Cursor Agent Skills Documentation](https://cursor.com/docs/skills)
- [Cursor Marketplace](https://cursor.com/marketplace)
- [Cursor Custom Commands Documentation](https://docs.cursor.com/chat/custom-commands)
- [Cursor Subagents Documentation](https://cursor.com/docs/subagents)
- [Cursor Changelog](https://cursor.com/changelog)
