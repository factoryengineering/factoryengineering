---
title: Claude Code
description: Complete factory engineering guide for Claude Code — skills, commands, agents, and workflow orchestration.
---

# Claude Code

Claude Code is Anthropic's AI-native coding agent and the origin of many factory engineering conventions. It pioneered the Agent Skills open standard, native sub-agents, and workflow orchestration via the Agent tool (named the Task tool before v2.1.63). Claude Code is the reference implementation for many factory engineering patterns. It is also the one IDE that does not read the cross-tool `.agents/skills/` folder, so it needs a mirror of your canonical skills.

---

## Skills

**Supports Agent Skills standard:** ✅ Native implementation

| Scope | Path |
|-------|------|
| Project | `.claude/skills/` |
| Global | `~/.claude/skills/` |

Claude Code automatically detects skills in `.claude/skills/` and loads them into context when relevant to your request. Skills can also be invoked explicitly using the skill name in your prompt.

Claude Code extends the base standard with frontmatter that other IDEs do not read: invocation control (`disable-model-invocation`, `user-invocable`), forked execution (`context: fork` with `agent:` to pick the subagent type), path scoping (`paths`), and dynamic context injection (a line starting with `` !`command` `` runs the command and replaces itself with the output before the skill reaches the model). The `anthropics/skills` repository on GitHub provides official skills ready to use.

**Getting started:** Use the **skill-creator** skill to create new skills (see [Authoring Skills with skill-creator and skill-optimizer](/skills#authoring-skills-with-skill-creator-and-skill-optimizer)). It guides you through the workflow and produces a proper skill directory and SKILL.md.

**Sharing:** Claude Code does not read `.agents/skills/`, the canonical location. Generate `.claude/skills/` from it with a one-way rsync:

```bash
mkdir -p .agents/skills .claude/skills
rsync -a --delete .agents/skills/ .claude/skills/
```

Edit skills only in `.agents/skills/`, including when you work in Claude Code. Treat `.claude/skills/` as generated output, and do not keep Claude-specific skills there: `--delete` removes anything that is not in `.agents/skills/`. In an existing repository, migrate `.claude/skills/` first.

Automate this with a Git hook or a CI check so the copies stay in sync, and commit both folders. See [Mirror for Claude Code](/skills#mirror-for-claude-code) for the migration steps.

📖 [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.claude/commands/` (project) or `~/.claude/commands/` (global)

**Invocation:** `/command-name` — the filename without `.md` is the slash command (e.g. `write-spec.md` → `/write-spec`). Prefer `/command-name` for the command; the `@` symbol in **slash-command at-artifact** refers to the *artifact*, not the command.

Claude Code stores commands as markdown files; each file becomes a slash command. Use the recommended pattern: state in the command what the user will supply and instruct the LLM to stop and prompt if it's missing. Do not rely on `$ARGUMENTS` — commands are shared across IDEs and not all IDEs support it.

**Usage:**

```
/write-spec @submit-sales-order
```

📖 [Claude Code Slash Commands Documentation](https://code.claude.com/docs/en/slash-commands)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Sub-agents

**Storage location:** `.claude/agents/` (project) or `~/.claude/agents/` (global)

Claude Code provides native support for agents as defined in factory engineering. Each sub-agent operates in its own independent context window. The sub-agent has a role definition, reads persistent memory at the start of its session, and writes back to that memory after it completes its work.

**Native memory:** Set `memory: project` in the agent's frontmatter. Claude Code stores the agent's memory in `.claude/agent-memory/{agent-name}/MEMORY.md` and injects the first 200 lines (up to 25 KB) into the agent's prompt at the start of each invocation. Commit that folder so the whole team shares what the agent learns. (`memory: user` stores it in `~/.claude/agent-memory/`; `memory: local` stores it in `.claude/agent-memory-local/` for uncommitted use.)

**Defining an agent:**

1. Ask Claude Code to create a project-level subagent in `.claude/agents/{agent-name}.md`.
2. In the request, give the name of the agent, what it will expect, and the specific role you want it to play.
3. Be specific about the expected behavior and operating rules.
4. Specify the frontmatter: `name`, `description`, `model` (`sonnet`, `opus`, `haiku`, a full model ID, or `inherit`), `color`, and `memory: project`. Restrict `tools` when the role does not need them.
5. Review the agent definition and commit it.

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

Invoke with **slash-workflow at-artifact** (e.g. `/tdd-cycle @path/to/design.md`). The main agent reads the workflow from `.claude/commands/` and the artifact you supplied, then uses the Agent tool to delegate work to named subagents. The orchestrator reads the workflow, assesses the situation, and dynamically routes work based on what it discovers. It loops, branches, and coordinates parallel work according to the workflow.

By default, a subagent can spawn subagents of its own, up to three levels below the main conversation. Keep delegation at the orchestrator level: the workflow coordinates specialists, and specialists do their own work. Remove `Agent` from a specialist's `tools` list (or add it to `disallowedTools`) so it cannot delegate further.

**Where workflows live:** In `.claude/commands/`, one file per workflow (e.g. `tdd-cycle.md`). Invoke with `/tdd-cycle @path/to/design.md`.

Define an orchestrator subagent that is restricted to specific tools and subagents, and that is instructed to read a given workflow file before starting. That makes the orchestrator a reusable, named agent the team can invoke by name.

📖 [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
📖 [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)
