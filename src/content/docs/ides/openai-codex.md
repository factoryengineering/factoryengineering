---
title: OpenAI Codex
description: Complete factory engineering guide for OpenAI Codex — skills, sub-agent workflows, and custom agent roles via TOML profiles.
---

# OpenAI Codex

OpenAI Codex adopted the Agent Skills open standard in December 2025, reaching parity with the rest of the AI IDE ecosystem. In March 2026, Codex added **sub-agents** with custom TOML-defined roles, enabling parallel delegation and workflow orchestration. Codex loads skills from `.agents/skills/` and evaluates each skill's `description` to decide when to load it — the same progressive disclosure model used by Claude Code, Cursor, and Copilot.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes — adopted December 2025

| Scope | Path |
|-------|------|
| Project | `.agents/skills/` |
| User | `~/.agents/skills/` |
| Admin | `/etc/agents/skills/` |

Codex uses the shared `.agents/skills/` convention (not a Codex-specific folder) and evaluates each skill's `description` via progressive disclosure to decide when to load it. Symlinks to a canonical skills directory are supported.

Create the symlink to your canonical location:

```bash
mkdir -p .agents
ln -s ../.claude/skills .agents/skills
```

Codex supports the standard `user-invocable` and `disable-model-invocation` frontmatter properties for controlling when a skill is loaded automatically versus invoked by name. Inside Codex, list loaded skills with the `/skills` command and invoke a skill explicitly by name with `$skill-name`.

📖 [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** Not natively supported as slash-command markdown files. Codex's primary reusable-instruction mechanism is the Agent Skills standard (`$skill-name` invocation), not per-file slash commands.

**Invocation:** Use `$skill-name` to invoke a skill explicitly, or `/skills` to list loaded skills. To use factory-engineering commands in Codex, author them as skills (one skill per command) under `.agents/skills/` so they are invocable by name.

For teams maintaining canonical `.claude/commands/*.md` files, the practical approach today is to either (a) wrap each command in a thin SKILL.md that references the command body, or (b) invoke commands by reading the markdown file directly from context. Native slash-command markdown parity (the pattern used by Claude Code, Cursor, Windsurf, Kilo Code, and Antigravity) is not supported.

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ⚠️ Partial

**Feature name:** Custom agents (sub-agents with role definitions)

**Storage location:** `.agents/` (TOML profiles)

OpenAI Codex added sub-agents with custom role definitions in March 2026. Each custom agent is defined in a TOML file that declares its role, tool access, and model. Codex ships with three built-in agents — `default`, `worker`, and `explorer` — and lets you author additional custom agents for specialized roles.

**Role specialization:** ✅ Custom agents are defined as TOML profiles with a distinct role, scoped tool access, and configurable model selection, so each agent runs in its own context for its delegated task.

**Persistent memory:** ❌ Not native. Codex agents start fresh each invocation; there is no built-in read/write memory slot per agent. The `AGENTS.md` file that Codex reads at session start is an **instruction document**, not an agent memory file or an agent implementation.

**Memory via markdown instruction:** Get the factory-engineering memory pattern by instructing each custom agent (in its TOML role definition or referenced skill) to read from a markdown file at the start of work and append learnings at the end. Use the path `.claude/agent-memory/{agent-name}/MEMORY.md` for cross-IDE compatibility.

📖 [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/agents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Yes — native sub-agent orchestration

Codex provides native workflow orchestration through its sub-agent system. The top-level agent spawns custom sub-agents in parallel, routes results between them, and manages thread lifecycle. Orchestration is configurable via:

- **`max_threads`** — maximum concurrent sub-agents (default: `6`)
- **Depth limits** — how deep sub-agents can spawn further sub-agents
- **Role delegation** — specialized agents are invoked by name from the orchestrator

This pattern maps directly to factory-engineering workflows: the top-level agent acts as the orchestrator, reads a workflow document, and delegates to named specialist agents (sub-agents) based on the workflow's branching and looping logic. Combined with the Agent Skills standard, Codex can run the same orchestration patterns as Claude Code and Kilo Code, with the caveat that specialist roles are TOML-defined rather than markdown-defined.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)
- [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/agents)
- [Agent Skills Standard](https://agentskills.io)
