# Phase 03 Plan 01 — SUMMARY

## What was built
`EditTaskDialog` — an `AcceptDialog` scene with three input fields (title, deadline, description) that pre-fills from a `TaskResource` and emits `task_saved` signal on confirm.

## Artifacts created
- `src/ui/task_edit_dialog.gd` — Dialog script with `show_for_task()`, `_on_confirmed()`, `task_saved` signal, static `parse_deadline()` and `format_deadline()` helpers
- `src/ui/task_edit_dialog.tscn` — AcceptDialog scene with `MarginContainer/VBoxContainer/{TitleEdit,DeadlineEdit,DescEdit}` nodes

## Key decisions / patterns
- Root node `type="AcceptDialog"` — script extends AcceptDialog directly, no wrapper node
- OK button disabled when title is empty (`get_ok_button().disabled`)
- `parse_deadline()` and `format_deadline()` are `static func` — callable without a scene instance, enabling GdUnit4 unit tests in plan 03-03
- Deadline format: `dd/mm/yyyy` (Italian locale per project conventions)
- Empty or invalid deadline text → returns 0 (no crash)

## Signals
- `task_saved(task: TaskResource)` — emitted by `_on_confirmed()` after mutating the task resource in-place

## Commit
`feat(03-01): EditTaskDialog scene with parse/format deadline helpers`
