# Task Persistence Across Sessions

## Cross-Session Task Sharing

To share a task list across multiple Claude Code windows/sessions, set the environment variable:

```bash
CLAUDE_CODE_TASK_LIST_ID=<project-name> claude
```

Tasks are stored in `~/.claude/tasks/<project-name>/` and any session with the same ID shares the same task list.

### Setup Options

**Per-project (direnv):** Add to `.envrc` in project root:
```bash
export CLAUDE_CODE_TASK_LIST_ID=<project-name>
```

**Shell alias:** Add to `~/.zshrc`:
```bash
alias claude-<project>='CLAUDE_CODE_TASK_LIST_ID=<project-name> claude'
```

## Native Task Tools

Claude Code 2.1+ includes native task tools:
- `TaskCreate` - Create tasks with subject, description, activeForm
- `TaskUpdate` - Update status (pending/in_progress/completed), set dependencies
- `TaskList` - View all tasks
- `TaskGet` - Get task details by ID

Tasks support dependencies via `addBlockedBy` and `addBlocks` fields.

## Plans Directory

Configure where plan files are stored via `plansDirectory` setting (default: `~/.claude/plans`).

---

## Sources (for refreshing this info)

- [Claude Code Interactive Mode - Task list](https://code.claude.com/docs/en/interactive-mode#task-list)
- [Claude Code Settings - Environment Variables](https://code.claude.com/docs/en/settings)
- [Claude Code Memory Management](https://code.claude.com/docs/en/memory)
- [VentureBeat: Claude Code Tasks Update](https://venturebeat.com/orchestration/claude-codes-tasks-update-lets-agents-work-longer-and-coordinate-across)
- [DEV: Task Tool Agent Orchestration](https://dev.to/bhaidar/the-task-tool-claude-codes-agent-orchestration-system-4bf2)

Last verified: January 2026
