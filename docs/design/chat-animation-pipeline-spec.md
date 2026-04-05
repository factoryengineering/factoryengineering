# Chat Animation Pipeline — Build Specification

## Overview

This pipeline converts a YAML conversation file into an animated GIF as part of a static site build. Authors describe an AI interaction in a structured YAML format; the build system renders it as a branded chat animation and outputs a GIF that can be embedded into any content page. The embedding tag causes the animation to float right on wide screens, with following content flowing to its left, and to stack below it on narrow screens. Each embedding tag implicitly begins a new section, preventing animations from floating adjacent to one another.

---

## Repository Layout

```
/tools/chat-anim/
  render.js          # entry point — orchestrates the full pipeline
  template.html      # Handlebars template, driven by conversation data
  capture.js         # Puppeteer frame capture
  defaults.js        # visual constants aligned to factoryengineering.dev
  package.json

/content/
  some-article/
    index.md         # content page
    ask-plan-agent.chat.yaml   # conversation source file
    ask-plan-agent.gif         # build output (generated, not committed)

/site/
  css/
    chat-embed.css   # float/responsive embed styles
```

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

The encoded GIF is written to the same directory as the source YAML file, with the `.chat.yaml` extension replaced by `.gif`:

```
ask-plan-agent.chat.yaml  →  ask-plan-agent.gif
```

The `.gif` output is a build artifact. It should be listed in `.gitignore` and regenerated on each build. If build output is committed (e.g., for GitHub Pages), commit only the `dist/` or `_site/` directory, not the intermediate frames.

---

## Build Integration

### npm Script

```json
{
  "scripts": {
    "build:anims": "node tools/chat-anim/render.js --glob 'content/**/*.chat.yaml'",
    "build":       "npm run build:anims && eleventy"
  }
}
```

`render.js` accepts `--glob` to process all matching files, or a single `--file` argument for targeted rebuilds.

### GitHub Actions

```yaml
name: Build Site

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install system dependencies
        run: |
          sudo apt-get install -y ffmpeg
          # Optional: install gifski
          # cargo install gifski

      - name: Install Node dependencies
        run: npm ci

      - name: Build animations
        run: npm run build:anims
        # Puppeteer downloads Chromium on first run via postinstall.
        # Pin the Puppeteer version to control the Chromium revision.

      - name: Build site
        run: npm run build

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
```

**CI note:** Puppeteer on Linux requires `--no-sandbox` in headless mode. Set this in `capture.js`:
```js
const browser = await puppeteer.launch({
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});
```

---

## Embedding in Content Pages

### Shortcode / Custom Tag

The site's static site generator (Eleventy, Hugo, Astro, etc.) should register a shortcode that accepts the GIF filename and optional alt text:

**Eleventy example (`chat_anim` shortcode):**
```js
eleventyConfig.addShortcode('chat_anim', (filename, alt = 'Chat animation') => {
  return `
<div class="chat-anim-embed">
  <img src="${filename}" alt="${alt}" class="chat-anim-img" loading="lazy">
</div>`;
});
```

**Usage in Markdown:**
```
{% chat_anim "ask-plan-agent.gif", "Demonstrating the Ask-Plan-Agent cycle" %}

The Ask-Plan-Agent cycle front-loads human judgment to the cheapest moment...
```

### Embed CSS (`chat-embed.css`)

```css
/*
  Each embed is a block-level section boundary.
  On wide screens: GIF floats right; following text wraps left.
  On narrow screens: GIF is full-width; text stacks below.
*/

.chat-anim-embed {
  /* Force a new block formatting context — prevents adjacency with prior floats */
  clear: both;
  display: flow-root;   /* contains the float without overflow:hidden hacks */
  margin-bottom: 2rem;
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

**How section isolation works:** The `clear: both` on `.chat-anim-embed` ensures each new embed starts below any preceding floated element. `display: flow-root` on the wrapper contains the float so that the text following the embed in the DOM wraps correctly around the image without bleeding into the next embed's region.

---

## Summary of Deliverables

| File | Purpose |
|---|---|
| `tools/chat-anim/render.js` | CLI entry point, YAML parsing, pipeline orchestration |
| `tools/chat-anim/template.html` | Handlebars animation template |
| `tools/chat-anim/capture.js` | Puppeteer frame capture |
| `tools/chat-anim/defaults.js` | Visual/timing constants |
| `tools/chat-anim/package.json` | Dependencies: puppeteer, handlebars, js-yaml, glob |
| `site/css/chat-embed.css` | Float/responsive embed styles |
| `.github/workflows/build.yml` | CI configuration |
| `content/**/*.chat.yaml` | Authored conversation files |
| `content/**/*.gif` | Build artifacts (gitignored) |
