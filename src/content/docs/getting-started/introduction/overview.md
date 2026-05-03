---
title: What is a Software Factory?
description: A short introduction to factory engineering — what skills, commands, agents, and workflows are, and why teams compose them into repeatable processes.
---

# What is a Software Factory?

Modern AI IDEs ship with a handful of features — **skills**, **commands**, **agents**, and **workflows** — that let you encode how *your* team writes software. A **software factory** is what you get when you compose those features into repeatable processes a whole team can rely on.

Instead of every developer prompting the assistant from scratch, the factory captures your team's standards once and applies them everywhere: in code reviews, in PR descriptions, in test generation, in release notes. The assistant follows the factory; the factory evolves with the codebase.

---

## Why factory engineering matters

Ad-hoc prompting is fast for one developer on one task. It does not scale to a team.

- **Consistency.** Two developers asking the same question get the same answer, because the assistant loads the same skills and follows the same commands.
- **Quality.** Standards live in version control alongside the code they govern, reviewed in pull requests like anything else.
- **Shared knowledge.** A senior engineer's taste, encoded as a skill, becomes available to every teammate from their next session onward.
- **Portability.** The same factory works across whichever AI IDE a teammate prefers — Claude Code, Cursor, Copilot, Windsurf, Kilo Code, Antigravity, or Codex.

Factory engineering is the practice of building, testing, and refining these factories so that AI-assisted development produces reliable results, not lucky ones.

---

## The four factory components

Every factory is built from four kinds of components. Each addresses a different need:

- **[Skills](/skills)** — reusable capabilities that teach the assistant *how* to do a task. Skills carry knowledge, opinions, and supporting scripts. The assistant loads them automatically when relevant.
- **[Commands](/commands)** — single-purpose, user-invoked instructions for specific tasks (`/review`, `/release-notes`). Composable and easy to share.
- **[Agents](/agents)** — roles with memory that handle complex, multi-step construction and decision-making.
- **[Workflows](/workflows)** — multi-step processes that coordinate multiple agents to accomplish sophisticated orchestrations.

Most teams start with skills. A handful of well-tested skills will already raise the floor on quality across the team.

---

## Choose your IDE

Factory components live in your repository, so they work across IDEs. Pick the guide that matches the tool your team uses today:

- [Claude Code](/ides/claude-code)
- [GitHub Copilot](/ides/github-copilot)
- [Cursor](/ides/cursor)
- [Windsurf](/ides/windsurf)
- [Kilo Code](/ides/kilo-code)
- [Google Antigravity](/ides/google-antigravity)
- [OpenAI Codex](/ides/openai-codex)

See the full comparison on the [IDEs](/ides) page.

---

## Ready to build something?

The fastest way to understand factory engineering is to build a skill yourself. The next page walks through it in five minutes — no installs, no setup, just your existing AI IDE and a task you already do often.

Continue to [Your First Skill in 5 Minutes →](/getting-started/quick-start/)
