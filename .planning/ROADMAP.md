## ROADMAP.md

### Phase 1: Data Layer (Resource definitions & Persistence)
**Goal:** Clean data schema for Tasks and Notes with robust persistence.
**Plans:** 3 plans
Plans:
- [x] 01-01-01-SUMMARY.md — TaskResource data model & GdUnit4 setup
- [x] 01-01-02-SUMMARY.md — PersistenceManager (Save/Load with .tres)
- [ ] 01-03-PLAN.md — Data layer patch: remove graph_position, add NoteResource, fix persistence bugs

### Phase 2: Task List UI
**Goal:** Mobile-first tab bar + grouped task list (Expired/Todo/Completed) with collapse/expand and row add/complete/delete.
**Requirements:** R01, R02, R03, R04, R09, R10, R11
**Plans:** 5 plans
Plans:
- [x] 02-01-PLAN.md — PersistenceManager autoload + UUID filenames
- [x] 02-02-PLAN.md — TaskRow scene (2-line layout, swipe detection)
- [x] 02-03-PLAN.md — GroupSection scene (collapsible, accent header)
- [x] 02-04-PLAN.md — MainScene + TaskListView (full wiring, FAB, modal)
- [x] 02-05-PLAN.md — GdUnit4 tests (categorization + scene integration)

### Phase 3: Task Editing
**Goal:** Tapping a task row opens a compact edit modal (title, deadline text dd/mm/yyyy, description). Saves in-place without full list reload.
**Requirements:** R03, R04
**Plans:** 3 plans

Plans:
- [x] 03-01-PLAN.md — EditTaskDialog scene (AcceptDialog + 3 input fields, deadline parse/format)
- [x] 03-02-PLAN.md — Tap detection in TaskRow + wiring in TaskListView (save in-place, recategorize)
- [x] 03-03-PLAN.md — GdUnit4 tests for deadline parsing and formatting

### Phase 4: Notes UI
**Goal:** Notes tab with scrollable list + tap-to-open full-screen text editor.
**Requirements:** R05, R06, R07, R10
**Plans:** TBD

### Phase 5: App Shell & Export
**Goal:** 3-dot menu (Send JSON stub, Stats stub, Quit), mobile polish, Android export test.
**Requirements:** R08, R09
**Plans:** TBD
