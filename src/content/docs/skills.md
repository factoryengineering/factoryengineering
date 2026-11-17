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

The IDEs covered here all implement the **Agent Skills open standard**, originally pioneered by Anthropic and Claude Code and now adopted across every major AI IDE vendor: Claude Code, GitHub Copilot, Cursor, Windsurf (Devin Desktop), Kilo Code, Google Antigravity, and OpenAI Codex. Agent Skills has effectively become a platform-level convention rather than an IDE-specific feature, with enterprise adoption visible through projects like [Elastic's agent-skills repository](https://github.com/elastic/agent-skills). The standard is published and maintained at **[agentskills.io](https://agentskills.io)**.

A skill is a directory containing:

```
my-skill/
├── SKILL.md          # Required: skill definition with YAML frontmatter
├── scripts/          # Optional: executable code the skill can run
├── references/       # Optional: additional documentation loaded on demand
└── assets/           # Optional: templates, images, and data files
```

The `SKILL.md` file uses YAML frontmatter to declare the skill's name and description. The description is critical. It is what the agent reads to determine whether to load and apply the skill. The standard requires only `name` and `description`, and defines four optional fields: `license`, `compatibility`, `metadata`, and `allowed-tools` (experimental). Keep portable skills to these six fields:

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

Some IDEs extend the standard with their own frontmatter. The most useful extension is `disable-model-invocation: true`, which prevents the model from auto-loading a skill and reserves it for explicit invocation by name. Claude Code, Cursor, and GitHub Copilot in VS Code honor it. It is not part of the standard, so other IDEs ignore it. OpenAI Codex declares the same policy in a separate `agents/openai.yaml` file (see [OpenAI Codex](/ides/openai-codex#skills)).

```markdown
---
name: release-notes
description: Generate release notes from the current milestone. Run only when explicitly requested.
disable-model-invocation: true
---
```

---

## Authoring Skills with skill-creator and skill-optimizer

Two skills support authoring:

- **skill-creator**: Install with `npx skills add anthropics/skills --skill skill-creator`. The [`skills`](https://github.com/vercel-labs/skills) installer writes it to `.agents/skills/skill-creator/`. Use it when creating or updating a skill; it provides authoring guidance, best practices, and the full skill-creation workflow.
- **skill-optimizer**: Use it to apply authoring best practices to an existing skill or to verify a skill after creation. If the target skill does not exist yet, use skill-creator first, then skill-optimizer. See [Sharpen Your Skill with /skill-optimizer](/articles/06-sharpen-your-skill-with-skill-optimizer).

After installing, run the [Claude Code mirror](#mirror-for-claude-code) so Claude Code sees the new skills.

---

## Creating Skills Iteratively

**1. Do the task once with the agent.** Pick a concrete task (e.g. "Write a LINQ query to fetch this data" or "Refactor this unit test"). Work through the result. Fix gaps, adjust structure, clarify wording until the output is what you want. Do not compromise on quality.

**2. Capture the process as a skill.** Ask the agent to use the **skill-creator** skill to create a skill in `.agents/skills/` that captures your standards and opinions. Give it the name of the skill. Then instruct the agent to use **skill-optimizer** to align it with best practices and refine the content.

**3. Run the skill against a task.** In a new session, give the agent a new instance of the same kind of task (e.g. another user story or PR). Carefully observe whether the LLM uses the skill you created. Do not hand-hold; let the skill stand on its own. Note where the output is wrong, vague, or inconsistent with how you refined it in step 1.

**4. Refine the skill.** If the skill was not applied, ask: *How can the description be improved?* For each shortcoming, ask: *Which part of the skill allowed this?* Update the skill—add triggers, tighten the description, add constraints or examples, or clarify steps. Use **skill-optimizer** to re-check best practices, or edit the SKILL.md and skill files directly. Commit the change.

**5. Repeat steps 3 and 4.** Re-run the skill on the same or a different task. Keep tightening instructions until the skill produces the desired result without extra guidance. When it does, that skill is ready for the team.

**6. Add more skills the same way.** For each new repeatable task (e.g. writing release notes, generating test cases), do the task once, capture it with skill-creator, optimize it with skill-optimizer, then iterate by running and refining until the skill is reliable.

From here, every team member can invoke the skill by describing the task or by naming the skill in their prompt; the agent loads skills when relevant.

---

## Managing Skills Across IDEs

Different IDEs look for skills in different folders. Managing multiple hand-maintained copies of the same skill is not viable for a team. It creates drift, duplication, and maintenance burden. Establish one canonical skills location in your repository and keep every IDE in sync from it.

**Canonical location:**

```
.agents/skills/
```

`.agents/skills/` is the cross-tool convention, and the `skills` installer writes to it. Use it as the canonical project directory. Current releases of GitHub Copilot, Cursor, OpenAI Codex, Kilo Code, Google Antigravity, and Windsurf (Devin Desktop) discover it directly. Discovery rules change between versions, so check each IDE's documentation (linked from its [IDE guide](/ides)) and verify that a new skill loads in every IDE your team uses.

**Claude Code is the exception.** It reads only `.claude/skills/`, so maintain `.claude/skills/` as a generated compatibility mirror. That single mirror is the only sharing step a team needs.

### Mirror for Claude Code

Keep canonical skills in `.agents/skills/` and generate `.claude/skills/` from them with a one-way `rsync`. This works on every OS (rsync is pre-installed on macOS and Linux, and available on Windows via Git Bash/MSYS2) and produces real files that every IDE's file watcher detects reliably.

**Edit skills only in `.agents/skills/`.** Treat `.claude/skills/` as generated output, and do not keep Claude-specific skills there. The canonical folder always wins: a one-way mirror cannot overwrite newer canonical work with a stale copy, and deletions in canonical always propagate. Do not add a reverse sync.

```bash
#!/usr/bin/env bash
# sync-skills.sh: run from repo root
set -euo pipefail

mkdir -p .agents/skills .claude/skills

# Generate .claude/skills from canonical. --delete removes anything not in .agents/skills.
rsync -a --delete .agents/skills/ .claude/skills/
```

**`--delete` removes every file in `.claude/skills/` that is not in `.agents/skills/`.** In a repository that already has skills in `.claude/skills/`, migrate them before the first run:

1. Move each existing skill directory from `.claude/skills/` into `.agents/skills/`.
2. Preview the mirror without changing anything: `rsync -a --delete --dry-run --itemize-changes .agents/skills/ .claude/skills/`. Any line starting with `*deleting` is a file the mirror would remove.
3. When the preview shows no unexpected deletions, run `sync-skills.sh` and commit both folders.

Automate the mirror with a `pre-commit` or `post-merge` Git hook, or add a CI check that fails when `.claude/skills/` differs from `.agents/skills/`, so the copies never drift. Commit both folders so every team member gets them on clone.

GitHub Copilot, Cursor, and Kilo Code read both `.agents/skills/` and `.claude/skills/`, so they find each skill twice. Because the mirror is exact, both copies have the same name and content. Run the sync before every commit so the copies never disagree.

---

## IDE-by-IDE Reference

Every major AI IDE supports the Agent Skills standard. The table below summarizes folder locations and sharing requirements for current releases. Verify discovery in the versions your team uses.

| IDE | Reads `.agents/skills/` | Other project folders | Sharing Required? | Details |
|-----|------------------------|-----------------------|-------------------|---------|
| [Claude Code](/ides/claude-code) | ❌ No | `.claude/skills/` | ✅ Yes (mirror to `.claude/skills/`) | [Full setup →](/ides/claude-code#skills) |
| [GitHub Copilot](/ides/github-copilot) | ✅ Yes | `.github/skills/`, `.claude/skills/` | No | [Full setup →](/ides/github-copilot#skills) |
| [Cursor](/ides/cursor) | ✅ Yes | `.cursor/skills/`, `.claude/skills/`, `.codex/skills/` | No | [Full setup →](/ides/cursor#skills) |
| [Windsurf (Devin Desktop)](/ides/windsurf) | ✅ Yes | `.devin/skills/`, `.windsurf/skills/` | No | [Full setup →](/ides/windsurf#skills) |
| [Kilo Code](/ides/kilo-code) | ✅ Yes | `.kilo/skills/`, `.claude/skills/` | No | [Full setup →](/ides/kilo-code#skills) |
| [Google Antigravity](/ides/google-antigravity) | ✅ Yes | `.agent/skills/` (legacy) | No | [Full setup →](/ides/google-antigravity#skills) |
| [OpenAI Codex](/ides/openai-codex) | ✅ Yes | `.codex/skills/` | No | [Full setup →](/ides/openai-codex#skills) |

---

## Ecosystem: Agent Skills as a Platform Standard

Agent Skills is no longer an IDE-specific feature. It is a platform-level standard adopted by every major AI IDE vendor. Claude Code pioneered the format; GitHub Copilot, Cursor, Windsurf, Kilo Code, Google Antigravity, and OpenAI Codex have all implemented it natively, and all but Claude Code have converged on `.agents/skills/` as the shared project folder. Enterprise organizations publish shared skill libraries (for example, [Elastic's agent-skills repository](https://github.com/elastic/agent-skills)), installers such as [`skills`](https://github.com/vercel-labs/skills) distribute them across IDEs, and the specification is maintained openly at [agentskills.io](https://agentskills.io).

For factory engineering, this ecosystem-wide support is a defining strength. A skill authored in your repository today works across whichever IDE your teammates choose, and continues to work as the market evolves. You are investing in an open, portable standard, not a single vendor's proprietary format. Keep that portability by limiting frontmatter to the standard fields, plus IDE extensions that other IDEs safely ignore (such as `disable-model-invocation`).

---

## Complete Setup: Step-by-Step

Here is the full setup for a team using multiple IDEs with one canonical skills location.

**1. Create your canonical skills directory:**

```bash
mkdir -p .agents/skills
```

**2. Create your first skill:** Use the **skill-creator** skill (see [Authoring Skills with skill-creator and skill-optimizer](#authoring-skills-with-skill-creator-and-skill-optimizer)). Ask your agent to create a new skill in `.agents/skills`; it will guide you through the workflow and produce a proper SKILL.md and directory structure.

**3. Mirror skills for Claude Code:** Add the `sync-skills.sh` script from [Mirror for Claude Code](#mirror-for-claude-code) and run it. Every other IDE reads `.agents/skills/` directly.

**4. Commit everything:**

```bash
git add .agents/skills .claude/skills sync-skills.sh
git commit -m "Initialize software factory skills"
```

From this point forward, every team member has the full skills library available in their preferred IDE immediately after cloning the repository.
