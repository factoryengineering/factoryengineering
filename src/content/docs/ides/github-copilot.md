---
title: GitHub Copilot
description: Complete factory engineering guide for GitHub Copilot — skills, commands, agents, and workflow orchestration.
---

# GitHub Copilot

GitHub Copilot is GitHub's AI coding assistant, available in VS Code, Visual Studio, JetBrains IDEs, Eclipse, Xcode, the Copilot CLI, the GitHub Copilot app, and the Copilot cloud agent on GitHub.com (formerly the coding agent). It provides native Agent Skills support and custom agents with sub-agent delegation.

---

## Skills

**Supports Agent Skills standard:** ✅ Native — reads `.agents/skills/`, `.github/skills/`, and `.claude/skills/`

| Scope | Path |
|-------|------|
| Project | `.github/skills/`, `.agents/skills/`, `.claude/skills/` |
| Personal | `~/.copilot/skills/`, `~/.agents/skills/` |

GitHub Copilot reads `.github/skills/`, `.agents/skills/`, and `.claude/skills/` at the project level, which means **no copy or symlink is needed** for the canonical `.agents/skills/` location. Copilot will find your skills automatically. Because Copilot also reads the `.claude/skills/` mirror kept for Claude Code, keep that mirror exact so both copies match.

Agent Skills work across the Copilot cloud agent, Copilot code review, Copilot CLI, the Copilot app, and agent mode in VS Code, Visual Studio, and JetBrains IDEs. Skills are on by default in VS Code since version 1.109 (February 2026); no setting is required.

📖 [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/concepts/customizations/agent-skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.agents/skills/{command-name}/SKILL.md` (canonical; read directly)

**Invocation:** Type `/` in Copilot Chat or the Copilot CLI, then the skill name (e.g. `/write-spec`). Add the artifact with `@` (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`).

Author commands as skills with `disable-model-invocation: true` (see [Commands](/commands#example-command)). VS Code honors that property and lists the skill as a slash command. Copilot reads `.agents/skills/` directly, so no sharing step is needed.

**Do not author new prompt files.** Prompt files (`.github/prompts/*.prompt.md`) work only in VS Code's Local harness, which is deprecated and scheduled for removal by February 2027. The default Copilot harness (VS Code 1.143+) does not load them, and the Copilot CLI never did. Use VS Code's **Convert prompt files to skills** action to migrate existing prompt files, then move the results into `.agents/skills/`.

📖 [Migrate customizations in VS Code](https://code.visualstudio.com/docs/agent-customization/migrate-customizations) · [Use prompt files in VS Code (legacy)](https://code.visualstudio.com/docs/agent-customization/prompt-files)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes

**Feature name:** Custom agents + sub-agents

**Storage location:** Repository: `.github/agents/{agent-name}.agent.md`. Personal: `~/.copilot/agents/`. Organization: `/agents/` in the organization's `.github` or `.github-private` repository. Enterprise: `/agents/` in the designated `.github-private` repository. Copilot in VS Code and the Copilot CLI also read Claude Code agents from `.claude/agents/`.

**Copilot Memory** is available on all paid Copilot plans. It stores repository facts and user preferences, not per-agent memory, so use the markdown-instruction pattern below for factory engineering agents.

Custom agents are specialized versions of the Copilot coding agent that you tailor to your workflows, conventions, and use cases. You define them once with **agent profiles**: Markdown files with YAML frontmatter that specify name, description, prompt, and optionally tools or MCP servers. Custom agents and sub-agents are generally available in VS Code, the Copilot CLI, the cloud agent, and JetBrains IDEs (JetBrains GA announced March 11, 2026). Eclipse and Xcode support remains in preview.

**Sub-agents:** Custom agents can spawn sub-agents to handle discrete subtasks within a session. A parent agent delegates work to a sub-agent, which runs in its own context with its own tool access, then returns results to the parent.

For factory-engineering-style persistent memory, include explicit instructions in the prompt to read from a markdown file at session start and append learnings at session end.

**Defining an agent:**

1. Create an agent profile as a Markdown file with YAML frontmatter.
2. Set `name` (unique identifier) and `description` (purpose and capabilities).
3. In the body, write the **prompt**: custom instructions that define the agent's behavior and expertise.
4. Optionally specify **tools** the agent can use.
5. For persistent memory, add instructions such as: "At the start of each session, read `path/to/memory.md`. At the end of each session, append your learnings to that file."
6. Save the file as `.github/agents/{agent-name}.agent.md`.

**Invoking an agent:** After you create agent profiles, they appear in the agent picker in VS Code and JetBrains IDEs, in the Copilot cloud agent on GitHub.com, and in the Copilot CLI (`/agent`).

📖 [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/customizations/custom-agents)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Partial (in-session sub-agent orchestration, but no workflow-document consumption)

**`/fleet`:** The Copilot CLI reached GA on February 25, 2026. Its `/fleet` slash command (also the `--fleet` flag) breaks a task down, spawns parallel sub-agents, and coordinates their work within a single session. It runs in the Copilot CLI and the Copilot app. Note that `/fleet` provides task decomposition and parallel sub-agent coordination, but does not read a structured workflow document the way Claude Code or Kilo Code's orchestrators do — the orchestration is driven by the model's interpretation of the task, not by a workflow file.

**Agent HQ and third-party agents:** GitHub announced Agent HQ at Universe in October 2025. Since February 4, 2026, you can assign tasks on GitHub to third-party coding agents such as Claude and Codex (public preview) alongside Copilot and review their output in one place. This is cross-session task assignment, not orchestration within a session.

📖 [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli) · [Third-party coding agents](https://docs.github.com/en/copilot/concepts/agent-capabilities/about-agents/about-third-party-coding-agents)

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/concepts/customizations/agent-skills)
- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/customizations/custom-agents)
- [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Third-party coding agents](https://docs.github.com/en/copilot/concepts/agent-capabilities/about-agents/about-third-party-coding-agents)
- [Use prompt files in VS Code](https://code.visualstudio.com/docs/agent-customization/prompt-files)
