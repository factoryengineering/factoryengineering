# Pre-packaging factory engineering: skills and MCP

Ideas for pre-packaging a set of skills or an MCP server so people have immediate access to tools that help them build and maintain software factories.

---

## 1. Factory-engineering skill bundle (curated skill set)

**Idea:** Ship a single bundle (repo or archive) that contains a fixed set of skills and optional scripts:

- **skill-creator** — already present; create/update skills.
- **sync-copilot-prompts** — (to add) sync `.claude/commands/*.md` → `.github/prompts/*.prompt.md`.
- **example-factories** — already present; format and conventions for example factories.
- **factory-bootstrap** (new) — one skill that knows how to scaffold a factory: create `.claude/commands/`, stub commands (`write-spec`, `write-story`, `review-pr`), symlink setup, and when to run the Copilot sync.

**Delivery:** “Clone this repo and copy `.claude/skills/<names>` into your project,” or “Download the factory-engineering skill bundle and extract into `.claude/skills/`.”

**Benefit:** One download/clone gives a standard set of skills; teams add the bundle to a repo and get the same workflows everywhere.

---

## 2. MCP server: “factory-engineering” tools

**Idea:** An MCP server that exposes tools for building and maintaining a factory. The agent (in any MCP-capable IDE) calls these tools instead of re-deriving the steps each time.

**Example tools:**

| Tool | Purpose |
|------|--------|
| `scaffold_factory` | Create `.claude/commands/`, `.cursor/commands/`, optional `.github/prompts/`, stub command files, and (optionally) run symlink logic. |
| `sync_copilot_prompts` | Read `.claude/commands/*.md`, add minimal frontmatter, write `.github/prompts/*.prompt.md`. |
| `validate_skill` | Check a skill dir for required `SKILL.md`, frontmatter, and structure (reuse or mirror `quick_validate.py`). |
| `list_commands` | List commands (and which IDE folders they’re linked to) for the current workspace. |
| `list_skills` | List skills under `.claude/skills/` (or configured path). |

**Delivery:** Publish as an npm package (e.g. `@factoryengineering/mcp-server`) or a Python package; user runs it (e.g. `npx factory-engineering-mcp` or `uv run factory-engineering-mcp`) and adds the server to their IDE MCP config.

**Benefit:** Same tools in VS Code, Cursor, etc.; deterministic, scriptable behavior; no need to load a skill to “run the sync” — the agent just calls the tool.

---

## 3. Starter template repo

**Idea:** A repo like `factoryengineering/starter` or `factoryengineering/template` that is a ready-to-use factory:

- Pre-populated `.claude/skills/` (skill-creator, sync-copilot-prompts, example-factories, bootstrap).
- `.claude/commands/` with a few stub commands.
- Symlinks (or a script that creates them) for Cursor, Windsurf, KiloCode, Antigravity.
- Script (or skill) to generate `.github/prompts/`.
- Short README: “Clone this repo (or use it as a template) to start your factory.”

**Benefit:** “Immediate access” = clone and go; the structure and conventions are already in place.

---

## 4. Single “factory bootstrap” skill with bundled script

**Idea:** One skill that encodes the full bootstrap workflow and ships a script that does the heavy lifting:

- **SKILL.md:** When to use it (“setting up factory engineering in a new or existing repo”), steps (create dirs, create stub commands, run symlink script, run Copilot sync), and when to run the script.
- **scripts/bootstrap_factory.sh** (or `.js`): Creates directories, writes stub `.md` command files, creates symlinks, optionally calls the Copilot sync.

**Delivery:** Part of the skill bundle (1) or the starter template (3).

**Benefit:** No separate MCP server; anyone with the skill can say “bootstrap a factory” and the agent follows the skill and/or runs the script.

---

## 5. `create-factory-engineering` (npm/yarn style)

**Idea:** A single command that sets up the factory in the current directory:

- `npx create-factory-engineering` or `yarn create factory-engineering`
- Copies (or clones) the starter template into the cwd, or unpacks a tarball of skills + commands + scripts.
- Optionally runs the symlink script and Copilot sync.

**Benefit:** Familiar “create-*” UX; one command, no manual cloning or copying.

---

## 6. MCP server + bundled skills/docs

**Idea:** Combine (2) and (1): the MCP server provides the tools, and the same package (or a companion package) includes the skill bundle and/or a small doc index.

- Server tools: `scaffold_factory`, `sync_copilot_prompts`, `validate_skill`, etc.
- Bundled skills: either embedded in the server’s package (e.g. `node_modules/@factoryengineering/mcp-server/skills/`) or in a separate “factory-engineering-skills” repo that the docs point to.
- Optional tool: `install_skill` (or `add_skill`) that copies a named skill from the bundle into the workspace `.claude/skills/`.

**Benefit:** One install (the MCP server) gives both tools and a clear path to the standard skills; “immediate access” without hunting for repos.

---

## Suggested order

1. **Short term:** Add the **sync-copilot-prompts** skill (with script) and a **factory-bootstrap** skill (with script) to this repo, and document “copy these skills into your project” as the first packaging story.
2. **Next:** Add a **starter template repo** that contains those skills + stub commands + symlink script so “clone template” is the one-step path.
3. **Then:** Implement an **MCP server** with `scaffold_factory`, `sync_copilot_prompts`, and `validate_skill` so any IDE can use the same tooling; optionally ship the skill bundle alongside the server (idea 6).

That gives: immediate access via skills + template, and a single, IDE-agnostic tool layer (MCP) for building and maintaining software factories.
