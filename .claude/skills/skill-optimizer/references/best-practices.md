# Skill authoring best practices

Authoritative guidance for creating and revising skills. **Source:** [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md). See also [source.md](source.md) for the npm package and Agent Skills spec.

## Contents

- Core principles (concise, degrees of freedom)
- Skill structure (naming, description)
- Progressive disclosure
- Workflows and feedback loops
- Content guidelines
- Common patterns
- Anti-patterns
- Checklist for effective Skills

---

## Core principles

### Concise is key

The context window is shared with conversation history, other skills, and requests. Every token competes for space. Only add context the agent doesn't already have.

Challenge each piece of information:
- "Does the agent really need this explanation?"
- "Can I assume the agent knows this?"
- "Does this paragraph justify its token cost?"

**Good (concise):** Give the agent what it needs to act (e.g. library name + minimal code). **Bad (verbose):** Explain what PDFs are or why libraries exist.

### Set appropriate degrees of freedom

Match specificity to the task's fragility:

| Level | When to use | Example |
|-------|-------------|---------|
| **High** (text instructions) | Multiple valid approaches, context-dependent | Code review guidelines |
| **Medium** (templates, pseudocode) | Preferred pattern with acceptable variation | Report generation |
| **Low** (specific scripts, few params) | Fragile operations, consistency critical | Database migrations |

Provide a default with one escape hatch; avoid listing many options.

---

## Skill structure

### Frontmatter requirements

- **name:** Max 64 chars, lowercase letters/numbers/hyphens only. No XML tags. No reserved words (e.g. "anthropic", "claude").
- **description:** Non-empty, max 1024 chars, no XML tags. Must describe **what** the skill does and **when** to use it.

### Naming

- Prefer **gerund form** (e.g. `processing-pdfs`, `analyzing-spreadsheets`). Noun phrases or action-oriented also acceptable.
- Avoid vague names: `helper`, `utils`, `tools`, `documents`, `data`.

### Description (critical for discovery)

- **Always third person.** Good: "Processes Excel files and generates reports." Avoid: "I can help you..." or "You can use this to..."
- **Specific + trigger terms.** Good: "Extract text and tables from PDFs, fill forms. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction." Bad: "Helps with documents."
- **WHAT and WHEN:** Capabilities + trigger scenarios.

---

## Progressive disclosure

- **SKILL.md:** Overview and essential instructions. Keep body under 500 lines.
- **Reference files:** Detailed docs, examples, API refs. Agent reads only when needed.
- **Keep references one level deep** from SKILL.md. Link directly to reference files. Deeply nested refs (SKILL → advanced → details) may get partial reads.
- For reference files over ~100 lines, add a **table of contents** at the top so the agent can see scope when previewing.

---

## Workflows and feedback loops

### Workflows for complex tasks

Break operations into clear steps. For multi-step workflows, provide a **checklist** the agent can copy and check off:

```
Task Progress:
- [ ] Step 1: ...
- [ ] Step 2: ...
```

Then document each step (what to run, what to edit, what to verify).

### Feedback loops

Use **validate → fix → repeat** when quality is critical. Example: "Validate immediately with script X. If validation fails, fix and run again. Only proceed when validation passes."

---

## Content guidelines

- **No time-sensitive information** in the main flow. If something is deprecated, put it in an "Old patterns" or `<details>` section.
- **Consistent terminology:** Pick one term per concept (e.g. "API endpoint" not mixed with "URL", "route", "path"). Use it throughout.

---

## Common patterns

- **Template pattern:** Provide output format templates (strict or flexible as needed).
- **Examples pattern:** For style-sensitive output, give input/output pairs.
- **Conditional workflow:** "If X → follow workflow A. If Y → follow workflow B."
- **Utility scripts:** Document scripts with purpose, command, and whether the agent should **execute** or **read as reference**. Prefer execution for deterministic tasks.

---

## Anti-patterns

- **Windows-style paths:** Use `scripts/helper.py`, not `scripts\helper.py`.
- **Too many options:** Give one default + one escape hatch. Avoid "you can use A, or B, or C, or..."
- **Vague descriptions:** Avoid "Helps with documents" / "Processes data."
- **Assuming tools installed:** State required packages and how to install; then show usage.

---

## Checklist for effective Skills

Before finalizing any skill, verify:

### Core quality

- [ ] Description is specific and includes key terms
- [ ] Description includes both what the skill does and when to use it
- [ ] Written in third person
- [ ] SKILL.md body is under 500 lines
- [ ] Consistent terminology throughout
- [ ] Examples are concrete, not abstract
- [ ] No time-sensitive information (or in "old patterns" section)

### Structure

- [ ] File references are one level deep from SKILL.md
- [ ] Progressive disclosure used appropriately
- [ ] Workflows have clear steps

### If including scripts

- [ ] Scripts solve problems rather than punt to the agent
- [ ] Error handling is explicit and helpful
- [ ] Required packages listed and verified as available
- [ ] No Windows-style paths
- [ ] Validation/verification steps for critical operations

### Testing (when applicable)

- [ ] Tested with real usage scenarios
- [ ] Team feedback incorporated if applicable
