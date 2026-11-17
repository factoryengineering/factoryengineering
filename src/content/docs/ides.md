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
| [Claude Code](/ides/claude-code) | ✅ Native (`.claude/skills/` mirror) | ✅ As skills (`/skill` in CLI and IDE extensions) | ✅ Sub-agents | ✅ Subagent delegation | [→ Guide](/ides/claude-code) |
| [GitHub Copilot](/ides/github-copilot) | ✅ Native (`.agents/skills/`) | ✅ As skills (`/skill` in VS Code chat and Copilot CLI) | ✅ Custom agents | ✅ Subagent delegation | [→ Guide](/ides/github-copilot) |
| [Cursor](/ides/cursor) | ✅ Native (`.agents/skills/`) | ✅ As skills (`/skill` in editor and Agents Window) | ✅ Subagents | ✅ Subagent delegation | [→ Guide](/ides/cursor) |
| [Windsurf (Devin Desktop)](/ides/windsurf) | ✅ Native (`.agents/skills/`) | ✅ As skills (`@skill` in Devin Desktop) | ✅ Devin Local; subagents (preview) | ⚠️ Preview | [→ Guide](/ides/windsurf) |
| [Kilo Code](/ides/kilo-code) | ✅ Native (`.agents/skills/`) | ✅ As skills (`/skill` in VS Code extension and Kilo CLI) | ✅ Agents | ✅ Subagent delegation | [→ Guide](/ides/kilo-code) |
| [Google Antigravity](/ides/google-antigravity) | ✅ Native (`.agents/skills/`) | ✅ As skills (`/skill` in App, CLI, and IDE) | ✅ Custom subagents | ✅ Subagent delegation | [→ Guide](/ides/google-antigravity) |
| [OpenAI Codex](/ides/openai-codex) | ✅ Native (`.agents/skills/`) | ✅ As skills (`$skill-name` in Codex CLI) | ✅ Custom agents (TOML) | ✅ Subagent delegation | [→ Guide](/ides/openai-codex) |

---

## How to Read the Guides

Each IDE guide is structured with the same sections:

- **Overview** — what the IDE is and how it fits into factory engineering
- **Skills** — folder locations, setup, and sharing with the canonical `.agents/skills/` folder
- **Commands** — authoring commands as skills, invocation pattern, legacy formats
- **Agents** — support status, feature name, storage, memory capability
- **Workflows** — orchestration support and notes
- **External docs** — links to official documentation

For conceptual background on each factory component, see the dedicated pages:

- [Skills](/skills) — what skills are, how to create and manage them
- [Commands](/commands) — what commands are, how to write and invoke them
- [Agents](/agents) — what agents are, how persistent memory works
- [Workflows](/workflows) — what workflows are, how orchestration works
