# CLAUDE.md

## Project Overview

Factory Engineering is a documentation site built with **Astro + Starlight** and styled with **Tailwind CSS**. It showcases composable AI skills, commands, agents, and workflows organized into "factories" (curated toolsets for specific application domains).

- **Package manager:** Yarn
- **Language:** TypeScript (strict mode)
- **Deployment:** Azure Static Web Apps (primary), Netlify (alternative)
- **Localization:** English (root) and French (`fr`)

## Commands

```bash
yarn dev        # Start dev server
yarn build      # Build static site + export markdown to dist/
yarn preview    # Preview production build locally
```

The build runs `astro build` then `node scripts/export-markdown.mjs` to copy `.md`/`.mdx` files from `src/content/docs/` into `dist/`.

## Project Structure

```
src/
  components/
    override-components/   # Starlight default component overrides (Head, Header, Hero, Footer, Sidebar, etc.)
    user-components/       # Custom presentational components (NewCard, Grid, Button, ListCard, etc.)
    *.astro                # Shared components (Accordion, Section, CTA, HeroTabs, etc.)
  content/
    docs/                  # Main Starlight pages (index.mdx, skills.md, commands.md, etc.)
    articles/              # Educational articles (01-*.md, 02-*.md)
    skills/                # Skill/command/agent/workflow docs
    example-factories/     # Factory configs (JSON + supporting markdown)
    sections/              # Reusable page sections (CTA, with fr/ translations)
  config/                  # JSON config files (config.json, theme.json, sidebar.json, locals.json, social.json, menu.*.json)
  styles/                  # CSS layers (global.css, base.css, components.css, button.css, navigation.css)
  lib/utils/               # Helpers (textConverter.ts, languagePerser.ts)
  tailwind-plugin/         # Custom Tailwind plugins (tw-theme.js, tw-bs-grid.js)
  assets/                  # Images, logos, SVGs
  content.config.ts        # Astro content collection schemas
.claude/skills/            # Claude Code skills for this project
public/                    # Static assets (favicon, llms.txt, staticwebapp.config.json)
```

## Content Collections

Defined in `src/content.config.ts`. Six collections:

| Collection | Format | Location |
|---|---|---|
| `docs` | MDX/MD | `src/content/docs/` |
| `articles` | MD | `src/content/articles/` |
| `skills` | MD | `src/content/skills/` |
| `examples` | MD | `src/content/examples/` |
| `exampleFactories` | JSON | `src/content/example-factories/*.json` |
| `exampleFactoryPrompts` | MD | `src/content/example-factories/*/` |

### Content frontmatter conventions

- **Articles:** `title`, `description`, `publishDate`, `author`, `tags`, `draft`
- **Skills:** `title`, `description`, `category`, `toolType` (skill|command|agent|workflow), `featured`, `installUrl`
- **Factory JSON:** `title`, `technologies[]`, `applicationStyle`, `skills[]`, `commands[]`, `agents[]`, `workflows[]`

Files use numeric-prefix ordering: `01-name.md`, `02-name.md`.

## Styling

- **CSS layers** (in order): `base`, `starlight`, `theme`, `components`, `utilities`
- **Theme config** in `src/config/theme.json` drives CSS variables and Tailwind utilities via `tw-theme.js`
- Primary color: `#C23B00`
- Font: Inter (400, 500, 600)
- Dark mode is the default theme
- Starlight's built-in styles are extended, not replaced

## Component Patterns

- **Override components** (`override-components/`) replace Starlight defaults. Configured in `astro.config.mjs` under `starlight.components`.
- **User components** (`user-components/`) are presentational. They accept props and use slots -- no data fetching.
- Components use Astro's `.astro` single-file format with scoped `<style>` blocks and TypeScript `Props` interfaces.
- Responsive design: mobile-first breakpoints via Tailwind and custom Grid component.

## Configuration

All site configuration lives in `src/config/` as JSON files:

- `config.json` -- site title, logos, feature flags (search, theme switcher)
- `theme.json` -- colors, fonts, typography scale
- `sidebar.json` -- navigation structure
- `locals.json` -- supported locales
- `social.json` -- social media links
- `menu.en.json` / `menu.fr.json` -- menu translations

## Path Aliases

- `@/*` and `~/*` both resolve to `src/*`

## Key Files

- `astro.config.mjs` -- Astro/Starlight config, component overrides, integrations
- `src/content.config.ts` -- content collection schemas (Zod)
- `src/styles/global.css` -- CSS variable definitions and layer imports
- `src/tailwind-plugin/tw-theme.js` -- generates Tailwind utilities from theme.json

## Development Guidelines

1. **Prefer editing existing files** over creating new ones.
2. **Content goes in collections** -- add articles to `src/content/articles/`, skills to `src/content/skills/`, etc. Follow the numeric prefix convention.
3. **New components** should go in `user-components/` (presentational) or `override-components/` (Starlight overrides). Keep them simple with typed Props interfaces.
4. **Theming changes** go in `src/config/theme.json`, not hardcoded in CSS.
5. **No ESLint/Prettier configured** -- follow existing code style (2-space indent, no trailing semicolons in Astro frontmatter, semicolons in TS files).
6. **Factory definitions** use JSON with supporting markdown in a same-named directory.
7. **i18n:** Add French translations in parallel (`fr/` subdirectories or `menu.fr.json`).
8. **Do not modify** generated files in `.astro/` or `dist/`.
9. Use the available Claude Code skills (in `.claude/skills/`) for specialized tasks like creating skills, working with Astro components, or writing documentation.
