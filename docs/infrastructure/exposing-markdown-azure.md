---
title: Exposing Markdown Files on Azure
description: Production guide for publishing raw Markdown from Astro/Starlight through Azure Static Web Apps.
---

# Exposing Markdown Files on Azure

Use a build-time export and serve generated `.md` files from the same URL path as the HTML pages, with a `.md` suffix. For example, expose `/skills` as HTML and `/skills.md` as Markdown. Do not route directly to `src/content/docs` at runtime. Azure Static Web Apps serves built artifacts, not your source tree.

## Recommended architecture

1. Keep authoring docs in `src/content/docs/` for Starlight.
2. Build the site with Astro into `dist/`.
3. Export raw Markdown files to `dist/` after the build.
4. Normalize `.mdx` filenames to `.md` during export.
5. Publish `public/staticwebapp.config.json` with Markdown MIME type configuration.
6. Add `llms.txt` that points to canonical Markdown URLs.

This pattern keeps the website and machine-readable Markdown in sync and avoids custom runtime infrastructure.

## 1) Export Markdown after build

Create `scripts/export-markdown.mjs`:

```js
import { copyFile, mkdir, readdir } from "node:fs/promises";
import path from "node:path";

const sourceDir = path.resolve("src/content/docs");
const targetDir = path.resolve("dist");
const markdownExtensions = new Set([".md", ".mdx"]);

async function exportDirectory(currentDir) {
  const entries = await readdir(currentDir, { withFileTypes: true });

  for (const entry of entries) {
    const sourcePath = path.join(currentDir, entry.name);
    if (entry.isDirectory()) {
      await exportDirectory(sourcePath);
      continue;
    }

    const ext = path.extname(entry.name).toLowerCase();
    if (!markdownExtensions.has(ext)) continue;

    const relativePath = path.relative(sourceDir, sourcePath);
    const targetRelativePath = relativePath.replace(/\.(md|mdx)$/i, ".md");
    const targetPath = path.join(targetDir, targetRelativePath);

    await mkdir(path.dirname(targetPath), { recursive: true });
    await copyFile(sourcePath, targetPath);
  }
}

await exportDirectory(sourceDir);
```

Update `package.json`:

```json
{
  "scripts": {
    "build": "astro build && node scripts/export-markdown.mjs"
  }
}
```

Result: every deploy includes raw Markdown at paths like `/skills.md`.

## 2) Configure Static Web Apps for Markdown

Create `public/staticwebapp.config.json`:

```json
{
  "mimeTypes": {
    ".md": "text/markdown; charset=utf-8",
    ".mdx": "text/markdown; charset=utf-8"
  }
}
```

`public/` is copied into `dist/` by Astro, so Azure receives this config in the deployment artifact.

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
https://factoryengineering.dev/skills.md
https://factoryengineering.dev/commands.md
https://factoryengineering.dev/workflows.md
https://factoryengineering.dev/agents.md
```

Keep this list current. Every URL in `llms.txt` must resolve with HTTP 200.

## 5) Validate after deployment

Run these checks against the Azure hostname or custom domain:

```bash
curl -I https://factoryengineering.dev/skills.md
curl https://factoryengineering.dev/llms.txt
```

Confirm all of the following:

- `Content-Type` is `text/markdown; charset=utf-8`.
- Markdown files return `200 OK`.
- `llms.txt` returns `200 OK` and only contains live URLs.
- Preview environments and production return the same Markdown paths.

## Summary

Use static export as the default implementation. Add an API layer only when you need access policy or response transformation. This keeps Azure Static Web Apps simple, fast, and predictable for both humans and agents.
