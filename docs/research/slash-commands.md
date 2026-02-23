# Slash-commands and equivalents across IDEs

Research comparison of slash-command (or equivalent) support, the distinction between commands and workflows, storage formats, and single-file vs one-file-per-item patterns across Claude Code, Cursor, Windsurf, Kilo Code, GitHub Copilot, and Antigravity.

---

## 1. Slash-command (or equivalent) support

| IDE | Slash / equivalent | Where defined | How invoked |
|-----|-------------------|---------------|-------------|
| **Claude Code** | Yes | `.claude/commands/` (one `.md` per command) or `.claude/skills/<name>/SKILL.md` | `/command-name` or `/skill-name` |
| **Cursor** | Yes | `.cursor/commands/` (one `.md` per command) | `/command-name` |
| **Windsurf** | Yes | `.windsurf/workflows/` (one `.md` per “workflow”) | `/workflow-name` |
| **Kilo Code** | Yes | **Modes:** `.kilocodemodes` (single YAML). **Workflows:** `.kilocode/workflows/` (one `.md` per) | `/workflow-name`; modes via Orchestrator / mode switch |
| **GitHub Copilot** | Partial | Built-in slash commands; custom **agents** in `.github/agents/` (one `.agent.md` per agent) | `/agent` then choose agent; no “one custom slash per file” like Claude/Cursor |
| **Antigravity** | Yes | **Workflows:** `.agent/workflows/` (one `.md` per). **Skills:** `.agent/skills/<name>/SKILL.md` | `/workflow-name`; skills auto-loaded or `/learn @owner/skill-name` |

**Summary:** Claude Code, Cursor, Windsurf, Kilo Code, and Antigravity all support “slash something” for user-defined behaviors. Copilot supports custom **agents** (selected via `/agent` or UI), not per-file custom slash commands.

---

## 2. Commands vs workflows (conceptual split)

**In factory engineering (this project):**

- **Command** = single-agent task (one set of steps, one “agent”).
- **Workflow** = orchestration (one coordinator delegating to multiple specialist agents, with branching/loops).

**How each IDE lines up:**

- **Claude Code:** Matches that split. “Commands”/“skills” are single-agent; “workflows” are orchestration (read by main agent + Task tool to subagents). No special `workflows` folder; you use a launcher command that reads workflow content.
- **Cursor:** Only “commands” (single-agent). No orchestration or “workflow” concept.
- **Windsurf:** Uses the word “Workflows” for what are really **command-like** prompts (one agent, sequential steps). No multi-agent orchestration.
- **Kilo Code:** “Workflows” = command-like (one agent, steps); **Orchestrator mode** = real orchestration (delegates to modes). So: same word “workflow” for command-like things; orchestration is a separate feature (Orchestrator).
- **GitHub Copilot:** “Custom agents” = different agent profiles (single-agent). Agent HQ = cross-agent assignment, not in-session orchestration. No command vs workflow distinction like ours.
- **Antigravity:** “Workflows” = step-by-step recipes (single agent). “Skills” = extra knowledge/behavior. No built-in multi-agent orchestration.

**Summary:** Only **Claude Code** and **Kilo Code** have a real command vs orchestration split; in the others, “workflow” (when present) is either command-like or a different concept.

---

## 3. Storage format: Markdown vs JSON/YAML vs “one file for many”

### Per-item format (one command/workflow/agent per file or per directory)

| IDE | Format | Structure |
|-----|--------|-----------|
| **Claude Code** | **Commands:** one `.md` per command (optional frontmatter). **Skills:** directory `skill-name/` with `SKILL.md` (YAML frontmatter + markdown). | One file per command; one directory + `SKILL.md` per skill. |
| **Cursor** | **Commands:** one `.md` per command, **plain markdown only** (no frontmatter). **Rules:** `.cursor/rules/` use `.mdc` with YAML frontmatter (different from commands). | One file per command. |
| **Windsurf** | One `.md` per workflow: title, description, numbered steps. ~12k character limit per file. | One file per workflow. |
| **Kilo Code** | **Workflows:** one `.md` per workflow in `.kilocode/workflows/`. **Modes:** see “Single file with multiple items” below. | One file per workflow. |
| **GitHub Copilot** | One `.agent.md` per custom agent in `.github/agents/`: **YAML frontmatter** (name, description, tools, etc.) + **markdown body** (instructions, max ~30k chars). | One file per agent. |
| **Antigravity** | **Workflows:** one `.md` per workflow in `.agent/workflows/` with **YAML frontmatter** (e.g. `description`) + numbered steps (and optional `// turbo` annotations). **Skills:** directory + `SKILL.md` (YAML frontmatter + markdown). | One file per workflow; one directory + `SKILL.md` per skill. |

**Summary:** Markdown is the primary content format everywhere. YAML is used for metadata/frontmatter in Claude Code (skills), Copilot (agents), Antigravity (workflows and skills), and Cursor **rules** (`.mdc`), but **not** in Cursor **commands** (plain markdown only).

### Single file with multiple items (Kilo Code-style)

- **Kilo Code** is the one that clearly **bundles multiple definitions in one file:** Custom modes live in a single **`.kilocodemodes`** file at the project root (or global YAML in `~/.../custom_modes.yaml`). That file is **YAML** with a top-level list, e.g. `customModes: [ { slug, name, roleDefinition, groups, customInstructions }, ... ]`. So: **one file, many modes** (like “combining agents into a single .kilocodemodes file”).
- **Workflows in Kilo Code** stay **one `.md` per workflow** in `.kilocode/workflows/`; they are not bundled into one file.
- **Other IDEs:** Claude Code, Cursor, Windsurf: one file (or one skill directory) per command/workflow. GitHub Copilot: one `.agent.md` per agent. Antigravity: one file per workflow, one directory per skill. None use a single JSON/YAML file that holds many commands or many workflows in one place.

**Summary:** **Kilo Code is the only one that “combines” multiple definitions into a single file (`.kilocodemodes` for modes).** Everyone else uses one file (or one directory) per command/workflow/agent/skill.

---

## 4. Summary table

| IDE | Slash support | “Command” vs “Workflow” in product | Primary format | Multiple items in one file? |
|-----|---------------|------------------------------------|----------------|----------------------------|
| **Claude Code** | Yes (commands + skills) | Yes (commands/skills vs orchestration) | Markdown (+ YAML in skills) | No (one file or one skill dir per item) |
| **Cursor** | Yes (commands) | No (only commands) | Markdown (no frontmatter for commands) | No |
| **Windsurf** | Yes (“workflows”) | No (their “workflows” = command-like) | Markdown | No |
| **Kilo Code** | Yes (workflows + modes) | Yes (workflows = steps; Orchestrator = orchestration) | **Modes:** single YAML file. **Workflows:** one `.md` per | **Yes for modes** (`.kilocodemodes`) |
| **GitHub Copilot** | Built-in + `/agent` | No (custom agents only) | YAML frontmatter + Markdown (`.agent.md`) | No (one file per agent) |
| **Antigravity** | Yes (workflows + skills) | Workflows = recipes; skills = knowledge | Markdown + YAML frontmatter | No (one file per workflow, one dir per skill) |

---

## 5. References (used in research)

- Claude Code: [Slash commands / skills](https://code.claude.com/docs/en/slash-commands), [Memory](https://code.claude.com/docs/en/memory), [Subagents](https://code.claude.com/docs/en/sub-agents)
- Cursor: [Slash commands](https://docs.cursor.com/context/%40-symbols/slash-commands), rules vs commands (`.mdc` with frontmatter vs `.md` plain)
- Windsurf: [Workflows](https://docs.windsurf.com/plugins/cascade/workflows)
- Kilo Code: [Custom Modes](https://kilo.ai/docs/features/custom-modes), [Workflows](https://kilo.ai/docs/agent-behavior/workflows), [.kilocodemodes](https://github.com/Kilo-Org/Kilo Code/blob/main/.kilocodemodes)
- GitHub Copilot: [Custom agents configuration](https://docs.github.com/en/copilot/reference/custom-agents-configuration), [Creating custom agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- Antigravity: [Workflows](https://antigravity.codes/rules/antigravity-workflows/antigravity-workflow-fundamentals), [Skills](https://codelabs.developers.google.com/getting-started-with-antigravity-skills)
