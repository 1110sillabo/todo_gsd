---
created: 2026-05-10 10:51:29
phase: 4
title: Notes UI
status: locked
---

# 04-CONTEXT.md

## Decisions

### 1. Note Selection & Performance
- **Decision:** Standard VBox scroll (starting simpler, lazy loading deferred if needed).
- **Rationale:** Codebase already uses `TaskListView` with a `VBoxContainer` inside a `ScrollContainer`. We will stick to this pattern for consistency unless performance becomes an issue.

### 2. Editor Experience
- **Decision:** Modal dialog (consistent with Tasks).
- **Rationale:** Reuse the `AcceptDialog` pattern from Phase 3 (`TaskEditDialog`) for a unified user experience. The dialog will feature a `LineEdit` for the title and a `TextEdit` for the content.

### 3. Visual Style
- **Decision:** Compact rows (Title only).
- **Rationale:** Maximum information density. Each row will show the note title and potentially a small timestamp.

## Scope Guardrails
- **In-Scope:** Notes list view, `NoteRow` component, `NoteEditDialog`, integration into `MainScene`'s "Note" tab, persistence wiring.
- **Out-of-Scope:** Folders, tags, search, rich text editing, attachments.

## Next Steps
1. **Research:** Investigate `TextEdit` scroll behavior and signal wiring for `NoteEditDialog`.
2. **Planning:** Create task breakdown for the `NoteRow` and `NoteEditDialog` scenes.
