# VS Code Prompt Files — Spec Summary

Summary of [Use prompt files in VS Code](https://code.visualstudio.com/docs/copilot/customization/prompt-files). Prompt files are slash commands: standalone Markdown files with `.prompt.md` extension, invoked by typing `/` then the prompt name in Chat.

## Locations

| Scope     | Default location                          |
|----------|-------------------------------------------|
| Workspace| `.github/prompts` folder                  |
| User     | `prompts` folder of current VS Code profile |

Additional workspace folders: `chat.promptFilesLocations` setting.

## Frontmatter Fields (YAML)

| Field         | Required | Description |
|---------------|----------|-------------|
| description   | No       | Short description of the prompt. |
| name          | No       | Name used after `/` in chat. If omitted, the file name is used. |
| argument-hint | No       | Hint text shown in the chat input. |
| agent         | No       | `ask`, `agent`, `plan`, or custom agent name. Default: current agent. If `tools` is set, default is `agent`. |
| model         | No       | Language model for this prompt. Default: model picker selection. |
| tools         | No       | List of tool or tool set names (built-in, MCP, extensions). Use `<server>/*` for all tools of an MCP server. Unavailable tools are ignored. |

## Body

- Markdown. Use for instructions and guidelines.
- Reference workspace files with Markdown links (relative paths from the prompt file).
- Reference tools in text: `#tool:<tool-name>` (e.g. `#tool:githubRepo`).

## Variables (in body)

| Kind     | Variables |
|----------|-----------|
| Workspace| `${workspaceFolder}`, `${workspaceFolderBasename}` |
| Selection| `${selection}`, `${selectedText}` |
| File     | `${file}`, `${fileBasename}`, `${fileDirname}`, `${fileBasenameNoExtension}` |
| Input    | `${input:variableName}`, `${input:variableName:placeholder}` — user is prompted when the prompt runs |

## Tips (from VS Code docs)

- Clearly describe what the prompt should accomplish and expected output format.
- Provide examples of expected input/output when helpful.
- Use Markdown links to reference custom instructions instead of duplicating.
- Use variables (`${selection}`, input variables) to keep prompts flexible.
- Test with the editor play button and refine.

## Tool list priority

When both prompt file and agent specify tools, order is:

1. Tools in the prompt file (if any)
2. Tools from custom agent referenced in prompt (if any)
3. Default tools for the selected agent
