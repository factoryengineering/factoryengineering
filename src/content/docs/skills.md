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

## Installing skill-creator and skill-optimizer

To support authoring and optimizing skills, install these published skills with the [`skills`](https://github.com/vercel-labs/skills) installer. It writes each skill to `.agents/skills/{name}/` and supports every IDE covered here.

- **skill-creator**: Install with `npx skills add anthropics/skills --skill skill-creator`. Use when creating or updating a skill; it provides authoring guidance, best practices, and the full skill-creation workflow.
- **skill-optimizer**: Install with `npx skills add factoryengineering/skills --skill skill-optimizer`. Use to apply authoring best practices to an existing skill or to verify a skill after creation. If the target skill does not exist yet, use skill-creator first, then skill-optimizer.

After installing, mirror the new skills into `.claude/skills/` for Claude Code (see [Managing Skills Across IDEs](#managing-skills-across-ides)).

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

`.agents/skills/` is the cross-tool convention. GitHub Copilot, Cursor, OpenAI Codex, Kilo Code, Google Antigravity, and Windsurf (Devin Desktop) all read it directly, and the `skills` installer writes to it. Use it as your source of truth.

**Claude Code is the exception.** It reads only `.claude/skills/`, so mirror the canonical folder there. That single mirror is the only sharing step a team needs.

### Strategy 1: Sync with rsync (recommended)

Keep canonical skills in `.agents/skills/` and use a two-step `rsync` to keep `.claude/skills/` in sync. This works on every OS (rsync is pre-installed on macOS and Linux, and available on Windows via Git Bash/MSYS2), avoids symlink pitfalls, and produces real files that every IDE's file watcher detects reliably.

The two-step pattern handles the case where a Claude Code user edits a skill in `.claude/skills/` rather than in `.agents/skills/`. Step 1 gathers those changes back to canonical before step 2 mirrors canonical, so no work is lost.

```bash
#!/usr/bin/env bash
# sync-skills.sh: run from repo root

mkdir -p .agents/skills .claude/skills

# Step 1: reverse-sync. Gather changes made in .claude/skills back to canonical.
rsync -a .claude/skills/ .agents/skills/

# Step 2: forward-sync. Mirror canonical to .claude/skills.
rsync -a --delete .agents/skills/ .claude/skills/
```

**Step 1** is additive (no `--delete`): new or modified files in `.claude/skills/` are copied back to `.agents/skills/` without removing anything. **Step 2** uses `--delete` so `.claude/skills/` becomes an exact mirror of canonical. Stale files that were removed from `.agents/skills/` are cleaned up.

Automate this with a `post-commit` or `post-merge` Git hook, a file-watcher script, or a CI step so the copies never drift. Commit both folders so every team member gets them on clone.

GitHub Copilot, Cursor, and Kilo Code read both `.agents/skills/` and `.claude/skills/`, so they find each skill twice. Because the mirror is exact, both copies have the same name and content. Run the sync before every commit so the copies never disagree.

### Strategy 2: Symlink (macOS/Linux only, with caveats)

A single symlink points `.claude/skills/` at the canonical folder:

```bash
mkdir -p .claude
ln -s ../.agents/skills .claude/skills
```

Commit the symlink. This avoids duplicate files but has significant caveats:

- **Windows:** Symlinks require Developer Mode or administrator privileges. Developer Mode is often restricted in corporate environments, and `core.symlinks` must be enabled in Git. Without it, the symlink is checked out as a plain text file containing the target path.
- **Cursor:** Cursor does not reliably discover skills through symlinked directories, especially in the CLI and Cloud Agents. Because Cursor reads `.agents/skills/` directly, keep the canonical folder a real directory.
- **IDE inconsistencies:** Some IDEs watch the symlink target correctly; others watch the symlink itself or skip watching entirely. Test with your specific IDE versions.

Use the symlink only when your team is macOS/Linux-only. Otherwise, use rsync.

---

## IDE-by-IDE Reference

Every major AI IDE supports the Agent Skills standard. The table below summarizes folder locations and sharing requirements.

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

**2. Create your first skill:** Use the **skill-creator** skill (see [Installing skill-creator and skill-optimizer](#installing-skill-creator-and-skill-optimizer)). Ask your agent to create a new skill in `.agents/skills`; it will guide you through the workflow and produce a proper SKILL.md and directory structure.

**3. Mirror skills for Claude Code:** Add the `sync-skills.sh` script from [Strategy 1](#strategy-1-sync-with-rsync-recommended) and run it. Every other IDE reads `.agents/skills/` directly.

**4. Commit everything:**

```bash
git add .agents/skills .claude/skills sync-skills.sh
git commit -m "Initialize software factory skills"
```

From this point forward, every team member has the full skills library available in their preferred IDE immediately after cloning the repository.
