# Phase 3: Task Editing — Context

**Gathered:** 2026-05-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement task editing: tapping a task row opens a compact modal with title, deadline (text field),
and description. User can save changes back to disk.

Does NOT cover: drag-to-reorder (deferred to later phase).
Does NOT cover: tag editing (not in scope).
Does NOT cover: Notes tab (Phase 4).
</domain>

<decisions>
## Implementation Decisions

### D-01 — Edit Trigger
Tapping a task row opens a compact modal/bottom sheet that stays on top of the list.
Full-screen panel is not required — modal keeps the list visible behind it.

### D-02 — Edit Fields
Modal contains three fields:
- Title (LineEdit, required)
- Deadline date (LineEdit, text input format dd/mm/yyyy — type manually)
- Description (TextEdit, multiline, optional)

No tags field in this phase.

### D-03 — Deadline Input Format
User types the date as text: `dd/mm/yyyy` (e.g. `15/06/2026`).
Parse on confirm: split by `/`, convert to Unix timestamp via `Time.get_unix_time_from_datetime_dict()`.
If input is empty or invalid: deadline = 0 (no deadline).
Show current deadline pre-filled in the field when opening edit.

### D-04 — Reorder
Drag-to-reorder is DEFERRED — not in Phase 3.
Note in backlog for a future phase.

### D-05 — Save Behavior
On confirm: update task fields in-place, call `PersistenceManager.save_task(task)`,
refresh the task row display (call `set_task()` again on the existing row).
No full list reload needed — update the single row.

### D-06 — Edit vs Create
FAB modal (Phase 2) stays as-is for creation.
Tapping an existing row opens the edit modal (separate scene/dialog from FAB flow).
They can share structure but are distinct entry points.
</decisions>

<deferred_ideas>
## Deferred Ideas

- Drag-to-reorder rows within a group (user explicitly deferred to after Phase 3)
- Tag field in edit modal (not requested)
- Calendar grid picker (user chose text input instead)
</deferred_ideas>

<agent_discretion>
## Agent Discretion

- Modal styling: match Phase 2 dark theme, reuse AcceptDialog or build a custom Panel — agent decides
- Validation feedback: if title is empty on confirm, either shake the field or show a brief label — agent decides
- Deadline clear button: optionally add an "×" to clear the deadline field — agent decides
</agent_discretion>
