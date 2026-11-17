---
title: Commands
description: Reusable task instructions—skills you invoke explicitly with a slash to run a repeatable sequence of steps against an artifact.
---

# Commands: Reusable Task Instructions

Commands encode repeatable instructions for specific tasks. You invoke a command explicitly, by name, to execute a predefined sequence of steps against an artifact.

Factory engineering uses three related terms. They share a file format but are not interchangeable:

- **Skill:** a reusable capability that an agent may discover and load on its own when a request matches its description.
- **Command:** a user-facing entry point that deliberately invokes a capability. A command is implemented as a skill.
- **Workflow:** an ordered process that coordinates multiple agents, with conditions, loops, and escalation to the user. A workflow is *described* in a skill, but the skill does not execute it (see [Workflows](/workflows)).

Every IDE covered here has converged on one mechanism for commands: **a command is a skill you invoke by name.** Claude Code merged custom commands into skills. Cursor ships `/migrate-to-skills` to convert commands. GitHub Copilot's default VS Code harness doesn't run prompt files. Kilo Code and Google Antigravity expose every skill as a slash command. OpenAI Codex has no command files at all, only skills. Author commands as skills, and one file is discovered by every IDE. How each IDE invokes it, and whether you can stop the model from loading it on its own, still differs by product (see [Portable metadata and vendor-specific controls](#portable-metadata-and-vendor-specific-controls)).

In factory engineering, artifacts such as user stories, specifications, product requirements documents, and user journeys move through the software factory. Commands define how to process those artifacts. The power move is **slash-command at-artifact**: e.g. `/write-spec @docs/user-stories/submit-sales-order.md` runs the write-spec command against that user story. The command provides the instructions, the artifact provides the target, and the agent does the work.

## Why Project-Scoped Commands Matter for Factory Engineering

Like skills, commands must live in your project repository and evolve with your codebase. When commands are stored at the project level, they are versioned with your code, reviewed in pull requests, and automatically available to every team member on clone.

**Invocation rule:** The command name is the **skill name** (the directory name and the `name` field). For example, `.agents/skills/write-spec/SKILL.md` → `/write-spec`. The prefix depends on the product: `/write-spec` in most, `$write-spec` in the Codex CLI, and `@write-spec` in Devin Desktop (see the [IDE-by-IDE Reference](#ide-by-ide-reference)). Always use **slash-command at-artifact** to run a command against a specific artifact.

## Example command

A command is a skill directory in the canonical `.agents/skills/` folder (see [Skills](/skills#managing-skills-across-ides)).

### Portable metadata and vendor-specific controls

Separate what every IDE reads from what only some IDEs honor:

- **Portable metadata:** `name` and `description` in `SKILL.md`. Every IDE uses them to list the command and decide when it applies. Write the description so it says when to run and when not to (e.g. "Run only when the user invokes /write-design explicitly"), and keep it specific to the artifact the command processes. This is the only invocation control that reaches every IDE.
- **Vendor-specific controls:** each stops the model from loading the command on its own, in the products that honor it:

| Control | Honored by |
|---------|-----------|
| `disable-model-invocation: true` in `SKILL.md` frontmatter | Claude Code; Cursor; GitHub Copilot in VS Code and the Copilot CLI |
| `agents/openai.yaml` with `policy.allow_implicit_invocation: false` | OpenAI Codex |
| None documented | Windsurf (Devin Desktop), Kilo Code, Google Antigravity |

Include both vendor controls in every command. IDEs ignore the control they do not recognize. Do not treat either control as a portable guarantee: in IDEs without a documented control, a command can still load when a request matches its description, and vendor behavior changes between releases.

Keep commands **IDE-agnostic**: do not rely on `$ARGUMENTS` or other placeholders, since not all IDEs support them. Instead, write the command so it **states what the user will supply** (e.g. a user story or design document, by link or by name) and **instructs the LLM to stop and prompt the user** if that input is missing. That pattern works consistently in every IDE.

**Layout:**

```
.agents/skills/write-design/
├── SKILL.md
└── agents/
    └── openai.yaml
```

**`agents/openai.yaml`:**

```yaml
policy:
  allow_implicit_invocation: false
```

**`SKILL.md`:**

```markdown
---
name: write-design
description: Write or update a design document from a user story. Run only when the user invokes /write-design explicitly.
disable-model-invocation: true
---

# Write Design Document

The user will supply a user story or design document, either by link or by name. If no user story or design document is supplied, then stop and prompt the user. Create a new design document or update the existing one using the following instructions.

## Location

- **Path:** `docs/designs/`
- **Filename:** Descriptive kebab-case ending in `-design.md`.

## Purpose

Design documents capture: user story and scope, domain definitions, technical approach and data sources, gaps and recommendations, test cases, acceptance criteria. They are planning artifacts; reference user stories and scenarios, not implementation.

## Contents

Include:
1. Title and user story
2. Data model and validation rules
3. Data model diagrams
4. Test cases driven by acceptance criteria
5. OpenAPI endpoint specifications
6. References

## Structure

Use the recommended template in the [documentation-spec](../documentation-spec/SKILL.md) skill.
```

---

## Creating Commands Iteratively

**1. Do the task once with the agent.** Pick a concrete artifact (e.g. a user story) and tell the agent what you want (e.g. "Write a technical spec for this story"). Work through the result. Fix gaps, adjust structure, and clarify wording until the output is what you want. Do not compromise on quality.

**2. Capture the process as a command.** Ask the agent to create a command skill in `.agents/skills/{command-name}/` that encodes the instructions you just followed. The command should state what the user supplies (e.g. a user story or design doc) and tell the LLM to stop and prompt if that input is missing. Use the [recommended pattern](#example-command): `disable-model-invocation: true`, `agents/openai.yaml`, and sections for location, purpose, contents, and structure.

**3. Run the command against an artifact.** Invoke **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`). Do not hand-hold; let the command stand on its own. Note where the output is wrong, vague, or inconsistent with how you refined it in step 1.

**4. Refine the command.** For each shortcoming, ask: *Which part of the command allowed this?* Update the command text: add constraints, examples, or explicit structure (e.g. "Include…", "Do not…", "Use the template in…"). Commit the change.

**5. Repeat steps 3 and 4.** Re-run the command on the same or a different artifact. Keep tightening instructions until the command produces the desired result without extra guidance. When it does, that command is ready for the team.

**6. Add more commands the same way.** For each new repeatable task (e.g. implementation plan, code review), do the task once, capture it as a command, then iterate by running and refining until the command is reliable.

From here, every team member uses **slash-command at-artifact** (e.g. `/write-spec @docs/user-stories/submit-sales-order.md`). For multi-step orchestration, see the [Workflows](/workflows) page.

## Sharing Commands Across IDEs

Commands are skills, so they share with skills. Store them in `.agents/skills/` and run the [skills sync](/skills#managing-skills-across-ides) to mirror them into `.claude/skills/` for Claude Code. Every other IDE reads `.agents/skills/` directly. No separate commands folder or sync step is needed.

### Migrating legacy command files

If your repository has commands in IDE-specific folders, convert each one to a skill directory. The legacy folders below remain supported compatibility paths in most IDEs, so existing commands keep working while you migrate:

1. Create `.agents/skills/{command-name}/SKILL.md`.
2. Add frontmatter with `name`, a `description`, and `disable-model-invocation: true`.
3. Paste the command body below the frontmatter.
4. Add `agents/openai.yaml` with `allow_implicit_invocation: false`.
5. Verify the new command in every IDE your team uses (see [Verify a command](#verify-a-command)).
6. Remove the legacy file and any sync script that maintained it. Keeping both creates two commands with the same name in IDEs that read both locations.

Several IDEs automate the conversion: Cursor's `/migrate-to-skills`, VS Code's **Convert prompt files to skills**, Antigravity's `/migrate-workflows`, and Codex's `/import`. Each writes to its own folder, so move the results into `.agents/skills/`.

Legacy command folders and their current status:

| IDE | Legacy command folder | Status |
|-----|----------------------|--------|
| Claude Code | `.claude/commands/` | Still works; merged into skills |
| Cursor | `.cursor/commands/` | Still works; skills recommended |
| GitHub Copilot | `.github/prompts/*.prompt.md` | VS Code runs them only in sessions using the deprecated Local harness (removal by February 2027); the Copilot CLI and the default Copilot harness do not run them |
| Windsurf (Devin Desktop) | `.windsurf/workflows/` | Still works |
| Kilo Code | `.kilocode/workflows/` | Migrated automatically to `.kilo/commands/` |
| Google Antigravity | `.agent/workflows/` | Deprecated; still works during the transition |
| OpenAI Codex | None | Codex supports skills only |

### Verify a command

Vendor invocation behavior changes between releases. Before relying on a command, test it in a clean session of each product your team uses:

1. **Explicit invocation:** invoke it by name with the product's prefix and an artifact (e.g. `/write-design @docs/user-stories/billing-email.md`). Confirm it runs.
2. **Non-invocation:** without naming the command, ask for something that matches its description (e.g. "Write a design for the billing email story"). Confirm that products with an explicit-only control do not load it. In products without one, note whether it loads, and tighten the description if it does.
3. Repeat after upgrading an IDE.

## IDE-by-IDE Reference

All IDEs support commands authored as skills. The table below summarizes invocation and sharing by product. For full setup details, see each IDE's dedicated page.

| IDE | Reads command skills from | Invocation (product) | Sharing Required? | Details |
|-----|---------------------------|----------------------|-------------------|---------|
| [Claude Code](/ides/claude-code) | `.claude/skills/` | `/command-name` (CLI, IDE extensions, desktop) | ✅ Yes (skills mirror) | [Full setup →](/ides/claude-code#commands) |
| [GitHub Copilot](/ides/github-copilot) | `.agents/skills/` | `/command-name` (VS Code chat, Copilot CLI) | No | [Full setup →](/ides/github-copilot#commands) |
| [Cursor](/ides/cursor) | `.agents/skills/` | `/command-name` (editor, Agents Window) | No | [Full setup →](/ides/cursor#commands) |
| [Windsurf (Devin Desktop)](/ides/windsurf) | `.agents/skills/` | `@command-name` (Devin Desktop) | No | [Full setup →](/ides/windsurf#commands) |
| [Kilo Code](/ides/kilo-code) | `.agents/skills/` | `/command-name` (VS Code extension, Kilo CLI) | No | [Full setup →](/ides/kilo-code#commands) |
| [Google Antigravity](/ides/google-antigravity) | `.agents/skills/` | `/command-name` (App, `agy` CLI, IDE) | No | [Full setup →](/ides/google-antigravity#commands) |
| [OpenAI Codex](/ides/openai-codex) | `.agents/skills/` | `$command-name` (Codex CLI) | No | [Full setup →](/ides/openai-codex#commands) |

**Note:** Windsurf and Kilo Code call their legacy commands "Workflows." That is their storage mechanism for reusable instructions, not factory engineering workflows.
