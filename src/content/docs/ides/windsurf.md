---
title: Windsurf
description: Complete factory engineering guide for Windsurf — skills, commands, and Cascade's capabilities and limitations.
---

# Windsurf

Windsurf is an AI-powered code editor featuring Cascade, a single shared AI agent. Windsurf supports the Agent Skills standard via its `.windsurf/skills/` folder and provides reusable command instructions through what it calls "Workflows." However, Windsurf does not support multiple agents or workflow orchestration in the factory engineering sense.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes, via `.windsurf/skills/`

| Scope | Path |
|-------|------|
| Project | `.windsurf/skills/` |
| Global | `~/.windsurf/skills/` |

Windsurf's Cascade agent looks for skills in `.windsurf/skills/`. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .windsurf/skills
```

Cascade automatically invokes skills when your request matches a skill's description. To invoke a skill explicitly, type `@skill-name` in the Cascade input.

📖 [Windsurf Cascade Skills Documentation](https://docs.windsurf.com/windsurf/cascade/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

**Folder location:** `.windsurf/workflows/` (project) or `~/.windsurf/workflows/` (global)

**Invocation:** `/workflow-name` or `@workflow-name`

Windsurf calls them "workflows" — note that this is different from workflows in the factory engineering sense. In Windsurf, these are simply the storage mechanism for reusable command instructions. Windsurf workflows are markdown files that define a sequence of steps for Cascade to follow.

**Usage:**

```
/write-spec @submit-sales-order
```

Create a symlink to use your canonical commands folder:

```bash
ln -s ../.claude/commands .windsurf/workflows
```

📖 [Windsurf Workflows Documentation](https://docs.windsurf.com/windsurf/cascade/workflows)

For more about how commands work in factory engineering, see [Commands](/commands).

---

## Agents

**Supports true agents:** ❌ No

Windsurf has a single agent called Cascade, which does generate and maintain memories automatically. However, you cannot create multiple agents with different roles, nor can you control how Cascade reads from and writes to memory in the way factory engineering defines.

Cascade is a single, shared agent that all users work with in a given Windsurf session. It is not possible to define specialized agents like "spec writer" or "code reviewer" that operate independently with their own memory. You can still get the same memory pattern by instructing Cascade in `AGENTS.md` or in `.windsurf/rules` to read from a markdown file at the start and append learnings at the end.

For more about how agents work in factory engineering, see [Agents](/agents).

---

## Workflows

**Orchestration support:** ❌ No

Windsurf calls its slash commands "Workflows"; they are commands, not agent orchestration. Cascade is a single shared agent with no delegation layer, so the closest you can get is running commands yourself in sequence. That is human orchestration, not workflow-driven agent orchestration.

**Terminology collision:** Windsurf's "Workflows" (in `.windsurf/workflows/`) are what factory engineering calls commands — reusable task instructions invoked with a slash. They are not orchestration documents that coordinate multiple named agents.

For more about how workflows work in factory engineering, see [Workflows](/workflows).

---

## External Docs

- [Windsurf Cascade Skills Documentation](https://docs.windsurf.com/windsurf/cascade/skills)
- [Windsurf Workflows Documentation](https://docs.windsurf.com/windsurf/cascade/workflows)
