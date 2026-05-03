---
title: Your First Skill in 5 Minutes
description: A no-setup walkthrough — pick a task you already do, get the assistant's output to your standards, then capture it as your first skill.
---

# Your First Skill in 5 Minutes

You already have an AI IDE. You already have a task you do often. That is everything you need to build your first factory component.

This walkthrough mirrors the **Do the Work, Then Capture It** pattern from [Article 1](/articles/03-do-the-work-then-capture-it/), distilled to the shortest possible loop. Five minutes from now, you will have a working skill saved in your repository.

---

## What you need

- An AI IDE you already use — Claude Code, Cursor, Copilot, Windsurf, Kilo Code, Antigravity, or Codex.
- A repeatable task you do often. Anything works: writing a unit test, drafting a PR description, formatting a config file, generating release notes from commits.
- A repository to save the skill into.

No installs. No configuration.

---

## The five-minute loop

### 1. Open your AI IDE

Open the project where you would normally do this kind of work. The skill will live in this repository so your teammates get it on their next pull.

### 2. Ask the assistant to do the task

Pick something concrete and small. For example:

> Write a unit test for the `calculateInvoiceTotal` function in `src/billing/invoice.ts`.

Or:

> Draft a PR description for the changes on this branch.

Or:

> Format `config/staging.yaml` to match the project's style.

The first answer will be roughly right. It will not match your team's standards.

### 3. Correct the output until it matches your standards

Push back on what is wrong. Be specific. *"Use `describe`/`it`, not `test`. Mock the database with our `createTestDb` helper, not Jest's `jest.mock`. Assert on the return value, not on side effects."*

Iterate until the output is something you would happily commit. Do not compromise. The corrections you make in this step are the standards you are about to capture.

### 4. Ask the assistant to capture what it just learned

Once the output is right, say:

> Create a skill that captures the standards you just followed. Save it to `.claude/skills/my-first-skill/SKILL.md`. Use a clear `description` so the assistant knows when to load it.

The assistant will write a `SKILL.md` containing the rules it followed during the corrections.

### 5. Save and commit

Verify the file exists at `.claude/skills/my-first-skill/SKILL.md`. Read it. Tighten the description if it is vague. Commit it with the rest of your changes.

```bash
git add .claude/skills/my-first-skill
git commit -m "Add my-first-skill"
```

### 6. Test it in a fresh session

Start a new session in the same IDE. Give the assistant a similar task — a different function to test, a different config file to format. Do not mention the skill by name.

If the description is good, the assistant will load the skill on its own and follow your standards without further prompting.

If it does not, the description is not specific enough. Edit the `description:` line in `SKILL.md` so it names the *trigger*: when this skill should fire. Test again.

### 7. Celebrate

You just built your first factory component. The next teammate to clone this repo gets it for free.

---

## What you actually built

A `SKILL.md` is a tiny file with YAML frontmatter and a body. The frontmatter declares when the skill should load; the body explains what to do. The assistant reads the description before every task and loads the skill when relevant — that is what makes the standards consistent across the team.

For the deeper version of this loop, with worked corrections and the full reasoning behind each one, read [Article 1: Do the Work, Then Capture It](/articles/03-do-the-work-then-capture-it/).

---

## Where to go next

Continue to [Where to Go Next →](/getting-started/next-steps/) for the recommended path through the rest of the site.
