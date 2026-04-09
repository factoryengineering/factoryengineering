---
title: IDEs
description: Dedicated guides for each AI IDE tracked by factory engineering — setup, configuration, and feature support across skills, commands, agents, and workflows.
---

# IDEs

Factory engineering works across seven major AI IDEs. Each IDE implements the same core concepts — skills, commands, agents, and workflows — but with different folder locations, invocation patterns, and levels of support.

Choose your IDE below for a dedicated guide covering everything you need to set up and use factory engineering with that tool.

---

## Supported IDEs

| IDE | Skills | Commands | Agents | Workflows | Guide |
|-----|--------|----------|--------|-----------|-------|
| [Claude Code](/ides/claude-code) | ✅ Native | ✅ `/command` | ✅ Sub-agents | ✅ Full orchestration | [→ Guide](/ides/claude-code) |
| [GitHub Copilot](/ides/github-copilot) | ✅ Native | ✅ `/command` | ✅ Custom agents | ⚠️ Partial (Fleet mode) | [→ Guide](/ides/github-copilot) |
| [Cursor](/ides/cursor) | ✅ Native | ✅ `/command` | ✅ Subagents | ⚠️ Partial (subagent delegation) | [→ Guide](/ides/cursor) |
| [Windsurf](/ides/windsurf) | ✅ Via copy or symlink | ✅ `/workflow` | ❌ No | ❌ No | [→ Guide](/ides/windsurf) |
| [Kilo Code](/ides/kilo-code) | ✅ Native | ✅ `/workflow` | ✅ Modes | ✅ Orchestrator Mode | [→ Guide](/ides/kilo-code) |
| [Google Antigravity](/ides/google-antigravity) | ✅ Via copy or symlink | ✅ `/workflow` | ✅ AgentKit 2.0 | ⚠️ Partial (Manager View) | [→ Guide](/ides/google-antigravity) |
| [OpenAI Codex](/ides/openai-codex) | ✅ Via copy or symlink | ⚠️ Needs investigation (`$skill-name`) | ⚠️ Custom agents (TOML) | ⚠️ Partial (sub-agent delegation) | [→ Guide](/ides/openai-codex) |

---

## How to Read the Guides

Each IDE guide is structured with the same sections:

- **Overview** — what the IDE is and how it fits into factory engineering
- **Skills** — folder locations, setup, sharing strategies (copy-on-change, symlinks)
- **Commands** — folder location, invocation pattern, format notes
- **Agents** — support status, feature name, storage, memory capability
- **Workflows** — orchestration support and notes
- **External docs** — links to official documentation

For conceptual background on each factory component, see the dedicated pages:

- [Skills](/skills) — what skills are, how to create and manage them
- [Commands](/commands) — what commands are, how to write and invoke them
- [Agents](/agents) — what agents are, how persistent memory works
- [Workflows](/workflows) — what workflows are, how orchestration works
