---
title: "Site Content Management"
description: "Skill for maintaining and updating content in the Factory Engineering website"
category: "Documentation"
toolType: "skill"
featured: true
---

# Site Content Management

A comprehensive skill for managing content in the Factory Engineering static website. This skill provides knowledge about the content structure, schemas, and workflows for maintaining articles, examples, and skills.

## Project Overview

The Factory Engineering site is built with Astro and Starlight, featuring a custom content structure organized into three main collections:

- **Articles**: Educational content about factory engineering concepts
- **Examples**: Ready-to-use factory configurations
- **Skills**: Documentation for reusable AI skills and tools
- **Docs**: General documentation and landing pages

## Content Collections

### Articles Collection

Articles provide educational content about factory engineering concepts and best practices.

**Location**: `src/content/articles/`

**Schema**:
```yaml
---
title: "Article Title"
description: "Brief description"
publishDate: 2024-01-15
author: "Author Name"
tags: ["tag1", "tag2"]
draft: false
---
```

**Required Fields**:
- `title` (string): Article title
- `description` (string): Brief description
- `publishDate` (date): Publication date in YYYY-MM-DD format

**Optional Fields**:
- `author` (string): Author name
- `tags` (array of strings): Categorization tags
- `draft` (boolean): Set to true to hide from production (default: false)

**Naming Convention**: Use numeric prefixes for ordering
- `01-introduction-to-factory-engineering.md`
- `02-building-your-first-skill.md`

### Examples Collection

Examples demonstrate ready-to-use factory configurations for common scenarios.

**Location**: `src/content/examples/`

**Schema**:
```yaml
---
title: "Example Factory Name"
description: "What this factory does"
difficulty: "beginner"
tags: ["documentation", "markdown"]
githubUrl: "https://github.com/..."
---
```

**Required Fields**:
- `title` (string): Example name
- `description` (string): What the factory does

**Optional Fields**:
- `difficulty` (enum): "beginner", "intermediate", or "advanced"
- `tags` (array of strings): Categorization tags
- `githubUrl` (URL string): Link to example repository

**Naming Convention**: Use numeric prefixes for ordering
- `01-simple-documentation-factory.md`
- `02-code-review-factory.md`

### Skills Collection

Skills document reusable AI capabilities and tools for factory engineering.

**Location**: `src/content/skills/`

**Schema**:
```yaml
---
title: "Skill Name"
description: "What the skill does"
category: "Documentation"
toolType: "skill"
featured: true
installUrl: "https://..."
---
```

**Required Fields**:
- `title` (string): Skill name
- `description` (string): What the skill does
- `category` (string): Category (e.g., "Documentation", "Testing", "Code Review")
- `toolType` (enum): "skill", "command", "agent", or "workflow"

**Optional Fields**:
- `featured` (boolean): Whether to feature on homepage (default: false)
- `installUrl` (URL string): Installation or reference link

**Naming Convention**: Use numeric prefixes for ordering
- `01-doc-coauthoring.md`
- `02-site-content.md`

### Docs Collection

General documentation pages and landing pages for the site.

**Location**: `src/content/docs/`

**Schema**: Uses Starlight's standard schema

```yaml
---
title: "Page Title"
description: "Page description"
---
```

**Special Pages**:
- `index.mdx`: Home page (uses splash template)
- `articles.md`: Articles landing page
- `examples.md`: Examples landing page
- `skills.md`: Skills landing page
- `404.md`: Not found page

## Content Organization

### File Structure

```
src/content/
├── articles/           # Educational articles
│   ├── 01-*.md
│   └── 02-*.md
├── examples/           # Factory configurations
│   ├── 01-*.md
│   └── 02-*.md
├── skills/             # Skill documentation
│   ├── 01-*.md
│   └── 02-*.md
├── docs/               # General docs & landing pages
│   ├── index.mdx
│   ├── articles.md
│   ├── examples.md
│   └── skills.md
├── i18n/               # Internationalization
└── sections/           # Page sections (CTA, etc.)
```

### Ordering Content

Files are sorted alphabetically using `localeCompare()`. Use numeric prefixes to control display order:

**Good Examples**:
- `01-introduction.md` → appears first
- `02-getting-started.md` → appears second
- `10-advanced-topics.md` → appears tenth

**Bad Examples**:
- `introduction.md` → alphabetical ordering only
- `1-intro.md` → sorts before `10-*` incorrectly

## Content Workflows

### Adding a New Article

1. Create file: `src/content/articles/[NN]-[slug].md`
2. Add frontmatter with required fields
3. Write content in markdown
4. Preview locally: `yarn dev`
5. Commit changes

**Example**:
```bash
# Create new article
cat > src/content/articles/03-workflow-patterns.md << 'EOF'
---
title: "Workflow Patterns in Factory Engineering"
description: "Common patterns for orchestrating multi-step workflows"
publishDate: 2024-02-16
author: "Factory Engineering Team"
tags: ["workflows", "patterns", "best-practices"]
draft: false
---

# Workflow Patterns in Factory Engineering

Content here...
EOF

# Preview
yarn dev

# Commit
git add src/content/articles/03-workflow-patterns.md
git commit -m "Add workflow patterns article"
```

### Adding a New Example

1. Create file: `src/content/examples/[NN]-[slug].md`
2. Add frontmatter with required fields
3. Document the factory configuration
4. Include setup instructions and use cases
5. Preview and commit

### Adding a New Skill

1. Create file: `src/content/skills/[NN]-[slug].md`
2. Add frontmatter with required fields
3. Document features, usage, and examples
4. Preview and commit

### Updating Landing Pages

Landing pages (`articles.md`, `examples.md`, `skills.md`) should be updated when:
- New categories are added
- Featured content changes
- Navigation structure changes

### Updating Home Page

The home page (`index.mdx`) uses MDX format and custom components:
- Import components from `~/components/`
- Use `<Section>`, `<Grid>`, `<Card>`, etc.
- Update FAQ accordion items as needed

## Development Commands

```bash
# Install dependencies
yarn install

# Start dev server (http://localhost:4321)
yarn dev

# Build for production
yarn build

# Preview production build
yarn preview

# Run Astro CLI commands
yarn astro [command]
```

## Configuration Files

### Content Configuration

**File**: `src/content.config.ts`

Defines content collection schemas using Zod:
- `articles`: Article schema
- `examples`: Example schema
- `skills`: Skill schema
- `docs`: Starlight docs schema (auto-loaded)

### Site Configuration

**File**: `src/config/config.json`

Site metadata, author info, base URL

**File**: `src/config/theme.json`

Theme colors and styling

**File**: `src/config/sidebar.json`

Navigation structure (supports icons with `[icon-name]` syntax)

## Content Guidelines

### Writing Style

- **Articles**: Educational, thorough, concept-focused
- **Examples**: Practical, actionable, scenario-focused
- **Skills**: Reference-style, feature-focused, usage-focused

### Markdown Features

Supported markdown features:
- Standard markdown (headings, lists, links, images)
- Code blocks with syntax highlighting
- Frontmatter (YAML)
- MDX (for `.mdx` files) - allows importing components

### Links and References

**Internal Links**:
- Articles: `/articles/[slug]`
- Examples: `/examples/[slug]`
- Skills: `/skills/[slug]`
- Docs: `/[slug]`

**External Links**: Use full URLs

### Images and Assets

**Location**: `src/assets/`

**Reference in markdown**:
```markdown
![Alt text](../../assets/image-name.png)
```

**Reference in MDX**:
```jsx
import ImageMod from '~/components/ImageMod.astro';

<ImageMod src="/src/assets/image-name.png" alt="Alt text" />
```

## Deployment

The site builds to static HTML in `./dist/`:

```bash
# Build
yarn build

# Output: ./dist/
```

Deploy to any static hosting:
- **Netlify**: Connect repo, build command `yarn build`
- **Vercel**: Connect repo, build command `yarn build`
- **GitHub Pages**: Build and push `dist/` folder
- **Cloudflare Pages**: Connect repo, build command `yarn build`

## Common Tasks

### Add a Featured Article

1. Create article file with complete frontmatter
2. Update home page if needed to feature it
3. Optionally update `articles.md` landing page

### Reorganize Content Order

1. Rename files with new numeric prefixes
2. Files sort alphabetically, so:
   - `01-` before `02-`
   - `09-` before `10-`
   - Leading zeros matter: `01-` not `1-`

### Archive Old Content

1. Set `draft: true` in frontmatter (hides from production)
2. Or move to archive directory outside `src/content/`
3. Or delete file and commit removal

### Update Navigation

1. Edit `src/config/sidebar.json` for main navigation
2. Edit landing pages (`articles.md`, etc.) for section navigation
3. Edit `index.mdx` for home page links

## Tips for Content Maintenance

1. **Use consistent numeric prefixes**: Start at `01-`, use leading zeros
2. **Test locally**: Always preview with `yarn dev` before committing
3. **Write clear descriptions**: Frontmatter descriptions appear in listings
4. **Tag appropriately**: Tags help users find related content
5. **Link between content**: Create connections between articles, examples, and skills
6. **Keep landing pages updated**: Reflect current content in overview pages
7. **Version control everything**: Commit regularly with clear messages

## Troubleshooting

### Content Not Appearing

- Check frontmatter is valid YAML
- Verify `draft` is not set to `true`
- Ensure file is in correct directory
- Check file extension is `.md` or `.mdx`
- Restart dev server

### Build Errors

- Validate frontmatter against schema
- Check for required fields
- Ensure dates are in correct format (YYYY-MM-DD)
- Verify enum values match schema (difficulty, toolType)
- Check for broken links or missing images

### Ordering Issues

- Verify numeric prefixes are consistent
- Use leading zeros (`01-` not `1-`)
- Files sort alphabetically by full filename
- Restart dev server after renaming files

## Example: Complete Content Addition Workflow

```bash
# 1. Create new article
cat > src/content/articles/04-testing-factories.md << 'EOF'
---
title: "Testing Your Software Factory"
description: "Strategies for testing and validating factory configurations"
publishDate: 2024-02-16
author: "Factory Engineering Team"
tags: ["testing", "quality", "validation"]
draft: false
---

# Testing Your Software Factory

When building software factories, testing ensures your composed
tools work together correctly...

## Test Strategies

1. **Component Testing**: Test individual skills and commands
2. **Integration Testing**: Test tool composition
3. **End-to-End Testing**: Test complete workflows

...
EOF

# 2. Preview locally
yarn dev
# Visit http://localhost:4321/articles/04-testing-factories

# 3. Build to verify
yarn build

# 4. Commit
git add src/content/articles/04-testing-factories.md
git commit -m "Add testing factories article

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 5. Deploy (push to hosting)
git push origin main
```

## References

- [Astro Documentation](https://docs.astro.build)
- [Starlight Documentation](https://starlight.astro.build)
- [Content Collections Guide](https://docs.astro.build/en/guides/content-collections/)
- Repository README: `/README.md`
