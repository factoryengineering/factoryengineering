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

## Punctuation — m-dash

Use the m-dash (—) only for:

- **Header separation:** "Build Your Software Factory — Article 1 of 20"
- **Parenthetical exposition**, where the text between the dashes is a sentence fragment that cannot stand on its own: "In the next article, we test it in a clean room — a fresh conversation with no prior context — to see if it holds up without hand-holding."

Do not use the m-dash for:

- **Pauses.** Use an ellipsis instead.
  - Wrong: "It works. It's also wrong — at least by your team's standards."
  - Right: "It works. It's also wrong... at least by your team's standards."
- **Introducing a grammatically complete clause.** If the text after the dash has a subject and a verb and could stand as its own sentence, start a new sentence instead. This applies even when the follow-up is short or rhetorical.
  - Wrong: "This makes queries composable — you can layer on new operators."
  - Right: "This makes queries composable. You can layer on new operators."
  - Wrong: "The description says 'use when writing LINQ queries' — is that too broad?"
  - Right: "The description says 'use when writing LINQ queries.' Is that too broad?"

## Terminology

- **Assistant**, not **agent**, when referring to an LLM-based coding environment (Claude Code, Copilot, Cursor, etc.). The reader tells the assistant what to do; the assistant produces output.
- **Agent** is reserved for the Factory Engineering definition: an autonomous component with a role, delegation rules, and escalation conditions. Do not use "agent" casually to mean "the thing I'm chatting with."
- **Skill**, **command**, **workflow** — use these terms precisely as defined in the Factory Engineering model. Do not conflate them.

## Cross-article links

- Never create a link to an article that does not yet exist. Broken links erode trust and break builds.
- When referencing an upcoming article, mention it by name as plain text: "In the next article, *Test It in a Clean Room*, we validate..."
- Do not repeat reference material in the article body. Point to it and move on.
