# Feature Specification: Task Management System

## 1. Overview & Objective
Implement a robust, Trello-style task tracking system natively within Discord for game development projects. The system distinguishes between a high-level **"Task Board"** (visualization) and granular **"Task Threads"** (execution/discussion).

**Key Constraints:**
- **No Ambiguity:** Imports must use explicit Discord IDs.
- **Role-Based Access:** Strict separation between "Leads/Admins" and "Assignees".
- **Thread-Centric:** All work happens in Discord Threads.
- **Automation:** Automatic status updates, reminders, and thread management.

---

## 2. Architecture & Workflow

### A. The "Central Dashboard" (High-Level View)
- **Concept:** A single, read-only channel per game project (e.g., `#nd-task-board`).
- **Content:** The bot maintains a persistent message (or series of messages) acting as a status board.
- **Layout:**
    - **Embed 1 (To Do):** List of unstarted tasks.
    - **Embed 2 (In Progress):** List of active tasks + Assignees.
    - **Embed 3 (In Review):** Tasks waiting for Lead approval.
    - **Embed 4 (Done):** Recently completed tasks.
- **Updates:** Real-time updates as task statuses change in threads.

### B. The "Task Thread" (Execution Context)
- **Concept:** Every task creates a dedicated **Public Thread** in a specific *Target Channel* (e.g., `#nd-code-frontend` for a frontend task).
- **Creation Logic:**
    1.  Admin/Lead creates task (via command or import).
    2.  Bot posts a "Task Header" in the *Target Channel*.
    3.  Bot creates a **Public Thread** on that header.
    4.  Bot posts the **"Control Panel" Embed** inside the thread.
    5.  Bot pings the `Assignee` and `Project Lead` inside the thread to subscribe them.
- **Locking:**
    - While the thread is **Public**, the bot monitors messages.
    - If a non-assignee/non-lead posts, the bot (optionally) warns or deletes the message to keep the thread focused.
    - When `Done`, the thread is **Archived** and **Locked** (Read-Only) to preserve history.

### C. The "Lead's HQ" (Notification Center)
- **Concept:** A specific channel (e.g., `#nd-leads`) restricted to Project Leads/Admins.
- **Notifications:**
    - "Task Submitted for Review" alerts.
    - "I have a Question" alerts (triggered by assignee).
    - Overdue task warnings.

---

## 3. Detailed UI/UX Specification

### Control Panel Embed (Inside Thread)
The first message in every task thread is an Embed controlled by the bot.

**Fields:**
- **Title:** Task Name
- **Description:** Full detailed text.
- **Assignee:** @User
- **Deadline:** YYYY-MM-DD
- **Current Status:** `To Do` | `In Progress` | `Review` | `Done`
- **ETA:** (User provided timestamp/text)

**Interactive Buttons:**
1.  `▶ Start` (Assignee Only): Moves status to `In Progress`.
2.  `⏸ Pause` (Assignee Only): Moves status back to `To Do` (or `Blocked`).
3.  `📅 Update ETA` (Assignee Only): Opens a Modal to enter text/date.
4.  `❓ I have a Question` (Assignee Only):
    - **Action:** Bot posts a message in `#nd-leads` tagging the Lead with a link to this thread.
    - **Feedback:** Bot posts "Lead has been notified" in the thread.
5.  `✅ Submit for Review` (Assignee Only):
    - **Action:** Moves status to `Review`. Pings Lead in `#nd-leads`.
6.  `🏁 Approve & Close` (Lead Only):
    - **Action:** Moves status to `Done`. Updates Dashboard. Locks & Archives Thread.

---

## 4. Commands API

### A. Management Commands
| Command | Arguments | Description |
| :--- | :--- | :--- |
| `/task create` | `title` (str), `description` (str), `target_channel` (channel), `assignee` (user), `deadline` (str: YYYY-MM-DD) | Creates a single task, posts to dashboard, and spawns the thread. |
| `/task board` | `[refresh]` (bool) | Reposts/Refreshes the dashboard in the current channel. |
| `/task list` | `[filter_user]` | Lists active tasks for the user. |

### B. Bulk Import
| Command | Arguments | Description |
| :--- | :--- | :--- |
| `/task import` | `file` (attachment) | Accepts `.json` or `.xml`. Parses file and creates tasks in bulk. |

### C. Discovery (Helper) Commands
Essential for gathering IDs for the import files.
| Command | Arguments | Description |
| :--- | :--- | :--- |
| `/debug list-channels` | `[category_id]` | Returns a list of `Channel Name | ID` for the server or category. |
| `/debug list-members` | `[role]` | Returns a list of `Username | ID` for the server or specific role. |

---

## 5. Data Formats (Import)

The import system **must** strictly validate fields. It requires explicit IDs to avoid ambiguity.

### JSON Schema
```json
[
  {
    "title": "Implement Inventory System",
    "description": "Create a grid-based inventory UI.",
    "assignee_id": "123456789012345678",
    "target_channel_id": "987654321098765432",
    "deadline": "2026-05-20T12:00:00",
    "priority": "High"
  },
  {
    "title": "Fix Physics Bug",
    "description": "Player clips through walls at high velocity.",
    "assignee_id": "111222333444555666",
    "target_channel_id": "999888777666555444",
    "deadline": "2026-02-10T09:00:00"
  }
]
```

### XML Schema
```xml
<tasks>
  <task>
    <title>Compose Main Theme</title>
    <description>Orchestral track for the main menu.</description>
    <assignee_id>123456789012345678</assignee_id>
    <target_channel_id>555444333222111000</target_channel_id>
    <deadline>2026-04-15</deadline>
  </task>
</tasks>
```

---

## 6. Database Schema (SQLite)

New tables required in `data/bot.db`:

```sql
-- Track individual tasks
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    game_acronym TEXT NOT NULL,         -- Links to specific game project
    title TEXT NOT NULL,
    description TEXT,
    assignee_id INTEGER NOT NULL,       -- Discord User ID
    target_channel_id INTEGER NOT NULL, -- Where the thread lives
    thread_id INTEGER,                  -- The created thread ID (nullable until created)
    status TEXT DEFAULT 'todo',         -- todo, progress, review, done
    deadline DATETIME,
    eta TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit log for history/undo (Optional but recommended)
CREATE TABLE task_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER,
    user_id INTEGER,
    action TEXT,                        -- e.g., "status_change", "eta_update"
    old_value TEXT,
    new_value TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(task_id) REFERENCES tasks(id)
);
```

---

## 7. Automation & Background Workers

### A. Reminder Loop (Runs every hour)
1.  **Upcoming Deadline:**
    - Query `tasks` where `status != 'done'` AND `deadline` is within 24 hours.
    - **Action:** Ping Assignee in the *Task Thread*: "⚠️ This task is due in 24 hours."
2.  **Stagnation Check:**
    - Query `tasks` where `status == 'progress'` AND `updated_at` > 3 days ago.
    - **Action:** Ping Assignee in the *Task Thread*: "Update Request: How is this going?"

### B. Thread Monitor (Event Listener)
- **Event:** `on_message(message)`
- **Logic:**
    - Check if `message.channel` is a `Thread`.
    - Check if `message.channel.id` exists in `tasks` table.
    - If Sender != `assignee_id` AND Sender is not Admin/Lead:
        - Delete message OR Send warning: "Only the assignee and leads can discuss in this task thread."

---

## 8. Implementation Checklist

1.  [ ] **Database:** Run schema migration script to add `tasks` table.
2.  [ ] **Cog Creation:** Create `bot/cogs/tasks.py`.
3.  [ ] **Discovery:** Implement `/debug list-channels` and `/debug list-members`.
4.  [ ] **Core:** Implement `/task create` (Embed creation + Thread spawning).
5.  [ ] **Interactivity:** Implement `TaskView` (Buttons) and `ETAModal` (Inputs).
6.  [ ] **Dashboard:** Implement `/task board` and the logic to update it whenever a task changes.
7.  [ ] **Import:** Implement file parsing (JSON/XML) for `/task import`.
8.  [ ] **Background:** Setup `tasks.loop` for reminders.