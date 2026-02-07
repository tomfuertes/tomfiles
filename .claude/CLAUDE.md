# User Environment

## Preferences

### Communication

- Be ruthlessly concise: no intros, preambles, or filler.
- If clarification is needed: ask up to 4 questions in parallel, each with 4 options (16 total choices).
- Be thoughtful with options. Try not to make them yes/no/other. Explore the space.
- When design space is large: break into orthogonal dimensions (e.g., "which approach?" + "which scope?" + "which priority?").

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

### Execution — Parallelism First

**Default to spawning agents aggressively.** Synchronous sequential work is the last resort, not the default. Think like a senior engineer triaging work across a team — identify independent workstreams and fan them out immediately.

**When to spawn agents (do this proactively, don't wait to be asked):**
- Any task with 2+ independent information needs (e.g., "explore external docs" + "scan local codebase" → two agents, not one sequential flow)
- Research that touches both web/docs AND local code — spin off an Explore agent for local context while you WebSearch/WebFetch in parallel, or vice versa
- Multi-file investigations — fan out Explore agents per area rather than serially reading files
- Pre-fetching context you'll likely need next (e.g., while planning, spawn an agent to gather relevant code patterns)
- Any work a `haiku` model can handle — use cheaper models for straightforward searches, file gathering, and summarization

**How to think about it:**
- Before starting any multi-step task, ask: "What can I kick off right now that I'll need later?"
- Treat your main context as the orchestrator, not the worker. Delegate actual exploration/research to agents.
- Spawn first, synthesize after. Don't wait for one result before starting the next independent query.
- Use `run_in_background: true` for agents whose results you don't need immediately
- One focused task per agent — they're cheap, context switches are expensive

**Use Agent Teams (`TeamCreate`) for complex multi-workstream tasks:**
- Agent teams are the heavyweight tool — use them when a task has 3+ independent workstreams that benefit from coordination, shared task lists, and inter-agent messaging
- Examples: "build feature X" (research agent + implementation agent + test agent), "investigate and fix bug" (repro agent + root-cause agent + fix agent), "refactor module" (audit agent + migration agent + verification agent)
- Teams give you a shared task list (`TaskCreate`/`TaskList`) and messaging (`SendMessage`) — use these for coordination, not just fire-and-forget
- Prefer teams over sequential individual agents when the work has dependencies between subtasks that benefit from a task graph
- Spawn teammates with the cheapest viable `model` (haiku for research/exploration, sonnet for implementation, opus only when reasoning is critical)
- Don't hesitate to create a team even for "medium" tasks — the overhead is low and the parallelism payoff is high

**Anti-patterns to avoid:**
- Reading 5 files sequentially when you could spawn an Explore agent
- Doing a web search, waiting, then doing a local search — do both at once
- Keeping expensive research in the main context when an agent could handle it
- Asking the user "should I look into X?" when you could just spawn an agent to check
- Doing 3+ sequential steps that could be a team with a shared task list — use `TeamCreate` instead of chaining individual `Task` calls

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
