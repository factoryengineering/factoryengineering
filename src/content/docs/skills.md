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

The IDEs covered here all implement the **Agent Skills open standard**, originally pioneered by Anthropic and Claude Code and now adopted across the ecosystem. The standard is published and maintained at **[agentskills.io](https://agentskills.io)**.

A skill is a directory containing:

```
my-skill/
├── SKILL.md          # Required: skill definition with YAML frontmatter
├── scripts/          # Optional: scripts the skill can execute
├── examples/         # Optional: examples to guide the agent
└── resources/        # Optional: templates and reference files
```

The `SKILL.md` file uses YAML frontmatter to declare the skill's name and description. The description is critical—it is what the agent reads to determine whether to load and apply the skill:

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

---

## Managing Skills Across IDEs: The Symlink Approach

Different IDEs look for skills in different folders. Managing multiple copies of the same skill across multiple folders is not viable for a team—it creates drift, duplication, and maintenance burden.

The recommended approach is to establish one canonical skills location in your repository and use symlinks to point each IDE's expected folder to that location.

**Canonical location (recommended):**

```
.claude/skills/
```

This folder is the most widely recognized across the ecosystem. Use it as your source of truth.

**Option A — Use the factory-engineering skill:** Install with `npx openskills install michaellperry/factoryengineering`, then ask your agent to create symlinks. The skill sets up symlinks for **commands/workflows** (`.claude/commands/`) and, for IDEs that need them, **skills** (`.claude/skills/` → Windsurf, KiloCode, Antigravity; Cursor and Copilot read `.claude/skills/` directly). Use `--type all` (default) for both, or `--type commands` / `--type skills`. The agent can detect which IDEs you have, confirm with you, and offer to copy existing contents into the canonical folder if a target already exists. On Windows, the skill uses a PowerShell script. See the [Commands](/commands) page for the full symlink approach and the skill’s SKILL.md (and symlinks.md) for script options.

**Option B — Create symlinks manually for each IDE:**

```bash
# Windsurf
ln -s ../.claude/skills .windsurf/skills

# KiloCode
ln -s ../.claude/skills .kilocode/skills

# Antigravity (uses .agent/skills at project level)
ln -s ../.claude/skills .agent/skills

# Cursor and GitHub Copilot read .claude/skills directly — no symlink needed
```

Commit the symlinks to your repository. Every team member gets the correct folder structure automatically on clone, regardless of which IDE they use.

---

## Installing skill-creator and skill-optimizer

To support authoring and optimizing skills, install these published skills:

- **skill-creator** — Install with `npx openskills install anthropics/skills`. Use when creating or updating a skill; it provides authoring guidance, best practices, and the full skill-creation workflow.
- **skill-optimizer** — Install with `npx openskills install michaellperry/factory-engineering`. Use when you want to apply authoring best practices to an existing skill or to verify a skill after creation. If the target skill does not exist yet, use skill-creator first, then skill-optimizer.

---

## IDE-by-IDE Reference

### Claude Code

**Supports Agent Skills standard:** ✅ Native implementation

**Folder locations:**
| Scope | Path |
|-------|------|
| Project | `.claude/skills/` |
| Global | `~/.claude/skills/` |

Claude Code automatically detects skills in `.claude/skills/` and loads them into context when relevant to your request. Skills can also be invoked explicitly using the skill name in your prompt.

Claude Code extends the base standard with additional features including invocation controls and dynamic context injection. The `anthropics/skills` repository on GitHub provides a growing collection of community and official skills ready to use.

**Getting started:** Use the **skill-creator** skill to create new skills (see [Installing skill-creator and skill-optimizer](#installing-skill-creator-and-skill-optimizer)). It guides you through the workflow and produces a proper skill directory and SKILL.md.

📖 [Claude Code Skills Documentation](https://docs.claude.ai/code/skills)

---

### GitHub Copilot

**Supports Agent Skills standard:** ✅ Native — reads both `.claude/skills/` and `.github/skills/`

**Folder locations:**
| Scope | Path |
|-------|------|
| Project (primary) | `.github/skills/` |
| Project (compatibility) | `.claude/skills/` |
| Personal (primary) | `~/.copilot/skills/` |
| Personal (compatibility) | `~/.claude/skills/` |

GitHub Copilot reads from both `.github/skills/` and `.claude/skills/` at the project level, which means **no symlink is needed** if you use `.claude/skills/` as your canonical location. Copilot will find your skills automatically.

Agent Skills work across the Copilot coding agent, Copilot CLI, and VS Code. Enable the `chat.useAgentSkills` setting in VS Code to activate the feature.

📖 [GitHub Copilot Agent Skills Documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)

---

### Cursor

**Supports Agent Skills standard:** ✅ Yes — primary `.cursor/skills/`, compatibility `.claude/skills/`

**Folder locations:**
| Scope | Path |
|-------|------|
| Project (primary) | `.cursor/skills/` |
| Project (compatibility) | `.claude/skills/` |
| Global (primary) | `~/.cursor/skills/` |
| Global (compatibility) | `~/.claude/skills/` |

Cursor looks for skills in `.cursor/skills/` first, then in `.claude/skills/` for compatibility—similar to GitHub Copilot. If you use `.claude/skills/` as your canonical location, **no symlink is needed**; Cursor will find your skills automatically. Skills are loaded when they match your request, based on the `description` field in each `SKILL.md` frontmatter.

📖 [Cursor Documentation](https://docs.cursor.com)

---

### Windsurf

**Supports Agent Skills standard:** ✅ Yes, via `.windsurf/skills/`

**Folder locations:**
| Scope | Path |
|-------|------|
| Project | `.windsurf/skills/` |
| Global | `~/.windsurf/skills/` |

Windsurf's Cascade agent looks for skills in `.windsurf/skills/`. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .windsurf/skills
```

Cascade automatically invokes skills when your request matches a skill's description. You can also explicitly invoke a skill by typing `@skill-name` in the Cascade input.

📖 [Windsurf Cascade Skills Documentation](https://docs.windsurf.com/windsurf/cascade/skills)

---

### KiloCode

**Supports Agent Skills standard:** ✅ Native — one of the first agents to adopt the standard

**Folder locations:**
| Scope | Path |
|-------|------|
| Project | `.kilocode/skills/` |
| Global | `~/.kilocode/skills/` |

KiloCode is an open-source VS Code extension with a model aggregator backend that gives you access to 500+ models—including Claude, Gemini, and GPT series—with pay-per-token billing at raw provider rates. This makes it a flexible choice for teams that want model independence without committing to a single vendor.

KiloCode loads skills from `.kilocode/skills/`. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .kilocode/skills
```

KiloCode was one of the first agents to natively implement the Agent Skills specification with zero-configuration detection. Skills are evaluated before every response—the agent checks all skill descriptions against your request and loads the most relevant one.

KiloCode also supports mode-specific skills that activate only in specific modes (Code, Architect, Debugger, Orchestrator), which is especially useful for factory engineering workflows where different agents operate in different modes.

📖 [KiloCode Skills Documentation](https://kilo.ai/docs/agent-behavior/skills)

---

### Google Antigravity

**Supports Agent Skills standard:** ✅ Yes, using its own folder structure

**Folder locations:**
| Scope | Path |
|-------|------|
| Project | `.agent/skills/` |
| Global | `~/.gemini/antigravity/skills/` |

Google Antigravity is an AI-native IDE powered by Gemini. It uses progressive disclosure for skills—each skill sits dormant until a request matches its description, at which point it is loaded into the agent's context.

Antigravity uses `.agent/skills/` at the project level. A symlink to your canonical location is required:

```bash
ln -s ../.claude/skills .agent/skills
```

📖 [Google Antigravity Skills Documentation](https://antigravity.google/docs/skills)

---

## Complete Setup: Step-by-Step

Here is the full setup for a team using multiple IDEs with one canonical skills location.

**1. Create your canonical skills directory:**

```bash
mkdir -p .claude/skills
```

**2. Create your first skill:** Use the **skill-creator** skill (see [Installing skill-creator and skill-optimizer](#installing-skill-creator-and-skill-optimizer)). Ask your agent to create a new skill in `.claude/skills`; it will guide you through the workflow and produce a proper SKILL.md and directory structure.

**3. Create symlinks for each IDE your team uses:** Use the **factory-engineering** skill (Option A above) and ask your agent to set up symlinks—it will create command symlinks and skill symlinks for IDEs that need them (Windsurf, KiloCode, Antigravity). Or create them manually:

```bash
# Windsurf
ln -s ../.claude/skills .windsurf/skills

# KiloCode
ln -s ../.claude/skills .kilocode/skills

# Antigravity
ln -s ../.claude/skills .agent/skills

# Cursor and GitHub Copilot read .claude/skills directly — no symlink needed
```

**4. Commit everything:**

```bash
git add .claude/skills .cursor .windsurf .kilocode .agent
git commit -m "Initialize software factory skills"
```

From this point forward, every team member has the full skills library available in their preferred IDE immediately after cloning the repository.

---

## Writing Effective Skills

The `description` field is the most important part of your skill. It determines when the agent loads the skill. Write descriptions that are specific and action-oriented:

**Too vague:** `"Helps with API work"`

**Effective:** `"Use when designing or reviewing REST API endpoints, defining request/response schemas, generating OpenAPI specifications, or evaluating API design decisions for this project."`

Keep supporting files close to the skill. Templates, checklists, and reference documents placed in the skill folder are available to the agent when the skill is invoked—use them to encode your team's specific standards rather than leaving them in prose.

When a skill produces a bad result, don't just fix the output. Ask: *which part of the skill allowed this?* Then update the skill. Commit it. This is how your factory improves.

---

*Next: [Commands](/commands) →*
