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
**Plans:** TBD

### Phase 3: Task Editing
**Goal:** Inline title edit, calendar date picker for deadline, drag-to-reorder rows.
**Requirements:** R03, R04
**Plans:** TBD

### Phase 4: Notes UI
**Goal:** Notes tab with scrollable list + tap-to-open full-screen text editor.
**Requirements:** R05, R06, R07, R10
**Plans:** TBD

### Phase 5: App Shell & Export
**Goal:** 3-dot menu (Send JSON stub, Stats stub, Quit), mobile polish, Android export test.
**Requirements:** R08, R09
**Plans:** TBD
