---
name: skill-optimizer
description: Applies skill authoring best practices to a skill. Use when the user wants to optimize, improve, or audit an existing skill against best practices, or to ensure a new or existing skill follows canonical authoring rules. If the target skill does not yet exist, use the skill-creator skill first to create it, then apply this skill's optimization workflow.
---

# Skill Optimizer

This skill applies skill authoring best practices to a skill. It ensures a skill is concise, well-structured, and follows the canonical checklist before finalizing.

## When to use

- User asks to **optimize**, **improve**, **audit**, or **review** a skill against best practices
- User wants a skill to follow **authoring best practices** or the **Agent Skills** format
- After creating a new skill (with skill-creator), user wants to **verify and tighten** it

## Required: Use skill-creator first if the skill does not exist

If the user names or describes a skill that **does not yet exist**, use the **skill-creator** skill first to create it (understand examples, plan contents, init, edit, package). Only after the skill exists should you apply the optimization steps below.

If the skill **already exists** (path or name given and the directory/SKILL.md is present), proceed directly to the optimization workflow.

## Optimization workflow

1. **Load best practices**  
   Read [references/best-practices.md](references/best-practices.md). It contains the canonical rules and the **Checklist for effective Skills**.

2. **Apply the checklist**  
   Run through every item in the checklist (Core quality, Structure, Scripts if applicable, Testing if applicable) against the target skill. Fix or suggest concrete edits for any failures.

3. **Verify and package**  
   If the skill uses packaging (e.g. `package_skill.py`), run the packager after changes; fix validation errors until the skill passes.

## Resources

| Resource | Purpose |
|----------|---------|
| [references/best-practices.md](references/best-practices.md) | Authoring rules, anti-patterns, and checklist (copy of canonical best practices). |
| [references/source.md](references/source.md) | Links to the npm package, Agent Skills spec, and original best-practices source. |

## Source

Best practices in this skill are derived from the open Agent Skills ecosystem. For the canonical source and CLI, see [references/source.md](references/source.md). Direct link: **[npm: skills](https://www.npmjs.com/package/skills)**.
