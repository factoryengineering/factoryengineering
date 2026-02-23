---
title: Agents
description: Specialized roles with persistent memory. Configured LLM instances read and write state between sessions so context builds over time.
---

# Agents: Specialized Roles with Persistent Memory

An agent, in factory engineering, is a configured instance of an LLM with three critical properties: a defined role, a fresh context for each invocation, and persistent memory that the agent reads at the start and writes back to at the end.

An agent is not a prompt template. It is not a set of instructions injected into every conversation. It is a distinct entity that starts with a clean slate, loads its accumulated knowledge from a markdown file, performs its work, and then persists what it learned back to that file for the next invocation.

In practice, you give an agent a role like "technical specification writer" or "code reviewer." That agent reads from a memory file at the beginning of its session. That file holds everything it learned last time. It executes a task or sequence of tasks. Then, before closing, it writes back new learnings, decisions, and context to that memory file. The next time that agent starts, it reads those accumulated memories and builds on them.

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

## IDE Support for True Agents

Only a few IDEs provide true agent support as defined above:

| IDE | True Agent Support | Feature Name | Storage | Memory via markdown instruction |
|-----|-------------------|--------------|---------|----------------------------------|
| Claude Code | ✅ Yes | Sub-agents | `.claude/agents/` | Native (read/write at session start/end) |
| GitHub Copilot | ✅ Yes | Custom agents | Project-level (memory requires Pro+) | Yes (instruct agent to read/append a file) |
| KiloCode | ✅ Yes | Modes | `.kilocode/custom_modes.yaml` | Yes (instruct mode to load from markdown; use `.kilocode/rules/` or mode-specific rules) |
| Cursor | ❌ No | (feature removed) | N/A | N/A |
| Windsurf | ❌ No | Cascade (singular) | N/A | N/A |
| Antigravity | ❌ No | N/A | N/A | N/A |

**Memory via markdown instruction:** Even without native agent memory, you can get the same behavior by instructing the assistant via that IDE’s instruction mechanism (see table) to read from a markdown file at the start of work and append learnings at the end. KiloCode modes used this way function as true agents.

---

## Claude Code

**Supports true agents:**✅ Yes

**Feature name:** Sub-agents

**Storage location:** `.claude/agents/` (project) or `~/.claude/agents/` (global)

Claude Code provides native support for agents as defined in factory engineering. Each sub-agent operates in its own independent context window. The sub-agent has a role definition, reads persistent memory at the start of its session, and writes back to that memory after it completes its work.

**Defining an agent:**

1. In Claude Code, use the `/agents` command to create a new agent.
2. Select to create a new project-level agent with Claude.
3. In the description, give the name of the agent, what it will expect, and the specific role you want it to play.
4. Be specific about the expected behavior and operating rules.
5. Select the model, color, and memory location.
6. Review the agent definition and confirm.

For example, to create a TDD test-writer agent, enter the command:

```
/agents
```

Select "Create new agent," "Project (.claude/agents/)", and "Generate with Claude (recommended)."

Then enter the following description:

```
TDD Test Writer. You will be given a scenario and criteria for new behavior. Write a single test for that scenario. Ensure that the test assertion produces a clear failure message that includes the actual value, the expected value, and the reason for that expectation. Run the test to confirm it fails for the expected reason.
```

Claude Code will generate a complete agent definition from your description. Review the definition and confirm.

**Invoking an agent:**

In Claude Code, invoke a sub-agent by name:

```
@"tdd-test-writer (agent)" write a failing test for: add a new pipeline step that filters items based on a predicate
```

The agent reads its memory file, writes the test, and appends new learnings to the memory file.

📖 [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)

---

## GitHub Copilot

**Supports true agents:** ✅ Yes

**Feature name:** Custom agents

**Note:** Memory support requires Copilot Pro or Pro+ plan

GitHub Copilot custom agents support true agents when you instruct them to read from and append to a markdown memory file at the start and end of each session. Define a custom agent with explicit memory instructions:

```markdown
# Custom Agent: Spec Writer

You are a technical specification writer.

At the start of each session, read docs/.spec-writer-memory.md
At the end of each session, append your learnings to that file.

[Rest of your role definition]
```

The agent then reads and writes that memory file as part of its workflow.

📖 [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agents)

---

## KiloCode: Modes

**Supports true agents:** ✅ Yes

**Feature name:** Modes

**Storage location:** `.kilocode/custom_modes.yaml`; mode-specific rules in `.kilocode/rules-${mode}/`

KiloCode modes are true agents when you instruct them to load from a markdown file for memory. Modes support custom instructions and can load project- or mode-specific rules from markdown in `.kilocode/rules/` and `.kilocode/rules-${mode}/`. By adding instructions such as “At the start of each session, read from `spec-writer-memory.md`; at the end, append your learnings to that file,” a mode implements the same persistent, read/write memory pattern as factory-engineering agents.

KiloCode also has a project-level “Memory Bank” (`.kilocode/rules/memory-bank/`); for agent-specific memory, use a dedicated markdown file per mode and reference it in that mode’s instructions.

📖 [KiloCode Custom Modes Documentation](https://kilo.ai/docs/agent-behavior/custom-modes)

---

## Cursor: No Agent Support (Removed)

**Supports true agents:** ❌ No

Cursor previously had custom agent modes (called "custom agents"), but this feature was removed in recent versions. The functionality was consolidated into commands and other features, which do not provide the persistent agent memory capability you defined.

You can still implement the memory pattern: in a `.cursor/rules` rule or in `AGENTS.md`, instruct the assistant to read from a markdown file at the start of work and append learnings at the end.

---

## Windsurf: No Agent Support (Cascade Only)

**Supports true agents:** ❌ No

Windsurf has a single agent called Cascade, which does generate and maintain memories automatically. However, you cannot create multiple agents with different roles, nor can you control how Cascade reads from and writes to memory in the way you defined.

Cascade is a single, shared agent that all users work with in a given Windsurf session. It is not possible to define specialized agents like "spec writer" or "code reviewer" that operate independently with their own memory. You can still get the same memory pattern by instructing Cascade in `AGENTS.md` or in `.windsurf/rules` to read from a markdown file at the start and append learnings at the end.

---

## Antigravity: No Agent Support

**Supports true agents:** ❌ No

Google Antigravity does not support agents in the factory engineering sense. It uses skills (which are different from agents) and does not provide role-based, stateful agents with persistent memory. You can instruct the assistant via `AGENTS.md`, `GEMINI.md`, or a skill’s `SKILL.md` to read from a markdown file at the start of work and append learnings at the end, achieving the same memory pattern.

---

## Setting Up Agents in Claude Code

The following shows how to set up agents for factory engineering in Claude Code (which provides native agent memory):

**1. Create agent directories:**

```bash
mkdir -p .claude/agents/spec-writer
mkdir -p .claude/agents/code-reviewer
mkdir -p .claude/agents/implementation-planner
```

**2. Create agent definitions:**

```bash
cat > .claude/agents/spec-writer/AGENT.md << 'EOF'
# Specification Writer Agent

## Role
You are an elite technical specification writer. Your job is to transform user stories into detailed, unambiguous technical specifications that implementation teams can execute against with zero guesswork.

## Memory Protocol
At the start of each session, read: spec-writer-memory.md
At the end of each session, append your learnings to: spec-writer-memory.md

What goes in memory:
- Patterns you discover about how this team writes specifications
- Architectural decisions you learn about
- Standards the team values
- Common mistakes to avoid

## Standards Reference
Reference our specification standards in docs/spec-standards.md

## Success Criteria
Specifications include:
- Clear feature description
- Complete user flows (numbered steps)
- Data model and schema
- API endpoints and contracts
- Error handling and edge cases
- Performance requirements
- Acceptance criteria
EOF
```

**3. Create memory files:**

```bash
cat > .claude/agents/spec-writer/spec-writer-memory.md << 'EOF'
# Spec Writer Memory Bank

## Team Patterns
[To be filled by agent based on learnings]

## Standards Learned
[To be filled by agent based on learnings]

## Previous Work
[Agent will append specifications written and patterns discovered]
EOF
```

**4. Commit to repository:**

```bash
git add .claude/agents/
git commit -m "Initialize factory engineering agents"
```

**5. Use the agent:**

In Claude Code, reference the agent by name:

```
@spec-writer write a specification for: submit sales order
```

The agent automatically loads its role definition and reads its memory file.

---

## Why Agents Matter in Factory Engineering

Agents with persistent memory solve the context amnesia problem. Without persistent memory, an agent must re-learn the project's patterns, standards, and architectural decisions every time it starts a new session. With persistent memory, the agent builds on what it learned before.

This is especially powerful when you have specialized agents for different roles:
- A spec-writer agent learns how your team writes specifications
- A code-reviewer agent learns your code quality standards
- An implementation-planner agent learns how to break down work effectively

Each agent accumulates domain knowledge specific to its role and the project. Over time, each agent becomes more effective and more aligned with your team's practices.
