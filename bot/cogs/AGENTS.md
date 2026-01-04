# BOT COGS KNOWLEDGE BASE

**Context:** Feature implementations, Slash Commands, UI Views

## STRUCTURE
```
bot/cogs/
├── projects.py  # /project (new, delete, list, addchannel, removechannel, member, members)
├── templates.py # /template (list, add, remove, sync, export, import, groups, emoji)
├── tasks.py     # /task (new, close, list, board, delete, import, help)
└── setup.py     # /admin (setup, status, sync, migrate, channels, members)
```

## PATTERNS
- UI classes (`discord.ui.View`, `Modal`) defined in same file as Cog
- `custom_id` format: `action:id` (e.g., `task_start:123`)
- Views re-registered in `setup()` hook for persistence
- Heavy use of `ephemeral=True` for user actions

## COG DETAILS

### Projects (`projects.py`)
- `/project new` creates category + channels + roles
- `/project member` manages Coder/Artist/Audio/Writer/QA roles
- Acronyms auto-generated, roles get random color

### Templates (`templates.py`)
- `/template sync` applies changes to ALL active projects
- `/template groups` + `/template emoji` manage channel prefixes
- Leads channels auto-restricted to configured lead roles during sync

### Tasks (`tasks.py`)
- Trello-like state machine: Todo -> Progress -> Review -> Done
- Multi-assignee with approval rules (auto/all/majority/any)
- `reminder_loop` checks deadlines (24h) and stagnation (3d)
- Thread moderation via `on_message` listener
- Question modal: assignees type question, leads get Reply button
- Lead replies posted directly to task thread with @mention

### Setup (`setup.py`)
- `/admin setup` - interactive wizard for task config
- `/admin sync` - import existing Discord categories as projects
- `/admin migrate` - syncs existing tasks to multi-assignee
- `/admin channels` + `/admin members` - ID discovery for imports
