# PROJECT KNOWLEDGE BASE

**Generated:** 2026-01-04
**Context:** Discord bot for dev team project management

## OVERVIEW
Python Discord bot (`discord.py` + `aiosqlite`). Manages projects via auto-generated channels, role sync, and Trello-like task boards with multi-assignee support. Originally built for game dev, works for any project-based workflow.

## STRUCTURE
```
.
├── bot/
│   ├── cogs/           # Feature modules (4 cogs)
│   ├── config.py       # Env vars & constants
│   ├── database.py     # SQLite CRUD & Schema
│   ├── main.py         # Entry point & Role Sync
│   ├── models.py       # Data Classes
│   └── utils.py        # Helpers
├── data/               # SQLite storage
└── assets/             # Static media
```

## COMMAND GROUPS (4 total)
| Group | Cog | Commands |
|-------|-----|----------|
| `/project` | projects.py | new, delete, list, addchannel, removechannel, member, members |
| `/template` | templates.py | list, add, remove, sync, export, import, groups, emoji |
| `/task` | tasks.py | new, close, list, board, delete, import, help |
| `/admin` | setup.py | setup, status, sync, migrate, channels, members |

## KEY TABLES
| Table | Purpose |
|-------|---------|
| `projects` | Project records (name, acronym, category_id) |
| `project_channels` | Channels belonging to projects |
| `project_roles` | Roles belonging to projects |
| `tasks` | Task records (title, status, deadlines) |
| `task_assignees` | Multi-assignee (user_id, is_primary, has_approved) |
| `server_config` | Per-server setup (approval rules, lead roles) |

## KEY FEATURES
- Question modal: assignees ask questions, leads reply to thread
- Leads channel permissions: auto-restricted during template sync
- Admin sync: imports existing Discord categories as projects

## CONVENTIONS
- Raw SQL in `database.py`, no ORM
- UI Views (Buttons/Modals) live inside Cog files
- Acronyms auto-generated: "Neon Drift" -> "ND"
- Channels/Roles prefixed with acronym: `nd-general`, `ND-Coder`
