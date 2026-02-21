---
name: factory-engineering-sync-copilot-prompts
description: Converts project commands (.claude/commands/*.md) into GitHub Copilot prompt files (.github/prompts/*.prompt.md) for VS Code. Use when syncing commands for Copilot, defining frontmatter from a source command, or batch-generating .prompt.md files so slash commands work in VS Code Chat.
---

# Sync Commands to GitHub Copilot Prompts

Convert canonical commands into VS Code prompt files so Copilot Chat can run them via `/command-name`. Canonical source: `.claude/commands/*.md`. Output: `.github/prompts/*.prompt.md`. Spec: [VS Code prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files).

---

## Workflow

1. **Single command:** Read the source command (`.claude/commands/<name>.md`). Derive frontmatter from it (see below). Write `.github/prompts/<name>.prompt.md` with that frontmatter and the command body.
2. **Batch sync:** Run the bundled script from repo root: `python .claude/skills/factory-engineering-sync-copilot-prompts/scripts/sync_copilot_prompts.py [REPO_ROOT]`. It reads all `.claude/commands/*.md`, adds minimal frontmatter, and writes `.github/prompts/*.prompt.md`. Commit the generated files.

---

## Defining Frontmatter from the Source Command

Per [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files), prompt files support optional YAML frontmatter. Derive each field from the source command as follows.

| Field | Required | How to derive from source command |
|-------|----------|-----------------------------------|
| **description** | No | Short description for the prompt. Prefer: first non-empty line of the command body (if it reads like a summary and &lt; 120 chars). Else: humanize the filename (e.g. `write-spec` → "Write spec command"). If the source has YAML frontmatter with `description`, use that. |
| **name** | No | Name shown after `/` in chat. Default: filename without extension. Only set if you need to override (e.g. different display name). |
| **argument-hint** | No | Hint text for the chat input. Set when the command expects specific input (e.g. artifact path, framework choice). |
| **agent** | No | One of: `ask`, `agent`, `plan`, or a custom agent name. Use `agent` when the command implies editing files or multi-step work; use `ask` for read-only or advice. If not set, Copilot uses the current chat agent. |
| **model** | No | Only if the command must run with a specific model. Usually leave unset. |
| **tools** | No | List of tool or tool set names (e.g. `['search', 'read', 'edit']` or MCP tools). Add when the command clearly requires certain tools; otherwise omit and use the agent default. |

**Rules:**

- Output file **must** use the `.prompt.md` extension. Output path: `.github/prompts/<name>.prompt.md` (workspace default); user can add more locations via `chat.promptFilesLocations`.
- Frontmatter is YAML between `---` delimiters. Quote values that contain colons or `#`.
- Body = command body only. If the source has frontmatter, strip it and use the rest as the body. Preserve Markdown and any variable placeholders the command uses.

---

## Body and Variables

The prompt body is the command text. Copilot supports variables in the body; use them when the command should reference context:

- **Workspace:** `${workspaceFolder}`, `${workspaceFolderBasename}`
- **Selection:** `${selection}`, `${selectedText}`
- **File context:** `${file}`, `${fileBasename}`, `${fileDirname}`, `${fileBasenameNoExtension}`
- **Input:** `${input:variableName}`, `${input:variableName:placeholder}` (user is prompted when the prompt runs)

If the source command already uses these or similar placeholders, keep them. If converting a generic "artifact" reference, consider `${file}` or `${input:artifactPath:path or @mention}`.

---

## Checklist (single command)

- [ ] Read source from `.claude/commands/<name>.md`.
- [ ] Set `description` (from first line, slug, or existing frontmatter).
- [ ] Set `agent` (usually `agent` for commands that edit or orchestrate).
- [ ] Add `argument-hint` or `tools` only if needed.
- [ ] Write body only (no duplicate frontmatter from source) to `.github/prompts/<name>.prompt.md`.
- [ ] Ensure output filename is `<name>.prompt.md`.

---

## Batch Sync Script

For deterministic batch sync, run the bundled script from the repository root:

```bash
python .claude/skills/factory-engineering-sync-copilot-prompts/scripts/sync_copilot_prompts.py
# Or with explicit repo root:
python .claude/skills/factory-engineering-sync-copilot-prompts/scripts/sync_copilot_prompts.py /path/to/repo
```

The script creates `.github/prompts/` if missing, reads every `.claude/commands/*.md`, derives minimal frontmatter (description from first line or slug, `agent: 'agent'`), and writes each `.prompt.md`. Commit the generated files so the team gets slash commands in VS Code.

If the project keeps the same script at repo root (`scripts/sync_copilot_prompts.py`), that can be used instead; behavior is the same.

---

## Reference

- **Full spec and tips:** See [references/prompt-files-spec.md](references/prompt-files-spec.md) for field details, variable list, and VS Code tips for effective prompts.
