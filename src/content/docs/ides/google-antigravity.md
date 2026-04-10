---
title: Google Antigravity
description: Complete factory engineering guide for Google Antigravity — skills, commands, agents via AgentKit 2.0, and Manager View orchestration.
---

# Google Antigravity

Google Antigravity is an AI-native IDE powered by Gemini. It uses progressive disclosure for skills, supports commands via `.agent/workflows/`, and provides multi-agent orchestration through AgentKit 2.0's Manager View (March 2026). AgentKit 2.0 ships with 16 specialized agents across frontend, backend, testing, and DevOps roles, with support for assigning different models (Gemini, Claude, GPT) to each agent.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes, using its own folder structure

| Scope | Path |
|-------|------|
| Project | `.agent/skills/` |
| Global | `~/.gemini/antigravity/skills/` |

Antigravity uses progressive disclosure for skills — each skill sits dormant until a request matches its description, at which point it is loaded into the agent's context. **AgentKit 2.0** (March 2026) added multi-agent orchestration via Manager View but did not change skills loading: skills still live in `.agent/skills/` and are loaded on-demand by whichever specialized agent is handling the task.

Antigravity uses `.agent/skills/` at the project level. Share skills from your canonical location using copy-on-change or a symlink:

**Rsync (recommended):**

```bash
# Gather any local changes back to canonical, then mirror
[ -d .agent/skills ] && rsync -a .agent/skills/ .claude/skills/
mkdir -p .agent/skills
rsync -a --delete .claude/skills/ .agent/skills/
```

Automate with a Git hook or file watcher so copies stay in sync. See [Skills — Sync with rsync](/skills#strategy-1--sync-with-rsync-recommended-for-most-teams) for the full two-step pattern covering all IDEs.

**Symlink (macOS/Linux only):**

```bash
ln -s ../.claude/skills .agent/skills
```

Symlinks require macOS/Linux and may not work on Windows clones. See [Skills — Managing Skills Across IDEs](/skills#managing-skills-across-ides) for details on caveats and alternatives.

📖 [Google Antigravity Skills Documentation](https://antigravity.google/docs/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.agent/workflows/` (project)

**Invocation:** `/workflow-name` — Antigravity treats files in `.agent/workflows/` as workflows. With the symlink, your `.claude/commands/` files appear there. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`).

Share your canonical commands folder using copy-on-change or a symlink:

**Rsync (recommended):**

```bash
[ -d .agent/workflows ] && rsync -a .agent/workflows/ .claude/commands/
mkdir -p .agent/workflows
rsync -a --delete .claude/commands/ .agent/workflows/
```

**Symlink (macOS/Linux only):**

```bash
mkdir -p .agent
ln -s ../.claude/commands .agent/workflows
```

Without sharing, you would have to maintain a separate copy of commands in `.agent/workflows/`.

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** AgentKit 2.0 (specialized agents)

**Storage location:** IDE-managed profiles (Manager View)

Google Antigravity introduced agent support with **AgentKit 2.0** (March 2026). AgentKit 2.0 ships with 16 specialized agents across frontend, backend, testing, and DevOps roles, and each agent runs in its own context. You can assign a different model (Gemini, Claude, GPT) to each agent, so a reasoning-heavy role can run on one model while a fast-iteration role runs on another.

**Role specialization:** Each of the built-in agents has a distinct role definition and tool scope. AgentKit 2.0's **Manager View** lets you orchestrate multiple agents in parallel with asynchronous task execution, so specialized agents run side-by-side rather than as a single shared assistant.

**Persistent memory via markdown instruction:** AgentKit 2.0 does not provide a built-in persistent-memory slot per agent. Get the same pattern by instructing each agent via `AGENTS.md`, `GEMINI.md`, or a skill's `SKILL.md` to read from a markdown file at the start of work and append learnings at the end. For compatibility with Claude Code agents, use the path `.claude/agent-memory/{agent-name}/MEMORY.md`.

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial

Antigravity's **AgentKit 2.0 Manager View** (March 2026) orchestrates multiple specialized agents in parallel with asynchronous task execution. You can run frontend, backend, testing, and DevOps agents side-by-side, assign different models (Gemini, Claude, GPT) to each, and coordinate their output from a single view.

However, Manager View is UI-driven rather than workflow-document-driven. It does not read a structured workflow file the way Claude Code or Kilo Code's orchestrators do — routing and delegation are managed through the Manager View interface, not encoded in a `.claude/commands/{workflow}.md` file. You can approximate workflow-driven orchestration by writing detailed instructions in a command file and invoking agents from Manager View, but there is no orchestrator-as-agent that reads the workflow and delegates to named specialists based on its contents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Google Antigravity Skills Documentation](https://antigravity.google/docs/skills)
