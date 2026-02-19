---
name: astro-components
description: Guidance and best practices for Astro components in Starlight projects. Use when building or editing .astro components: presentational vs wrapper components, props and TypeScript interfaces, slots, reusing Section/Grid/Card and Starlight Icon, styling with cascade layers, and keeping data separate from presentation so content collections and MDX integration stay clean.
---

# Astro Components — Guidance and Best Practices

Apply this skill when implementing or refactoring Astro components so that data-driven sections (e.g. example factories, feature grids) are built with clear separation of data and presentation and consistent use of existing layout and iconography.

## Component anatomy

Every `.astro` file has two parts:

1. **Frontmatter (script)** — Between the first `---` and second `---`. Runs at build time. Use for:
   - Imports (e.g. `Icon` from `@astrojs/starlight/components`, or project components)
   - Destructuring `Astro.props` and defining defaults
   - TypeScript `interface Props { ... }` for clear, type-safe props
2. **Template** — HTML-like markup below the second `---`. Use `{expression}` for JS, `<slot />` for children, and `set:html` only for trusted content.

**Rule:** Do not use a leading `_` for “private” members (e.g. internal variables); follow project convention and use normal names.

## Presentational vs wrapper components

**Presentational component**

- Receives all data via **props**. Does not call `getCollection`, `getEntry`, or fetch.
- Renders one “unit” (e.g. one factory card, one feature column). Reusable anywhere the same shape of data is available.
- Example: `ExampleFactorySection.astro` with `factory: { title, technologies, applicationStyle, skills, commands, agents, workflows }`.

**Wrapper component**

- Calls `getCollection('collectionName')` (or `getEntry`) in the frontmatter. Handles sort/filter.
- Renders a section (e.g. `<Section>`) and **maps** over entries, rendering the presentational component for each with `entry.data`.
- Example: `ExampleFactoriesList.astro` that does `getCollection('exampleFactories')` and maps to `<ExampleFactorySection factory={entry.data} />`.

**Why:** MDX runs in a context where async `getCollection` in the template is awkward. Keeping data-fetch in an Astro wrapper and passing `entry.data` into a presentational component keeps MDX simple (import and render one wrapper) and makes the presentational component testable and reusable.

## Props and TypeScript

- Define an `interface Props` in the frontmatter. Destructure with defaults when appropriate: `const { title, size = "large" } = Astro.props;`
- For “one entry” components, accept a single object prop (e.g. `factory`) whose shape matches the content collection schema so the wrapper can pass `entry.data` directly.

## Reusing layout and iconography

**Section:** Use `<Section title="…" description="…">` from `~/components/Section.astro` for consistent section title and description. The `title` prop can include HTML (e.g. `<span class="light-text">…</span>`); use `set:html` in the component as in existing usage.

**Grid:** Use `<Grid columns={4}>` from `~/components/user-components/Grid.astro`. Pass the desired column count; children are laid out in a responsive grid. Use for four-column layouts that mirror the “Key components” cards.

**Icons (Starlight):** Import `Icon` from `@astrojs/starlight/components`. Use `<Icon name="…" color="…" size="…" />`. For the Skills/Commands/Agents/Workflows four-column layout, use the same icon names and colors as the Key components section — see the **astro-starlight** skill for the canonical table.

**Card-style blocks:** For a column that shows an icon, heading, and list (e.g. Skills + list of skill ids), reuse the same icon and color as [NewCard.astro](src/components/user-components/NewCard.astro). You can use a smaller or simplified card layout (e.g. icon + heading + `<ul>` of items) without the arrow. Keep visual consistency with the existing cards.

## Slots

- **Default slot:** `<slot />` renders the component’s children. Use for a single block of content (e.g. card body, section body).
- **Named slots:** `<slot name="footer" />` in the component; at the call site use `<Fragment slot="footer">…</Fragment>`. Use when the component has two or more distinct content areas.

For list/card components that only need a single content area, the default slot is usually enough. For Section, the default slot is the section body.

## Styling

- **Cascade layers:** Use `@layer starlight.components { ... }` for component-specific overrides so styles integrate with Starlight’s theme and don’t fight the default cascade.
- **Scoped styles:** Styles in a `<style>` block in an Astro component are scoped to that component by default. Use `:global(...)` only when you need to target child components or Starlight internals.
- **Layout:** Prefer the existing Grid and Section for spacing and structure; add minimal custom CSS for the new component’s internals (e.g. list spacing under each column heading).

## Checklist for new presentational components

- [ ] Props-only: no `getCollection` / `getEntry` in the component.
- [ ] `interface Props` defined; destructure with defaults where appropriate.
- [ ] Reuses `Section` / `Grid` / `Icon` (and card pattern if applicable) from the project.
- [ ] Icon names and colors match the four-column iconography in the **astro-starlight** skill when rendering Skills/Commands/Agents/Workflows.
- [ ] Component lives under `src/components/user-components/` (or override path per project).
- [ ] Styles use `@layer starlight.components` when overriding or extending Starlight.

## Checklist for wrapper components

- [ ] Calls `getCollection` (or `getEntry`) in the frontmatter; sorts/filters as needed.
- [ ] Renders one `<Section>` and maps entries to the presentational component, passing `entry.data`.
- [ ] Wrapper is the only place that knows about the collection name; the presentational component only knows the shape of one entry.

## Project references

- **Section:** [src/components/Section.astro](src/components/Section.astro)
- **Grid:** [src/components/user-components/Grid.astro](src/components/user-components/Grid.astro)
- **Card and Icon:** [src/components/user-components/NewCard.astro](src/components/user-components/NewCard.astro)
- **Index page (Section + Grid + Card usage):** [src/content/docs/index.mdx](src/content/docs/index.mdx)
- **Content config (collection shape):** [src/content.config.ts](src/content.config.ts)

For the full workflow (collection + data files + presentational component + wrapper + MDX), use the **astro-starlight** skill together with this one.
