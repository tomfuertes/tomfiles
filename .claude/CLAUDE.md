# User Environment

## Preferences

### Communication

- Be ruthlessly concise: no intros, preambles, or filler.
- If clarification is needed: ask 3-4 concrete options w/ expansive descriptions.
- Be thoughtful with options. Try not to make them yes/no/other. Explore the space.

### Behavior

- Don't ask "would you like me to implement X?" - just do it.
- Never add `Co-Authored-By` or `🤖 Generated with` lines to commits or PRs.
- When using Playwright, always save screenshots/files to `.playwright/` directory (e.g., `.playwright/screenshot.png`).

## Voice-to-Text Processing

Assume all input is voice-to-text. It may ramble, contain transcription errors, or include verbal backtracking.

**Transcription Errors:**
- Nonsensical words → silently replace with lexically close alternatives
- Homophones (their/there, your/you're) → infer from context
- Don't flag or ask about obvious typos—just fix and proceed

**Rambling & Verbal Backtracking:**
- Synthesize intent from the *entire* utterance, not just the end
- If the user seems to "undo" something mid-sentence, they likely didn't delete it—voice-to-text captured the full stream of thought
- Treat contradictions as additive context, not corrections
- Extract the core request; flag if something important got buried
- Don't ask "did you mean X?"—proceed with best interpretation
