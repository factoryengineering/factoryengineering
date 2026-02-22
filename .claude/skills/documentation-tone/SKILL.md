---
name: documentation-tone
description: Use when writing or editing documentation, docs, READMEs, or skill/command content. Applies firm, consistent tone: state recommendations clearly, avoid soft language that contradicts or weakens your own advice, and do not offer outs that undermine the main recommendation.
---

# Documentation Tone

Apply this skill when writing or revising documentation so that recommendations are clear, consistent, and not undercut by hedging or alternatives that encourage readers to ignore the guidance.

## Principle: Be firm in your recommendations

Documentation should state what to do and what not to do. Avoid language that makes the recommendation sound optional or that gives readers an easy way to disregard it.

## Do

- **Use imperatives.** Say "Use symlinks," "Follow the recommended pattern," "Do not rely on `$ARGUMENTS`."
- **State requirements plainly.** End with the requirement, not a vague escape: e.g. "On Windows, use the skill's PowerShell script (`Setup-Symlinks.ps1`)." not "...; the agent will use it when appropriate."
- **Prefer direct invocation rules.** e.g. "Prefer `/command-name` for the command; the `@` symbol refers to the artifact." not "Use `@command-name` only if your IDE supports it."
- **Show only the recommended method in examples.** When you recommend one way to do something, demonstrate that way only; do not show alternative ways to do the same thing. One clear example reinforces the recommendation.
- **Explain the cost of not following.** If someone skips a step, describe what they give up: "Without the symlink, you would have to maintain a separate copy in `.agent/workflows/`." Do not say "If you don't use the symlink, you can still..." — that invites skipping the recommendation.
- **Tie advice to shared constraints.** When content is shared (e.g. via symlinks) or must work across tools, state the constraint and the rule: "Commands are shared via symlinks; not all IDEs support `$ARGUMENTS`. Do not rely on it."

## Avoid

- **Softening the main recommendation.** Avoid "if you need it," "when appropriate," "only if your IDE supports it," "you can still..." when they weaken the primary guidance.
- **Offering an out that contradicts the recommendation.** If the doc says "use the symlink," do not add "if you don't use the symlink, you can still do X." Either remove the alternative or reframe it as the cost of not following (e.g. "otherwise you would have to...").
- **Showing multiple ways to do the same thing.** When the doc recommends one method, do not also show "Or you can..." or equivalent alternatives for the same action—it dilutes the recommendation. Show the preferred method only.
- **Making the reader guess.** Prefer "Use the [recommended pattern]:" over "For cross-IDE consistency, use the recommended pattern." Lead with the action.
- **Vague delegation.** Prefer "On Windows, use the skill's PowerShell script." over "...; the agent will use it when appropriate."

## Checklist

- [ ] Recommendations are stated as imperatives (Use / Do not / Follow).
- [ ] No sentence undercuts the main recommendation (e.g. no "you can still" that encourages skipping a step).
- [ ] Requirements are explicit; no "when appropriate" or "if you need it" that softens a requirement.
- [ ] For shared or cross-tool content, the constraint (e.g. symlinks, IDE-agnostic) is stated and the rule (e.g. do not use `$ARGUMENTS`) is firm.
- [ ] Examples show only the recommended method (no "Or you can..." alternatives for the same action).

## Example (before → after)

| Before (soft) | After (firm) |
|---------------|--------------|
| For cross-IDE consistency, use the recommended pattern. Claude Code also supports `$ARGUMENTS` if you need it. | **Use the recommended pattern.** Do not rely on `$ARGUMENTS`—commands are shared via symlinks and not all IDEs support it. |
| Use the PowerShell script; the agent will use it when appropriate. | Use the PowerShell script. |
| Use `@command-name` only if your IDE supports it. | Prefer `/command-name` for the command; the `@` symbol refers to the artifact. |
| Showing the recommended method and also "Or you can do X" for the same action. | Show only the recommended method; do not document alternatives for the same action. |
| If you don't use the symlink, you can still use `@` to bring a file into context. | Without the symlink, you would have to maintain a separate copy in `.agent/workflows/`. |

When in doubt, ask: *Does this sentence make it easier for the reader to ignore our own advice?* If yes, tighten or remove it.
