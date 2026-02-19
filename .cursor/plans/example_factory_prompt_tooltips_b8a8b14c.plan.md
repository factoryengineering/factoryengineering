---
name: Example factory prompt tooltips
overview: "Add per-item prompts by naming convention only: prompt file is always `<entryId>/<name>.md`. Store prompts as markdown in per-factory subfolders, load at build time, show on hover with opacity-only fade and non-blocking behavior. All example factories use the new schema (no backward compatibility, no promptFile or other override)."
todos: []
isProject: false
---

# Example factory prompt tooltips

## Current state

- **[ExampleFactorySection.astro](src/components/user-components/ExampleFactorySection.astro)** renders each factory with four columns (skills, commands, agents, workflows). Each column shows a list of string names only (`factory[key].map((item) => <li>{item}</li>)`).
- **[content.config.ts](src/content.config.ts)** defines `exampleFactories` with flat string arrays: `skills`, `commands`, `agents`, `workflows`.
- Example JSON files (e.g. [2-sales-portal.json](src/content/example-factories/2-sales-portal.json)) use plain string arrays.

Reference formats for abbreviated prompt content:

- **Skill** ([linq-query-patterns SKILL.md](file:///Users/michaelperry/projects/Pluralsight/aaad/.kilocode/skills/linq-query-patterns/SKILL.md)): section structure (Core Principles, Examples) with 1–2 bullets, minimal detail.
- **Agent** ([tdd-test-first.agent.md](file:///Users/michaelperry/projects/Pluralsight/aaad/.github/agents/tdd-test-first.agent.md)): **second person** ("You …"), same structural headings (Purpose, What you do, When to use, Process) with minimal bullets.

---

## 1. JSON schema changes (no backward compatibility)

**File:** [src/content.config.ts](src/content.config.ts)

- Define a factory item type as an object with `name` only. Prompt file is determined solely by naming convention (no property to override):

```ts
const factoryItemSchema = z.object({
  name: z.string(),
});
```

- Use it for all four arrays:

```ts
skills: z.array(factoryItemSchema),
commands: z.array(factoryItemSchema),
agents: z.array(factoryItemSchema),
workflows: z.array(factoryItemSchema),
```

- All four example factory JSON files will be migrated to this shape; no support for plain strings.

---

## 2. Prompt file layout and loading

**Folder structure:** Each example factory has its own subfolder under `src/content/example-factories/` for prompt markdown files only. JSON stays at the collection root.

- `src/content/example-factories/1-catalog-administration.json` (unchanged location)
- `src/content/example-factories/1-catalog-administration/linq-standards.md`, `ef-migrations.md`, etc.

**Naming convention (no override):** The prompt file for an item is always `src/content/example-factories/<entryId>/<name>.md`, where `entryId` is the JSON filename without extension and `name` is the item's `name` property. There is no `promptFile` property or any other way to override this.

**Loading prompts:** Add a second content collection (e.g. `exampleFactoryPrompts`) that loads markdown from those subfolders.

- **Loader:** `glob({ pattern: "**/*.md", base: "src/content/example-factories" })`. Entries will have ids like `1-catalog-administration/linq-standards` (path without `.md`). Split id on first `/` to get `factoryId` and slug (the filename base).
- **Schema:** Minimal (e.g. empty object or optional frontmatter). Entry `id` is derived from path.
- **Resolving:** In [ExampleFactoriesList.astro](src/components/user-components/ExampleFactoriesList.astro), call `getCollection("exampleFactoryPrompts")`. Build a map keyed by `${factoryId}/${slug}`. For each factory entry, map over `skills`, `commands`, `agents`, `workflows` and look up prompt by `${entry.id}/${item.name}`; render that entry's markdown to HTML and attach as `promptHtml` on the item. Pass the augmented factory to the component.

---

## 3. ExampleFactorySection.astro updates

**File:** [src/components/user-components/ExampleFactorySection.astro](src/components/user-components/ExampleFactorySection.astro)

- **Props:** Accept `factory` where each of `skills`, `commands`, `agents`, `workflows` is `{ name: string }[]`. The list page augments each item with `promptHtml` (from the naming-convention lookup) before passing, so the component receives optional `promptHtml` on each item.
- **Markup per list item:** For each item render:
  - `<li class="factory-item">` as the hover target.
  - The **name** (e.g. `<span class="item-name">`).
  - A **prompt block** below the name when `promptHtml` is present: e.g. `<div class="item-prompt">` with `set:html={promptHtml}` (or safe equivalent) so markdown-rendered content displays. Position below the name; do not extend the hover target.
- **Hover behavior:** Show prompt when the list item (or name) is hovered. Give the prompt element `pointer-events: none` so moving the mouse into the prompt does not capture hover and the element below in Z-order can receive hover.
- **Fade:** Use a **short opacity-only** transition (e.g. `opacity` 0 → 1, ~120–150ms). **Do not** use a transform (no translate, scale, etc.) for the transition.
- **Positioning:** Position the prompt below the name (e.g. `position: absolute` + `top: 100%`), left-aligned, so it doesn't shift layout and doesn't capture pointer events.

---

## 4. Migrate and seed example factories

**JSON (all four factories):** Change every array to the new shape: objects with `name` only (no plain strings, no promptFile).

- [src/content/example-factories/1-catalog-administration.json](src/content/example-factories/1-catalog-administration.json)
- [src/content/example-factories/2-sales-portal.json](src/content/example-factories/2-sales-portal.json)
- [src/content/example-factories/3-fulfillment-engine.json](src/content/example-factories/3-fulfillment-engine.json)
- [src/content/example-factories/4-data-warehouse.json](src/content/example-factories/4-data-warehouse.json)

Example: `"skills": ["linq-standards", "ef-migrations"]` becomes `"skills": [{"name": "linq-standards"}, {"name": "ef-migrations"}]`.

**Prompt markdown files:** Create one subfolder per factory (e.g. `1-catalog-administration/`, `2-sales-portal/`, …). Add one `.md` file per item, named exactly `<name>.md` (e.g. `linq-standards.md`, `ef-migrations.md`) so the naming convention resolves correctly.

- **Skills:** Abbreviated structure (Core Principles, Examples) with 1–2 bullets; minimal detail.
- **Agents:** Second person; structure (Purpose, What you do, When to use, Process) with minimal bullets.
- **Commands / Workflows:** Short purpose + steps or phases (structure only).

Keep each prompt concise so the hover tooltip stays readable.

---

## 5. Data flow

- **ExampleFactoriesList.astro:** `getCollection("exampleFactories")` and `getCollection("exampleFactoryPrompts")`. Build a map from `${factoryId}/${slug}` to rendered prompt HTML. For each entry, map over `entry.data.skills`, `commands`, `agents`, `workflows` and attach `promptHtml` from the map using key `${entry.id}/${item.name}` (naming convention). Pass the augmented `entry.data` to `ExampleFactorySection`.
- **ExampleFactorySection:** Receives `factory` with items that may have `promptHtml`; renders name and, on hover, prompt block with opacity-only fade and `pointer-events: none`.

---

## Summary


| Area        | Action                                                                                                                                                                 |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Schema      | `factoryItemSchema = z.object({ name })` only; use for skills, commands, agents, workflows. No string union, no promptFile or override.                                |
| Convention  | Prompt file is always `<entryId>/<name>.md`; no property to override.                                                                                                  |
| Collections | Keep `exampleFactories` (JSON). Add `exampleFactoryPrompts` (glob `**/*.md` under `example-factories`); resolve by id to factoryId + slug.                             |
| List page   | Resolve by `${entry.id}/${item.name}` to markdown entry, render to HTML, attach `promptHtml` to each item; pass augmented factory to section.                          |
| Component   | Render name + optional prompt block below name on hover; opacity-only fade; `pointer-events: none` on prompt.                                                          |
| Content     | Migrate all four JSON files to `{ name }[]`. Add per-factory subfolders with `<name>.md` files (abbreviated prompts; skills/agents/commands/workflows style as above). |


