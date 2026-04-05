---
title: OpenAI Codex
description: Complete factory engineering guide for OpenAI Codex — skills setup and Agent Skills standard support.
---

# OpenAI Codex

OpenAI Codex adopted the Agent Skills open standard in December 2025, bringing parity with the rest of the AI IDE ecosystem. Codex loads skills from `.codex/skills/` and evaluates each skill's `description` to decide when to load it — the same progressive disclosure model used by Claude Code, Cursor, and Copilot.

---

## Skills

**Supports Agent Skills standard:** ✅ Yes — adopted December 2025

| Scope | Path |
|-------|------|
| Project | `.codex/skills/` |
| Global | `~/.codex/skills/` |

Codex loads skills from `.codex/skills/` and evaluates each skill's `description` to decide when to load it. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .codex/skills
```

Codex supports the standard `user-invocable` and `disable-model-invocation` frontmatter properties for controlling when a skill is loaded automatically versus invoked by name.

📖 [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)

For more about how skills work in factory engineering, see [Skills](/skills).

---

## Commands

No dedicated commands documentation is available for OpenAI Codex at this time. Refer to the [Commands](/commands) page for the general approach to sharing commands via symlinks.

---

## Agents

No dedicated agents documentation is available for OpenAI Codex at this time. Refer to the [Agents](/agents) page for the general approach to implementing agent patterns.

---

## Workflows

No dedicated workflow orchestration documentation is available for OpenAI Codex at this time. Refer to the [Workflows](/workflows) page for the general approach to workflow orchestration.

---

## External Docs

- [OpenAI Codex Skills Documentation](https://developers.openai.com/codex/skills)
