---
title: "Site Navigation"
description: "Technical details, standards, and opinions for maintaining the Factory Engineering site navigation menus"
category: "Documentation"
toolType: "skill"
featured: false
---

# Site Navigation

This skill documents how to maintain the site’s navigation: the **top-level header menu** and the **sidebar**. Use it when adding or changing nav items, adding locales, or keeping nav in sync with content.

## Overview

The site has two navigation surfaces:

1. **Top-level nav (header)** – Driven by locale-specific JSON under `src/config/`. Rendered by the custom Header; items can be links or dropdowns.
2. **Sidebar (left)** – Driven by `src/config/sidebar.json`, consumed by Starlight. Defines doc sections and slugs for the docs collection.

The top-level nav should reflect the same content structure as the sidebar: same sections and same order, so users see a consistent mental model.

---

## Technical Details

### Top-level menu (header)

**Config files**

- **English**: `src/config/menu.en.json`
- **Other locales**: `src/config/menu.{locale}.json` (e.g. `menu.fr.json`)
- **Fallback**: If `menu.{locale}.json` is missing, `src/lib/utils/languagePerser.ts` falls back to `menu.en.json`.

**Loading**

- `Header.astro` calls `getTranslations(Astro.currentLocale || "en")`, which dynamic-imports `menu.${lang}.json`.
- The header uses only the **`main`** array from that JSON. The same file may contain `footer`, `help_links`, `company`; those are not part of the header nav.

**Menu item shape**

- **Link (no dropdown)**  
  - `name` (string): Label.  
  - `url` (string): Path, e.g. `"/"`, `"/articles/"`, `"/fr/articles/"`.  
  - No `hasChildren` or `children`.

- **Dropdown**  
  - `name` (string): Label for the dropdown.  
  - `url`: Use `""` when the item is a dropdown only (no direct URL).  
  - `hasChildren: true`.  
  - `children`: Array of `{ "name": "...", "url": "..." }`.  
  - Active state: Header treats the parent as active if the current path matches any child `url` (with or without trailing slash).

**URLs and active state**

- Pathname comes from `Astro.request.url`. Active comparison supports both with and without trailing slash (e.g. `/articles` and `/articles/`).
- Use **trailing slashes** in config (e.g. `"/articles/"`) for consistency with Starlight and the code that normalizes paths.

**Locale prefixes**

- Default locale (e.g. `en`) uses paths like `/`, `/skills/`, `/articles/`.
- Other locales use a prefix: `/fr/`, `/fr/skills/`, `/fr/articles/`. Keep the same structure and only add the locale prefix.

### Sidebar

**Config file**

- `src/config/sidebar.json`
- Consumed in `astro.config.mjs` as `sidebar: sidebar.main || []`.

**Shape**

- Top-level array of groups. Each group:
  - `label`: Section heading (e.g. `"Factory components"`).
  - `items`: Array of `{ "label": "...", "slug": "..." }`.
- **Slug** must match a doc in the Starlight docs collection (e.g. under `src/content/docs/`). The slug is the path segment: `skills` → `/skills/` (or `/fr/skills/` for French).

**Relationship to content**

- Each `slug` must correspond to an existing doc (e.g. `src/content/docs/skills.md` → slug `skills`). Invalid slugs cause build or runtime errors.
- After editing `sidebar.json`, clear cache and restart: `rm -rf .astro` then restart the dev server.

---

## Standards

1. **One menu file per locale**  
   Maintain `menu.en.json` and a `menu.{locale}.json` for each other locale. Same keys and structure; translate only labels and use locale-prefixed URLs where needed.

2. **Top nav mirrors sidebar structure**  
   - Same sections in the same order.  
   - “Factory components” in the sidebar = “Factory Components” dropdown in the header with the same four items: Skills, Commands, Agents, Workflows.  
   - “Articles” and “Examples” in the sidebar = top-level “Articles” and “Examples” links in the header.

3. **URL format**  
   - Use trailing slashes in menu JSON: `"/skills/"`, `"/articles/"`, `"/fr/skills/"`.  
   - Match the actual doc routes (Starlight slug-based paths).

4. **Dropdowns only for groups**  
   - Use a dropdown when a sidebar section has multiple items (e.g. Factory Components).  
   - Use a single top-level link when the section has one main destination (e.g. Articles → `/articles/`, Examples → `/examples/`).

5. **No broken or placeholder links**  
   - Every `url` and every sidebar `slug` must point to real content. Remove or update links when content is moved or removed.

---

## Opinions

1. **Keep the top nav minimal**  
   Prefer a small number of top-level items. Avoid adding a separate “Documentation” link when the home page (`/`) already serves as the docs landing; it duplicates “Home” and adds noise.

2. **Factory Components as the only dropdown**  
   The only dropdown should be “Factory Components” (Skills, Commands, Agents, Workflows). Articles and Examples stay as direct links so the nav stays simple and matches the sidebar.

3. **Translate labels, not slugs**  
   In non-default locales, translate the display names (e.g. “Composants d’usine”, “Articles”) but keep URL paths and slug names in English for consistency and fewer bugs (e.g. `/fr/skills/`, not a translated path).

4. **Single source of truth for structure**  
   Treat `sidebar.json` as the canonical list of doc sections and order. When adding or reordering docs, update the sidebar first, then update the top-level menu so both stay in sync.

5. **Avoid footer/nav drift**  
   If the menu JSON also drives footer or other links, keep those sections updated when you change `main`, so labels and URLs stay consistent across the site.

---

## File reference

| Purpose              | File(s)                                      |
|----------------------|-----------------------------------------------|
| Header nav (English) | `src/config/menu.en.json`                     |
| Header nav (locale)  | `src/config/menu.{locale}.json`              |
| Menu loading         | `src/lib/utils/languagePerser.ts`            |
| Header rendering     | `src/components/override-components/Header.astro` |
| Sidebar config       | `src/config/sidebar.json`                    |
| Sidebar usage        | `astro.config.mjs` (sidebar: sidebar.main)   |

---

## Common tasks

### Add a new top-level link

1. Add an entry to `main` in `menu.en.json`: `{ "name": "Label", "url": "/path/" }`.
2. Add the same entry in each `menu.{locale}.json` with translated `name` and locale-prefixed `url` (e.g. `"/fr/path/"`).
3. Ensure a doc or page exists at that path.

### Add an item to the Factory Components dropdown

1. Add the doc (e.g. `src/content/docs/new-section.md`) and ensure its slug is what you want (e.g. `new-section`).
2. Add the slug to `sidebar.json` under the “Factory components” group.
3. Add a child to the “Factory Components” item in `main` in `menu.en.json`: `{ "name": "Label", "url": "/new-section/" }`.
4. Do the same in each `menu.{locale}.json` with translated name and locale-prefixed URL.

### Add a new locale

1. Add the locale to `src/config/locals.json` (if not already present).
2. Create `src/config/menu.{locale}.json` with the same structure as `menu.en.json`, translated labels and locale-prefixed URLs in `main` (and in footer/help_links/company if used).

### Change order of nav items

1. Reorder entries in `main` in each `menu.*.json` (and, if needed, reorder groups/items in `sidebar.json`).
2. Keep order identical across all locale menu files.

---

## Troubleshooting

- **Nav item does not appear**  
  Check that the item is in the `main` array (not only in footer/company). Restart dev server after editing JSON.

- **Wrong locale menu**  
  Ensure the file is named `menu.{locale}.json` and matches the locale code in `locals.json`. Check `Astro.currentLocale` and the fallback in `languagePerser.ts`.

- **Dropdown shows but children don’t**  
  Ensure each child has `name` and `url`. Check for typos in `url` and that the path exists.

- **Active state wrong**  
  Header compares pathname with and without trailing slash. If you use query or hash, the comparison may not match; keep nav URLs to path-only.

- **Sidebar “slug does not exist”**  
  Every `slug` in `sidebar.json` must match a doc (e.g. a file under `src/content/docs/` that compiles to that slug). Fix or remove the slug, then `rm -rf .astro` and restart.

---

## Related

- **Site Content Management** (`02-site-content.md`) – Content collections, frontmatter, and content guidelines; includes a short “Update Navigation” section and sidebar troubleshooting.
- **Sidebar** – Define structure in `src/config/sidebar.json`; keep top-level nav in sync with it.
