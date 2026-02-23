# Sync Commands to GitHub Copilot Prompts

Converts `.claude/commands/*.md` to `.github/prompts/*.prompt.md` so Copilot Chat can run them via `/command-name`. Spec: [VS Code prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files).

---

## Workflow

1. **Single command:** Read `.claude/commands/<name>.md`. Derive frontmatter (see table below). Write `.github/prompts/<name>.prompt.md` with that frontmatter and the command body.
2. **Batch sync:** From repo root: `python path/to/skill/scripts/sync_copilot_prompts.py [REPO_ROOT]`. Reads all `.claude/commands/*.md`, adds minimal frontmatter, writes `.github/prompts/*.prompt.md`. Commit the generated files.

---

## Frontmatter from source command

| Field | Required | How to derive |
|-------|----------|----------------|
| **description** | No | First non-empty line of body (if summary-like, &lt; 120 chars); else humanize filename (e.g. `write-spec` → "Write spec command"). Or use source frontmatter `description` if present. |
| **name** | No | Filename without extension. Override only if needed. |
| **argument-hint** | No | When the command expects specific input (e.g. artifact path). |
| **agent** | No | `ask`, `agent`, `plan`, or custom. Use `agent` when the command implies editing or multi-step work; `ask` for read-only. |
| **model** | No | Only if a specific model is required. |
| **tools** | No | List of tool names when the command clearly requires them. |

**Rules:** Output must use `.prompt.md` extension. Path: `.github/prompts/<name>.prompt.md`. Frontmatter is YAML between `---`. Body = command body only (strip source frontmatter if present). Preserve Markdown and variable placeholders.

---

## Body and variables

Body is the command text. Copilot variables: `${workspaceFolder}`, `${file}`, `${selection}`, `${input:variableName}`, `${input:variableName:placeholder}`. Keep existing placeholders; for generic "artifact" consider `${file}` or `${input:artifactPath:path or @mention}`.

Full field list and tips: **[references/prompt-files-spec.md](references/prompt-files-spec.md)**.

---

## Checklist (single command)

- [ ] Read source from `.claude/commands/<name>.md`.
- [ ] Set `description` (first line, slug, or existing frontmatter).
- [ ] Set `agent` (usually `agent` for commands that edit or orchestrate).
- [ ] Add `argument-hint` or `tools` only if needed.
- [ ] Write body only to `.github/prompts/<name>.prompt.md`.
- [ ] Output filename is `<name>.prompt.md`.

---

## Batch script

From repository root:

```bash
python path/to/skill/scripts/sync_copilot_prompts.py
# Or: python path/to/skill/scripts/sync_copilot_prompts.py /path/to/repo
```

Script creates `.github/prompts/` if missing, reads every `.claude/commands/*.md`, derives minimal frontmatter (description from first line or slug, `agent: 'agent'`), writes each `.prompt.md`. Commit the generated files.
