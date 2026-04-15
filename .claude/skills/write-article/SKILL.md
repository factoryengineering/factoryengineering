---
name: write-article
description: Write a new article in the Build Your Software Factory series from a GitHub issue number. Use when the user specifically asks you to write an article and references a GitHub issue that describes it.
---

# Write Article

The user will give you a GitHub issue number. That issue describes an article in the Build Your Software Factory series. Follow these steps to produce the article, its chat animation, and the related updates.

## 1. Research

Gather every piece of context before you write a word.

- **Read the issue.** Fetch the issue by number. Extract the article number in the series, target length, technology stack, the core concept, the step-by-step walkthrough, teaching points, and the concluding hook.
- **Read the previous article in the series.** The previous article establishes voice, pacing, code conventions, and the framing story. The new article must continue it seamlessly.
- **Read the `article-voice` skill.** This skill defines narrative pacing, tone, m-dash punctuation rules, and terminology. Apply every rule.
- **Read the `add-article` skill.** This skill defines the file layout, frontmatter, series header, chat animation placement, references footer, homepage card update, and cross-article link conversion. Follow it exactly.
- **Read any page the issue references.** If the issue points to `/skills` or another doc page, read it so the article stays consistent with what's already published.
- **List existing articles.** Check `src/content/docs/articles/` to determine the next numeric prefix and to see which articles already exist (so you know which cross-article references are safe to link).

## 2. Design the chat animation

The chat animation sits at the top of the article and illustrates the key exchange. Design it before you draft the prose — the animation often clarifies which beats matter most.

- **Pick the essential beats only.** A typical animation is the initial prompt, one or two assistant responses with corrections, and a final observation or payoff prompt. Three or four exchanges total.
- **Do not reproduce every code block from the article.** The animation is a teaser, not a transcript. Use shortened code with comments or ellipses where appropriate.
- **Match the article's narrative arc.** If the article ends with the reader asking the assistant a specific question, the animation should end there too.
- **Write the `.chat.yaml` file alongside the article** using the same base name as the `.mdx`.

## 3. Craft the narrative

Draft the article following `article-voice` and `add-article`. Work the teaching points from the issue into the narrative, but do not treat the issue's outline as a literal section list.

- **Open with the task.** The reader should be doing something by the second paragraph. No theory preamble.
- **Show real work.** Real code, real prompts, real corrections. The reader should recognize the output as something they would get in their own IDE.
- **Drive every action through the assistant.** When the reader needs information (did the skill load, what convention was violated), they ask the assistant — they do not dig through logs or external tools. Keep the workflow assistant-driven.
- **Stay inside the target word count.** Typically ~800 words. Cut explanation before cutting examples.
- **End with the next-article hook.** Name the next article as plain text (no link, since it does not exist yet) and state what it covers.
- **Add the references footer** per `add-article`: horizontal rule, `Next: Article N+1 — Title` line, and a short pointer to the [Skills page](/skills) and [agentskills.io](https://agentskills.io).

## 4. Update related articles and navigation

Now that the new article exists, wire it into every surface that lists articles. Missing one of these is the most common write-article bug.

- **Convert cross-article references.** Search earlier articles for plain-text mentions of the new article's title. Convert each one to a proper link. Only convert references that match the new article — do not touch references to articles that still do not exist.
- **Update the homepage Articles card.** In `src/content/docs/index.mdx`, add the new article to the `<ListCard title="Articles">` bullet list and increment the `number` prop. Confirm the link path matches the file's slug.
- **Update the /articles index page.** In `src/content/docs/articles.md`, add the new article as a bullet under the `## Build Your Software Factory` section. Use the same one-line description tone as the existing entries.
- **Update the top navigation dropdown.** In `src/config/menu.en.json`, add the new article to the `Articles` entry's `children` array. The Articles entry is a `hasChildren: true` dropdown — keep `All articles` as the first child and append each article in series order. Use trailing slashes on URLs to match the existing pattern.
- **Update the sidebar.** In `src/config/sidebar.json`, add the new article to the `Articles` group's `items` array, after `Browse Articles`. Use a slug like `articles/NN-title-in-kebab-case` (no leading slash, no `.mdx`).
- **Verify the previous article's "Next" line.** If the previous article's hook referenced this article as plain text, convert it to a link.

## 5. Review against the rules

Before committing, walk through this checklist:

- [ ] Frontmatter is complete (`title`, `description`, `publishDate`, `author`, `tags`, `draft: false`).
- [ ] Series header is present: `*Build Your Software Factory — Article N of 20*`.
- [ ] `<ChatAnim>` is imported and embedded near the top of the article.
- [ ] `.chat.yaml` file exists alongside the `.mdx`.
- [ ] Word count is near the target.
- [ ] M-dash usage matches `article-voice` rules (header separation and parenthetical fragments only).
- [ ] Terminology matches `article-voice` (assistant vs. agent, skill vs. command vs. workflow).
- [ ] No links point to articles that do not yet exist.
- [ ] Homepage Articles card has been updated (link added, count incremented).
- [ ] `/articles` index page (`src/content/docs/articles.md`) has the new article under `## Build Your Software Factory`.
- [ ] Top navigation dropdown (`src/config/menu.en.json`) lists the new article under `Articles`.
- [ ] Sidebar (`src/config/sidebar.json`) lists the new article under `Articles`, after `Browse Articles`.
- [ ] Previous article's cross-article reference has been converted to a link if applicable.

## 6. Commit and push

Create one or more focused commits on the current feature branch:

- The new article and its `.chat.yaml` in one commit.
- Cross-article link updates and the homepage card update in a separate commit if the changes are substantial, otherwise fold them in.

Push the branch.

## 7. Open a pull request

After the branch is pushed, open a pull request for the new article. Use the GitHub MCP tools (do not use `gh`).

- **Title:** `Article N: <Article Title>` — match the article's series position and title.
- **Body:** a short summary of what the article teaches, a reference to the source issue (e.g. `Closes #30`), and a brief list of the files touched (new `.mdx`, new `.chat.yaml`, homepage card update, previous-article link conversion).
- **Base branch:** `main`.
- **Head branch:** the feature branch you just pushed.

Return the PR URL in your final message so the user can review it.
