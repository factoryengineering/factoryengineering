---
title: Agents
description: Specialized roles with persistent memory. Configured LLM instances read and write state between sessions so context builds over time.
---

# Agents: Specialized Roles with Persistent Memory

An agent, in factory engineering, is a configured instance of an LLM with three critical properties: a defined role, a fresh context for each invocation, and persistent memory that the agent reads at the start and writes back to at the end.

An agent is not a prompt template. It is not a set of instructions injected into every conversation. It is a distinct entity that starts with a clean slate, loads its accumulated knowledge from a markdown file, performs its work, and then persists what it learned back to that file for the next invocation.

In practice, you give an agent a role like "technical specification writer" or "code reviewer." That agent reads from a memory file at the beginning of its session. That file holds everything it learned last time. It executes a task or sequence of tasks. Then, before closing, it writes back new learnings, decisions, and context to that memory file. The next time that agent starts, it reads those accumulated memories and builds on them.

**For factory engineering, use project-level agents.** Define agents in the project (e.g. `.claude/agents/`, `.kilo/agents/`) so roles and memory live with the repo and the whole team shares the same agent setup.

## Word of Caution: "Agent" is Overused

Many IDEs use the word "agent" to mean different things. Some use it to refer to the overall coding assistant. Some use it for project-specific instructions. **None of these are agents in the factory engineering sense.** We will be very specific about what each IDE actually supports and what it calls those features.

The file `AGENTS.md` that appears in some IDEs has nothing to do with the agents described here. `AGENTS.md` is a text file of instructions. An agent, as defined here, is a persistent, stateful entity with its own memory.

## Example: One Agent and Its Memory

A TDD test-writer agent illustrates the pattern. The agent has a single responsibility (write exactly one failing test for a given scenario), strict rules (minimal scaffolding, run the test, verify the right failure), and a memory protocol.

**Agent definition:**

```markdown
---
name: tdd-test-writer
description: "Use this agent as part of the TDD cycle to write a single failing test for a given scenario."
model: sonnet
color: red
memory: project
---

You are a senior test-driven development (TDD) engineer with deep expertise in writing precise, expressive, single-responsibility tests.

## Your Responsibility

Write **exactly one** failing test based on the scenario and criteria provided. Nothing more.

## Strict Operating Rules

### 1. Write ONE Test
- Write a single test case that covers the specific scenario given.
- Do not write multiple tests, parameterized suites, or helper tests.
- Do not refactor existing tests.

### 2. ...

**Update your agent memory** as you discover test patterns, naming conventions, testing utilities, common stub shapes, and recurring architectural patterns in this codebase. This builds institutional knowledge for future TDD cycles.
```

**Agent memory:**

```markdown
# TDD Test Writer Memory

## Test Framework
- Jest (not Vitest); test command: `npm run test:core`. Do not use Vitest-only `expect(value, message)`.
- Rich failure messages: use descriptive variable names; Jest shows actual vs expected in diffs.

## Conventions
- Test files: `packages/*/src/test/*.test.ts`. Stubs throw `new Error('Not implemented: ClassName')`.
- Assign results to named variables before asserting. All existing tests must still pass.

## Learned patterns
- [Agent appends: test locations, stub shapes, assertion patterns, debugging insights, user preferences.]
```

The agent reads MEMORY.md at start, writes one failing test and any minimal stubs, runs the test, then appends what it learned (e.g. "this project uses Jest, not Vitest" or "stub constructors use `_param` for unused args"). The next run builds on that.

---

## Why Agents Matter in Factory Engineering

Agents with persistent memory solve the context amnesia problem. Without persistent memory, an agent must re-learn the project's patterns, standards, and architectural decisions every time it starts a new session. With persistent memory, the agent builds on what it learned before.

This is especially powerful when you have specialized agents for different roles:
- A spec-writer agent learns how your team writes specifications
- A code-reviewer agent learns your code quality standards
- An implementation-planner agent learns how to break down work effectively

Each agent accumulates domain knowledge specific to its role and the project. Over time, each agent becomes more effective and more aligned with your team's practices.

---

## IDE Support for True Agents

Only a few IDEs provide true agent support as defined above:

| IDE | True Agent Support | Feature Name | Storage | Memory via markdown instruction |
|-----|-------------------|--------------|---------|----------------------------------|
| Claude Code | ✅ Yes | Sub-agents | `.claude/agents/` | Native (`memory: project` → `.claude/agent-memory/{name}/MEMORY.md`) |
| GitHub Copilot | ✅ Yes | Custom agents + sub-agents | `.github/agents/*.agent.md` (also reads `.claude/agents/`) | Yes (instruct agent to read/append a file) |
| Kilo Code | ✅ Yes | Agents (formerly modes) | `.kilo/agents/*.md` | Yes (instruct agent in its prompt to read/append a markdown file) |
| Cursor | ✅ Yes | Subagents | `.cursor/agents/` (also reads `.claude/agents/`) | Yes (instruct agent via its definition, `.cursor/rules`, or `AGENTS.md`) |
| Windsurf (Devin Desktop) | ⚠️ Preview | Subagents (Devin Local) | `.devin/agents/*.md` | Yes (instruct subagent in its definition to read/append a markdown file) |
| Antigravity | ✅ Yes | Custom subagents | `.agents/agents/*.md` | Yes (instruct subagent in its role definition to read/append a markdown file) |
| OpenAI Codex | ✅ Yes | Custom agents (TOML roles) | `.codex/agents/*.toml` | Yes (instruct agent in `developer_instructions` to read/append a markdown file) |

**Memory via markdown instruction:** Even without native agent memory, you can get the same behavior by instructing the assistant via that IDE's instruction mechanism (see table) to read from a markdown file at the start of work and append learnings at the end. Kilo Code agents used this way function as true agents.

---

For full setup details on defining, configuring, and invoking agents in each IDE, see the dedicated IDE pages:

- **[Claude Code](/ides/claude-code#agents)** — Native sub-agents with persistent memory; defined in `.claude/agents/`
- **[GitHub Copilot](/ides/github-copilot#agents)** — Custom agents + sub-agents; defined in `.github/agents/`; Copilot Memory stores repository facts, not per-agent memory
- **[Kilo Code](/ides/kilo-code#agents)** — Markdown agents (formerly modes) in `.kilo/agents/`; `mode: subagent` for delegated roles
- **[Cursor](/ides/cursor#agents)** — Subagents; defined in `.cursor/agents/` (also reads `.claude/agents/`); async delegation (v2.5+); Agents Window (v3.0)
- **[Windsurf (Devin Desktop)](/ides/windsurf#agents)** — Subagents in preview with Devin Local, which replaced Cascade; defined in `.devin/agents/`
- **[Antigravity](/ides/google-antigravity#agents)** — Custom subagents in `.agents/agents/`, invoked by name with `invoke_subagent`
- **[OpenAI Codex](/ides/openai-codex#agents)** — Custom agents via TOML role profiles in `.codex/agents/`; built-in `default`/`worker`/`explorer` roles; native memories are global, not per agent, so use the markdown-instruction pattern
