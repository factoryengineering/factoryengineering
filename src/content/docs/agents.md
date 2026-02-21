---
title: Agents
description: Specialized roles with persistent memory—configured LLM instances that read and write state between sessions for context that builds over time.
---

# Agents: Specialized Roles with Persistent Memory

An agent, in factory engineering, is a configured instance of an LLM with three critical properties: a defined role, a fresh context for each invocation, and persistent memory that the agent reads at the start and writes back to at the end.

An agent is not a prompt template. It is not a set of instructions injected into every conversation. It is a distinct entity that starts with a clean slate, loads its accumulated knowledge from a markdown file, performs its work, and then persists what it learned back to that file for the next invocation.

Think of it this way: you give an agent a role like "technical specification writer" or "code reviewer." That agent reads from a memory file at the beginning of its session—everything it learned last time. It executes a task or sequence of tasks. Then, before closing, it writes back new learnings, decisions, and context to that memory file. The next time that agent starts, it reads those accumulated memories and builds on them.

## Word of Caution: "Agent" is Overused

Many IDEs use the word "agent" to mean different things. Some use it to refer to the overall coding assistant. Some use it for custom instructions. Some use it for role-based chat modes. **None of these are agents in the factory engineering sense.** We will be very specific about what each IDE actually supports and what it calls those features.

The file `AGENTS.md` that appears in some IDEs has nothing to do with the agents described here. `AGENTS.md` is a text file of instructions. An agent, as defined here, is a persistent, stateful entity with its own memory.

## IDE Support for True Agents

Only a few IDEs provide true agent support as defined above:

| IDE | True Agent Support | Feature Name | Storage |
|-----|-------------------|--------------|---------|
| Claude Code | ✅ Yes | Sub-agents | `.claude/agents/` |
| GitHub Copilot | ⚠️ Partial | Custom agents | Project-level (memory requires Pro+) |
| KiloCode | ❌ No* | Modes | `.kilocode/custom_modes.yaml` |
| Cursor | ❌ No | (feature removed) | N/A |
| Windsurf | ❌ No | Cascade (singular) | N/A |
| Antigravity | ❌ No | N/A | N/A |

*Note: KiloCode modes allow role definition but do not provide the persistent, writable memory mechanism described here.

---

## Claude Code: True Agent Support

**Supports true agents:**✅ Yes

**Feature name:** Sub-agents

**Storage location:** `.claude/agents/` (project) or `~/.claude/agents/` (global)

Claude Code is the only IDE with full support for agents as defined in factory engineering. Each sub-agent operates in its own independent context window. The sub-agent has a role definition, reads persistent memory at the start of its session, and writes back to that memory after it completes its work.

**How it works:**

1. Define an agent with a role and initial instructions
2. The agent reads from a persistent memory directory at session start
3. The agent executes tasks in a fresh context
4. The agent writes learnings, decisions, and context back to its memory directory
5. On the next invocation, the agent reads those accumulated memories

**Example agent setup (`.claude/agents/spec-writer/AGENT.md`):**

```markdown
# Specification Writer Agent

## Role
You are a technical specification writer. Your job is to take user stories and produce detailed, clear technical specifications that the implementation team can follow without ambiguity.

## Your Memory
Read from: spec-writer-memory.md
After each specification you write, append your learnings to this file.

## Standards
Reference our specification standards in docs/spec-standards.md

## Success Criteria
- Specifications are complete and unambiguous
- They include data models, API contracts, and edge cases
- Implementation teams never need to guess your intent

## Memory Protocol
At the end of each session, write:
- Any patterns you discovered about how this team writes specs
- Common mistakes you avoided
- Standards the team values
- Architectural decisions you learned about
```

**Example agent memory file (`.claude/agents/spec-writer/spec-writer-memory.md`):**

```markdown
# Spec Writer Memory Bank

## Team Patterns
- This team uses OpenAPI3.1 for API specifications
- They prefer user flows as numbered steps, not prose
- Edge cases must be explicitly listed, never assumed

## Standards Learned
- API endpoints follow {resource}/{id}/action pattern
- Status codes: 200 (success), 400 (validation), 401 (auth), 500 (server)
- Specs must include performance requirements

## Previous Specifications
- [Previous spec 1]: Key learnings
- [Previous spec 2]: Key learnings
```

**Usage:**

In Claude Code, you invoke a sub-agent by name. The sub-agent loads its role definition and reads its memory file automatically.

```
@spec-writer write a specification for this user story: submit sales order
```

The agent reads spec-writer-memory.md, writes the specification, and appends new learnings to the memory file.

📖 [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)

---

## GitHub Copilot: Partial Agent Support

**Supports true agents:** ⚠️ Partial

**Feature name:** Custom agents

**Limitation:** Memory support requires Copilot Pro or Pro+ plan

GitHub Copilot has custom agents, but they do not natively provide the persistent, writable memory mechanism you defined. Custom agents are role-based configurations, but memory is repository-level, not agent-specific with write-back capability.

GitHub Copilot Pro and Pro+ users can enable Copilot Memory, which allows Copilot to store details about a repository. However, this is not the same as an individual agent reading from and writing to its own memory file at the start and end of each session.

For factory engineering purposes, GitHub Copilot's custom agents are limited. You can work around this by using `AGENTS.md` (which is just a text file of instructions, not a true agent) or by creating your own memory file at the project level and explicitly referencing it in your custom agent instructions.

**Workaround approach:**

Create a custom agent with explicit memory instructions:

```markdown
# Custom Agent: Spec Writer

You are a technical specification writer.

At the start of each session, read docs/.spec-writer-memory.md
At the end of each session, append your learnings to that file.

[Rest of your role definition]
```

Then manually manage the memory file by ensuring the agent reads and writes to it.

⚠️ This is a workaround, not true agent support.

📖 [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/about-agents)

---

## KiloCode: Modes (Not True Agents)

**Supports true agents:** ❌ No

**Feature name:** Modes

**Storage location:** `.kilocode/custom_modes.yaml`

KiloCode uses "modes" which allow you to define different roles and tool sets. However, modes do not provide the persistent, agent-specific, writable memory mechanism described in factory engineering.

KiloCode does have a "Memory Bank" feature (stored in `.kilocode/rules/memory-bank/`) which persists project context, but this is project-level memory, not agent-specific memory that an individual mode reads from and writes to independently.

If you need true agent support in KiloCode, you would need to create workarounds similar to the GitHub Copilot approach: manually managing memory files and explicitly referencing them in your mode instructions.

📖 [KiloCode Custom Modes Documentation](https://kilo.ai/docs/agent-behavior/custom-modes)

---

## Cursor: No Agent Support (Removed)

**Supports true agents:** ❌ No

Cursor previously had custom agent modes (called "custom agents"), but this feature was removed in recent versions. The functionality was consolidated into commands and other features, which do not provide the persistent agent memory capability you defined.

If you need agent-like behavior in Cursor, you would need to manage memory files manually using commands or other workarounds.

---

## Windsurf: No Agent Support (Cascade Only)

**Supports true agents:** ❌ No

Windsurf has a single agent called Cascade, which does generate and maintain memories automatically. However, you cannot create multiple agents with different roles, nor can you control how Cascade reads from and writes to memory in the way you defined.

Cascade is a single, shared agent that all users work with in a given Windsurf session. It is not possible to define specialized agents like "spec writer" or "code reviewer" that operate independently with their own memory.

---

## Antigravity: No Agent Support

**Supports true agents:** ❌ No

Google Antigravity does not support agents in the factory engineering sense. It uses skills (which are different from agents) and does not provide role-based, stateful agents with persistent memory.

---

## Setting Up Agents in Claude Code

Claude Code is the only IDE with true agent support. Here's how to set up agents for factory engineering:

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
