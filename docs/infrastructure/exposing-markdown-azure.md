---
title: Exposing Markdown Files on Azure
description: Production guide for publishing raw Markdown from Astro/Starlight through Azure Static Web Apps.
---

# Exposing Markdown Files on Azure

Use a build-time export and serve the generated `.md` files as static assets. Do not route directly to `src/content/docs` at runtime. Azure Static Web Apps serves built artifacts, not your source tree.

## Recommended architecture

1. Keep authoring docs in `src/content/docs/` for Starlight.
2. Export raw Markdown files to `public/markdown/` before build.
3. Publish `public/staticwebapp.config.json` with Markdown MIME type and cache headers.
4. Add `llms.txt` that points to canonical Markdown URLs.

This pattern keeps the website and machine-readable Markdown in sync and avoids custom runtime infrastructure.

## 1) Export Markdown during build

Create `scripts/export-markdown.mjs`:

```js
import { cp, mkdir, rm } from "node:fs/promises";
import path from "node:path";

const sourceDir = path.resolve("src/content/docs");
const targetDir = path.resolve("public/markdown");

// Recreate the output directory on every build to avoid stale files.
await rm(targetDir, { recursive: true, force: true });
await mkdir(targetDir, { recursive: true });

await cp(sourceDir, targetDir, {
  recursive: true,
  filter: (filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    if (!ext) return true;
    return ext === ".md" || ext === ".mdx";
  },
});
```

Update `package.json`:

```json
{
  "scripts": {
    "prebuild": "node scripts/export-markdown.mjs",
    "build": "astro build"
  }
}
```

Result: every deploy includes raw Markdown at paths like `/markdown/skills.md`.

## 2) Configure Static Web Apps for Markdown

Create `public/staticwebapp.config.json`:

```json
{
  "mimeTypes": {
    ".md": "text/markdown; charset=utf-8",
    ".mdx": "text/markdown; charset=utf-8"
  },
  "routes": [
    {
      "route": "/markdown/*",
      "headers": {
        "Cache-Control": "public, max-age=300, s-maxage=300",
        "X-Content-Type-Options": "nosniff"
      }
    }
  ]
}
```

`public/` is copied into `dist/` by Astro, so Azure receives this config and the exported Markdown files in one deployment artifact.

## 3) Add an API endpoint only when you need policy control

Use Azure Functions when you need authorization, request logging, or response shaping. Keep anonymous public docs static.

Do not read from `src/content/docs` in a Function. That source path is not present at runtime in Static Web Apps.

Example proxy function (`api/get-markdown/index.js`) using a configured upstream:

```js
module.exports = async function (context, req) {
  const doc = req.query.doc || req.params.doc;
  if (!doc || !/^[a-z0-9/_-]+$/i.test(doc)) {
    context.res = { status: 400, body: "Invalid document name." };
    return;
  }

  const markdownBaseUrl = process.env.MARKDOWN_BASE_URL;
  const upstreamUrl = `${markdownBaseUrl}/${doc}.md`;
  const upstream = await fetch(upstreamUrl);

  if (!upstream.ok) {
    context.res = { status: upstream.status, body: "Document not found." };
    return;
  }

  context.res = {
    status: 200,
    headers: { "Content-Type": "text/markdown; charset=utf-8" },
    body: await upstream.text(),
  };
};
```

## 4) Publish `llms.txt` for agent discovery

Create `public/llms.txt` and list canonical Markdown endpoints:

```txt
# Factory Engineering markdown index
https://factoryengineering.dev/markdown/skills.md
https://factoryengineering.dev/markdown/commands.md
https://factoryengineering.dev/markdown/workflows.md
https://factoryengineering.dev/markdown/agents.md
```

Keep this list current. Every URL in `llms.txt` must resolve with HTTP 200.

## 5) Validate after deployment

Run these checks against the Azure hostname or custom domain:

```bash
curl -I https://factoryengineering.dev/markdown/skills.md
curl https://factoryengineering.dev/llms.txt
```

Confirm all of the following:

- `Content-Type` is `text/markdown; charset=utf-8`.
- Markdown files return `200 OK`.
- `llms.txt` returns `200 OK` and only contains live URLs.
- Preview environments and production return the same Markdown paths.

## Summary

Use static export as the default implementation. Add an API layer only when you need access policy or response transformation. This keeps Azure Static Web Apps simple, fast, and predictable for both humans and agents.
