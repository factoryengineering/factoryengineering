---
title: Windsurf (Devin Desktop)
description: Complete factory engineering guide for Windsurf, now Devin Desktop — skills, commands, subagents, and orchestration.
---

# Windsurf (Devin Desktop)

Cognition acquired Windsurf in July 2025 and renamed the editor **Devin Desktop** in June 2026. **Devin Local**, which shares its harness with the Devin CLI, subsequently replaced Cascade as the primary local coding agent. Cascade is now a legacy agent: current Devin Desktop releases no longer start new Cascade conversations or open existing ones. Devin Local supports subagents, sandboxing, worktrees, skills, and permission controls. Its subagent feature is in preview; Devin Local itself is not.

Devin Desktop moves project configuration to `.devin/` and still reads the legacy `.windsurf/` folders and the cross-tool `.agents/` folder. To move Cascade workflows and memories over, run **Devin: Open Cascade Migration Wizard** from the command palette.

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

**Folder location:** `.agents/skills/{command-name}/SKILL.md` (canonical; read directly)

**Invocation:** `@command-name`. Mention the artifact in the same message (e.g. `@write-spec @docs/user-stories/submit-sales-order.md`).

Author commands as skills (see [Commands](/commands#example-command)). Devin Desktop picks them up from `.agents/skills/` with no extra sharing step.

Windsurf's own slash commands are called "Workflows" (`.windsurf/workflows/` in the project, `~/.codeium/windsurf/global_workflows/` globally). They are what factory engineering calls commands: reusable task instructions, not orchestration documents. They are invoked manually only, and each file is limited to 12,000 characters. Do not maintain a second copy of your commands there.

📖 [Windsurf Workflows Documentation](https://docs.devin.ai/desktop/cascade/workflows)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ✅ Yes (Devin Local; custom subagents in preview)

**Feature name:** Devin Local; Subagents (Preview)

**Storage location:** `.devin/agents/{agent-name}.md` (project) or `~/.config/devin/agents/{agent-name}.md` (global)

Devin Local can delegate work to subagents that run in parallel and report back. Enable the **Subagents (Preview)** setting, and define custom subagents as Markdown files in `agents/`. Set a default model for subagents in settings.

**Instructions:** Devin Local reads `AGENTS.md` (and `AGENTS.local.md`) as always-on rules, including nested `AGENTS.md` files that apply to their directory.

**Memory:** Devin Local does not persist memories. (Cascade's automatic memories do not carry over except through the migration wizard.) Get the factory engineering memory pattern by instructing each subagent, in its definition, to read from `.claude/agent-memory/{agent-name}/MEMORY.md` at the start of work and append learnings at the end.

📖 [Devin Local](https://docs.devin.ai/desktop/devin-local) · [Cascade (legacy)](https://docs.devin.ai/desktop/cascade/cascade) · [AGENTS.md in Devin Desktop](https://docs.devin.ai/desktop/cascade/agents-md)

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ⚠️ Preview

With the **Subagents (Preview)** setting enabled, Devin Local can read a factory engineering workflow and delegate steps to named subagents. Store the workflow as a skill and invoke it with **slash-workflow at-artifact** (e.g. `/tdd-cycle @docs/specs/order-validation.md`). Subagent support is in preview, so test each workflow before relying on it.

**Terminology collision:** Windsurf's "Workflows" (in `.windsurf/workflows/`) are what factory engineering calls commands. They are not orchestration documents that coordinate multiple named agents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Devin Desktop Skills Documentation](https://docs.devin.ai/desktop/cascade/skills)
- [Windsurf Workflows Documentation](https://docs.devin.ai/desktop/cascade/workflows)
- [Devin Local](https://docs.devin.ai/desktop/devin-local)
- [Cascade (legacy)](https://docs.devin.ai/desktop/cascade/cascade)
- [AGENTS.md in Devin Desktop](https://docs.devin.ai/desktop/cascade/agents-md)
- [Devin Desktop Changelog](https://docs.devin.ai/desktop/changelog)
