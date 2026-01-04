<p align="center">
  <img src="https://kagi.com/proxy/tupac_shakur_photo_by_steve_eichner_archive_photos_getty_83928439.jpg?c=CO4LUKZbRFWAMar9Ouxd47EwU47WPl3o3nzqn97mCtVTrK_dM-bW2xJeWDX7J9obDzYE8LRsBLJ_zgE6S3ksG8H-ZMnDuNoYFnZm7tmVT6YDpYOhRzduw_5kxe1iqmWP-EVNRXTwmDUFPr7olXA9ZUtgwR4Z9KC_h4qsNddNw8I%3D" alt="logo" width="96"/>
</p>

<h1 align="center">tupac</h1>

<p align="center">
  discord bot for organizing dev team projects with auto-generated channels, roles, acronyms, and task management. originally built for game dev teams, works for any project-based workflow.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="license"/>
  <img src="https://img.shields.io/badge/python-3.11-blue.svg" alt="python"/>
  <img src="https://img.shields.io/badge/discord.py-2.3-5865F2.svg" alt="discord"/>
</p>

---

### quickstart

**1. create discord bot**

1. go to [discord developer portal](https://discord.com/developers/applications)
2. create new application -> bot tab -> create bot -> copy token
3. enable **Server Members Intent** under Privileged Gateway Intents
4. oauth2 -> url generator -> scopes: `bot`, `applications.commands` -> permissions: `Administrator`
5. use generated url to invite bot

**2. run with docker (recommended)**

```bash
git clone https://github.com/microck/tupac.git
cd tupac
cp .env.example .env
# edit .env with your DISCORD_TOKEN and GUILD_ID
docker compose up -d
```

**3. run manually**

```bash
pip install -r requirements.txt
python -m bot.main
```

---

### features

- **auto channels:** creates 25+ organized channels per project from a template
- **smart acronyms:** "Neon Drift" -> ND, "The Great Escape" -> TGE
- **role sync:** members with @Coder auto-get @ND-Coder for every project
- **emoji groups:** channels prefixed by category (💻-nd-frontend, 🎨-nd-concept)
- **live templates:** modify template, sync to all existing projects instantly
- **task management:** trello-style task tracking with threads, dashboards, automation
- **multi-assignee:** assign multiple people to tasks with configurable approval rules
- **question system:** assignees ask questions via modal, leads reply directly to thread
- **leads-only channels:** task-leads channels auto-restricted to configured lead roles
- **setup wizard:** interactive `/admin setup` to configure task system
- **project import:** `/admin sync` imports existing Discord categories as projects

---

### commands

all commands organized into 4 groups:

| group | command | description |
|-------|---------|-------------|
| **project** | `/project new <name>` | create project with channels and roles |
| | `/project delete <acronym>` | delete project and all channels/roles |
| | `/project list` | list all projects |
| | `/project addchannel` | add custom channel to a project |
| | `/project removechannel` | remove channel from a project |
| | `/project member add/remove` | assign/remove member roles |
| | `/project members` | list all users with roles |
| **template** | `/template list` | show channel template |
| | `/template add` | add channel to template |
| | `/template remove` | remove from template |
| | `/template sync` | sync template to all projects |
| | `/template export` | download template as JSON |
| | `/template import` | import template from JSON |
| | `/template groups` | list groups and emojis |
| | `/template emoji` | change a group's emoji |
| **task** | `/task new` | create task with thread |
| | `/task close [id]` | close task (run in thread or specify ID) |
| | `/task list [user]` | list active tasks |
| | `/task board <project>` | show/refresh task dashboard |
| | `/task import <file>` | bulk import tasks from JSON/XML |
| | `/task delete <id>` | delete a task |
| | `/task help` | show detailed help |
| **admin** | `/admin setup` | configure task system (wizard) |
| | `/admin status` | show current config |
| | `/admin sync` | import existing categories as projects |
| | `/admin migrate` | migrate tasks to multi-assignee |
| | `/admin channels` | list channels with IDs |
| | `/admin members` | list members with IDs |

---

### usage

#### 1. create a project

```
/project new "Neon Drift"
```

creates:
- category with 25+ channels from template
- project-specific roles: `@ND-Coder`, `@ND-Artist`, `@ND-Audio`, `@ND-Writer`, `@ND-QA`
- channels prefixed with acronym: `nd-general`, `nd-code-frontend`, etc.

#### 2. import existing projects

```
/admin sync
```

- discovers Discord categories not yet tracked
- auto-detects acronyms from channel naming patterns
- imports channels and matches existing roles
- multi-select for batch import

#### 3. manage members

```
/project member add @user Coder   -> assign role
/project member remove @user Coder -> remove role
/project members                   -> list all
```

available roles: `Coder`, `Artist`, `Audio`, `Writer`, `QA`

members with base roles auto-get project roles (e.g., @Coder gets @ND-Coder)

#### 4. manage templates

```
/template list                  -> view current template
/template add <name> <group>    -> add channel to template
/template remove <name>         -> remove from template
/template sync                  -> apply changes to all projects
/template export                -> download as JSON
/template import <file>         -> import from JSON
```

**note:** channels with "lead" in the name are auto-restricted to configured lead roles during sync.

#### 5. create tasks

```
/task new <title> <description> <channel> <assignee> [priority] [deadline]
```

- creates thread in target channel
- supports multiple assignees via `additional_assignees` parameter
- first assignee becomes primary owner (can close solo)

#### 6. task workflow

1. admin creates task -> thread spawned in target channel
2. assignee clicks `Start` -> status becomes "In Progress"
3. click `Submit for Review` -> leads notified
4. click `Approve & Close` or `/task close` -> task done, thread archived

**header buttons (in channel):**
- `View Thread` - jump to discussion thread
- `Manage Team` - add/remove members, set primary owner
- `Change Priority` - update priority level
- `Cancel Task` - cancel and archive

**thread buttons (in task thread):**
- `Start/Pause` - toggle work status
- `Update ETA` - set estimated completion
- `Question` - open modal to ask leads (they can reply directly to thread)
- `Submit for Review` - request approval
- `Approve & Close` - complete task

#### 7. question flow

1. assignee clicks `Question` button in task thread
2. modal opens to type the question
3. question posted to project's leads channel with task context
4. leads see `Reply` button on the question
5. lead clicks `Reply`, types response in modal
6. response posted directly to task thread, @mentioning the asker

#### 8. server setup

```
/admin setup    -> choose Quick Setup or Custom Setup
/admin status   -> view current config
/admin migrate  -> sync existing tasks to multi-assignee
```

**Quick Setup** - choose channel mode first:
- **Per-Project**: adds `task-board`, `task-questions`, `task-leads` to the template and syncs to all existing projects
- **Global**: creates a single `Tasks` category with shared channels

Then configure lead roles and approval mode.

**Custom Setup** - full wizard with step-by-step configuration for all options.

---

### channel groups

| group | emoji | channels |
|-------|-------|----------|
| general | 💬 | announcements, general, brainstorming, tasks |
| code | 💻 | frontend, backend, gamelogic, networking, bugs |
| design | 🎨 | gui, 3d, 2d, animation, vfx, concept |
| audio | 🔊 | music, sfx |
| writing | ✍️ | story, dialogue, copy |
| qa | 🧪 | playtesting, feedback |
| resources | 📚 | refs, tools |
| voice | 🎙️ | voice channel |

---

### template import/export format

```json
{
  "groups": [
    {"name": "general", "emoji": "💬"},
    {"name": "code", "emoji": "💻"}
  ],
  "channels": [
    {
      "name": "announcements",
      "group": "general",
      "is_voice": false,
      "description": "Project updates"
    },
    {
      "name": "voice",
      "group": "voice",
      "is_voice": true,
      "description": null
    }
  ]
}
```

import modes:
- `merge` (default): add new entries, update existing
- `replace`: clear template, import fresh

---

### task import format

**JSON:**
```json
[
  {
    "title": "Implement Inventory",
    "description": "Create grid-based inventory UI",
    "assignee_id": "123456789012345678",
    "target_channel_id": "987654321098765432",
    "deadline": "2026-05-20",
    "priority": "High",
    "additional_assignees": "111222333,444555666"
  }
]
```

**XML:**
```xml
<tasks>
  <task>
    <title>Compose Main Theme</title>
    <description>Orchestral track for main menu</description>
    <assignee_id>123456789012345678</assignee_id>
    <target_channel_id>555444333222111000</target_channel_id>
    <deadline>2026-04-15</deadline>
  </task>
</tasks>
```

use `/admin channels` and `/admin members` to get IDs.

---

### project structure

```
tupac/
├── bot/
│   ├── main.py          # bot entry, role sync
│   ├── config.py        # env vars
│   ├── database.py      # sqlite crud
│   ├── models.py        # dataclasses
│   ├── utils.py         # acronym generation
│   └── cogs/
│       ├── projects.py  # /project commands
│       ├── templates.py # /template commands
│       ├── tasks.py     # /task commands
│       └── setup.py     # /admin commands
├── assets/              # static files
└── data/                # sqlite database
```

---

### troubleshooting

**commands not showing** - wait for discord sync, or set `GUILD_ID` in .env

**role sync not working** - enable Server Members Intent in developer portal

**permission errors** - move bot role higher in server role list

**acronym conflicts** - if "ND" exists, new project becomes "ND2", or specify custom: `/project new "Name" acronym:XYZ`

**task threads not working** - bot needs "Create Public Threads" and "Send Messages in Threads" permissions

**leads channel not restricted** - run `/admin setup` first to configure lead roles, then `/template sync`

---

### license

mit
