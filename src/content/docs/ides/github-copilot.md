---
title: GitHub Copilot
description: Complete factory engineering guide for GitHub Copilot — skills, commands, agents, and workflow orchestration.
---

# GitHub Copilot

GitHub Copilot is GitHub's AI coding assistant, available across VS Code, JetBrains IDEs, Eclipse, Xcode, and the Copilot CLI. It provides native Agent Skills support, custom agents with sub-agent delegation, and partial workflow orchestration via Fleet mode.

---

## Skills

**Supports Agent Skills standard:** ✅ Native — reads both `.claude/skills/` and `.github/skills/`

| Scope | Path |
|-------|------|
| Project (primary) | `.github/skills/` |
| Project (compatibility) | `.claude/skills/` |
| Personal (primary) | `~/.copilot/skills/` |
| Personal (compatibility) | `~/.claude/skills/` |

GitHub Copilot reads from both `.github/skills/` and `.claude/skills/` at the project level, which means **no symlink is needed** if you use `.claude/skills/` as your canonical location. Copilot will find your skills automatically.

Agent Skills work across the Copilot coding agent, Copilot CLI, and VS Code. Enable the `chat.useAgentSkills` setting in VS Code to activate the feature.

📖 [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.github/prompts/` (default workspace location). Additional folders can be listed in the `chat.promptFilesLocations` setting.

**Invocation:** Type `/` in the Chat view, then the prompt name (filename without `.prompt.md`). For example, `write-spec.prompt.md` → `/write-spec`. You can then add an artifact with `@artifact-name` (e.g. `/write-spec @submit-sales-order`).

**Format:** Prompt files use the `.prompt.md` extension (not plain `.md`). They support optional YAML frontmatter (`description`, `agent`, `tools`, etc.). See [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files) (VS Code 1.100+, April 2025).

**Syncing commands for Copilot:** Copilot expects `.prompt.md` files and optional frontmatter, so the same `.claude/commands/*.md` files cannot be used directly via symlink. Keep canonical commands in `.claude/commands/*.md` and **sync** them into `.github/prompts/` when you add or change commands.

**Use the factory-engineering skill** for sync (workflow, frontmatter rules, and batch script):

```bash
npx openskills install factoryengineering/skills
```

Then:

1. **When you add or change commands**, ask your agent to sync commands to Copilot, or run the skill's bundled script from repo root.
2. **Commit** the generated `.github/prompts/*.prompt.md` files so everyone on the team gets slash commands in VS Code.

Avoid maintaining `.github/prompts/` by hand so the canonical source stays `.claude/commands/`.

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Custom agents + sub-agents

**Storage location:** Repository: `.github/agents/{agent-name}.md`. Organization or enterprise: `/agents/{agent-name}.md` in a `.github-private` repository.

**Note:** Memory support requires Copilot Pro or Pro+ plan.

Custom agents are specialized versions of the Copilot coding agent that you tailor to your workflows, conventions, and use cases. You define them once with **agent profiles**: Markdown files with YAML frontmatter that specify name, description, prompt, and optionally tools or MCP servers. Custom agents, sub-agents, and the plan agent are GA across VS Code, JetBrains IDEs, Eclipse, and Xcode (announced March 11, 2026 via [GitHub Changelog](https://github.blog/changelog/)).

**Sub-agents:** Custom agents can spawn sub-agents to handle discrete subtasks within a session. A parent agent delegates work to a sub-agent, which runs in its own context with its own tool access, then returns results to the parent.

For factory-engineering-style persistent memory, include explicit instructions in the prompt to read from a markdown file at session start and append learnings at session end.

**Defining an agent:**

1. Create an agent profile as a Markdown file with YAML frontmatter.
2. Set `name` (unique identifier) and `description` (purpose and capabilities).
3. In the body, write the **prompt**: custom instructions that define the agent's behavior and expertise.
4. Optionally specify **tools** the agent can use.
5. For persistent memory, add instructions such as: "At the start of each session, read `path/to/memory.md`. At the end of each session, append your learnings to that file."
6. Save the file as `.github/agents/{agent-name}.md`.

**Invoking an agent:** After you create agent profiles, they appear in the Copilot coding agent on GitHub.com, Copilot coding agent in IDEs (VS Code, JetBrains, Eclipse, Xcode), and GitHub Copilot CLI.

📖 [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial (in-session sub-agent orchestration, but no workflow-document consumption)

**Fleet mode (`/fleet`):** The Copilot CLI reached GA on February 25, 2026 ([GitHub Changelog](https://github.blog/changelog/)) and introduced Fleet mode — in-session orchestration through parallel sub-agent spawning. Invoke `/fleet` to start a Fleet session where the orchestrator breaks down a task, spawns parallel sub-agents, and coordinates their work. Fleet mode runs in the Copilot CLI and operates within a single session. Note that Fleet mode provides task decomposition and parallel sub-agent coordination, but does not read a structured workflow document the way Claude Code or Kilo Code's orchestrators do — the orchestration is driven by the model's interpretation of the task, not by a workflow file.

**Agent HQ:** GitHub Agent HQ (Feb 2026) lets developers assign tasks to different agents and monitor progress in a single dashboard. Agent HQ is cross-agent task assignment — you route work between agents and review their output. Fleet mode and Agent HQ are complementary: Fleet mode handles in-session orchestration (one task, multiple parallel sub-agents), while Agent HQ handles cross-session coordination (multiple tasks, multiple agents, dashboard monitoring).

📖 [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/copilot-cli) · [GitHub Agent HQ](https://github.com/features/copilot/agents)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)
- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/copilot-cli)
- [GitHub Agent HQ](https://github.com/features/copilot/agents)
- [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
