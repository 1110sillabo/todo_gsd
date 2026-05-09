# Phase 2: Task List UI — Context

**Gathered:** 2026-05-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement the mobile-first main screen: a tab bar (Tasks / Notes / Stats-placeholder) and a
grouped task list with three collapsible sections (Expired, Todo, Completed).
Covers: tab bar shell, group headers with collapse, task rows, add-task flow, complete/delete
interaction, and basic persistence wiring (load on ready, save on change).

Does NOT cover: inline title editing, calendar date picker, reordering (Phase 3).
Does NOT cover: Notes tab content (Phase 4).
Does NOT cover: 3-dot menu (Phase 5).
</domain>

<decisions>
## Implementation Decisions

### D-01 — Task Row Layout
Two-line row layout (Todoist style):
- Line 1: Task title (bold, full width)
- Line 2: Deadline label in smaller text below the title
- If no deadline: Line 2 shows nothing (row collapses to single visible line)

### D-02 — Add Task Entry Point
Floating Action Button (FAB) in the bottom-right corner of the Tasks tab.
Standard mobile pattern — always visible, does not scroll with the list.

### D-03 — Complete / Delete Gesture
Prefer swipe gestures (swipe left → delete, swipe right → complete).
**Planner discretion:** If swipe gesture implementation in Godot 4.6 is too fragile or
complex for a reliable mobile experience, fall back to Option 3:
tapping the row opens a small action sheet (Complete / Edit / Delete buttons).
Do not implement a fragile swipe — a reliable action sheet is better than a broken swipe.

### D-04 — Group Header Style
Colored accent bar on the left edge + section label + item count + collapse chevron.
Each group has a distinct accent color:
- Expired: red/orange accent
- Todo: blue/neutral accent
- Completed: green/muted accent

### D-05 — New Task Creation Flow
Tapping the FAB opens a modal dialog/popup with:
- Text field: task title (required, auto-focused)
- Optional deadline picker (calendar icon — opens date picker inline or as sub-dialog)
- Confirm / Cancel buttons
On confirm: task is saved via PersistenceManager and row appears in Todo group.

### D-06 — Tab Bar
Three tabs: Tasks (active), Notes (placeholder — no content yet), Stats (placeholder).
Tabs use Godot's TabContainer or a custom HBoxContainer of buttons.
Mobile touch-friendly: each tab target ≥ 48dp height.

### D-07 — Completed Group Default State
Completed group starts collapsed (hidden) by default, matching revision.md spec.
Expired and Todo groups start expanded by default.

### Agent's Discretion
- Exact color palette and font sizes (mobile-readable, system defaults acceptable)
- Whether TabContainer or custom tab bar is used (planner decides based on Godot 4.6 best practice)
- Exact dialog widget for new-task modal (AcceptDialog, Window, or custom Panel)
- Whether group item count updates reactively or on reload
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Data Layer
- `src/resources/task_resource.gd` — TaskResource fields: title, description, deadline, completed_at, reschedule_count, tags
- `src/persistence/persistence_manager.gd` — save_task, load_task, list_tasks, delete_task methods

### Project Context
- `.planning/PROJECT.md` — Vision: mobile-first Todoist-style, Godot 4.6, .tres persistence
- `.planning/REQUIREMENTS.md` — R01–R11 (especially R01–R04, R09, R10)
- `.planning/ROADMAP.md` — Phase boundaries (what's in Phase 2 vs Phase 3–5)

### Revision Reference
- `.planning/revision.md` — Original UI spec from user (groups, row layout, menu)
</canonical_refs>

<specifics>
## Specific References

- Target feel: Todoist mobile app — clean rows, clear grouping, FAB for add
- Task groups in Italian labels per revision.md: "Scadute" (Expired), "Da fare" (Todo), "Completate" (Completed)
- Completed group hidden/collapsed by default
</specifics>

<deferred>
## Deferred Ideas

- Inline title editing on tap (Phase 3)
- Calendar date picker on existing tasks (Phase 3)
- Drag-to-reorder rows (Phase 3)
- Notes tab content (Phase 4)
- 3-dot menu / app shell (Phase 5)
- Reschedule changelog / counter display (Backlog R11)
</deferred>

---

*Phase: 02-taskbox*
*Context gathered: 2026-05-09 via gsd-discuss-phase*
