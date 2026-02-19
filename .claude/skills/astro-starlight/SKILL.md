---
name: astro-starlight
description: Implements Astro Starlight data-driven sections using content collections (glob loader + Zod schema), presentational components, and MDX integration. Use when adding example factories, feature grids, or any "one JSON file per entry" content; defining collections in content.config.ts; or wiring getCollection into docs pages.
---

# Astro Starlight — Data Collections and Components

Implements data-driven sections: content collection (schema + glob loader), one JSON file per entry, a presentational component (data via props), and an Astro wrapper that calls `getCollection` and renders the component from MDX.

## Workflow checklist

Copy and track progress:

```
Task progress:
- [ ] 1. Add collection and schema in content.config.ts
- [ ] 2. Add JSON data files under src/content/<collection>/
- [ ] 3. Create presentational component (props only; no getCollection)
- [ ] 4. Create wrapper Astro component (getCollection + Section + map)
- [ ] 5. Render wrapper from index.mdx
```

---

## 1. Data collection

**In `src/content.config.ts`:** Use `defineCollection` with a **glob loader** (no `type: 'content'`). Add to exported `collections`. Follow the existing `ctaSection` pattern.

- **Loader:** `glob({ pattern: "**/*.json", base: "src/content/<collection-name>" })`.
- **Schema:** `z.object({ ... })` — keys must match each JSON file’s root.

**Example (example factories):**

```ts
const exampleFactories = defineCollection({
  loader: glob({
    pattern: "**/*.json",
    base: "src/content/example-factories",
  }),
  schema: z.object({
    title: z.string(),
    technologies: z.array(z.string()),
    applicationStyle: z.string(),
    skills: z.array(z.string()),
    commands: z.array(z.string()),
    agents: z.array(z.string()),
    workflows: z.array(z.string()),
  }),
});

export const collections = {
  // ... existing
  exampleFactories,
};
```

**Data files:** One JSON per entry. Filename (no extension) = entry `id`. Root keys = schema keys.

---

## 2. Presentational component

**Location:** `src/components/user-components/`. **Rule:** Receives data via props only; does not call `getCollection`.

**Reuse:** `Section`, `Grid` from `~/components/` and `~/components/user-components/`. For four-column iconography matching the "Key components" cards:

| Column    | Icon name       | Color   |
|----------|-----------------|--------|
| Skills   | `setting`       | `#FF8585` |
| Commands | `forward-slash` | `#7BE1A4` |
| Agents   | `puzzle`        | `#FFD97B` |
| Workflows| `list-format`   | `#979BFF` |

**Icon:** Import `Icon` from `@astrojs/starlight/components`. Use `<Icon name="…" color="…" />` as in [NewCard.astro](src/components/user-components/NewCard.astro).

**Structure:** Props = one entry (e.g. `factory: { title, technologies, applicationStyle, skills, commands, agents, workflows }`). Render: subheader (`factory.title`), meta line (technologies + applicationStyle), then `<Grid columns={4}>` with four columns (icon + heading + list per column). Keep component presentational: no side effects, no content fetching.

---

## 3. MDX integration

**Default:** Use an Astro **wrapper** so `getCollection` runs at build time. MDX then only renders the wrapper.

1. Create a wrapper (e.g. `ExampleFactoriesList.astro`) that:
   - Calls `const entries = await getCollection('exampleFactories')`.
   - Sorts by `entry.id` if order matters.
   - Renders `<Section title="…" description="…">` and maps `entries` to `<ExampleFactorySection factory={entry.data} />`.
2. In `src/content/docs/index.mdx`: import and render `<ExampleFactoriesList />`.

**Escape hatch:** If logic must live in MDX, ensure `getCollection` runs in a build-time context (e.g. layout or an Astro component imported by the MDX page). Prefer the wrapper pattern.

---

## 4. File summary

| Step | Path / convention |
|------|-------------------|
| Collection | `src/content.config.ts` — loader `base` = `src/content/<collection-name>/` |
| Data | One JSON file per entry in that folder; keys match schema |
| Presentational component | `src/components/user-components/<Name>.astro` — props = one entry; uses Section, Grid, Icon |
| Wrapper | Astro component that `getCollection` + Section + map; rendered once from MDX |

---

## 5. Project references

All references are one level deep from this file.

- **Config and existing pattern:** [src/content.config.ts](src/content.config.ts) — see `ctaSection` for glob loader; `docs` uses Starlight’s loader/schema.
- **Index and Key components layout:** [src/content/docs/index.mdx](src/content/docs/index.mdx) — Section, Grid, Card usage and four-column icons.
- **Card and Icon usage:** [src/components/user-components/NewCard.astro](src/components/user-components/NewCard.astro).
- **Grid:** [src/components/user-components/Grid.astro](src/components/user-components/Grid.astro) — `<Grid columns={4}>`.
