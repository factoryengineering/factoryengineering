---
title: Commands
description: Reusable task instructions—lightweight markdown files that encode repeatable steps for specific tasks, invoked with a slash or at symbol in your IDE.
---

# Commands: Reusable Task Instructions

Commands are lightweight markdown files that encode repeatable instructions for specific tasks. Unlike skills, which are standardized across platforms, commands are simple prompt templates that you invoke with a slash (or at symbol in any IDE) to execute a predefined sequence of steps against an artifact.

In factory engineering, artifacts—such as user stories, specifications, product requirements documents, and user journeys—move through the software factory. Commands define how to process those artifacts. The power move is **slash-command at-artifact**: e.g. `/write-spec @submit-sales-order` runs the write-spec command against that artifact. The command provides the instructions, the artifact provides the target, and the agent does the work.

## Why Project-Scoped Commands Matter for Factory Engineering

Like skills, commands must live in your project repository and evolve with your codebase. When commands are stored at the project level, they are versioned with your code, reviewed in pull requests, and automatically available to every team member on clone.

**Invocation rule:** The slash name is the **filename without `.md`** (e.g. `write-spec.md` → `/write-spec`). Always use **slash-command at-artifact** to run a command against a specific artifact.

## Command Folder Locations by IDE

Commands are not standardized. Each IDE looks in a different folder:

| IDE | Folder | Invocation |
|-----|--------|-----------|
| Claude Code | `.claude/commands/` | `/command-name` |
| Cursor | `.cursor/commands/` | `/command-name` |
| Windsurf | `.windsurf/workflows/` | `/workflow-name` |
| KiloCode | `.kilocode/workflows/` | `/workflow-name` |
| Antigravity | `.agent/workflows/` | `/workflow-name` |
| GitHub Copilot (VS Code) | `.github/prompts/` (default) or `chat.promptFilesLocations` | `/prompt-name` (type `/` in chat; files must use the `.prompt.md` extension) |

## The Symlink Approach

Both **commands** and **workflows** are stored in `.claude/commands/`. Each IDE looks in a different folder, so use symlinks so that one canonical location works everywhere.

**Option A — Use the factory-engineering-symlinks skill:** Install with `npx openskills install michaellperry/factoryengineering`, then ask your agent to create symlinks for your selected IDEs. The skill can auto-detect IDEs from your directory structure and will prompt to copy existing command files into `.claude/commands` if a target folder already exists.

**Option B — Create symlinks manually for each IDE:**

```bash
# Cursor
ln -s ../.claude/commands .cursor/commands

# Windsurf
ln -s ../.claude/commands .windsurf/workflows

# KiloCode
ln -s ../.claude/commands .kilocode/workflows

# Antigravity
mkdir -p .agent
ln -s ../.claude/commands .agent/workflows
```

Commit the symlinks so every team member gets the correct structure on clone.

**GitHub Copilot (VS Code)** uses prompt files (`.prompt.md`) with different naming and optional frontmatter, so commands cannot be shared via symlinks. Use a **sync** step instead; install the **factory-engineering-sync-copilot-prompts** skill to assist (see [GitHub Copilot (VS Code)](#github-copilot-vs-code) below).

## IDE-by-IDE Reference

### Claude Code

**Folder location:** `.claude/commands/` (project) or `~/.claude/commands/` (global)

**Invocation:** `/command-name` — the filename without `.md` is the slash command (e.g. `write-spec.md` → `/write-spec`). Use `@command-name` only if your IDE supports it. The `@` symbol in **slash-command at-artifact** refers to the *artifact*, not the command.

Claude Code stores commands as markdown files; each file becomes a slash command. Use the `$ARGUMENTS` placeholder to receive the artifact (or other parameters) when the user types `/write-spec @path/to/artifact`.

**Example command file (`.claude/commands/write-spec.md`):**

```markdown
Write a detailed technical specification for this user story.

Include:
- Feature description
- User flows and interactions
- Data requirements and schema
- API endpoints (if applicable)
- Error handling and edge cases
- Performance requirements
- Acceptance criteria

Reference our specification standards in docs/spec-standards.md
```

**Usage in Claude Code:**

```
/write-spec @submit-sales-order
```

Or using the at symbol:

```
@write-spec @submit-sales-order
```

📖 [Claude Code Slash Commands Documentation](https://code.claude.com/docs/en/slash-commands)

---

### Cursor

**Folder location:** `.cursor/commands/` (project) or `~/.cursor/commands/` (global)

**Invocation:** `/command-name` — filename without `.md` becomes the slash command. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`). `$ARGUMENTS` receives the artifact or other parameters when provided.

**Example command file (`.cursor/commands/write-spec.md`):**

```markdown
Write a detailed technical specification for this user story.

Include:
- Feature description
- User flows and interactions
- Data requirements and schema
- API endpoints (if applicable)
- Error handling and edge cases
- Performance requirements
- Acceptance criteria

Reference our specification standards in docs/spec-standards.md
```

**Usage in Cursor:**

```
/write-spec @submit-sales-order
```

Or using the at symbol:

```
@write-spec @submit-sales-order
```

Since Cursor uses `.cursor/commands/` and we're storing our canonical commands in `.claude/commands/`, create a symlink:

```bash
ln -s ../.claude/commands .cursor/commands
```

📖 [Cursor Custom Commands Documentation](https://docs.cursor.com/chat/custom-commands)

---

### Windsurf

**Folder location:** `.windsurf/workflows/` (project) or `~/.windsurf/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

Windsurf calls them workflows—note that this is different from workflows in the factory engineering sense. In Windsurf, these are simply the storage mechanism for reusable command instructions. Windsurf workflows are markdown files that define a sequence of steps for Cascade to follow.

**Example Windsurf workflow file (`.windsurf/workflows/write-spec.md`):**

```markdown
# Write Technical Specification

Write a detailed technical specification for this user story.

## Include:
- Feature description and goals
- User flows and interactions
- Data requirements and schema
- API endpoints (if applicable)
- Error handling and edge cases
- Performance requirements
- Acceptance criteria

Reference our specification standards in docs/spec-standards.md
```

**Usage in Windsurf:**

```
/write-spec @submit-sales-order
```

Or using the at symbol:

```
@write-spec @submit-sales-order
```

Create a symlink to use your canonical commands folder:

```bash
ln -s ../.claude/commands .windsurf/workflows
```

📖 [Windsurf Workflows Documentation](https://docs.windsurf.com/windsurf/cascade/workflows)

---

### KiloCode

**Folder location:** `.kilocode/workflows/` (project) or `~/.kilocode/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

KiloCode calls them workflows—again, this is KiloCode's storage mechanism for commands, not factory engineering workflows. KiloCode workflows are markdown files that define a sequence of steps.

**Example KiloCode workflow file (`.kilocode/workflows/write-spec.md`):**

```markdown
# Write Technical Specification

Write a detailed technical specification for this user story.

Include:
- Feature description and goals
- User flows and interactions
- Data requirements and schema
- API endpoints (if applicable)
- Error handling and edge cases
- Performance requirements
- Acceptance criteria

Reference our specification standards in docs/spec-standards.md
```

**Usage in KiloCode:**

```
/write-spec @submit-sales-order
```

Or using the at symbol:

```
@write-spec @submit-sales-order
```

Use the symlink from the setup above so `.kilocode/workflows` points to `.claude/commands`.

📖 [KiloCode Workflows Documentation](https://kilo.ai/docs/features/slash-commands/workflows)

---

### Antigravity

**Folder location:** `.agent/workflows/` (project) or `~/.gemini/antigravity/skills/` (global skills; workflows are in `.agent/workflows/`)

**Invocation:** `/workflow-name` — Antigravity treats files in `.agent/workflows/` as workflows. With the symlink, your `.claude/commands/` files appear there. Use **slash-command at-artifact** (e.g. `/write-spec @submit-sales-order`).

Create the symlink from the setup above: `mkdir -p .agent` then `ln -s ../.claude/commands .agent/workflows`. If you don't use the symlink, you can still use the at symbol to bring a command file and artifact into context.

---

### GitHub Copilot (VS Code)

**Folder location:** `.github/prompts/` (default workspace location). Additional folders can be listed in the `chat.promptFilesLocations` setting.

**Invocation:** Type `/` in the Chat view, then the prompt name (filename without `.prompt.md`). For example, `write-spec.prompt.md` → `/write-spec`. You can then add an artifact with `@artifact-name` (e.g. `/write-spec @submit-sales-order`).

**Format:** Prompt files use the `.prompt.md` extension (not plain `.md`). They support optional YAML frontmatter (`description`, `agent`, `tools`, etc.). See [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files) (VS Code 1.100+, April 2025).

**Syncing commands for Copilot:** Copilot expects `.prompt.md` files and optional frontmatter, so the same `.claude/commands/*.md` files cannot be used directly. Keep canonical commands in `.claude/commands/*.md` and **sync** them into `.github/prompts/` when you add or change commands.

**Install the factory-engineering-sync-copilot-prompts skill** so your IDE can assist with the sync (workflow, frontmatter rules, and optional batch script):

```bash
npx openskills install michaellperry/factoryengineering
```

Then:

1. **When you add or change commands**, ask your agent to sync commands to Copilot, or run the skill’s bundled script from repo root (the skill documents the exact command).
2. **Commit** the generated `.github/prompts/*.prompt.md` files so everyone on the team gets slash commands in VS Code.

Avoid maintaining `.github/prompts/` by hand so the canonical source stays `.claude/commands/`.

---

## Complete Setup: Step-by-Step

**1. Create your canonical commands directory:**

```bash
mkdir -p .claude/commands
```

**2. Create your first command:**

```bash
cat > .claude/commands/write-spec.md << 'EOF'
Write a detailed technical specification for this user story.

Include:
- Feature description and goals
- User flows and interactions
- Data requirements and schema
- API endpoints (if applicable)
- Error handling and edge cases
- Performance requirements
- Acceptance criteria

Reference our specification standards in docs/spec-standards.md
EOF
```

**3. Create symlinks for each IDE your team uses (except GitHub Copilot):**

```bash
# Cursor
ln -s ../.claude/commands .cursor/commands

# Windsurf
ln -s ../.claude/commands .windsurf/workflows

# KiloCode
ln -s ../.claude/commands .kilocode/workflows

# Antigravity
mkdir -p .agent
ln -s ../.claude/commands .agent/workflows
```

**4. Sync commands for GitHub Copilot (if your team uses VS Code):** Install the factory-engineering-sync-copilot-prompts skill (`npx openskills install michaellperry/factoryengineering`), then run the sync (ask your agent or run the skill’s script) to generate `.github/prompts/*.prompt.md` from `.claude/commands/*.md`. Add and commit those files (see [GitHub Copilot (VS Code)](#github-copilot-vs-code)).

**5. Commit everything:**

```bash
git add .claude/commands .cursor .windsurf .kilocode .agent
# If you synced for Copilot:
git add .github/prompts
git commit -m "Initialize factory engineering commands and workflows"
```

From this point forward, every team member has commands and workflows in their preferred IDE. Both live in `.claude/commands/`. Use **slash-command at-artifact** (e.g. `/write-spec @docs/stories/submit-sales-order.md`) and **slash-workflow at-artifact** (e.g. `/feature-development @docs/specs/submit-sales-order.md`). See the Workflows page for orchestration workflow content.

---

## Writing Effective Commands

A command is a template for processing an artifact. Keep it focused on a single repeatable task. Be explicit about what you expect in the output.

**Example: Write Specification Command**

```markdown
Write a detailed technical specification for this user story.

Include:
- Feature description and acceptance criteria
- User flows and interaction patterns
- Data model and schema requirements
- API endpoints and request/response formats
- Error handling and edge cases
- Performance and security considerations

Structure it as a single coherent document. Reference our specification standards in docs/spec-standards.md
```

**Example: Implementation Plan Command**

```markdown
Create a detailed implementation plan for this user story.

Include:
- High-level approach and architecture decisions
- Step-by-step implementation steps
- Files that need to be created or modified
- Database migrations (if applicable)
- Testing strategy and test coverage
- Deployment considerations

Break down the work into discrete, reviewable chunks.
```

**Example: Code Review Command**

```markdown
Review the implementation of this user story against its specification.

Check:
- Does the implementation match the specification?
- Are acceptance criteria met?
- Code quality and adherence to standards
- Test coverage and test quality
- Performance and security implications
- Edge cases and error handling

Provide specific, actionable feedback.
```

When a command produces suboptimal output, don't just edit the output. Ask: which part of the command instructions allowed this? Update the command. Commit it. This is how your factory improves.
