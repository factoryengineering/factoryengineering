---
title: OpenAI Codex
description: Complete factory engineering guide for OpenAI Codex — skills, sub-agent workflows, and custom agent roles via TOML profiles.
---

# OpenAI Codex

OpenAI Codex implements the Agent Skills open standard, reaching parity with the rest of the AI IDE ecosystem. Codex also supports **sub-agents** with custom TOML-defined roles, enabling parallel delegation and workflow orchestration. Codex loads skills from `.agents/skills/` and evaluates each skill's `description` to decide when to load it — the same progressive disclosure model used by Claude Code, Cursor, and Copilot.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes

| Scope | Path |
|-------|------|
| Project | `.agents/skills/` |
| User | `~/.agents/skills/` |
| Admin | `/etc/codex/skills/` |

Codex scans `.agents/skills/` in every directory from the current working directory up to the repository root. It still loads the older `~/.codex/skills/` user location for backward compatibility; do not add new skills there.

Codex uses the shared `.agents/skills/` convention, the canonical factory engineering location, so **no copy or symlink is needed**. Codex does not read `.claude/skills/`. Codex evaluates each skill's `description` via progressive disclosure to decide when to load it.

Codex reads only `name` and `description` (plus `metadata.short-description`) from `SKILL.md`. It ignores Claude Code's `disable-model-invocation` and `user-invocable` properties. To reserve a skill for explicit invocation, add an `agents/openai.yaml` file inside the skill directory:

```yaml
policy:
  allow_implicit_invocation: false
```

Inside Codex, list loaded skills with the `/skills` command and invoke a skill explicitly by name with `$skill-name`.

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

**Supports true agents:** ✅ Yes (memory via markdown instruction)

**Feature name:** Custom agents (sub-agents with role definitions)

**Storage location:** TOML profiles — Project: `.codex/agents/`; User: `~/.codex/agents/`

OpenAI Codex supports sub-agents with custom role definitions. Each custom agent is a TOML file in `.codex/agents/` that declares `name`, `description`, and the required `developer_instructions` (the role prompt), plus any `config.toml` setting to override for that role, such as `model`, `model_reasoning_effort`, or `sandbox_mode`. Codex ships with three built-in roles (`default`, `worker`, and `explorer`) and lets you author additional custom agents for specialized roles.

```toml
# .codex/agents/spec-writer.toml
name = "spec-writer"
description = "Technical specification writer. Use to turn a user story into a detailed spec."
developer_instructions = """
You are a technical specification writer.
At the start of each task, read .claude/agent-memory/spec-writer/MEMORY.md.
At the end of each task, append your learnings to that file.
"""
model_reasoning_effort = "high"
```

**Role specialization:** ✅ Custom agents are defined as TOML profiles with a distinct role, scoped tool access, and configurable model selection, so each agent runs in its own context for its delegated task.

**Persistent memory:** ⚠️ Not per agent. Codex has a native **memories** feature (off by default; enable it in the `[memories]` section of `config.toml` or with `/memories`) that summarizes past sessions into `~/.codex/memories/` and injects the summary into later sessions. Those memories are global to the user, live outside the repository, and are not generated in sub-agent sessions, so they do not give each role its own shared memory. The `AGENTS.md` file that Codex reads at session start is an **instruction document**, not an agent memory file or an agent implementation.

**Memory via markdown instruction:** Get the factory-engineering memory pattern by instructing each custom agent (in its TOML role definition or referenced skill) to read from a markdown file at the start of work and append learnings at the end. Use the path `.claude/agent-memory/{agent-name}/MEMORY.md` for cross-IDE compatibility.

📖 [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/subagents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial — native sub-agent delegation, workflow-document consumption unverified

Codex provides native **sub-agent delegation**: the top-level agent spawns custom sub-agents in parallel, routes results between them, and manages thread lifecycle. Orchestration is configurable via:

- **`agents.max_threads`** — maximum concurrent sub-agents per session (default: `6`)
- **`agents.max_depth`** — how deep sub-agents can spawn further sub-agents (default: `1`)
- **Role delegation** — specialized TOML-defined agents are invoked by name from the parent agent

Whether Codex's parent agent reads a structured workflow document (the way Claude Code and Kilo Code orchestrators do) and routes based on its branching/looping logic has not been confirmed in official documentation at the time of writing. You can approximate workflow-driven orchestration by writing a detailed workflow markdown file and providing it to the parent agent as context, but there is no documented orchestrator-as-agent that reads a workflow file and delegates to named specialists based on its contents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)
- [OpenAI Codex Sub-Agents Documentation](https://developers.openai.com/codex/subagents)
- [Agent Skills Standard](https://agentskills.io)
