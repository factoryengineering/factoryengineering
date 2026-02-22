---
title: Workflows
description: Orchestrating agents—workflow documents that guide a top-level orchestrator to delegate, loop, and coordinate specialist agents through complex tasks.
---

# Workflows: Orchestrating Agents

A workflow, in factory engineering, is an orchestration document. It is read by a top-level orchestrator agent that breaks down a large task into discrete pieces, delegates each piece to a named specialist agent, evaluates the results, and decides what to do next. Workflows are not linear checklists. They contain conditions and loops—if the spec reviewer finds gaps, delegate back to the spec-writer. If the implementation passes review, proceed to test. If not, route back to the developer.

This is the highest layer of the software factory. Skills encode knowledge. Commands encode task instructions. Agents are the specialist roles. Workflows define how those agents coordinate to move artifacts through the factory.

## The Word "Workflow" Is Used Differently by Different IDEs

Before diving in, a critical terminology note: several IDEs use the word "workflow" for something entirely different. Windsurf calls its command mechanism "Workflows." KiloCode also has a feature it calls "Workflows." Neither of these are workflows in the factory engineering sense—they are commands, task instructions that a single agent follows in sequence.

This page covers what factory engineering means by the word—orchestration of named agents—and assesses how close each IDE can come to that capability.

**Software factory invocation:** To run a workflow with an artifact, use **slash-workflow at-artifact**, e.g. `/feature-development @docs/specs/submit-sales-order.md`. The workflow name is the filename without `.md`. Workflows are stored in `.claude/commands/`, alongside commands. Symlinks from `.cursor/commands/`, `.windsurf/workflows/`, `.kilocode/workflows/`, and `.agent/workflows/` point to `.claude/commands/` so every IDE sees the same files (see the Commands page).

---

## IDE Support for Workflow Orchestration

| IDE | Orchestration Support | Feature Name | Notes |
|-----|----------------------|--------------|-------|
| Claude Code | ✅ Yes | CLAUDE.md + subagent orchestration | Main agent reads workflow, delegates via Task tool |
| KiloCode | ✅ Yes | Orchestrator Mode | Built-in orchestrator delegates to named modes |
| GitHub Copilot | ⚠️ Partial | Agent HQ | Cross-agent task assignment, not in-session orchestration |
| Cursor | ❌ No | — | No orchestration layer |
| Windsurf | ❌ No (terminology collision) | "Workflows" = commands | Cascade has no orchestration capability |
| Antigravity | ❌ No | — | No orchestration layer |

---

## Claude Code: Full Workflow Orchestration

**Orchestration support:** ✅ Yes

**How it works:** The main Claude Code agent reads an orchestration document from CLAUDE.md or a referenced file and uses the Task tool to delegate work to named subagents. The orchestrator reads the workflow, assesses the situation, and dynamically routes work based on what it discovers. It can loop, branch, and coordinate parallel work.

Subagents cannot spawn other subagents—only the main orchestrator can delegate. This means the workflow sits at the orchestrator level, coordinating specialists below it.

### How to Write a Claude Code Workflow

Workflows for Claude Code are markdown documents written as orchestration instructions. They describe how the orchestrator should assess a situation and which subagents to delegate to. They are not step-by-step scripts—they are decision-making guidance for the orchestrator.

**Where workflows live:** Workflows are markdown files in `.claude/commands/`, the same folder as commands. One file per workflow (e.g. `feature-development.md`). The orchestrator reads that file when you invoke `/feature-development @artifact`.

**Example workflow: Feature Development (`feature-development.md`)**

This workflow assumes the user story and specification are already done. The user provides a specification (which contains a link to the user story). The workflow starts at implementation planning.

````markdown
# Feature Development Workflow

You are the orchestrator for this project's feature development process.
The user will provide a technical specification. The specification should 
contain a link to the user story. User story and specification steps are 
already complete—begin at implementation planning.

## Input Check
- If the user has **not** provided a specification: do **not** continue.
  Ask the user to provide a specification before proceeding. Do not 
  attempt to write a specification or infer one from a user story.
- If a specification is provided: read it (and the user story it links to, 
  if needed for context). Then proceed to Implementation Planning.

## Implementation Planning
Delegate to @implementation-planner:
- Input: the specification
- Expected output: a task breakdown saved to docs/plans/{story-slug}.md
- Review the plan for completeness. If any tasks are missing, loop back 
  to the implementation-planner with specific feedback.

## Implementation
For each task in the implementation plan:
- Delegate to the appropriate agent based on the task type:
  - UI tasks → @front-end-developer
  - API tasks → @back-end-developer
  - Data model tasks → @back-end-developer
  - Test tasks → @test-writer
- Run each task sequentially unless the tasks are independent, in which 
  case run them in parallel using background subagents

## Review
After implementation is complete, delegate to @code-reviewer:
- Input: all modified files
- If the reviewer finds critical issues, route back to the appropriate 
  developer agent with the specific findings
- If the reviewer finds warnings, surface them to the user for a decision
- Continue until the reviewer approves

## Completion
When all tasks pass review:
- Delegate to @test-runner to execute the test suite
- If tests fail, loop back to the appropriate developer with the failure output
- When tests pass, report completion to the user with a summary of what 
  was built
````

**Invoke the workflow:**

```
/feature-development @docs/specs/submit-sales-order.md
```

Execution is **slash-workflow then at-artifact**: the workflow name (filename without `.md`) followed by `@` and the specification path. The file `.claude/commands/feature-development.md` contains the orchestration instructions. The user supplies the specification; the orchestrator reads the workflow, checks that a specification was provided, and begins at implementation planning—delegating to the implementation-planner, developers, and reviewer in sequence, looping where the workflow instructs, and surfacing decisions that require human judgment. If no specification is provided, the orchestrator asks for one and does not continue.

### Restricting Which Subagents an Orchestrator Can Spawn

You can define an orchestrator subagent that has explicit control over which other subagents it can invoke:

````markdown
---
name: feature-orchestrator
description: Use to orchestrate feature development from specification through implementation and review. Expects the user to provide a specification (with a link to the user story); does not write specs.
tools: Task(implementation-planner, front-end-developer, back-end-developer, code-reviewer, test-runner), Read
---

You are the feature development orchestrator for this project.

Read your orchestration instructions from .claude/commands/feature-development.md
before beginning any feature development task. If the user has not provided a
specification, ask for one and do not proceed.
````

This makes the orchestrator itself a reusable, named agent that the team can invoke by name.

📖 [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)

📖 [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

---

## KiloCode: Orchestrator Mode

**Orchestration support:** ✅ Yes

**How it works:** KiloCode has a built-in Orchestrator mode whose explicit purpose is to break down complex tasks and delegate to other modes. The Orchestrator reads the task, formulates a plan, and uses the `new_task()` tool to spawn work in other modes. Each delegated task runs in its own context. The Orchestrator monitors results and coordinates the sequence.

Custom modes include a `whenToUse` field specifically to guide the Orchestrator's delegation decisions—it reads each mode's `whenToUse` description to decide which mode is appropriate for a given subtask.

### Important Terminology Note

KiloCode also has a feature it calls "Workflows" (stored in `.kilocode/workflows/`). **These are not workflows in the factory engineering sense.** KiloCode's "Workflows" are commands—reusable step-by-step task instructions invoked with a slash. They are covered in the Commands page of this guide.

What factory engineering calls a workflow is implemented in KiloCode through Orchestrator Mode, not through KiloCode's "Workflows" feature.

### How to Write Orchestration Instructions for KiloCode

Orchestration instructions for KiloCode are written as custom rules or instructions for the Orchestrator mode. The Orchestrator reads these and uses them to decide how to delegate.

**Example: Orchestration instructions for feature development**

Place in `.kilo/rules-orchestrator/feature-development.md`:

User story and specification are assumed done. The user provides a specification (which contains a link to the user story). Start at implementation planning.

````markdown
# Feature Development Orchestration

The user will provide a technical specification (with a link to the user 
story). User story and specification steps are already complete—begin at 
implementation planning.

## Input Check
If the user has **not** provided a specification: do **not** continue. Ask 
the user to provide a specification before proceeding. Do not attempt to 
write a specification or infer one from a user story.

If a specification is provided, read it (and the user story it links to if 
needed), then proceed to Implementation Planning.

## Implementation Planning
- Delegate to architect mode for implementation planning
- Input: the specification document
- Review the plan before proceeding

## Implementation
For each task in the plan:
- Route to the appropriate mode:
  - Frontend work → code mode (with front-end context)
  - Backend/API → code mode (with backend context)
  - Tests → code mode (with testing context)
- If a task fails, delegate to debug mode with the failure output
- Loop until the task succeeds before moving to the next

## Review
When implementation is complete:
- Delegate to a review-focused code mode
- If issues are found, route back to code mode with specific feedback
- Repeat until review passes
````

**Invoke the orchestrator:**

Switch to Orchestrator mode in KiloCode, then give it the specification (slash-workflow then at-artifact):

```
/feature-development @docs/specs/submit-sales-order.md
```

KiloCode may expose this as a slash command if the orchestration is wired to a workflow; otherwise use the same pattern in your prompt (workflow name + @ artifact). The Orchestrator reads its instructions, verifies a specification was provided, and begins at implementation planning—delegating to named modes in sequence and looping or branching as needed. If no specification is provided, it asks for one and does not continue.

📖 [KiloCode Custom Modes Documentation](https://kilo.ai/docs/customize/custom-modes)

📖 [KiloCode Orchestrator Mode](https://kilo.ai/docs/agent-behavior/orchestrator-mode)

---

## GitHub Copilot: Agent HQ (Cross-Agent, Not In-Session)

**Orchestration support:** ⚠️ Partial — cross-agent assignment, not in-session orchestration

In early February 2026, GitHub launched **Agent HQ** for Copilot Pro+ and Enterprise subscribers. Agent HQ is a unified dashboard where developers can assign tasks to GitHub Copilot, Anthropic's Claude Code, or OpenAI's Codex, and let those agents work asynchronously within GitHub's native workflows. All sessions are logged, and all agent output surfaces through the same PR and review workflow.

This is orchestration at a different level than what factory engineering describes. Agent HQ does not have an orchestrator agent that reads a workflow document and dynamically delegates to specialist sub-agents based on conditions. Instead, it gives developers a single interface to manually assign tasks to different agents and monitor their progress.

What it does provide that is relevant to factory engineering:

- **Parallel agent work**: Assign the same task to multiple agents and compare approaches
- **Asynchronous operation**: Agents work independently and submit PRs for review
- **Cross-agent visibility**: A single pane of glass for all agent activity across your repository
- **GitHub-native integration**: Agent output fits into your existing PR and code review process

For factory engineering purposes, GitHub Agent HQ is the closest thing to a workflow layer that GitHub Copilot offers today. You can assign a user story to one agent, review its output, then assign follow-up work to another agent—approximating the sequence of a factory workflow, but with human routing between each step rather than an orchestrator.

📖 [GitHub Agent HQ](https://github.com/features/copilot/agents)

📖 [The New Stack: GitHub Agent HQ Launch Coverage (Feb 4, 2026)](https://thenewstack.io/github-agent-hq/)

---

## Cursor: No Orchestration Support

**Orchestration support:** ❌ No

Cursor has no orchestrator agent and no mechanism for one agent to delegate to named specialist agents based on a workflow document. Cursor operates as a single agent and does not support the multi-agent coordination layer that factory engineering workflows require.

The closest Cursor can come is chaining commands manually—running one command, reviewing output, then running another. This is human orchestration, not agent orchestration.

---

## Windsurf: No Orchestration Support (Terminology Collision)

**Orchestration support:** ❌ No

**Terminology note:** Windsurf calls its command mechanism "Workflows." These are step-by-step task instructions stored in `.windsurf/workflows/` and invoked with a slash. They are covered in the Commands page of this guide. They are not workflows in the factory engineering sense.

Windsurf has a single agent, Cascade. Cascade cannot spawn specialist sub-agents or delegate work to named agents based on a workflow document. The factory engineering workflow concept—an orchestrator coordinating specialists—does not have an equivalent in Windsurf today.

The closest Windsurf can come is writing a Windsurf "workflow" (command) that sequences multiple steps within a single Cascade session, approximating a linear process but without the branching, looping, or multi-agent delegation that factory engineering workflows provide.

---

## Antigravity: No Orchestration Support

**Orchestration support:** ❌ No

Antigravity does not support multi-agent orchestration. It operates as a single agent and has no mechanism for reading a workflow document and delegating to named specialist agents.

---

## Writing Effective Factory Engineering Workflows

A factory engineering workflow is not a checklist. It is orchestration logic—decision-making guidance for an agent that is reading the situation and routing work dynamically.

### Principles for Workflow Documents

**Describe conditions, not just steps.** A workflow that only lists steps in order is a command, not a workflow. A real workflow tells the orchestrator how to respond to what it finds.

**Name agents explicitly.** The orchestrator delegates to specific named agents. Be precise about which agent handles which type of work.

**Define loop conditions.** When does the orchestrator loop back? What triggers a re-run? What constitutes completion? State these explicitly.

**Include escalation paths.** When should the orchestrator surface a decision to the human rather than proceeding autonomously? Define these gates.

### Example: Specification Review Workflow

````markdown
# Specification Review Workflow

You are orchestrating a specification review process.

## Input
A technical specification document.

## Initial Assessment
Read the specification. Evaluate completeness against our specification 
standards in docs/spec-standards.md.

If the specification is missing any required sections, delegate to 
@spec-writer with a specific list of missing elements.
Loop until all required sections are present.

## Domain Review
Delegate to @domain-expert for a review of the specification's correctness 
against our domain model.
- If the domain expert flags factual errors, route back to @spec-writer 
  with the specific errors.
- If the domain expert flags ambiguities, surface them to the user.
- Continue until the domain expert approves.

## Technical Feasibility
Delegate to @technical-architect for a feasibility review.
- If the architect flags implementation concerns, route back to @spec-writer 
  with those concerns.
- If the architect flags conflicts with existing architecture, surface to 
  the user for a decision.
- Continue until the architect approves.

## Completion
When all reviews pass, mark the specification as approved and update its 
status in the artifact registry.
Report completion to the user with a summary of any decisions that were 
made during the review process.
````

### When a Workflow Produces Poor Results

When a workflow produces poor orchestration—the orchestrator makes a wrong routing decision, loops unnecessarily, or misses a condition—update the workflow document. Make the condition more explicit. Add an example of the edge case. Commit the change. This is how your factory improves.

---

## Setting Up Workflows: Step-by-Step

**1. Create your commands directory:**

```bash
mkdir -p .claude/commands
```

**2. Add your first workflow:**

Create `.claude/commands/feature-development.md` and paste the Feature Development Workflow markdown from the example above. Workflows live in the same folder as commands.

**3. Create symlinks for other IDEs (see the [Commands](/commands) page).** Use the **factory-engineering** skill (`npx openskills install michaellperry/factoryengineering`) and run the skill to set up symlinks for your IDEs. The skill sets up both **commands/workflows** (`.claude/commands/`) and **skills** (`.claude/skills/`) by default. It can detect which IDEs you have and offer to copy existing contents if a target folder already exists. On Windows, use the skill's PowerShell script. Or create symlinks manually:

```bash
ln -s ../.claude/commands .cursor/commands
ln -s ../.claude/commands .windsurf/workflows
ln -s ../.claude/commands .kilocode/workflows
mkdir -p .agent && ln -s ../.claude/commands .agent/workflows
```

**4. Define the orchestrator agent (Claude Code):**

```bash
cat > .claude/agents/orchestrator.md << 'EOF'
---
name: orchestrator
description: Orchestrates feature development from specification through implementation and review. Use when the user provides a specification; ask for a specification if none is provided.
tools: Task(implementation-planner, front-end-developer, back-end-developer, code-reviewer, test-runner), Read
---

You are the feature development orchestrator for this project.

Before beginning any task, read the appropriate workflow document from
.claude/commands/ to understand how to coordinate the specialist agents.

Your role is to break down work, delegate to specialists, evaluate their
output, and coordinate the sequence until the work is complete. Do not
proceed without a specification from the user.
EOF
```

**5. Commit everything:**

```bash
git add .claude/commands/ .claude/agents/orchestrator.md .cursor .windsurf .kilocode .agent
git commit -m "Initialize factory engineering workflows and orchestrator"
```
