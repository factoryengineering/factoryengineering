---
name: example-factories
description: Defines the format and opinions for example factories: schema (factory items with name only), prompt file layout by naming convention, prompt content formats (skills, agents, commands, workflows), and hover tooltip behavior. Use when adding or editing example factories, prompt markdown files, or the ExampleFactorySection/ExampleFactoriesList components.
---

# Example Factories — Format and Opinions

Example factories show how skills, commands, agents, and workflows compose for different application styles. Each factory is one JSON entry plus a subfolder of prompt markdown files; prompts are resolved by naming convention only and shown on hover.

---

## 1. Schema (no backward compatibility)

**Factory item:** One shape only — an object with `name` (no plain strings, no `promptFile` or override).

```ts
const factoryItemSchema = z.object({
  name: z.string(),
});
```

Use for all four arrays: `skills`, `commands`, `agents`, `workflows`.

**Factory JSON root:** `title`, `technologies` (string[]), `applicationStyle`, and the four arrays of `{ name }` objects.

**Opinion:** Prompt file is determined solely by naming convention; there is no property to override it.

---

## 2. Prompt file layout and convention

**Folder structure:**
- JSON files stay at the collection root: `src/content/example-factories/<entryId>.json`.
- Prompt markdown lives in a subfolder per factory: `src/content/example-factories/<entryId>/<name>.md`.

**Naming convention (no override):** The prompt file for an item is always `src/content/example-factories/<entryId>/<name>.md`, where `entryId` is the JSON filename without extension and `name` is the item’s `name` property.

**Collections:**
- `exampleFactories`: glob `**/*.json` on `src/content/example-factories`; schema includes the four arrays of `factoryItemSchema`.
- `exampleFactoryPrompts`: glob `**/*.md` on `src/content/example-factories` with `generateId: ({ entry }) => entry.replace(/\.md$/, "")` so entry ids are like `1-catalog-administration/linq-standards` and match the lookup key `${entryId}/${item.name}`.

**Resolving prompts:** In the list page, call `getCollection("exampleFactoryPrompts")`, build a map keyed by prompt entry `id`, then for each factory entry map over `skills`, `commands`, `agents`, `workflows` and attach `promptHtml` from the map using key `${entry.id}/${item.name}`. Render markdown to HTML (e.g. with `markdownify(entry.body, true)`) and pass the augmented factory to the section component.

---

## 3. Prompt content formats

Keep each prompt **concise** so the hover tooltip stays readable.

| Type       | Structure | Voice / style |
|-----------|-----------|----------------|
| **Skills** | **Core Principles** (1–2 bullets), **Examples** (1–2 bullets) | Minimal detail; no long prose |
| **Agents** | **Purpose**, **What you do**, **When to use**, **Process** | Second person (“You …”); minimal bullets |
| **Commands** | **Purpose:** one line. **Steps:** short list or phases | Structure only |
| **Workflows** | **Purpose:** one line. **Phases:** high-level steps | Structure only |

**Example — Skill (linq-standards.md):**
```markdown
**Core Principles**
- Prefer declarative LINQ; avoid N+1.
- Use async when querying (ToListAsync, etc.).

**Examples**
- Project only needed columns; filter in DB.
```

**Example — Agent (fe-dev.md):**
```markdown
**Purpose:** You implement and maintain front-end behavior and UI.

**What you do:** You build pages, components, and client-side logic.

**When to use:** For UI, forms, and browser-facing behavior.

**Process:** Follow design and accessibility guidelines; integrate with APIs.
```

**Example — Command (create-migration.md):**
```markdown
**Purpose:** Add a new EF Core migration.

**Steps:** Define schema change in code → run migration command → verify Up/Down.
```

**Example — Workflow (implement-feature.md):**
```markdown
**Purpose:** Deliver a feature from story to production.

**Phases:** Spec → implementation → PR → review → merge → deploy.
```

---

## 4. Section component and tooltip behavior

**Props:** `factory` where each of `skills`, `commands`, `agents`, `workflows` is an array of `{ name: string; promptHtml?: string }`. The list page augments each item with `promptHtml` before passing.

**Markup per list item:**
- `<li class="factory-item">` as the hover target.
- `<span class="item-name">` for the name.
- When `promptHtml` is present: `<div class="item-prompt">` with `set:html={promptHtml}` below the name; do not extend the hover target.

**Tooltip behavior:**
- **Position:** Below the name (`position: absolute`, `top: 100%`, left-aligned) so it doesn’t shift layout.
- **Pointer:** `pointer-events: none` on the prompt so moving the mouse into it doesn’t capture hover and the element below can receive hover.
- **Transition:** Short **opacity-only** fade (e.g. 120–150ms); **no** transform (no translate, scale).

---

## 5. Data flow summary

| Layer        | Responsibility |
|-------------|----------------|
| **Schema**  | `factoryItemSchema = z.object({ name })` only; use for skills, commands, agents, workflows. No string union, no promptFile. |
| **Convention** | Prompt file is always `<entryId>/<name>.md`; no override. |
| **Collections** | `exampleFactories` (JSON); `exampleFactoryPrompts` (glob `**/*.md`, `generateId` to preserve path). |
| **List page** | Resolve by `${entry.id}/${item.name}` to prompt entry; render body to HTML; attach `promptHtml` to each item; pass augmented factory to section. |
| **Section** | Render name + optional prompt block below name on hover; opacity-only fade; `pointer-events: none` on prompt. |

---

## 6. Adding a new factory or item

**New factory:**
1. Add `src/content/example-factories/<id>.json` with `title`, `technologies`, `applicationStyle`, and the four arrays of `{ "name": "slug" }`.
2. Create folder `src/content/example-factories/<id>/` and add one `<name>.md` per item (slug = filename without `.md`).

**New item in an existing factory:**
1. Add `{ "name": "slug" }` to the appropriate array in the factory JSON.
2. Add `src/content/example-factories/<id>/slug.md` using the correct format (skill, agent, command, or workflow).

**Project references:**
- [src/content.config.ts](src/content.config.ts) — `factoryItemSchema`, `exampleFactories`, `exampleFactoryPrompts`.
- [ExampleFactoriesList.astro](src/components/user-components/ExampleFactoriesList.astro) — prompt map and augmentation.
- [ExampleFactorySection.astro](src/components/user-components/ExampleFactorySection.astro) — list item and tooltip markup/styles.
