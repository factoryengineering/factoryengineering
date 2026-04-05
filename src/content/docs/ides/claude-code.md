---
title: Claude Code
description: Complete factory engineering guide for Claude Code — skills, commands, agents, and workflow orchestration.
---

# Claude Code

Claude Code is Anthropic's AI-native coding agent and the origin of many factory engineering conventions. It pioneered the Agent Skills open standard, native sub-agents, and workflow orchestration via the Task tool. Claude Code is the canonical reference implementation for factory engineering — the `.claude/` folder structure is the recommended canonical location for skills and commands across all IDEs.

---

## Skills

**Supports Agent Skills standard:** ✅ Native implementation

| Scope | Path |
|-------|------|
| Project | `.claude/skills/` |
| Global | `~/.claude/skills/` |

Claude Code automatically detects skills in `.claude/skills/` and loads them into context when relevant to your request. Skills can also be invoked explicitly using the skill name in your prompt.

Claude Code extends the base standard with additional features including invocation controls and dynamic context injection. The `anthropics/skills` repository on GitHub provides a growing collection of community and official skills ready to use.

**Getting started:** Use the **skill-creator** skill to create new skills (see [Installing skill-creator and skill-optimizer](/skills#installing-skill-creator-and-skill-optimizer)). It guides you through the workflow and produces a proper skill directory and SKILL.md.

**Symlinks:** Claude Code's `.claude/skills/` is the recommended canonical location. No symlink needed — other IDEs symlink *to* this folder.

📖 [Claude Code Skills Documentation](https://code.claude.com/docs/en/slash-commands)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.claude/commands/` (project) or `~/.claude/commands/` (global)

**Invocation:** `/command-name` — the filename without `.md` is the slash command (e.g. `write-spec.md` → `/write-spec`). Prefer `/command-name` for the command; the `@` symbol in **slash-command at-artifact** refers to the *artifact*, not the command.

Claude Code stores commands as markdown files; each file becomes a slash command. Use the recommended pattern: state in the command what the user will supply and instruct the LLM to stop and prompt if it's missing. Do not rely on `$ARGUMENTS` — commands are shared via symlinks and not all IDEs support it.

**Usage:**

```
/write-spec @submit-sales-order
```

**Symlinks:** Claude Code's `.claude/commands/` is the canonical location. Other IDEs symlink *to* this folder.

📖 [Claude Code Slash Commands Documentation](https://code.claude.com/docs/en/slash-commands)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Sub-agents

**Storage location:** `.claude/agents/` (project) or `~/.claude/agents/` (global)

Claude Code provides native support for agents as defined in factory engineering. Each sub-agent operates in its own independent context window. The sub-agent has a role definition, reads persistent memory at the start of its session, and writes back to that memory after it completes its work.

**Defining an agent:**

1. In Claude Code, use the `/agents` command to create a new agent.
2. Select to create a new project-level agent with Claude.
3. In the description, give the name of the agent, what it will expect, and the specific role you want it to play.
4. Be specific about the expected behavior and operating rules.
5. Select the model, color, and memory location.
6. Review the agent definition and confirm.

**Invoking an agent:**

```
@"tdd-test-writer (agent)" write a failing test for: add a new pipeline step that filters items based on a predicate
```

The agent reads its memory file, writes the test, and appends new learnings to the memory file.

📖 [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ✅ Full

Invoke with **slash-workflow at-artifact** (e.g. `/tdd-cycle @path/to/design.md`). The main agent reads the workflow from `.claude/commands/` and the artifact you supplied, then uses the Task tool to delegate work to named subagents. The orchestrator reads the workflow, assesses the situation, and dynamically routes work based on what it discovers. It loops, branches, and coordinates parallel work according to the workflow.

Subagents cannot spawn other subagents. Only the main orchestrator can delegate. The workflow sits at the orchestrator level, coordinating specialists below it.

**Where workflows live:** In `.claude/commands/`, one file per workflow (e.g. `tdd-cycle.md`). Invoke with `/tdd-cycle @path/to/design.md`.

Define an orchestrator subagent that is restricted to specific tools and subagents, and that is instructed to read a given workflow file before starting. That makes the orchestrator a reusable, named agent the team can invoke by name.

📖 [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
📖 [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/slash-commands)
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)
