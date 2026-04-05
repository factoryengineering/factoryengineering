---
title: Skills
description: The foundation of your software factory—structured packages of instructions, scripts, and resources that teach your AI-assisted IDE how to complete tasks in a repeatable way.
---

# Skills: The Foundation of Your Software Factory

Skills are structured packages of instructions, scripts, and resources that teach your AI-assisted IDE how to complete specific tasks in a repeatable, consistent way. They form the foundation of your software factory by encoding domain knowledge, best practices, and team standards directly into your repository—where they evolve alongside your code.

---

## Why Project-Scoped Skills Matter for Factory Engineering

In a software factory, skills must evolve with your codebase and be shared across your entire team. This means storing skills at the project level rather than globally on individual machines.

When you keep skills in your project repository, they are:

- **Versioned with your code** — every change is tracked in Git
- **Reviewed in pull requests** — the same quality gates that govern your code govern your factory
- **Automatically available to every team member** — no setup required after cloning
- **Auditable** — you can trace when a skill was introduced or changed and why

This alignment between skills and code is fundamental to factory engineering.

---

## The Agent Skills Open Standard

The IDEs covered here all implement the **Agent Skills open standard**, originally pioneered by Anthropic and Claude Code and now adopted across every major AI IDE vendor—Claude Code, GitHub Copilot, Cursor, Windsurf, Kilo Code, Google Antigravity, and OpenAI Codex. Agent Skills has effectively become a platform-level convention rather than an IDE-specific feature, with enterprise adoption visible through projects like [Elastic's agent-skills repository](https://github.com/elastic/agent-skills). The standard is published and maintained at **[agentskills.io](https://agentskills.io)**.

A skill is a directory containing:

```
my-skill/
├── SKILL.md          # Required: skill definition with YAML frontmatter
├── scripts/          # Optional: scripts the skill can execute
├── examples/         # Optional: examples to guide the agent
└── resources/        # Optional: templates and reference files
```

The `SKILL.md` file uses YAML frontmatter to declare the skill's name and description. The description is critical—it is what the agent reads to determine whether to load and apply the skill. The standard also defines optional invocation controls such as `user-invocable` (whether a user can call the skill explicitly by name) and `disable-model-invocation` (prevent the model from auto-loading the skill, reserving it for explicit invocation):

```markdown
---
name: api-design
description: Use when designing or reviewing REST APIs, defining endpoints, request/response schemas, or OpenAPI specifications for this project.
---

# API Design Standards

## Standards
...

## Resources
- **OpenAPI reference**: See [references/openapi-patterns.md](references/openapi-patterns.md) for request/response patterns and examples.
- **Templates**: Use [assets/endpoint-template.yaml](assets/endpoint-template.yaml) when adding new endpoints.

## Scripts
- **Validate spec**: Run `scripts/validate-openapi.sh` to check the OpenAPI file before commit.
```

The agent loads only the skills relevant to the current task, keeping context lean and responses accurate. This is called **progressive disclosure**—skills sit dormant until needed.

A skill that should only be invoked explicitly by name—never auto-loaded by the model—declares both optional properties in its frontmatter:

```markdown
---
name: release-notes
description: Generate release notes from the current milestone. Run only when explicitly requested.
user-invocable: true
disable-model-invocation: true
---
```

---

## Installing skill-creator and skill-optimizer

To support authoring and optimizing skills, install these published skills:

- **skill-creator** — Install with `npx openskills install anthropics/skills`. Use when creating or updating a skill; it provides authoring guidance, best practices, and the full skill-creation workflow.
- **skill-optimizer** — Install with `npx openskills install factoryengineering/skills`. Use to apply authoring best practices to an existing skill or to verify a skill after creation. If the target skill does not exist yet, use skill-creator first, then skill-optimizer.

---

## Creating Skills Iteratively

**1. Do the task once with the agent.** Pick a concrete task (e.g. "Write a LINQ query to fetch this data" or "Refactor this unit test"). Work through the result. Fix gaps, adjust structure, clarify wording until the output is what you want. Do not compromise on quality.

**2. Capture the process as a skill.** Ask the agent to use the **skill-creator** skill to create a skill that captures your standards and opinions. Give it the name of the skill. Then instruct the agent to use **skill-optimizer** to align it with best practices and refine the content.

**3. Run the skill against a task.** In a new session, give the agent a new instance of the same kind of task (e.g. another user story or PR). Carefully observe whether the LLM uses the skill you created. Do not hand-hold; let the skill stand on its own. Note where the output is wrong, vague, or inconsistent with how you refined it in step 1.

**4. Refine the skill.** If the skill was not applied, ask: *How can the description be improved?* For each shortcoming, ask: *Which part of the skill allowed this?* Update the skill—add triggers, tighten the description, add constraints or examples, or clarify steps. Use **skill-optimizer** to re-check best practices, or edit the SKILL.md and skill files directly. Commit the change.

**5. Repeat steps 3 and 4.** Re-run the skill on the same or a different task. Keep tightening instructions until the skill produces the desired result without extra guidance. When it does, that skill is ready for the team.

**6. Add more skills the same way.** For each new repeatable task (e.g. writing release notes, generating test cases), do the task once, capture it with skill-creator, optimize it with skill-optimizer, then iterate by running and refining until the skill is reliable.

From here, every team member can invoke the skill by describing the task or by naming the skill in their prompt; the agent loads skills when relevant.

---

## Managing Skills Across IDEs: The Symlink Approach

Different IDEs look for skills in different folders. Managing multiple copies of the same skill across multiple folders is not viable for a team—it creates drift, duplication, and maintenance burden.

Establish one canonical skills location in your repository and use symlinks to point each IDE's expected folder to that location.

**Canonical location (recommended):**

```
.claude/skills/
```

This folder is the most widely recognized across the ecosystem. Use it as your source of truth.

**Option A — Use the factory-engineering skill:** Install with `npx openskills install factoryengineering/skills`, then ask your agent to create symlinks. The skill sets up symlinks for **commands/workflows** (`.claude/commands/`) and, for IDEs that need them, **skills** (`.claude/skills/` → Windsurf, Kilo Code, Antigravity; Cursor and Copilot read `.claude/skills/` directly). Use `--type all` (default) for both, or `--type commands` / `--type skills`. The agent can detect which IDEs you have, confirm with you, and offer to copy existing contents into the canonical folder if a target already exists. On Windows, use the skill's PowerShell script. See the [Commands](/commands) page for the full symlink approach and the skill’s SKILL.md (and symlinks.md) for script options.

**Option B — Create symlinks manually for each IDE:**

```bash
# Windsurf
ln -s ../.claude/skills .windsurf/skills

# Kilo Code
ln -s ../.claude/skills .kilocode/skills

# Antigravity (uses .agent/skills at project level)
ln -s ../.claude/skills .agent/skills

# OpenAI Codex
ln -s ../.claude/skills .codex/skills

# Cursor and GitHub Copilot read .claude/skills directly — no symlink needed
```

Commit the symlinks to your repository. Every team member gets the correct folder structure automatically on clone, regardless of which IDE they use.

---

## IDE-by-IDE Reference

Every major AI IDE supports the Agent Skills standard. The table below summarizes folder locations and symlink requirements. For full setup details, see each IDE's dedicated page.

| IDE | Project Folder | Symlink Needed? | Details |
|-----|---------------|-----------------|---------|
| [Claude Code](/ides/claude-code) | `.claude/skills/` | No (canonical location) | [Full setup →](/ides/claude-code#skills) |
| [GitHub Copilot](/ides/github-copilot) | `.github/skills/` + `.claude/skills/` | No (reads `.claude/skills/` directly) | [Full setup →](/ides/github-copilot#skills) |
| [Cursor](/ides/cursor) | `.cursor/skills/` + `.claude/skills/` | No (reads `.claude/skills/` directly) | [Full setup →](/ides/cursor#skills) |
| [Windsurf](/ides/windsurf) | `.windsurf/skills/` | ✅ Yes | [Full setup →](/ides/windsurf#skills) |
| [Kilo Code](/ides/kilo-code) | `.kilocode/skills/` | ✅ Yes | [Full setup →](/ides/kilo-code#skills) |
| [Google Antigravity](/ides/google-antigravity) | `.agent/skills/` | ✅ Yes | [Full setup →](/ides/google-antigravity#skills) |
| [OpenAI Codex](/ides/openai-codex) | `.codex/skills/` | ✅ Yes | [Full setup →](/ides/openai-codex#skills) |

---

## Ecosystem: Agent Skills as a Platform Standard

Agent Skills is no longer an IDE-specific feature — it is a platform-level standard adopted by every major AI IDE vendor. Claude Code pioneered the format; GitHub Copilot, Cursor, Windsurf, Kilo Code, Google Antigravity, and OpenAI Codex have all implemented it natively. Enterprise organizations publish shared skill libraries (for example, [Elastic's agent-skills repository](https://github.com/elastic/agent-skills)) and the specification is maintained openly at [agentskills.io](https://agentskills.io).

For factory engineering, this ecosystem-wide support is a defining strength. A skill authored in your repository today works across whichever IDE your teammates choose, and continues to work as the market evolves. You are investing in an open, portable standard — not a single vendor's proprietary format.

---

## Complete Setup: Step-by-Step

Here is the full setup for a team using multiple IDEs with one canonical skills location.

**1. Create your canonical skills directory:**

```bash
mkdir -p .claude/skills
```

**2. Create your first skill:** Use the **skill-creator** skill (see [Installing skill-creator and skill-optimizer](#installing-skill-creator-and-skill-optimizer)). Ask your agent to create a new skill in `.claude/skills`; it will guide you through the workflow and produce a proper SKILL.md and directory structure.

**3. Create symlinks for each IDE your team uses:** Use the **factory-engineering** skill (Option A above) and ask your agent to set up symlinks—it will create command symlinks and skill symlinks for IDEs that need them (Windsurf, Kilo Code, Antigravity). Or create them manually:

```bash
# Windsurf
ln -s ../.claude/skills .windsurf/skills

# Kilo Code
ln -s ../.claude/skills .kilocode/skills

# Antigravity
ln -s ../.claude/skills .agent/skills

# OpenAI Codex
ln -s ../.claude/skills .codex/skills

# Cursor and GitHub Copilot read .claude/skills directly — no symlink needed
```

**4. Commit everything:**

```bash
git add .claude/skills .cursor .windsurf .kilocode .agent .codex
git commit -m "Initialize software factory skills"
```

From this point forward, every team member has the full skills library available in their preferred IDE immediately after cloning the repository.
