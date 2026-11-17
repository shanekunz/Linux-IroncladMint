---
name: read-aloud
description: Rewrite a response for listening through text-to-speech instead of reading on screen. Use when the user says they are driving, walking, or away from the screen, asks to "read it to me", "make it listenable", "TTS format", "read-aloud", or wants a previous answer rewritten for audio.
---

Write for the ear. A listener can't scan, skim, or reread, and the voice reads every character literally. Rewrite the content as a short spoken briefing that someone can follow once at listening speed.

## Structure

- Start with the bottom line in one or two sentences.
- Say how many points are coming, then name each one as you reach it: "First...", "Second...", "Last one...".
- Keep it to three to five main points. Push the rest into one closing sentence or drop it.
- End with a short recap and any decision the user needs to make, phrased as a direct question.
- Aim for two to four minutes of audio, about 300 to 600 words, unless the user asks for more.

## Sentences

- One idea per sentence. Most sentences should be under 20 words, short enough to say in one breath.
- Use subject, verb, object. Avoid nested clauses, parentheticals, and "which" chains.
- Put the condition before the result: "If the order is unpaid, the button says Collect."
- Use conversational words and contractions. Write like you're explaining it to a friend in the passenger seat.
- Repeat key terms instead of switching to synonyms or using "the former" and "the latter". Repetition helps listeners.

## Things the voice reads badly

- No markdown: no headings, bullets, tables, bold, code blocks, or links. Use plain paragraphs. Separate topics with a blank line, which most engines read as a pause.
- No symbols. Write words for `&`, `/`, `->`, `=`, `%`, `#`, `~`, and similar. Never use an arrow to show a flow. Say "then".
- Spell out numbers that are hard to say: "about fifteen percent", "October twenty-third", "three p.m.", "ten dollars and fifty cents". Round where precision doesn't matter.
- Leave out file paths, URLs, commit hashes, function names, and code. Say what they are: "the orders page", "the shared payment rule". If an identifier is needed later, say it will be in the written version.
- Say ticket IDs by their names. Mention the ID once, written the way it's spoken, like "C C two eighty-three", and use the name after that.
- Read an acronym as letters only if that's how people say it. Expand anything unclear the first time it comes up.
- Describe a table instead of reading it. Say the pattern or the one row that matters.
- Use commas and periods for pacing. Avoid dashes, semicolons, ellipses, and quotes around single words, which voices handle inconsistently.

## Content

- Keep every decision, recommendation, and open question from the original. Cut background the listener can't act on right now.
- If exact wording needs approval, say the proposed wording slowly, as its own sentence, and say it's a proposal.
- Don't add new claims that weren't in the source.

## Output

Output only the spoken text, with no preamble like "Here's the audio version". If the original had details that only work on screen, end with one sentence saying the details are in the written version.
