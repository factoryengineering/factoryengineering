---
title: Google Antigravity
description: Complete factory engineering guide for Google Antigravity — skills, custom subagents, and orchestration.
---

# Google Antigravity

Google Antigravity is Google's agent-first development platform. It launched as an IDE in November 2025. **Antigravity 2.0** (Google I/O, May 2026) added a standalone desktop app, the `agy` command-line tool (which replaces Gemini CLI), and an SDK; the IDE remains available. Antigravity implements the Agent Skills standard, supports custom subagents that the main agent delegates to by name, and adds script-driven Dynamic Workflows. Version 2.0 moved project configuration from `.agent/` to `.agents/`.

---

## Skills

**Supports Agent Skills standard:** ✅ Native

| Scope | Path |
|-------|------|
| Project | `.agents/skills/` (legacy: `.agent/skills/`) |
| Global | `~/.gemini/config/skills/` (legacy, IDE only: `~/.gemini/antigravity/skills/`) |

Antigravity reads `.agents/skills/` directly, so **no copy or symlink is needed** when your canonical skills live there. Antigravity uses progressive disclosure: each skill sits dormant until a request matches its description, at which point the agent loads it into context. Invoke a skill explicitly with `/skill-name`.

Antigravity does not read `.claude/skills/`. It can import skills, commands, subagents, MCP servers, and instruction files from Claude Code, Codex, and Cursor configurations.

📖 [Google Antigravity Skills Documentation](https://antigravity.google/docs/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.agents/skills/` (author commands as skills)

**Invocation:** `/command-name`. Use **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`).

Antigravity's legacy **workflows** (files in `.agent/workflows/`) are deprecated. The `/migrate-workflows` command converts each workflow into `.agents/skills/{name}/SKILL.md` and keeps the original with a `.bak` suffix. When a skill and a legacy workflow share a name, the skill wins.

Author factory engineering commands as skills (see [Commands](/commands)). Antigravity picks them up from `.agents/skills/` with no extra sharing step.

📖 [Migrating workflows to skills](https://antigravity.google/docs/migration/workflows-to-skills)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Custom subagents

**Storage location:** `.agents/agents/{agent-name}.md` (project) or `~/.gemini/config/agents/{agent-name}.md` (global)

A custom subagent is a Markdown file with YAML frontmatter that marks it as a subagent and declares its description. Optional fields set its model (`inherit`, `flash`, or `pro`), tools, skills, and MCP servers. The Markdown body is the agent's role definition. The main agent delegates to a named subagent with the `invoke_subagent` tool, and can also define a one-off subagent during a session. Each subagent can share the workspace or run in its own git worktree.

**Instructions:** Antigravity reads `AGENTS.md` and `GEMINI.md` from the workspace and its parent folders up to the repository root, and modular rules from `.agents/rules/`.

**Memory:** Antigravity maintains a knowledge base that agents retrieve from and contribute to, but it does not give each subagent its own memory file. Get the factory engineering memory pattern by instructing each subagent, in its role definition, to read from a markdown file at the start of work and append learnings at the end. Use the path `.claude/agent-memory/{agent-name}/MEMORY.md` so the same memory file works with Claude Code's native agent memory.

📖 [Google Antigravity Subagents Documentation](https://antigravity.google/docs/subagents) · [Rules Documentation](https://antigravity.google/docs/rules)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Yes

Invoke a factory engineering workflow with **slash-workflow at-artifact** (e.g. `/tdd-cycle @docs/specs/order-validation.md`). Store the workflow as a skill. The main agent reads it and delegates each step to the named custom subagents with `invoke_subagent`. Several subagents can run at once.

Antigravity 2.0 adds two more coordination features:

- **`/swarm`** coordinates several subagents over a shared message board.
- **Dynamic Workflows** (`/run-workflow`, rolling out to AI Pro and Ultra plans from November 2026) have the agent write a Python script that coordinates subagents in parallel or in sequence. You approve the script before it runs. This is script-driven orchestration rather than workflow-document orchestration (see [Workflows](/workflows)).

📖 [Google Antigravity Dynamic Workflows](https://antigravity.google/docs/dynamic-workflows) · [Introducing Google Antigravity 2.0](https://antigravity.google/blog/introducing-google-antigravity-2)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Google Antigravity Skills Documentation](https://antigravity.google/docs/skills)
- [Migrating workflows to skills](https://antigravity.google/docs/migration/workflows-to-skills)
- [Google Antigravity Subagents Documentation](https://antigravity.google/docs/subagents)
- [Google Antigravity Rules Documentation](https://antigravity.google/docs/rules)
- [Google Antigravity Dynamic Workflows](https://antigravity.google/docs/dynamic-workflows)
- [Google Antigravity Changelog](https://antigravity.google/docs/changelog)
