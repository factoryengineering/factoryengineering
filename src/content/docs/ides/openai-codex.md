---
title: OpenAI Codex
description: Complete factory engineering guide for OpenAI Codex — skills, sub-agent workflows, and custom agent roles via TOML profiles.
---

# OpenAI Codex

OpenAI Codex is OpenAI's autonomous coding agent, available as a CLI tool, IDE extension, and web interface. Codex adopted the Agent Skills open standard in December 2025, reaching parity with the rest of the AI IDE ecosystem. In March 2026 (GA March 16), Codex added **sub-agents** with custom TOML-defined roles, enabling parallel delegation and workflow orchestration. Codex executes tasks in isolated cloud environments using worktrees for parallel execution. It loads skills from `.agents/skills/` and evaluates each skill's `description` to decide when to load it — the same progressive disclosure model used by Claude Code, Cursor, and Copilot.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes — adopted December 2025

| Scope | Path |
|-------|------|
| Project | `.agents/skills/` |
| User | `~/.agents/skills/` |
| Admin | `/etc/codex/skills/` |

Codex uses the shared `.agents/skills/` convention (not a Codex-specific folder). At the project level, Codex searches the current working directory, parent directories, and the repository root for `.agents/skills/`. It evaluates each skill's `description` via progressive disclosure to decide when to load it. Symlinks to a canonical skills directory are supported.

Create the symlink to your canonical location:

```bash
mkdir -p .agents
ln -s ../.claude/skills .agents/skills
```

Codex supports the standard `user-invocable` and `disable-model-invocation` frontmatter properties for controlling when a skill is loaded automatically versus invoked by name. Inside Codex, list loaded skills with the `/skills` command and invoke a skill explicitly by name with `$skill-name`. Codex also ships a built-in `$skill-creator` authoring tool for generating new skills interactively.

**Distribution via Plugins:** Codex supports a Plugins system for distributing skills as installable packages. This provides a distribution channel alongside the standard file-based approach.

📖 [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Slash-command markdown file support:** ⚠️ Needs investigation — Codex's primary reusable-instruction mechanism is the Agent Skills standard (`$skill-name` invocation, `/skills` to list loaded skills), and whether Codex also reads per-file slash-command markdown from a dedicated folder has not been confirmed in official documentation at the time of writing.

**Practical approach today:** Use skills. To share factory-engineering commands with a Codex user, author them as skills (one skill per command) under `.agents/skills/` so they are invocable by name via `$skill-name`. For teams maintaining canonical `.claude/commands/*.md` files, wrap each command in a thin SKILL.md that references the command body, or invoke commands by reading the markdown file directly from context.

This page will be updated once OpenAI's documentation confirms whether Codex supports slash-command markdown files alongside skills.

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ⚠️ Partial

**Feature name:** Custom agents (sub-agents with role definitions)

**Storage location:** TOML profiles — Project: `.codex/agents/`; User: `~/.codex/agents/`

OpenAI Codex added sub-agents with custom role definitions in March 2026 (GA March 16). Each custom agent is defined in a TOML file with required fields (`name`, `description`, `developer_instructions`) and optional fields (`model`, `sandbox_mode`, `mcp_servers`). Codex ships with three built-in agents — `default`, `worker`, and `explorer` — and lets you author additional custom agents for specialized roles.

**Role specialization:** ✅ Custom agents run in isolated context threads with separate tool access. Each TOML profile declares a distinct role, scoped tool access, and configurable model selection.

**Persistent memory:** ❌ Not native. Codex agents start fresh each invocation; there is no built-in read/write memory slot per agent. The `AGENTS.md` file that Codex reads at session start is an **instruction document**, not an agent memory file or an agent implementation.

**Memory via markdown instruction:** Get the factory-engineering memory pattern by instructing each custom agent (in its `developer_instructions` field or a referenced skill) to read from a markdown file at the start of work and append learnings at the end. Use the path `.claude/agent-memory/{agent-name}/MEMORY.md` for cross-IDE compatibility. This is the same workaround used in [Cursor](/ides/cursor#agents), [Windsurf](/ides/windsurf#agents), and [Antigravity](/ides/google-antigravity#agents).

📖 [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/subagents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial — native sub-agent delegation, workflow-document consumption unverified

Codex provides native **sub-agent delegation**: the top-level agent spawns custom sub-agents in parallel, routes results between them, and manages thread lifecycle. Orchestration is configurable via:

- **`max_threads`** — maximum concurrent sub-agents (default: `6`)
- **`max_depth`** — how deep sub-agents can spawn further sub-agents (default: `1`)
- **Per-agent timeouts** — configurable time limits for individual sub-agent tasks
- **Role delegation** — specialized TOML-defined agents (e.g. `explorer` for codebase search, `worker` for implementation, or custom roles like `reviewer` and `docs_researcher`) are invoked by name from the parent agent

Whether Codex's parent agent reads a structured workflow document (the way Claude Code and Kilo Code orchestrators do) and routes based on its branching/looping logic has not been confirmed in official documentation at the time of writing. You can approximate workflow-driven orchestration by writing a detailed workflow markdown file and providing it to the parent agent as context, but there is no documented orchestrator-as-agent that reads a workflow file and delegates to named specialists based on its contents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)
- [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/subagents)
- [OpenAI Codex Configuration Reference](https://developers.openai.com/codex/configuration)
- [OpenAI Codex Changelog](https://developers.openai.com/codex/changelog)
- [OpenAI Codex Product Page](https://openai.com/codex)
- [Agent Skills Standard](https://agentskills.io)
