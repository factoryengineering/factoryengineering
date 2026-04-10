---
name: add-article
description: Use when adding a new article to the Build Your Software Factory series. Covers file creation, frontmatter, chat animation, homepage card, cross-article links, and the references footer.
---

# Add Article

Follow this checklist when adding a new article to the Build Your Software Factory series.

## 1. Create the article file

Place the file in `src/content/docs/articles/` using the numeric-prefix convention:

```
src/content/docs/articles/NN-title-in-kebab-case.mdx
```

Determine the next number by checking the highest existing prefix in the directory.

## 2. Frontmatter

Every article requires this frontmatter:

```yaml
---
title: "Article Title"
description: "One-sentence summary of what the reader will do"
publishDate: YYYY-MM-DD
author: "Factory Engineering Team"
tags: ["tutorial", "skills", "hands-on", "series-build-your-factory"]
draft: false
---
```

## 3. Series header

Add the series header as the first line of body content:

```markdown
*Build Your Software Factory — Article N of 20*
```

Replace `N` with the article's position in the series (not the file prefix).

## 4. Chat animation

Create a `.chat.yaml` file alongside the article with the same base name:

```
src/content/docs/articles/NN-title-in-kebab-case.chat.yaml
```

Import and embed the animation at the top of the article, directly after the series header:

```mdx
import ChatAnim from '~/components/user-components/ChatAnim.astro';

<ChatAnim src="/animations/NN-title-in-kebab-case.gif" alt="Description of the exchange" />
```

Keep the animation to the essential beats: the initial prompt, one or two corrections, and the payoff. Do not reproduce every code block from the article. Target 15 seconds or less — note that `pause_on_last_ms` defaults to 4000, so budget about 11 seconds for the typing itself.

The default viewport height (`config.height`) is 210 px, which only fits about two short bubbles before older content scrolls out. Multi-exchange animations should override it in the YAML — article 03 and 04 use `height: 340`, for example:

```yaml
config:
  height: 340
```

## 5. References footer

End the article with a horizontal rule and a references block:

```markdown
---

*Next: Article N+1 — Next Article Title*

For background on skill structure and folder locations, see the [Skills page](/skills). For the formal skill specification, see [agentskills.io](https://agentskills.io).
```

Do not link to the next article if it does not exist yet. Use plain text with the article name in italics.

## 6. Update the homepage Articles card

In `src/content/docs/index.mdx`, find the `<ListCard title="Articles" ...>` component:

1. Add a link to the new article in the bullet list.
2. Increment the `number` prop to match the new total.

## 7. Update cross-article links

Search earlier articles for plain-text references to this article's title. Convert them to proper links now that the article exists.

```
grep -r "Article Title" src/content/docs/articles/
```

Only convert references that match the new article's name. Do not create links to articles that do not exist yet.
