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
- **Ghostty config:** `.ghostty` is the shareable project theme (track in git). `.local.ghostty` is personal (gitignore via `*.local.*`). When setting up a new repo, use this convention.
- **Killing dev servers:** Use `killport` (or `killport 8080` for other ports) instead of raw `lsof -ti:PORT | xargs kill -9`. The alias is in `.zshrc`.

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

### Git Worktrees

When the user describes a task that should be done in isolation, or mentions "worktree"/"work tree":

**Setup:**
1. Auto-generate a branch name from the task intent. Check `git branch -a` for the repo's naming convention (e.g., `fix/auth-bug`, `feature/new-login`, or flat `fix-auth-bug`) and match it. If no clear pattern, just slugify to lowercase hyphenated. Keep under 50 chars.
2. Determine repo root (`git rev-parse --show-toplevel`) and repo name (`basename` of root).
3. Create the worktree: `git worktree add ../<repo-name>-<branch> -b <branch>`
4. If the project has `package.json`, `requirements.txt`, `Gemfile`, etc., install deps in the worktree.

**Working inline:**
- Prefix all Bash commands with `cd <worktree-abs-path> &&` to execute in the worktree.
- Use **absolute paths** for Read, Edit, Write, Glob, and Grep pointing into the worktree directory.
- The main session stays rooted in the original repo — only Bash commands cd into the worktree.

**Commits and PRs:**
- Commit and push from the worktree path: `cd <worktree-abs-path> && git add ... && git commit ...`
- Create PRs with `cd <worktree-abs-path> && gh pr create ...`

**Parallel via agent teams:**
When the user has multiple independent tasks (or one large task with independent workstreams), combine worktrees with `TeamCreate`:
1. Team lead stays in the main worktree and orchestrates.
2. Create one worktree per workstream.
3. Spawn each teammate with its worktree's **absolute path** in the prompt (e.g., "Work in /Users/tomfuertes/sandbox/git-repos/myapp-fix-auth. All file operations use that absolute path, all Bash commands cd there first.").
4. Each agent works independently — commits, pushes, and creates PRs from its own worktree.
5. Team lead coordinates via TaskList/SendMessage, reviews PRs, and cleans up worktrees when done.

**Cleanup:**
- Do NOT auto-remove worktrees after PR creation (user may have review feedback).
- When asked to clean up, run `git worktree list`, identify worktrees whose branches are merged or deleted on remote, and remove them with `git worktree remove`.
- Proactively mention stale worktrees if `git worktree list` shows 3+ entries during setup.

### PR Screenshots via R2

Host PR screenshots on a Cloudflare R2 bucket with a custom domain. GitHub has no image upload API ([cli/cli#1895](https://github.com/cli/cli/issues/1895)), so we self-host.

**Setup (once, all via `wrangler` CLI):**
```bash
npx wrangler r2 bucket create pr-assets
# Custom domain: configure in Cloudflare dashboard (R2 > pr-assets > Settings > Custom Domains)
# Custom domain: pr-assets.tomfuertes.com (configured in dashboard)
echo -e "User-agent: *\nDisallow: /" > /tmp/robots.txt
npx wrangler r2 object put pr-assets/robots.txt --file /tmp/robots.txt --content-type text/plain
```

**Upload:**
```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
UUID=$(uuidgen | head -c 8 | tr '[:upper:]' '[:lower:]')
npx wrangler r2 object put "pr-assets/${REPO}/${UUID}-<pr-number>-description.png" \
  --file .playwright/screenshot.png --content-type image/png
```

**Reference in PR body or comment:**
```
![description](https://pr-assets.tomfuertes.com/<repo>/<uuid>-<pr-number>-description.png)
```

- UUID prefix makes URLs unguessable — public but obscure
- Organized by repo name, so screenshots don't collide across projects
- `robots.txt` prevents search engine indexing
- **Cleanup:** `npx wrangler r2 object delete pr-assets/<repo>/<filename>`

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
