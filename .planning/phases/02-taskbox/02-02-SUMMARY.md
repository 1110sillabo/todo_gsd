---
plan: 02-02
phase: 02-taskbox
status: complete
commit: 420281a
---

## Summary

Created the reusable TaskRow scene — the atomic unit of the task list.

## What Was Built

- `src/ui/task_row.tscn`: PanelContainer (56px min height) → MarginContainer → VBoxContainer → TitleLabel (16px) + DeadlineLabel (13px, muted gray). Dark background `Color(0.10, 0.10, 0.12)`, corner radius 4.
- `src/ui/task_row.gd`: Extends PanelContainer. `set_task()` populates labels; formats deadline as `dd/mm/yyyy`; colors expired deadlines red `Color(0.85, 0.25, 0.18)`; hides label when no deadline. `_gui_input()` detects horizontal swipes > 80px with 1.5x X/Y ratio — right emits `task_completed`, left emits `task_deleted`.

## Key Files

### key-files.created
- src/ui/task_row.gd
- src/ui/task_row.tscn
