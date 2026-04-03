---
title: Workflows
description: Orchestrating agents. Workflow documents guide a top-level orchestrator to delegate, loop, and coordinate specialist agents through complex tasks.
---

# Workflows: Orchestrating Agents

A workflow, in factory engineering, is an orchestration document. It is read by a top-level orchestrator agent that breaks down a large task into discrete pieces, delegates each piece to a named specialist agent, evaluates the results, and decides what to do next. Workflows are not linear checklists. They contain conditions and loops. If the spec reviewer finds gaps, delegate back to the spec-writer; if the implementation passes review, proceed to test; if not, route back to the developer.

This is the highest layer of the software factory. Skills encode knowledge. Commands encode task instructions. Agents are the specialist roles. Workflows define how those agents coordinate to move artifacts through the factory.

## The Word "Workflow" Is Used Differently by Different IDEs

Several IDEs use the word "workflow" for something else. Windsurf and Kilo Code both have features they call "Workflows." Those are reusable slash commands, not orchestration of named agents. This page uses the factory engineering meaning: orchestration of agents, with delegation, branching, and looping.

**Invocation:** Use **slash-workflow at-artifact**, e.g. `/tdd-cycle @docs/specs/order-validation.md`. The workflow name is the filename without `.md`. Store workflows in `.claude/commands/` so they sit alongside commands and can be invoked the same way. Symlinks from `.cursor/commands/`, `.windsurf/workflows/`, `.kilocode/workflows/`, and `.agent/workflows/` point to `.claude/commands/` so every IDE sees the same files (see the [Commands](/commands) page).

---

## Recommended Location: `.claude/commands/`

Store workflow documents in `.claude/commands/`. That gives you:

- **One place for both commands and workflows.** The user invokes a workflow by name; the file lives next to single-agent commands.
- **Slash-workflow at-artifact.** Invoke with `/workflow-name @path/to/artifact`. The workflow name is the filename without `.md`; the artifact is the input (e.g. a spec, a design, a user story).
- **Shared across IDEs.** Symlink `.claude/commands/` into each IDE’s commands/workflows folder so the same workflow file is available everywhere.

Do not maintain separate copies of the same workflow in each IDE. Use symlinks. Without the symlink, you would have to keep each copy in sync by hand.

Because workflows are stored in `.claude/commands/` and shared via symlinks (like commands), keep them **IDE-agnostic**: do not rely on `$ARGUMENTS` or other placeholders. Not all IDEs support them. State in the workflow what the user will supply (e.g. a design or specification, via slash-workflow at-artifact) and instruct the orchestrator to stop and prompt the user if that input is missing. See the [Commands](/commands) page for the same pattern.

---

## Example: TDD Cycle Workflow

The following workflow runs a full TDD cycle from design to passing tests. It is stored as `.claude/commands/tdd-cycle.md` and invoked as `/tdd-cycle @path/to/design.md`. It shows delegation to named agents, conditional logic (refactor only when warranted, plan check), and a loop over tests. The orchestrator makes decisions based on what is learned each step. It uses the IDE-agnostic pattern: state what the user supplies and instruct the orchestrator to stop and prompt if missing (no `$ARGUMENTS`).

````markdown
---
description: Run a full TDD cycle from design to passing tests
---

# TDD Cycle

The user will supply a design or specification document. If no design or specification is supplied, stop and prompt the user before proceeding.

You are orchestrating a complete TDD cycle. The design or specification to implement is the document the user supplied. Read it from context. Follow these phases precisely, delegating to the appropriate specialized agents.

---

## Phase 1: Planning

Delegate to the **tdd-planner** agent with the full design specification above. Ask it to produce a complete, ordered test plan covering all phases (structural, behavioral, integration, edge cases).

When the planner returns, **read and internalize the full plan**. Extract the ordered list of tests. This is your working backlog.

---

## Phase 2: TDD Loop

Work through each test in the plan sequentially. For each test:

### Step A: Write the Failing Test

Delegate to the **tdd-test-writer** agent. Provide:
- The specific test scenario from the plan (be precise: include verifies, forces-into-existence, and why-here from the plan)
- Any context from previously completed tests that affects scaffolding

After the agent returns, confirm the test is **failing for the right reason** (assertion failure or not-implemented stub, not a compile error).

### Step B: Make the Test Pass

Delegate to the **tdd-code-writer** agent. Provide:
- The failing test details returned by tdd-test-writer
- The test scenario and what minimal implementation is needed

After the agent returns, confirm **all previously passing tests still pass** and the new test now passes.

### Step C: Refactor (if needed)

After the test passes, evaluate whether refactoring is warranted. Refactor if:
- There is obvious duplication introduced by the new code
- An abstraction is now clearly visible that was not visible before
- The code violates a clear project convention

If refactoring is warranted, delegate to the **tdd-refactor** agent. Provide:
- The newly passing code
- What refactoring you believe is needed and why

After refactoring, confirm all tests still pass.

### Step D: Plan Check

After each completed test, briefly assess:
- Does the plan still make sense given what was discovered during implementation?
- Did the implementation reveal any structural decisions that affect upcoming tests?
- Are there any new edge cases or integration concerns that should be added to the backlog?

If the plan needs significant adjustment (new tests needed, existing tests reordered, a test is now irrelevant), delegate to the **tdd-planner** agent with:
- The original specification
- The tests completed so far and what was learned
- The specific concern or deviation to address

Ask it to produce a revised plan for the remaining tests.

---

## Phase 3: Completion

When all tests in the plan have passed:

1. Run the full test suite to confirm nothing is broken: `npm test`
2. Run TypeScript type checking: `npm run typecheck`
3. If any Rust code was modified: `npm run fmt:check`

Summarize what was built:
- Feature/component implemented
- Tests written (count and names)
- Key design decisions that emerged through the TDD process
- Any deviations from the original plan and why

---

## Orchestration Rules

- **Never write test code yourself.** Always delegate test writing to tdd-test-writer.
- **Never write implementation code yourself.** Always delegate implementation to tdd-code-writer.
- **Never refactor yourself.** Always delegate refactoring to tdd-refactor.
- **Never skip the plan check** between tests. Small course corrections prevent large wasted efforts.
- **If an agent returns an error or unexpected state**, analyze it yourself before re-delegating. Don't re-run the same agent with the same prompt in a loop.
- **Track your position in the plan** explicitly. After each test completes, state clearly which test you just finished and which is next.
- **Proceed to the next test automatically** unless you need user input to resolve an ambiguity. Do not ask for permission between each test.
````

### What This Example Demonstrates

**Delegation.** The orchestrator never writes tests, implementation, or refactors. It delegates to **tdd-planner**, **tdd-test-writer**, **tdd-code-writer**, and **tdd-refactor**. The workflow states this in both the phase text and the Orchestration Rules.

**Conditional logic.** Step C runs only when refactoring is warranted (duplication, new abstraction, convention violation). Step D runs after every test; the orchestrator decides whether the plan needs revision and only then delegates back to **tdd-planner** with the current state and the specific concern.

**Looping.** Phase 2 is an explicit loop: "Work through each test in the plan sequentially." The plan itself can change mid-loop (Step D), so the orchestrator iterates over a possibly updated backlog.

**Decisions based on what is learned.** The "Plan Check" step tells the orchestrator to use what was discovered during implementation to decide if the plan still makes sense and whether to request a revised plan. Completion asks for a summary of deviations from the original plan and why. The workflow is built to react to what happens during execution.

---

## Agent Participation: Deviations and Opportunities

Workflows run better when specialist agents report back in a way the orchestrator can use. Two kinds of feedback matter:

**Deviations.** When an agent does something different from what was asked (e.g. it simplified a step, skipped something that turned out to be unnecessary, or took a different design turn), it should say so and why. The orchestrator can then update its mental model, adjust the plan (e.g. via a plan-check step), or surface the deviation in the completion summary. The TDD Cycle completion phase explicitly asks for "Any deviations from the original plan and why."

**Opportunities.** When an agent notices something that is not strictly required but would help (refactoring, a missing test, a clearer abstraction, a convention that could be applied), it should report it. The workflow can then decide: delegate to another agent (e.g. tdd-refactor), add an item to the backlog (e.g. in the plan check), or surface it to the user. The TDD example encodes this in Step C (refactor when duplication or abstraction is visible) and in the plan check (new edge cases or integration concerns to add to the backlog).

Instruct agents in the workflow or in their agent definitions to include deviations and opportunities in their responses. The orchestrator reads those responses to decide the next step; without that feedback, the orchestrator is driving blind.

---

## IDE Support for Workflow Orchestration

| IDE | Orchestration Support | Feature Name | Notes |
|-----|----------------------|--------------|-------|
| Claude Code | ✅ Yes | CLAUDE.md + subagent orchestration | Main agent reads workflow, delegates via Task tool |
| Kilo Code | ✅ Yes | Orchestrator Mode | Built-in orchestrator delegates to named modes |
| GitHub Copilot | ⚠️ Partial | Agent HQ | Cross-agent task assignment, not in-session orchestration |
| Cursor | ⚠️ Partial | Agents Window + subagent delegation | Parent agents delegate to subagents; no workflow-document orchestrator |
| Windsurf | ❌ No (terminology collision) | "Workflows" = commands | Cascade has no orchestration capability |
| Antigravity | ❌ No | — | No orchestration layer |

---

### Claude Code: Full Workflow Orchestration

**Orchestration support:** ✅ Yes

Invoke with **slash-workflow at-artifact** (e.g. `/tdd-cycle @path/to/design.md`). The main agent reads the workflow from `.claude/commands/` and the artifact you supplied, then uses the Task tool to delegate work to named subagents. The orchestrator reads the workflow, assesses the situation, and dynamically routes work based on what it discovers. It loops, branches, and coordinates parallel work according to the workflow.

Subagents cannot spawn other subagents. Only the main orchestrator can delegate. The workflow sits at the orchestrator level, coordinating specialists below it.

**Where workflows live:** In `.claude/commands/`, one file per workflow (e.g. `tdd-cycle.md`). Invoke with `/tdd-cycle @path/to/design.md`. The orchestrator reads the workflow and the artifact, then follows the phases. It delegates to tdd-planner, tdd-test-writer, tdd-code-writer, and tdd-refactor, and applies the conditional and looping logic in the document.

Define an orchestrator subagent that is restricted to specific tools and subagents, and that is instructed to read a given workflow file before starting. That makes the orchestrator a reusable, named agent the team can invoke by name.

📖 [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)  
📖 [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams)

---

### Kilo Code: Orchestrator Mode

**Orchestration support:** ✅ Yes

Kilo Code has a built-in Orchestrator mode that breaks down complex tasks and delegates to other modes via `new_task()`. The Orchestrator reads the task, formulates a plan, and spawns work in other modes. Custom modes use a `whenToUse` field to guide delegation.

**Terminology:** Kilo Code's "Workflows" (in `.kilocode/workflows/`) are commands, but can be used for orchestration of agents. Create a symlink from `.claude/commands/` to `.kilocode/workflows/` so the same workflow file is available everywhere.

Factory engineering workflows are implemented in Kilo Code through Orchestrator Mode. Invoke a workflow using the *slash-workflow at-artifact* pattern (e.g. `/tdd-cycle @docs/specs/order-validation.md`).

Place orchestration instructions in a rule file the Orchestrator reads, then invoke with the same pattern: slash-workflow at-artifact (e.g. `/tdd-cycle @docs/specs/order-validation.md`).

📖 [Kilo Code Custom Modes](https://kilo.ai/docs/customize/custom-modes)  
📖 [Kilo Code Orchestrator Mode](https://kilo.ai/docs/code-with-ai/agents/orchestrator-mode)

---

### GitHub Copilot: Agent HQ (Cross-Agent, Not In-Session)

**Orchestration support:** ⚠️ Partial

GitHub Agent HQ (Feb 2026) lets developers assign tasks to different agents and monitor progress in a single dashboard. It does not provide an in-session orchestrator that reads a workflow document and delegates to specialist subagents. You approximate a workflow by manually routing work between agents and reviewing their output.

📖 [GitHub Agent HQ](https://github.com/features/copilot/agents)

---

### Cursor: Partial Orchestration via Subagent Delegation

**Orchestration support:** ⚠️ Partial

Cursor's Agents Window (v3.0, April 2026) lets you run many agents in parallel across repos, worktrees, and cloud environments. A parent agent can delegate work to custom subagents defined in `.cursor/agents/`, and subagents can spawn their own subagents (v2.5+), creating a tree of coordinated work.

However, Cursor does not have a dedicated orchestrator that reads a workflow document and delegates to named specialists based on its contents. The delegation is ad-hoc — the parent agent decides how to split work based on its prompt, not by following a structured workflow file. You can approximate workflow-driven orchestration by writing detailed instructions in a command file and relying on the parent agent to follow them, but there is no enforcement layer.

**Closest pattern:** Write a command in `.cursor/commands/` that describes phases and specialist subagents. Invoke it with `/command-name @artifact`. The parent agent reads the command and delegates to subagents, but routing logic depends on the model's interpretation rather than a built-in orchestration engine.

📖 [Cursor Subagents Documentation](https://cursor.com/docs/subagents) · [Cursor Agents Window](https://cursor.com/changelog/3-0)

---

### Windsurf, Antigravity: No Orchestration Support

**Windsurf** calls its slash commands "Workflows"; they are commands, not agent orchestration. **Antigravity** does not support multi-agent orchestration. In these environments, the closest you can get is running commands yourself in sequence. That is human orchestration, not workflow-driven agent orchestration.

---

## Writing Effective Workflows

A factory engineering workflow is orchestration logic: decision-making guidance for an agent that reads the situation and routes work dynamically.

**Do not use `$ARGUMENTS`.** Workflows live in `.claude/commands/` and are shared via symlinks; not all IDEs support placeholders. State what the user will supply and instruct the orchestrator to stop and prompt if it is missing.

**Describe conditions, not just steps.** A list of steps in order is a command. A workflow tells the orchestrator how to respond to what it finds (e.g. refactor only when warranted; delegate back to the planner only when the plan needs adjustment).

**Name agents explicitly.** The orchestrator delegates to specific agents. State which agent handles which work (e.g. tdd-test-writer for tests, tdd-refactor for refactors).

**Define loop and branch conditions.** When does the orchestrator loop (e.g. for each test; loop until review passes)? What triggers a re-delegation (e.g. plan no longer makes sense)? What constitutes completion?

**Include escalation paths.** When should the orchestrator surface a decision to the user instead of proceeding? Define those gates.

**Expect deviations and opportunities from agents.** Tell agents to report when they deviated from the ask or when they see an opportunity (e.g. refactoring, extra tests). Use that feedback in conditionals and in the completion summary.

When a workflow produces poor orchestration (wrong routing, unnecessary loops, or missed conditions), update the workflow. Make the condition explicit, add an edge-case example, and commit. That is how the factory improves.
