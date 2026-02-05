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

### Core Principles

- **Simplicity First**: Make every change as simple as possible. Minimal code impact.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Only touch what's necessary. Avoid introducing bugs.

## Workflow

### Planning

- Enter plan mode for non-trivial tasks (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan—don't keep pushing
- Write detailed specs upfront to reduce ambiguity

### Execution

- Offload research/exploration to subagents to keep main context clean
- One task per subagent for focused execution
- For complex problems, throw more compute at it via parallel subagents

### Verification

- Never mark a task complete without proving it works
- Run tests, check logs, demonstrate correctness
- Ask: "Would a staff engineer approve this?"
- Diff behavior between main and your changes when relevant

### Quality

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky, step back and implement the elegant solution
- Skip this for simple fixes—don't over-engineer

### Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding.
- Point at logs, errors, failing tests → then resolve them
- Fix failing CI tests without being told how

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
