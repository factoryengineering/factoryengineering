---
name: chat-anim-renderer
description: Builds animated GIFs from .chat.yaml conversation files using a YAML to Handlebars HTML to Puppeteer frames to ffmpeg/gifski pipeline. Use when the user wants to author, render, embed, or modify chat animations; when working with .chat.yaml files; when setting up tools/chat-anim/; when embedding a ChatAnim component or chat GIFs in MDX/Markdown content pages; or when the user mentions chat animation, typewriter animation, conversation GIF, or the chat-animation-pipeline spec.
---

# chat-anim-renderer

Implements the chat-animation pipeline defined in
`docs/design/chat-animation-pipeline-spec.md`. This skill is the operational
authority for that spec — the spec describes the system, this skill builds it.

## What the pipeline does

```
content/foo/conversation.chat.yaml
  → render.js: parse YAML, merge config over defaults
  → template.html (Handlebars): typewriter animation in a fixed viewport
  → capture.js (Puppeteer): screenshot at fps, await animationComplete event
  → ffmpeg/gifski: palette-optimized GIF with baked-in trailing pause
  → public/animations/conversation.gif
```

Five stages, one contract (`animationComplete`), one output per YAML file.

## When to use which asset

All runnable code ships in `assets/`. Copy the entire directory into the user's
repo at `tools/chat-anim/`. The pieces are interdependent — `render.js` requires
`defaults.js`, `template.html`, and `capture.js` as siblings.

| File | Copy to | Purpose |
|---|---|---|
| `assets/render.js` | `tools/chat-anim/render.js` | CLI entry; parses YAML, orchestrates |
| `assets/capture.js` | `tools/chat-anim/capture.js` | Puppeteer frame capture |
| `assets/template.html` | `tools/chat-anim/template.html` | Handlebars animation template |
| `assets/defaults.js` | `tools/chat-anim/defaults.js` | Visual + timing constants |
| `assets/package.json` | `tools/chat-anim/package.json` | Module type declaration (deps are in repo-root `package.json`) |
| `assets/chat-embed.css` | Component `<style>` block | Float/responsive embed CSS |
| `assets/example.chat.yaml` | pattern reference only | Example author input |

## Workflow: scaffolding the pipeline in a new repo

Progress checklist (copy this to track work):

- [ ] 1. Copy all files from `assets/` into `tools/chat-anim/`
- [ ] 2. Run `npm install` inside `tools/chat-anim/`
- [ ] 3. Verify ffmpeg is installed (`ffmpeg -version`); if missing, install via apt/brew
- [ ] 4. Create a first `.chat.yaml` (use `assets/example.chat.yaml` as a model)
- [ ] 5. Run `node tools/chat-anim/render.js --file <path-to-yaml>`
- [ ] 6. Inspect the resulting `.gif` next to the YAML
- [ ] 7. Add `**/*.gif` (or a narrower pattern) to `.gitignore`
- [ ] 8. Add the embed component (see `references/astro-shortcode.md` for Astro)
- [ ] 9. Wire `build:anims` into the site build command
- [ ] 10. Add ffmpeg install step to CI

## Workflow: authoring a new animation

- [ ] 1. Create `<name>.chat.yaml` next to the content page that will embed it
- [ ] 2. Write the `exchanges:` list; estimate duration (see `references/yaml-schema.md`)
- [ ] 3. Target ≤ 15s total; shorten text if estimate exceeds this
- [ ] 4. Run `node tools/chat-anim/render.js --file <path>` to render
- [ ] 5. If text is fuzzy or too slow/fast, tune `config:` overrides and re-render
- [ ] 6. Embed with `<ChatAnim src="..." />` in the MDX page

## Workflow: modifying the pipeline itself

When the user wants to change behavior (new config keys, different encoder
defaults, new template features):

1. **Add the default first** in `defaults.js`. No parameter may be referenced
   elsewhere without a default.
2. Thread the new value through `template.html` (via `config_json`) and/or
   `capture.js` / `render.js` as needed.
3. Document the new key in `references/yaml-schema.md`.
4. Update the spec at `docs/design/chat-animation-pipeline-spec.md` to match —
   the spec and this skill must stay aligned.

## The animationComplete contract

This is the only coordination point between the template and the capture loop.
If frames are missing or the capture hangs, suspect this first. See
`references/timing-and-frames.md` for the full contract.

## References

Load these only when the current task needs them:

- `references/yaml-schema.md` — `.chat.yaml` fields, validation, authoring tips
- `references/timing-and-frames.md` — timing math, `animationComplete` contract, font loading
- `references/encoding.md` — ffmpeg palette options, gifski tradeoffs, file-size targets
- `references/astro-shortcode.md` — Astro Starlight `<ChatAnim />` component and MDX usage
- `references/troubleshooting.md` — common failures: Linux sandbox, truncated GIFs, fuzzy text

## Dependencies to install

System: `ffmpeg` (required), `gifski` (optional, only if user opts in via `encoder: gifski`).

Node: listed in `assets/package.json` — `puppeteer`, `handlebars`, `js-yaml`, `glob`.
Puppeteer downloads Chromium on `postinstall`. Pin the puppeteer version to
pin the Chromium revision; changing either can shift anti-aliasing output.

## Output conventions

- The GIF is written to `public/animations/<basename>.gif`.
- GIFs are build artifacts. Gitignore them.
- Intermediate frames go to `$TMPDIR/chat-anim-<timestamp>/frames/` and are
  deleted after encoding unless `--keep-frames` is passed.
