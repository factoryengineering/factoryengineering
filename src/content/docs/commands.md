---
title: Commands
description: Reusable task instructions—lightweight markdown files that encode repeatable steps for specific tasks, invoked with a slash or at symbol in your IDE.
---

# Commands: Reusable Task Instructions

Commands are lightweight markdown files that encode repeatable instructions for specific tasks. Unlike skills, which are standardized across platforms, commands are simple prompt templates that you invoke with a slash (or at symbol in any IDE) to execute a predefined sequence of steps against an artifact.

In factory engineering, artifacts—such as user stories, specifications, product requirements documents, and user journeys—move through the software factory. Commands define how to process those artifacts. The power move is combining a command with an artifact: slash write spec at submit sales order executes the write spec command against that specific user story. The command provides the instructions, the artifact provides the target, and the agent does the work.

## Why Project-Scoped Commands Matter for Factory Engineering

Like skills, commands must live in your project repository and evolve with your codebase. When commands are stored at the project level, they are versioned with your code, reviewed in pull requests, and automatically available to every team member on clone.

## Command Folder Locations by IDE

Commands are not standardized. Each IDE looks in a different folder:

| IDE | Folder | Invocation |
|-----|--------|-----------|
| Claude Code | `.claude/commands/` | `/command-name` |
| Cursor | `.cursor/commands/` | `/command-name` |
| Windsurf | `.windsurf/workflows/` | `/workflow-name` |
| KiloCode | `.kilocode/workflows/` | `/workflow-name` |
| GitHub Copilot | Not supported natively | Use at symbol as fallback |
| Antigravity | Not supported natively | Use at symbol as fallback |

## The Symlink Approach for Commands

Since commands live in different folders across IDEs, use symlinks to maintain a single canonical location. We recommend `.claude/commands/` as the source of truth.

**Create symlinks for each IDE:**

```bash
# Cursor
ln -s ../.claude/commands .cursor/commands

# Windsurf (stores commands as Windsurf workflows)
ln -s ../.claude/commands .windsurf/workflows

# KiloCode (stores commands as KiloCode workflows)
ln -s ../.claude/commands .kilocode/workflows

# GitHub Copilot and Antigravity: use @ symbol as fallback to bring command into context
```

Commit the symlinks to your repository so every team member gets the correct structure on clone.

## IDE-by-IDE Reference

### Claude Code

**Folder location:** `.claude/commands/` (project) or `~/.claude/commands/` (global)

**Invocation:** `/command-name` or `@command-name`

Claude Code stores commands as simple markdown files. Each file becomes a command. You can use the `$ARGUMENTS` placeholder to accept parameters.

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

**Invocation:** `/command-name` or `@command-name`

Cursor stores commands as markdown files in `.cursor/commands/`. The filename becomes the command name. Like Claude Code, you can use `$ARGUMENTS` for parameterization.

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

Create a symlink to use your canonical location:

```bash
ln -s ../.claude/commands .kilocode/workflows
```

📖 [KiloCode Workflows Documentation](https://kilo.ai/docs/features/slash-commands/workflows)

---

### GitHub Copilot

**Status:** Does not support custom slash commands or project-level commands natively.

GitHub Copilot does not provide a built-in mechanism for project-level custom commands like Claude Code or Cursor. However, you can use the at symbol to bring a command file into context alongside an artifact:

**Fallback usage:**

```
@write-spec @submit-sales-order
```

This brings both the write-spec command and the submit-sales-order artifact into the conversation context, allowing Copilot to execute the sequence of steps defined in the command.

For more structured command-like functionality, consider using custom agents in VS Code through the "Configure Custom Agents" menu in Copilot Chat.

---

### Antigravity

**Status:** Does not support custom commands natively.

Google Antigravity uses skills for reusable, parameterized capabilities. However, you can use the at symbol as a fallback:

**Fallback usage:**

```
@write-spec @submit-sales-order
```

This brings both the command instructions and the artifact into Antigravity's context, allowing the agent to execute the sequence of steps.

For more robust command-like behavior, encode your instructions as skills instead and invoke them explicitly.

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

**3. Create symlinks for each IDE your team uses:**

```bash
# Cursor
ln -s ../.claude/commands .cursor/commands

# Windsurf (stores commands as Windsurf workflows)
ln -s ../.claude/commands .windsurf/workflows

# KiloCode (stores commands as KiloCode workflows)
ln -s ../.claude/commands .kilocode/workflows

# GitHub Copilot and Antigravity: use @ symbol as fallback
```

**4. Commit everything:**

```bash
git add .claude/commands .cursor .windsurf .kilocode
git commit -m "Initialize factory engineering commands"
```

From this point forward, every team member has commands available in their preferred IDE immediately after cloning.

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
