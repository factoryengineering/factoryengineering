---
title: Workflows
description: Orchestrating agents. Workflow documents guide a top-level orchestrator to delegate, loop, and coordinate specialist agents through complex tasks.
---

# Workflows: Orchestrating Agents

A workflow, in factory engineering, is an orchestration document. It is read by a top-level orchestrator agent that breaks down a large task into discrete pieces, delegates each piece to a named specialist agent, evaluates the results, and decides what to do next. Workflows are not linear checklists. They contain conditions and loops. If the spec reviewer finds gaps, delegate back to the spec-writer; if the implementation passes review, proceed to test; if not, route back to the developer.

This is the highest layer of the software factory. Skills encode knowledge. Commands encode task instructions. Agents are the specialist roles. Workflows define how those agents coordinate to move artifacts through the factory.

## The Word "Workflow" Is Used Differently by Different IDEs

Several IDEs use the word "workflow" for something else. Windsurf and Kilo Code both have features they call "Workflows." Those are reusable slash commands, not orchestration of named agents. Claude Code, GitHub Copilot, and Google Antigravity use "workflows" for script-driven orchestration (see [Script-Driven Workflows](#script-driven-workflows)). This page uses the factory engineering meaning: a document that guides an orchestrator agent through delegation, branching, and looping.

**Invocation:** Use **slash-workflow at-artifact**, e.g. `/tdd-cycle @docs/specs/order-validation.md`. The workflow name is the skill name. Store workflows as skills in `.agents/skills/`, alongside commands, so every IDE finds them by the same name. The prefix depends on the product: `/tdd-cycle` in most, `$tdd-cycle` in the Codex CLI, and `@tdd-cycle` in Devin Desktop (see the [Commands](/commands#ide-by-ide-reference) page).

---

## Recommended Location: `.agents/skills/`

Store each workflow document as a command skill: `.agents/skills/{workflow-name}/SKILL.md` with `disable-model-invocation: true` and an `agents/openai.yaml` that disables implicit invocation (see [Commands](/commands#portable-metadata-and-vendor-specific-controls)). That gives you:

- **One place for skills, commands, and workflows.** The user invokes a workflow by name; the file lives next to single-agent commands.
- **Slash-workflow at-artifact.** Invoke with `/workflow-name @path/to/artifact`. The artifact is the input (e.g. a spec, a design, a user story).
- **Shared across IDEs.** Every IDE except Claude Code reads `.agents/skills/` directly. The [skills sync](/skills#managing-skills-across-ides) mirrors it into `.claude/skills/` for Claude Code.
- **Explicit invocation.** A workflow orchestrates many agents and spends many tokens. In Claude Code, Cursor, GitHub Copilot (VS Code and CLI), and OpenAI Codex, the vendor controls stop the model from starting it on its own. Windsurf (Devin Desktop), Kilo Code, and Google Antigravity have no explicit-only control, so write the workflow's description to say it runs only when the user invokes it by name, and keep it specific to the artifact it processes.

Do not maintain separate copies of the same workflow in each IDE by hand.

### A workflow skill is instructions, not an engine

The skill describes the process. The orchestrating agent reads it and decides, turn by turn, what to do next. Nothing in the skill format provides:

- **Guaranteed execution order.** The agent can skip, reorder, or repeat a step.
- **Isolation.** Specialists share the working tree unless the IDE offers per-agent worktrees and the workflow asks for them.
- **Approval gates.** The agent stops for a person only where the workflow tells it to and it follows that instruction.
- **Durable progress.** If the session ends, its progress ends with it. The next run starts from the beginning unless the workflow records progress somewhere it can read back.

Design for these limits. Make each step's result visible in the repository (a test, a file, a commit) so the orchestrator and the reviewer can check it. Write escalation points as explicit "stop and ask the user" instructions. Have long workflows record their position in a progress file that a restarted run reads first. For work that needs deterministic fan-out rather than judgment, use the IDE's script-driven orchestration instead.

Because workflows are shared across IDEs (like commands), keep them **IDE-agnostic**: do not rely on `$ARGUMENTS` or other placeholders. Not all IDEs support them. State in the workflow what the user will supply (e.g. a design or specification, via slash-workflow at-artifact) and instruct the orchestrator to stop and prompt the user if that input is missing. See the [Commands](/commands) page for the same pattern.

---

## Example: TDD Cycle Workflow

The following workflow runs a full TDD cycle from design to passing tests. It is stored as `.agents/skills/tdd-cycle/SKILL.md` and invoked as `/tdd-cycle @path/to/design.md`. It shows delegation to named agents, conditional logic (refactor only when warranted, plan check), and a loop over tests. The orchestrator makes decisions based on what is learned each step. It uses the IDE-agnostic pattern: state what the user supplies and instruct the orchestrator to stop and prompt if missing (no `$ARGUMENTS`).

````markdown
---
name: tdd-cycle
description: Run a full TDD cycle from design to passing tests. Run only when the user invokes /tdd-cycle explicitly.
disable-model-invocation: true
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

No IDE has a dedicated engine that parses a workflow file. In every IDE, the workflow is a command skill whose text tells the main agent which named specialists to call, in what order, and under what conditions. What matters is whether the main agent can delegate to **named, project-defined agents** and how reliably it does so.

**Support for delegation is not a guarantee of delegation.** In every IDE below, the model decides at run time whether to hand a step to the named agent or do it itself. Naming an agent in a workflow makes delegation likely, not certain. When a step must be done by an independent agent (for example, review by an agent that did not write the code), state that as an orchestration rule, check the transcript in a clean session, and use a script-driven workflow where the IDE offers one and the separation must be enforced.

| IDE | Orchestration Support | Delegation Mechanism | Notes |
|-----|----------------------|----------------------|-------|
| Claude Code | ✅ Yes | Agent tool → `.claude/agents/` | Subagents can nest up to three levels; also script-driven dynamic workflows |
| GitHub Copilot | ✅ Yes | `task` tool → `.github/agents/` | Copilot harness in VS Code and the CLI; the model may delegate or do the step itself; `/fleet` encourages parallel delegation; dynamic workflows (public preview) in the CLI, app, and SDK |
| Cursor | ✅ Yes | `Task` tool → `.cursor/agents/` | Async and nested subagents; test delegation, because the parent sometimes does the work itself |
| Kilo Code | ✅ Yes | `task` tool → `.kilo/agents/` | Foreground or background subagents; Orchestrator mode is deprecated |
| Google Antigravity | ✅ Yes | `invoke_subagent` → `.agents/agents/` | `/boost`, `/swarm`, and `/teamwork` are separate coordination modes; also script-driven Dynamic Workflows |
| OpenAI Codex | ✅ Yes | `spawn_agent` → `.codex/agents/` | `max_threads` default 6; `max_depth` default 1, so specialists cannot delegate further |
| Windsurf (Devin Desktop) | ⚠️ Preview | Subagents (Preview) in Devin Local | Devin Local replaced Cascade; delegation needs the Subagents (Preview) setting; Windsurf "Workflows" are commands |

---

For full details on workflow orchestration in each IDE, see the dedicated IDE pages:

- **[Claude Code](/ides/claude-code#workflows)** — ✅ The main agent reads the workflow skill and delegates via the Agent tool to named subagents with looping, branching, and parallel coordination.
- **[GitHub Copilot](/ides/github-copilot#workflows)** — ✅ The Copilot harness can delegate to named custom agents with its `task` tool, or handle the step itself. `/fleet` encourages parallel delegation, but Copilot decides how to divide the work.
- **[Cursor](/ides/cursor#workflows)** — ✅ The parent agent delegates to named subagents by `/name` or plain-language request. Projects (beta) add a coordinator agent for long-running work.
- **[Kilo Code](/ides/kilo-code#workflows)** — ✅ Primary agents delegate to named subagents with the `task` tool, in the foreground or background.
- **[Google Antigravity](/ides/google-antigravity#workflows)** — ✅ The main agent delegates to named custom subagents with `invoke_subagent`. `/boost`, `/swarm`, `/teamwork`, and Dynamic Workflows are separate coordination modes.
- **[OpenAI Codex](/ides/openai-codex#workflows)** — ✅ The parent agent spawns named TOML-defined roles with `spawn_agent`, in parallel.
- **[Windsurf (Devin Desktop)](/ides/windsurf#workflows)** — ⚠️ Preview. Devin Local, which replaced Cascade, delegates to subagents through its Subagents (Preview) setting.

---

## Script-Driven Workflows

In 2026 several IDEs added a second kind of orchestration, confusingly also called "workflows." Instead of a document the main agent interprets turn by turn, a **script** defines the steps, conditions, and handoffs, and a runtime executes it. The script spawns subagents, runs them in parallel or in sequence, and passes results between stages. Agents still handle the steps that need judgment, so their answers can differ between runs, but the process itself is code-enforced.

| IDE | Feature | How to run it |
|-----|---------|---------------|
| Claude Code | Dynamic workflows (JavaScript) | Ask for a workflow; monitor with `/workflows`; save to `.claude/workflows/` and run as `/{name}` |
| GitHub Copilot | Dynamic workflows (public preview), defined in Copilot extensions | Copilot CLI (`copilot workflow run {name}`), Copilot app, and Copilot SDK; not VS Code chat or the cloud agent. All plans except Pro and Pro+ subscribers on legacy annual premium-request billing |
| Google Antigravity | Dynamic Workflows (Python) | `/run-workflow` in the Antigravity App (AI Pro and Ultra plans); you approve the generated script before it runs |

The two kinds serve different purposes:

- **Document-driven workflows** (the subject of this page) hold the plan in prose. The orchestrator makes judgment calls at every step: whether to refactor, whether the plan still makes sense, when to escalate to the user. Use them for work whose next step depends on what the last step revealed, such as a TDD cycle or a spec-review loop.
- **Script-driven workflows** hold the plan in code. The runtime enforces the steps and handoffs, and some runtimes add checkpoints and resource limits. Use them for broad, uniform work such as a codebase-wide audit, a large migration, or research cross-checked from several angles.

### Comparing execution guarantees

For an unattended factory, the important question is what is enforced by the runtime and what depends on the model following instructions:

| Guarantee | Document-driven workflow skill | Claude Code dynamic workflows | Copilot dynamic workflows | Antigravity Dynamic Workflows |
|-----------|-------------------------------|-------------------------------|---------------------------|-------------------------------|
| **Execution order** | Model-directed; steps can be skipped or reordered | Code-defined | Code-defined | Code-defined |
| **Isolation** | Shared working tree unless the workflow asks for worktrees | Not documented for workflow agents | Subagents inherit the session's permissions | Not documented |
| **Checkpoints and resume** | None; progress ends with the session | Pause and resume from `/workflows`; a relaunch reuses completed agents' results | Pause at a checkpoint and resume the run | Not documented |
| **Approval gates** | Only as instructions the model may follow | No mid-run user input; pauses only for permission prompts and usage limits. Run each stage as its own workflow for sign-off | Can ask for input where the app supports it, and pause for review | You approve the script before it runs |
| **Resource limits** | None beyond the IDE's own limits | Up to 16 concurrent agents by default (`CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS`) | Limits on concurrent agents, total agents, active running time, and AI credits | Not documented |

"Not documented" means the vendor's documentation does not describe the behavior. Test it before relying on it.

Script-driven workflows are IDE-specific. They do not share across IDEs the way workflow skills do, so keep the factory's core workflows as document-driven skills, and move a workflow to a script when its order, checkpoints, or limits must be enforced rather than requested.

📖 [Claude Code dynamic workflows](https://code.claude.com/docs/en/workflows) · [Copilot dynamic workflows](https://docs.github.com/en/copilot/concepts/agent-capabilities/agent-powered-workflows-and-operations/dynamic-workflows) · [Antigravity Dynamic Workflows](https://antigravity.google/docs/dynamic-workflows)

---

## Writing Effective Workflows

A factory engineering workflow is orchestration logic: decision-making guidance for an agent that reads the situation and routes work dynamically.

**Do not use `$ARGUMENTS`.** Workflows are skills shared across IDEs; not all IDEs support placeholders. State what the user will supply and instruct the orchestrator to stop and prompt if it is missing.

**Describe conditions, not just steps.** A list of steps in order is a command. A workflow tells the orchestrator how to respond to what it finds (e.g. refactor only when warranted; delegate back to the planner only when the plan needs adjustment).

**Name agents explicitly.** The orchestrator delegates to specific agents. State which agent handles which work (e.g. tdd-test-writer for tests, tdd-refactor for refactors).

**Define loop and branch conditions.** When does the orchestrator loop (e.g. for each test; loop until review passes)? What triggers a re-delegation (e.g. plan no longer makes sense)? What constitutes completion?

**Include escalation paths.** When should the orchestrator surface a decision to the user instead of proceeding? Define those gates.

**Expect deviations and opportunities from agents.** Tell agents to report when they deviated from the ask or when they see an opportunity (e.g. refactoring, extra tests). Use that feedback in conditionals and in the completion summary.

When a workflow produces poor orchestration (wrong routing, unnecessary loops, or missed conditions), update the workflow. Make the condition explicit, add an edge-case example, and commit. That is how the factory improves.
