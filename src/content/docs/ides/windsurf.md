---
title: Windsurf (Devin Desktop)
description: Complete factory engineering guide for Windsurf, now Devin Desktop — skills, commands, subagents, and orchestration.
---

# Windsurf (Devin Desktop)

Cognition acquired Windsurf in July 2025 and renamed the editor **Devin Desktop** in June 2026. Devin Desktop adds **Devin Local**, a newer local agent that shares its harness with the Devin CLI, alongside the original Cascade agent. Sources differ on whether Cascade remains available in current releases, so check your version. Devin Desktop moves project configuration to `.devin/` and still reads the legacy `.windsurf/` folders and the cross-tool `.agents/` folder. Devin Local supports subagents (in preview), so Windsurf is no longer limited to a single shared agent. The agent and workflow features below are Devin Local's.

Documentation is moving from docs.windsurf.com to docs.devin.ai.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes

| Scope | Path |
|-------|------|
| Project | `.devin/skills/`, `.agents/skills/` (legacy: `.windsurf/skills/`) |
| Global | `~/.config/devin/skills/`, `~/.agents/skills/` (legacy: `~/.codeium/windsurf/skills/`) |

Devin Desktop reads `.agents/skills/` directly, so **no copy or symlink is needed** when your canonical skills live there. The agent loads a skill automatically when your request matches its description.

📖 [Devin Desktop Skills Documentation](https://docs.devin.ai/desktop/cascade/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.windsurf/workflows/` (project) or `~/.codeium/windsurf/global_workflows/` (global)

**Invocation:** `/workflow-name`. Use **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`).

Windsurf calls its slash commands "Workflows." They are what factory engineering calls commands: reusable task instructions invoked with a slash, not orchestration documents. Workflows are invoked manually only, and each file is limited to 12,000 characters.

Author factory engineering commands as skills (see [Commands](/commands)). Devin Desktop picks them up from `.agents/skills/` with no extra sharing step, which avoids maintaining a second copy in `.windsurf/workflows/`.

📖 [Windsurf Workflows Documentation](https://docs.devin.ai/desktop/cascade/workflows)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ⚠️ Preview

**Feature name:** Subagents (Devin Local)

**Storage location:** `.devin/agents/{agent-name}.md` (project) or `~/.config/devin/agents/{agent-name}.md` (global)

Devin Local can delegate work to subagents that run in parallel and report back. Enable the **Subagents (Preview)** setting, and define custom subagents as Markdown files in `agents/`. Set a default model for subagents in settings.

**Instructions:** Devin Local reads `AGENTS.md` (and `AGENTS.local.md`) as always-on rules, including nested `AGENTS.md` files that apply to their directory.

**Memory:** Devin Local generates memories automatically, but you cannot direct a specific subagent to read and write its own memory file. Get the factory engineering memory pattern by instructing each subagent, in its definition, to read from `.claude/agent-memory/{agent-name}/MEMORY.md` at the start of work and append learnings at the end.

📖 [Devin Desktop Changelog](https://docs.devin.ai/desktop/changelog) · [AGENTS.md in Devin Desktop](https://docs.devin.ai/desktop/cascade/agents-md)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Preview

With subagents enabled, Devin Local can read a factory engineering workflow and delegate steps to named subagents. Store the workflow as a skill and invoke it with **slash-workflow at-artifact** (e.g. `/tdd-cycle @docs/specs/order-validation.md`). Subagent support is in preview, so test each workflow before relying on it.

**Terminology collision:** Windsurf's "Workflows" (in `.windsurf/workflows/`) are what factory engineering calls commands. They are not orchestration documents that coordinate multiple named agents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Devin Desktop Skills Documentation](https://docs.devin.ai/desktop/cascade/skills)
- [Windsurf Workflows Documentation](https://docs.devin.ai/desktop/cascade/workflows)
- [AGENTS.md in Devin Desktop](https://docs.devin.ai/desktop/cascade/agents-md)
- [Devin Desktop Changelog](https://docs.devin.ai/desktop/changelog)
