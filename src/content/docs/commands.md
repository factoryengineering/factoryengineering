---
title: Commands
description: Reusable task instructions—skills you invoke explicitly with a slash to run a repeatable sequence of steps against an artifact.
---

# Commands: Reusable Task Instructions

Commands encode repeatable instructions for specific tasks. You invoke a command explicitly, by name, to execute a predefined sequence of steps against an artifact. A skill loads when the agent decides it is relevant. A command runs when you ask for it.

Every IDE covered here has converged on one mechanism for commands: **a command is a skill you invoke by name.** Claude Code merged custom commands into skills. Cursor ships `/migrate-to-skills` to convert commands. GitHub Copilot's default harness no longer loads prompt files. Kilo Code and Google Antigravity expose every skill as a slash command. OpenAI Codex has no command files at all, only skills. Author commands as skills, and one file works in every IDE. Claude Code, Cursor, GitHub Copilot, and OpenAI Codex also let you mark a skill explicit-only, so the model never loads it on its own; the other IDEs can still load a command when a request matches its description (see [Example command](#example-command)).

In factory engineering, artifacts such as user stories, specifications, product requirements documents, and user journeys move through the software factory. Commands define how to process those artifacts. The power move is **slash-command at-artifact**: e.g. `/write-spec @docs/user-stories/submit-sales-order.md` runs the write-spec command against that user story. The command provides the instructions, the artifact provides the target, and the agent does the work.

## Why Project-Scoped Commands Matter for Factory Engineering

Like skills, commands must live in your project repository and evolve with your codebase. When commands are stored at the project level, they are versioned with your code, reviewed in pull requests, and automatically available to every team member on clone.

**Invocation rule:** The command name is the **skill name** (the directory name and the `name` field). For example, `.agents/skills/write-spec/SKILL.md` → `/write-spec`. The prefix depends on the IDE: `/write-spec` in most IDEs, `$write-spec` in OpenAI Codex, and `@write-spec` in Windsurf (see the [IDE-by-IDE Reference](#ide-by-ide-reference)). Always use **slash-command at-artifact** to run a command against a specific artifact.

## Example command

A command is a skill directory in the canonical `.agents/skills/` folder (see [Skills](/skills#managing-skills-across-ides)). Its `SKILL.md` has two properties that make it a command:

- **`disable-model-invocation: true`** prevents the model from loading it automatically, so it runs only when invoked. Claude Code, Cursor, and GitHub Copilot honor this property.
- **An `agents/openai.yaml` file** with `allow_implicit_invocation: false` sets the same policy for OpenAI Codex, which ignores the frontmatter property.

Windsurf (Devin Desktop), Kilo Code, and Google Antigravity do not document an explicit-only control. They can load a command whenever a request matches its description. Write every command's description so it says when to run and when not to (e.g. "Run only when the user invokes /write-design explicitly"), and keep the description specific to the artifact the command processes. That limits implicit loading in those IDEs.

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

If your repository has commands in IDE-specific folders, convert each one to a skill directory and delete the original:

1. Create `.agents/skills/{command-name}/SKILL.md`.
2. Add frontmatter with `name`, a `description`, and `disable-model-invocation: true`.
3. Paste the command body below the frontmatter.
4. Add `agents/openai.yaml` with `allow_implicit_invocation: false`.
5. Remove the legacy file and any sync script or symlink that maintained it.

Several IDEs automate the conversion: Cursor's `/migrate-to-skills`, VS Code's **Convert prompt files to skills**, Antigravity's `/migrate-workflows`, and Codex's `/import`. Each writes to its own folder, so move the results into `.agents/skills/`.

Legacy command folders that the new pattern replaces:

| IDE | Legacy command folder | Status |
|-----|----------------------|--------|
| Claude Code | `.claude/commands/` | Still works; merged into skills |
| Cursor | `.cursor/commands/` | Still works; skills recommended |
| GitHub Copilot | `.github/prompts/*.prompt.md` | Not loaded by the default Copilot harness; Local harness deprecated |
| Windsurf (Devin Desktop) | `.windsurf/workflows/` | Still works |
| Kilo Code | `.kilocode/workflows/` | Migrated automatically to `.kilo/commands/` |
| Google Antigravity | `.agent/workflows/` | Deprecated |
| OpenAI Codex | None | Codex supports skills only |

## IDE-by-IDE Reference

All IDEs support commands authored as skills. The table below summarizes invocation and sharing. For full setup details, see each IDE's dedicated page.

| IDE | Reads command skills from | Invocation | Sharing Required? | Details |
|-----|---------------------------|------------|-------------------|---------|
| [Claude Code](/ides/claude-code) | `.claude/skills/` | `/command-name` | ✅ Yes (skills mirror) | [Full setup →](/ides/claude-code#commands) |
| [GitHub Copilot](/ides/github-copilot) | `.agents/skills/` | `/command-name` | No | [Full setup →](/ides/github-copilot#commands) |
| [Cursor](/ides/cursor) | `.agents/skills/` | `/command-name` | No | [Full setup →](/ides/cursor#commands) |
| [Windsurf (Devin Desktop)](/ides/windsurf) | `.agents/skills/` | `@command-name` | No | [Full setup →](/ides/windsurf#commands) |
| [Kilo Code](/ides/kilo-code) | `.agents/skills/` | `/command-name` | No | [Full setup →](/ides/kilo-code#commands) |
| [Google Antigravity](/ides/google-antigravity) | `.agents/skills/` | `/command-name` | No | [Full setup →](/ides/google-antigravity#commands) |
| [OpenAI Codex](/ides/openai-codex) | `.agents/skills/` | `$command-name` | No | [Full setup →](/ides/openai-codex#commands) |

**Note:** Windsurf and Kilo Code call their legacy commands "Workflows." That is their storage mechanism for reusable instructions, not factory engineering workflows.
