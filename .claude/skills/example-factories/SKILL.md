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
| **Skills** | Frontmatter with `description`. `## Section` headings expressing opinions. Code examples with ✅/❌ patterns where appropriate. | Opinionated; show preferred and discouraged patterns |
| **Agents** | **Purpose**, **What you do**, **When to use**, **Process** | Second person (“You …”); minimal bullets |
| **Commands** | One-line intent; numbered list of instructions (imperative) | Structure only |
| **Workflows** | **Purpose:** one line. **Phases:** high-level steps | Structure only |

**Skill prompt format:**
- **Frontmatter:** YAML `description` field that explains when to use the skill (e.g., "Use when writing LINQ queries").
- **Sections:** Use `## Heading` for each opinion or guideline.
- **Code examples:** Where appropriate, show `// ✅ Preferred` and `// ❌ Avoid` patterns in fenced code blocks.
- **Voice:** Express opinions directly — "Always use…", "Never rely on…", "Prefer X over Y".

**Example — Skill (linq-standards.md):**
````markdown
---
description: Guidelines for writing LINQ queries using Entity Framework Core. Use when writing LINQ queries.
---

## Separate specification from execution

Always use query syntax (`from...select`) and separate IQueryable definition from async execution:

```csharp
// ✅ Preferred
var customersSpec =
    from customer in context.Customer
    where customer.CustomerGUID == customerGuid
    select new { customer.CustomerID, customer.Name };
var customers = await customersSpec.ToListAsync();

// ❌ Avoid: Method chaining with immediate execution
var customers = await context.Customer
    .Where(customer => customer.CustomerGUID == customerGuid)
    .Select(customer => new { customer.CustomerID, customer.Name })
    .ToListAsync();
```
````

**Command prompt format:**
- One line stating intent, then a numbered list of instructions (imperative). No **Purpose** or **Steps** labels.

**Example — Agent (fe-dev.md):**
```markdown
**Purpose:** You implement and maintain front-end behavior and UI.

**What you do:** You build pages, components, and client-side logic.

**When to use:** For UI, forms, and browser-facing behavior.

**Process:** Follow design and accessibility guidelines; integrate with APIs.
```

**Example — Command (create-migration.md):**
```markdown
Add a new EF Core migration.

1. Define the schema change in code.
2. Run the migration command.
3. Verify Up and Down.
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
