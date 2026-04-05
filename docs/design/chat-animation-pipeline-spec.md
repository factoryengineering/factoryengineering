# Chat Animation Pipeline — Build Specification

## Overview

This pipeline converts a YAML conversation file into an animated GIF as part of a static site build. Authors describe an AI interaction in a structured YAML format; the build system renders it as a branded chat animation and outputs a GIF that can be embedded into any content page. The embedding tag causes the animation to float right on wide screens, with following content flowing to its left, and to stack below it on narrow screens. Each embedding tag implicitly begins a new section, preventing animations from floating adjacent to one another.

---

## Repository Layout

This spec targets the Factory Engineering site (Astro Starlight, Yarn, TypeScript strict).

```
tools/chat-anim/
  render.js          # entry point — orchestrates the full pipeline
  template.html      # Handlebars template, driven by conversation data
  capture.js         # Puppeteer frame capture
  defaults.js        # visual constants aligned to factoryengineering.dev
  package.json

src/content/articles/
  some-article.mdx             # content page (MDX, can import the ChatAnim component)
chat-anims/
  ask-plan-agent.chat.yaml     # conversation source file

public/animations/
  ask-plan-agent.gif           # build output: served at /animations/ask-plan-agent.gif

src/components/user-components/
  ChatAnim.astro               # presentational embed component
```

YAML sources live at the repo-root `chat-anims/` directory, outside
`src/content/` so Astro's content-collection loaders cannot accidentally parse
them as pages. GIFs are written to `public/animations/` because Astro serves
`public/` at the site root.

---

## YAML Conversation Format

The `config` section is optional. All visual and timing parameters have defaults (see Defaults). The only required key is `exchanges`.

```yaml
# Optional — override any default
config:
  width: 720
  height: 420
  fps: 15
  theme: dark
  char_delay_user_ms: 28
  char_delay_ai_ms: 18
  think_delay_ms: 900
  pause_on_last_ms: 2000
  font_mono: "JetBrainsMono-Regular.ttf"

exchanges:
  - role: user
    text: "What is the Ask-Plan-Agent cycle?"

  - role: assistant
    text: |
      The Ask-Plan-Agent cycle is a disciplined workflow for AI-assisted development.

      Ask: articulate the goal clearly, treating context as a scarce resource.
      Plan: the agent produces a step-by-step plan before writing any code. You review here.
      Agent: only then does the agent execute — making targeted, auditable changes.

      Front-loading judgment to the planning stage costs nothing. Catching a wrong
      assumption after 400 lines of generated code costs a context reset.
```

### Field Reference

| Field | Type | Required | Description |
|---|---|---|---|
| `exchanges` | list | **yes** | Ordered list of conversation turns |
| `exchanges[].role` | `user` \| `assistant` | yes | Determines bubble alignment and color |
| `exchanges[].text` | string | yes | Message content; newlines preserved |
| `config.*` | various | no | Any key overrides the corresponding default |

---

## Defaults (`defaults.js`)

All defaults are derived from the factoryengineering.dev visual identity. Developers adding new parameters must define a default here before referencing it elsewhere.

```js
module.exports = {
  // Canvas
  width:              720,
  height:             420,
  fps:                15,

  // Timing (milliseconds)
  char_delay_user_ms: 28,
  char_delay_ai_ms:   18,
  think_delay_ms:     900,
  pause_on_last_ms:   2000,   // hold on final frame before loop

  // Theme — dark, matching factoryengineering.dev
  theme:              'dark',

  // Colors (dark theme)
  bg:                 '#0d0f14',
  surface:            '#161a23',
  border:             '#252a38',
  user_bg:            '#1a2540',
  user_text:          '#b8caf5',
  user_label:         '#4f8aff',
  ai_bg:              '#141c14',
  ai_text:            '#a8d5b8',
  ai_label:           '#3eca7a',
  muted:              '#5a6080',

  // Typography
  font_mono:          'JetBrainsMono-Regular.ttf',
  font_display:       'Syne-ExtraBold.ttf',
  font_size_bubble:   13,     // px
  line_height:        1.65,

  // Layout
  bubble_max_width_pct: 0.82,
  bubble_padding:     '14px 18px',
  bubble_gap:         20,     // px between bubbles
  window_padding:     24,     // px inside chat viewport
};
```

---

## Pipeline Stages

### Stage 1 — Parse (`render.js`)

1. Read the `.chat.yaml` file.
2. Merge `config` (if present) over defaults.
3. Pass the merged config and exchanges to the template renderer.

### Stage 2 — Render Template (`template.html` via Handlebars)

The HTML template is a self-contained, single-file animation page:

- Receives `config` and `exchanges` as injected template variables.
- Renders a fixed-height chat viewport (`config.height`). Content aligns to the bottom; as new bubbles appear, older content scrolls upward out of the viewport — the viewport never grows.
- Runs the typewriter animation automatically on `DOMContentLoaded`.
- On completion of the final message, waits `config.pause_on_last_ms` milliseconds, then dispatches `window.dispatchEvent(new Event('animationComplete'))`.
- Does **not** loop internally — looping is a GIF property set at encode time.

**Scroll behavior:** The chat messages container has `overflow: hidden` and fixed `height`. A CSS `scroll-behavior: smooth` transition moves the scroll position as each new bubble is appended, so text enters from the bottom and older content exits through the top.

### Stage 3 — Capture Frames (`capture.js`)

Uses Puppeteer with headless Chrome:

```
launch browser
→ set viewport to config.width × config.height
→ open rendered HTML (file:// path or local http server)
→ begin screenshot loop at config.fps interval
→ listen for 'animationComplete' event
→ after event fires, capture config.pause_on_last_ms worth of additional frames
→ close browser
→ write frames to /tmp/chat-anim-frames/<timestamp>/frame_%04d.png
```

Frame capture uses `page.screenshot({ type: 'png', omitBackground: false })`. The loop runs on a `setInterval` driven by `1000 / config.fps`.

### Stage 4 — Encode GIF

Two-pass FFmpeg with palette optimization is the default encoder. gifski is supported as an opt-in for higher quality at the cost of slower encoding.

**FFmpeg (default):**
```bash
# Pass 1 — generate optimal palette
ffmpeg -framerate {fps} -i frame_%04d.png \
  -vf "palettegen=stats_mode=full" palette.png

# Pass 2 — encode with dithering
ffmpeg -framerate {fps} -i frame_%04d.png -i palette.png \
  -lavfi "paletteuse=dither=bayer:bayer_scale=5" \
  -loop 0 output.gif
```

**gifski (opt-in via `config.encoder: gifski`):**
```bash
gifski --fps {fps} --width {width} --quality 90 \
  -o output.gif frame_*.png
```

The `-loop 0` flag (FFmpeg) / implicit looping (gifski) causes the GIF to loop indefinitely. The pause on the last frame is baked in as repeated identical frames rather than a GIF loop-delay extension, ensuring consistent behavior across all viewers.

### Stage 5 — Output

The encoded GIF is written to `public/animations/`, using the YAML file's
basename with a `.gif` extension:

```
chat-anims/ask-plan-agent.chat.yaml
  →  public/animations/ask-plan-agent.gif
```

The resulting URL at runtime is `/animations/ask-plan-agent.gif`, which is what
`<ChatAnim src="..." />` references in MDX.

The `.gif` output is a build artifact. `public/animations/*.gif` should be
listed in `.gitignore` and regenerated on each build. The deployed `dist/`
output (produced by `yarn build`) is what Azure Static Web Apps serves — do
not commit `dist/`.

---

## Build Integration

### Yarn Scripts

```json
{
  "scripts": {
    "build:anims": "node tools/chat-anim/render.js --glob 'chat-anims/**/*.chat.yaml'",
    "build":       "yarn build:anims && astro build && node scripts/export-markdown.mjs"
  }
}
```

`yarn build:anims` regenerates every GIF into `public/animations/`, which
Astro then bundles into `dist/` during `astro build`. `render.js` accepts
`--glob` to process all matching files, or a single `--file` argument for
targeted rebuilds during authoring.

### GitHub Actions (Azure Static Web Apps)

The site's primary deployment target is Azure Static Web Apps. The animation
build runs before `astro build` so the GIFs land in `public/animations/` and
are bundled into `dist/` like any other static asset.

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'

      - name: Install ffmpeg
        run: sudo apt-get update && sudo apt-get install -y ffmpeg
        # Optional: install gifski via cargo if any YAML opts into encoder: gifski

      - name: Install Node dependencies
        run: yarn install --frozen-lockfile

      - name: Build animations
        run: yarn build:anims
        # Puppeteer downloads Chromium on postinstall.
        # Pin the puppeteer version to control the Chromium revision —
        # changing it can shift text anti-aliasing output.

      - name: Build site
        run: yarn build

      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: '/'
          output_location: 'dist'
          skip_app_build: true   # we already ran yarn build above
```

**CI note:** Puppeteer on Linux requires `--no-sandbox` in headless mode. Set this in `capture.js`:
```js
const browser = await puppeteer.launch({
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});
```

---

## Embedding in Content Pages

### Astro Component

Content pages embed animations through a presentational Astro component at
`src/components/user-components/ChatAnim.astro`:

```astro
---
interface Props {
  src: string;         // path relative to site root, e.g. /animations/foo.gif
  alt?: string;
}
const { src, alt = 'Chat animation' } = Astro.props;
---
<div class="chat-anim-embed">
  <img src={src} alt={alt} class="chat-anim-img" loading="lazy" />
</div>
```

The component is responsible for the wrapper element; the float/responsive
styles live in `src/styles/chat-embed.css` (imported from `global.css`) or in
a scoped `<style>` block on the component itself.

**Usage in MDX:**
```mdx
import ChatAnim from '~/components/user-components/ChatAnim.astro';

<ChatAnim src="/animations/ask-plan-agent.gif" alt="Ask-Plan-Agent cycle demo" />

The Ask-Plan-Agent cycle front-loads human judgment to the cheapest moment...
```

Plain Markdown (`.md`) pages cannot import components. Articles that embed
animations must use `.mdx` or migrate their frontmatter to a collection that
allows MDX.

### Embed CSS (`src/styles/chat-embed.css`)

```css
/*
  Each embed is a block-level section boundary.
  On wide screens: GIF floats right; following text wraps left.
  On narrow screens: GIF is full-width; text stacks below.
*/

.chat-anim-embed {
  /* Clear any preceding float so each embed begins a new section. */
  clear: both;
}

.chat-anim-img {
  display: block;
  max-width: 360px;     /* right-column width on wide screens */
  width: 100%;
  height: auto;
  border-radius: 10px;
  border: 1px solid #252a38;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.4);
}

/* Wide screen: float right, text flows left */
@media (min-width: 900px) {
  .chat-anim-img {
    float: right;
    margin: 0 0 1.5rem 2rem;
  }
}

/* Narrow screen: full-width block, content below */
@media (max-width: 899px) {
  .chat-anim-img {
    float: none;
    max-width: 100%;
    margin: 0 0 1.5rem 0;
  }
}
```

**How section isolation works:** The `clear: both` on `.chat-anim-embed` ensures each new embed starts below any preceding float. The wrapper does **not** establish a new block-formatting context (no `display: flow-root`) — this is deliberate, so the floated image escapes the wrapper and following prose wraps around it. When the next `.chat-anim-embed` appears later in the DOM, its own `clear: both` drops it below the escaped float, isolating one animation's section from the next.

**Important:** do not wrap these styles in `@layer starlight.core`. Starlight's markdown styles include `.sl-markdown-content :is(img, ...) { max-width: 100%; }` in `@layer starlight.content`, which has higher specificity. Unlayered component styles beat all layered styles in the cascade, so declare the rules at the component scope without a layer wrapper.

---

## Summary of Deliverables

| File | Purpose |
|---|---|
| `tools/chat-anim/render.js` | CLI entry point, YAML parsing, pipeline orchestration |
| `tools/chat-anim/template.html` | Handlebars animation template |
| `tools/chat-anim/capture.js` | Puppeteer frame capture |
| `tools/chat-anim/defaults.js` | Visual/timing constants |
| `tools/chat-anim/package.json` | Dependencies: puppeteer, handlebars, js-yaml, glob |
| `src/components/user-components/ChatAnim.astro` | Presentational embed component |
| `src/styles/chat-embed.css` | Float/responsive embed styles |
| `.github/workflows/build.yml` | CI configuration (Azure Static Web Apps) |
| `chat-anims/**/*.chat.yaml` | Authored conversation files |
| `public/animations/*.gif` | Build artifacts (gitignored) |
