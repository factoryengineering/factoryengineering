---
name: astro-starlight
description: Guides building and customizing documentation and marketing sites with Astro and Astro Starlight. Use when working on project setup, components, content collections, Starlight themes, landing pages, icons, or CSS in an Astro or Starlight project.
---

# Astro and Starlight

Reference for Astro fundamentals and Starlight customization. Covers common operations, patterns, and where to find details.

## Astro fundamentals

### What Astro is

Astro is a web framework for content-focused sites. It ships minimal JavaScript by default (islands architecture), uses file-based routing, and supports Markdown, MDX, and UI frameworks (React, Vue, etc.). Starlight is an official Astro integration that provides a full docs-site theme and structure.

### Project structure

```
project/
├── src/
│   ├── components/     # Reusable .astro (and framework) components
│   ├── layouts/        # Layout wrappers (convention, not required)
│   ├── pages/          # File-based routes (optional when using Starlight docs)
│   ├── content/        # Content collections (e.g. docs, blog)
│   ├── styles/         # Global CSS
│   └── content.config.ts  # Collection loaders and schemas
├── public/             # Static assets (unchanged in build)
├── astro.config.mjs    # Astro + integrations config
├── package.json
└── tsconfig.json       # Path aliases under compilerOptions.paths
```

Create a new project: `npm create astro@latest` (or pnpm/yarn). Add Starlight when prompted or later with `npx astro add starlight`.

### Astro components (.astro)

Each `.astro` file has a **frontmatter script** (between `---`) and a **template** (HTML-like). The script runs at build time; the template can use JavaScript expressions in `{}`.

```astro
---
const { title } = Astro.props;
const items = ['A', 'B', 'C'];
---
<div>
  <h1>{title}</h1>
  <ul>
    {items.map((x) => <li>{x}</li>)}
  </ul>
  <slot />  <!-- children go here -->
</div>
```

- **Props**: Destructure from `Astro.props`. Passed as attributes when the component is used.
- **Slots**: `<slot />` is the default slot for child content. Use `<slot name="header" />` for named slots; pass with `<Fragment slot="header">...</Fragment>`.
- **set:html**: Renders raw HTML: `<div set:html={htmlString} />`. Use only with trusted content (XSS risk).
- **Client directives**: Add `client:load`, `client:visible`, etc. to hydrate framework components when you need client-side JS.

### Pages and routing

- **File-based routing**: Files in `src/pages/` become routes. `src/pages/index.astro` → `/`, `src/pages/about.astro` → `/about`, `src/pages/blog/[slug].astro` → dynamic `/blog/:slug`.
- **Dynamic routes**: Export `getStaticPaths()` to define params at build time; read `Astro.params` in the page.
- **Starlight**: With Starlight, the **docs** collection drives docs routes; `src/content/docs/index.mdx` is the site root. You can still use `src/pages/` for custom routes (e.g. a custom dashboard).

### Content collections

Collections are defined in `src/content.config.ts` (or `content.config.js`). Each collection has a **loader** (where files live) and a **schema** (Zod) for frontmatter/entry shape.

```ts
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    pubDate: z.coerce.date(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
```

**Querying**: In a page or component, `const posts = await getCollection('blog')`. Use the second argument to filter: `getCollection('blog', ({ data }) => !data.draft)`.

### Config and imports

- **astro.config.mjs**: Use `defineConfig({ integrations: [...], vite: { ... } })`. Starlight is added as an integration with `starlight({ title, customCss, components, ... })`.
- **Path aliases**: In `tsconfig.json`, set `compilerOptions.paths` (e.g. `"@/*": ["src/*"]`). For Vite to resolve them, add `vite.resolve.alias` in `astro.config.mjs` if needed (e.g. `'@': fileURLToPath(new URL('./src', import.meta.url))`).
- **Astro.locals**: Request-scoped data set by middleware; read in components via `Astro.locals` (e.g. Starlight sets `Astro.locals.starlightRoute`).

### MDX

- Add MDX: `npx astro add mdx`. Then use `.mdx` files and import/use components inside them.
- In MDX you can import Astro or framework components; use `client:directive` on framework components when they need hydration.

---

## Starlight-specific

### Core concepts

- **Content**: Starlight uses the `docs` content collection. Put files in `src/content/docs/`. `index.md` or `index.mdx` is the homepage (`/`).
- **Overrides**: In `astro.config.mjs`, pass `components: { Hero: './src/components/MyHero.astro', ... }` to replace default layout pieces. Override only what you need.
- **Styling**: Starlight uses CSS cascade layers. Put overrides in `@layer starlight.components { ... }` or in unlayered CSS. Load your file via `customCss: ['./src/styles/global.css']`.

### Docs collection with Starlight

Use Starlight’s loader and schema so docs get the right frontmatter and routing:

```ts
import { docsLoader, i18nLoader } from '@astrojs/starlight/loaders';
import { docsSchema, i18nSchema } from '@astrojs/starlight/schema';

export const collections = {
  docs: defineCollection({ loader: docsLoader(), schema: docsSchema() }),
  i18n: defineCollection({ loader: i18nLoader(), schema: i18nSchema() }),
};
```

Extend the schema for custom frontmatter: `docsSchema({ extend: z.object({ featured: z.boolean().optional() }) })`.

### Home / landing page

- Use `src/content/docs/index.mdx` with frontmatter e.g. `template: splash`, `title`, `description`, and optional `hero` fields.
- In MDX, import and use your own components (Section, Card, Grid). Structure the page with sections and reuse layout components.

### Frontmatter (docs)

Common fields: `title`, `description`, `template`, `sidebar` (order, label, badge), `tableOfContents`, `head`, `draft`. See [Starlight frontmatter reference](https://starlight.astro.build/reference/frontmatter/).

### Overriding components

Implement the same contract Starlight expects (props/slots). Use `Astro.locals.starlightRoute` in overrides to read current route and entry data. Place override components in e.g. `src/components/override-components/` and reference them in `astro.config.mjs`.

### Icons

- **Built-in**: `import { Icon } from '@astrojs/starlight/components'`. Use `<Icon name="star" />` with a Starlight icon name (e.g. `star`, `rocket`, `pencil`, `setting`, `forward-slash`, `list-format`, `puzzle`, `open-book`, `approve-check`). Full list: [Starlight icons](https://starlight.astro.build/reference/icons/).
- **File-tree / Seti**: Names like `seti:html`, `seti:config` come from the file-tree icon set and work where that set is resolved.
- **Custom**: For icons not in Starlight, use your own SVG or image in a custom component.

### Styling

- **Layers**: Use `@layer starlight.components` for component overrides so they apply in the right order.
- **Tailwind**: Import `@astrojs/starlight-tailwind` and Tailwind theme/utilities; match layer order (e.g. `base, starlight, theme, components, utilities`). Theme via Starlight CSS variables (`--sl-color-accent`, `--sl-color-white`, etc.).
- **Heading line-height**: For multi-line section titles, use a unitless `line-height` (e.g. `1.25`) so wrapped lines have comfortable spacing.

### Card with arrow at bottom

Use a flex column for the card. On the arrow wrapper use `margin-top: auto` (e.g. Tailwind `mt-auto`) so it sticks to the bottom, and `padding-top` (e.g. `pt-15`) so the arrow isn’t tight to the body when content height varies. Avoid a fixed `margin-top` utility that would override `auto`.

### Custom pages with Starlight layout

For a custom route that still uses Starlight’s shell and sidebar:

```astro
---
import StarlightPage from '@astrojs/starlight/components/StarlightPage.astro';
---
<StarlightPage frontmatter={{ title: 'Dashboard' }} sidebar={customSidebar}>
  <h1>Custom content</h1>
</StarlightPage>
```

---

## Resources

### Astro (official)

- [Astro docs](https://docs.astro.build/) — main documentation
- [Project structure](https://docs.astro.build/en/basics/project-structure/) — directories and files
- [Astro components](https://docs.astro.build/en/basics/astro-components/) — syntax, props, slots
- [Pages and routing](https://docs.astro.build/en/guides/routing/) — file-based and dynamic routes
- [Content collections](https://docs.astro.build/en/guides/content-collections/) — define and query
- [Configuring Astro](https://docs.astro.build/en/guides/configuring-astro/) — astro.config
- [Import aliases](https://docs.astro.build/en/guides/imports/) — path aliases
- [MDX integration](https://docs.astro.build/en/guides/integrations-guide/mdx/) — MDX in Astro
- [Directives reference](https://docs.astro.build/en/reference/directives-reference/) — set:html, class:list, etc.
- [API reference](https://docs.astro.build/en/reference/api-reference/) — Astro global, locals

### Starlight (official)

- [Starlight docs](https://starlight.astro.build/)
- [Configuration](https://starlight.astro.build/reference/configuration/)
- [Overriding components](https://starlight.astro.build/guides/overriding-components/)
- [Icons reference](https://starlight.astro.build/reference/icons/)
- [CSS and Tailwind](https://starlight.astro.build/guides/css-and-tailwind/)
- [Frontmatter](https://starlight.astro.build/reference/frontmatter/)
