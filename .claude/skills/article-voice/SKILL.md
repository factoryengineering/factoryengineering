---
name: article-voice
description: Use when writing or editing articles in the Build Your Software Factory series or other tutorial content. Covers narrative voice, pacing, structure, and terminology conventions.
---

# Article Voice

Apply this skill when writing or editing tutorial articles, particularly the Build Your Software Factory series.

## Narrative pacing

- Jump into the task in the first paragraph. No theory preamble, no "in this article you will learn" lists.
- Show real work: real code, real prompts, real corrections. The reader should see the same output they would get in their own IDE.
- End with a clear next step that names the next article and what it covers.

## Structure

- Open with the task. The reader should be doing something by the second paragraph.
- Corrections drive the narrative. Each correction the reader makes becomes a teaching point. Show the wrong output, explain why it's wrong, show the corrected output.
- Close with the payoff. What did the reader produce? What's rough about it? What comes next?
- Keep articles to the target word count (typically ~800 words). Cut explanation before cutting examples.

## Tone

- Hands-on and concise. Write for a developer who has an AI IDE but hasn't created a skill before.
- Direct, not conversational. No "let's go ahead and" or "as you can see." State what happens and move on.
- Show confidence in the method. The article is teaching a workflow that works — present it as such.

## Terminology

- **Assistant**, not **agent**, when referring to an LLM-based coding environment (Claude Code, Copilot, Cursor, etc.). The reader tells the assistant what to do; the assistant produces output.
- **Agent** is reserved for the Factory Engineering definition: an autonomous component with a role, delegation rules, and escalation conditions. Do not use "agent" casually to mean "the thing I'm chatting with."
- **Skill**, **command**, **workflow** — use these terms precisely as defined in the Factory Engineering model. Do not conflate them.

## Chat animations

- Include a `.chat.yaml` animation that illustrates the key exchange. Place it at the top of the article so it floats beside the opening prose.
- Keep the animation to the essential beats — the initial prompt, one or two corrections, and the capture or payoff prompt. Do not reproduce every code block from the article.
- Target 15 seconds or less for the animation.

## References

- Link to the [Skills page](/skills) for readers who want background on skill structure.
- Link to [agentskills.io](https://agentskills.io) for the formal specification.
- Do not repeat reference material in the article body. Point to it and move on.
