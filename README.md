# Factory Engineering

[![Built with Starlight](https://astro.badg.es/v2/built-with-starlight/tiny.svg)](https://starlight.astro.build)

A static website promoting the concept of building custom software factories from AI development tool components. Built with **Astro Starlight** featuring articles, examples, and skills for factory engineering.

## 🚀 Quick Start

### Installation

Install dependencies and start the development server:

```bash
# Install dependencies
yarn install

# Start development server
yarn dev
```

Your site will be available at `http://localhost:4321`

## 📝 Content Management

### Adding Articles

Create new articles in `src/content/articles/` with numeric prefixes for ordering:

```markdown
---
title: "Your Article Title"
description: "Brief description"
publishDate: 2024-01-15
author: "Your Name"
tags: ["tag1", "tag2"]
draft: false
---

# Your article content here...
```

### Adding Examples

Create factory examples in `src/content/examples/`:

```markdown
---
title: "Example Factory Name"
description: "What this factory does"
difficulty: "beginner"  # or "intermediate", "advanced"
tags: ["tag1", "tag2"]
githubUrl: "https://github.com/..."
---

# Your example content...
```

### Adding Skills

Document skills in `src/content/skills/`:

```markdown
---
title: "Skill Name"
description: "What the skill does"
category: "Documentation"
toolType: "skill"  # or "command", "agent", "workflow"
featured: true
installUrl: "https://..."
---

# Your skill documentation...
```

## 🏗️ Project Structure

```
/
├── public/             # Static assets
├── src/
│   ├── content/        # Content collections
│   │   ├── articles/   # Factory engineering articles
│   │   ├── examples/   # Factory configurations
│   │   ├── skills/     # Skill documentation
│   │   ├── docs/       # General documentation pages
│   │   ├── i18n/       # Internationalization
│   │   └── sections/   # Page sections
│   ├── components/     # Astro components
│   ├── config/         # Site configuration
│   ├── assets/         # Images and media
│   └── styles/         # Custom CSS
└── package.json
```

## 📖 Content Organization

### Content Collections

The site uses Astro content collections to organize Factory Engineering content:

- **Articles**: Educational content about factory engineering concepts and best practices
- **Examples**: Ready-to-use factory configurations for common scenarios
- **Skills**: Documentation for reusable AI skills and tools
- **Docs**: General documentation and landing pages

### Ordering Content

Use numeric prefixes in filenames to control display order:
- `01-introduction-to-factory-engineering.md`
- `02-building-your-first-skill.md`

Files are sorted alphabetically by filename using `localeCompare()`.

## 🚢 Build and Deploy

```bash
# Build for production
yarn build

# Preview the build
yarn preview

# Deploy to your hosting platform
# (Netlify, Vercel, GitHub Pages, etc.)
```

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                | Action                                           |
| :--------------------- | :----------------------------------------------- |
| `yarn install`         | Installs dependencies                            |
| `yarn dev`             | Starts local dev server at `localhost:4321`      |
| `yarn build`           | Build your production site to `./dist/`          |
| `yarn preview`         | Preview your build locally, before deploying     |
| `yarn astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `yarn astro -- --help` | Get help using the Astro CLI                     |

## 👀 Learn More

Check out [Starlight's docs](https://starlight.astro.build/), read [the Astro documentation](https://docs.astro.build), or jump into the [Astro Discord server](https://astro.build/chat).
