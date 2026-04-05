---
title: Kilo Code
description: Complete factory engineering guide for Kilo Code — skills, commands, agents (modes), and workflow orchestration.
---

# Kilo Code

Kilo Code is an open-source VS Code extension with a model aggregator backend that gives you access to 500+ models — including Claude, Gemini, and GPT series — with pay-per-token billing at raw provider rates. This makes it a flexible choice for teams that want model independence without committing to a single vendor. Kilo Code was one of the first agents to natively implement the Agent Skills specification and provides full workflow orchestration via its built-in Orchestrator Mode.

---

## Skills

**Supports Agent Skills standard:** ✅ Native — one of the first agents to adopt the standard

| Scope | Path |
|-------|------|
| Project | `.kilocode/skills/` |
| Global | `~/.kilocode/skills/` |

Kilo Code loads skills from `.kilocode/skills/`. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .kilocode/skills
```

Kilo Code was one of the first agents to natively implement the Agent Skills specification with zero-configuration detection. Skills are evaluated before every response — the agent checks all skill descriptions against your request and loads the most relevant one.

Kilo Code also supports mode-specific skills that activate only in specific modes (Code, Architect, Debugger, Orchestrator), which is especially useful for factory engineering workflows where different agents operate in different modes.

📖 [Kilo Code Skills Documentation](https://kilo.ai/docs/customize/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.kilocode/workflows/` (project) or `~/.kilocode/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

Kilo Code calls them "workflows" — this is Kilo Code's storage mechanism for commands, not factory engineering workflows. Kilo Code workflows are markdown files that define a sequence of steps.

**Usage:**

```
/write-spec @submit-sales-order
```

Use a symlink so `.kilocode/workflows` points to `.claude/commands`:

```bash
ln -s ../.claude/commands .kilocode/workflows
```

📖 [Kilo Code Workflows Documentation](https://kilo.ai/docs/customize/workflows)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Modes

**Storage location:** Project modes: `.kilocodemodes` in the project root (YAML). Rules: `.kilo/rules-{slug}/` or `.kilorules-{slug}`

Kilo Code modes are true agents that work within their own context window. Modes support a role definition, custom instructions, and mode-specific rules from `.kilo/rules-{slug}/`. By adding instructions such as "At the start of each session, read from `.claude/agent-memory/{mode-name}/MEMORY.md`; at the end, append your learnings to that file," a mode implements the persistent, read/write memory pattern.

**Example mode definition:**

```yaml
customModes:
  - slug: spec-writer
    name: 📝 Spec Writer
    description: Technical specification writer. Transforms user stories into detailed, unambiguous technical specs.
    roleDefinition: |
      You are a technical specification writer.
      At the start of each session, read .claude/agent-memory/spec-writer/MEMORY.md.
      At the end of each session, append your learnings to that file.
      Write specs that include clear feature description, user flows, data model, API contracts, and acceptance criteria.
    groups:
      - read
      - - edit
        - fileRegex: \.(md|mdx)$
          description: Markdown and MDX only
    customInstructions: Update your agent memory with team patterns, standards learned, and spec conventions you discover.
```

**Note:** The `- - edit` is not a typo. In Kilo Code, `groups` is a list: each entry is either a capability string (e.g. `read`) or a list whose first element is the capability (e.g. `edit`) and whose remaining elements are options for that capability.

📖 [Kilo Code Custom Modes Documentation](https://kilo.ai/docs/customize/custom-modes)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Full

Kilo Code has a built-in Orchestrator mode that breaks down complex tasks and delegates to other modes via `new_task()`. The Orchestrator reads the task, formulates a plan, and spawns work in other modes. Custom modes use a `whenToUse` field to guide delegation.

**Terminology:** Kilo Code's "Workflows" (in `.kilocode/workflows/`) are commands, but can be used for orchestration of agents. Create a symlink from `.claude/commands/` to `.kilocode/workflows/` so the same workflow file is available everywhere.

Factory engineering workflows are implemented in Kilo Code through Orchestrator Mode. Invoke a workflow using the *slash-workflow at-artifact* pattern (e.g. `/tdd-cycle @docs/specs/order-validation.md`).

Place orchestration instructions in a rule file the Orchestrator reads, then invoke with the same pattern: slash-workflow at-artifact.

📖 [Kilo Code Custom Modes](https://kilo.ai/docs/customize/custom-modes)
📖 [Kilo Code Orchestrator Mode](https://kilo.ai/docs/code-with-ai/agents/orchestrator-mode)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Kilo Code Skills Documentation](https://kilo.ai/docs/customize/skills)
- [Kilo Code Workflows Documentation](https://kilo.ai/docs/customize/workflows)
- [Kilo Code Custom Modes Documentation](https://kilo.ai/docs/customize/custom-modes)
- [Kilo Code Orchestrator Mode](https://kilo.ai/docs/code-with-ai/agents/orchestrator-mode)
