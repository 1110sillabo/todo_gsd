---
plan: 02-04
phase: 02-taskbox
status: complete
commit: fc219b9
---

## Summary

Wired everything together: MainScene with TabContainer, TaskListView with three GroupSections, FAB modal, and full complete/delete flow.

## What Was Built

- `src/ui/main_scene.tscn` + `main_scene.gd`: Root Control with TabContainer. Tabs: "Da fare", "Note", "Stats" (Stats disabled via `set_tab_disabled(2, true)`). Registered as `run/main_scene` in project.godot.
- `src/ui/task_list_view.tscn` + `task_list_view.gd`: Three GroupSection instances (Expired/Todo/Completed), FAB Button anchored bottom-right. `_ready()` calls `setup()` on each group with Italian labels and accent colors, connects signals, calls `_load_tasks()`.
- `_load_tasks()`: Reads all `.tres` from PersistenceManager, routes each task to the correct group by checking `completed_at > 0` → Completate, `deadline < now` → Scadute, else → Da fare.
- FAB → AcceptDialog modal → `_create_task()` saves and adds to Da fare.
- Swipe/drag right → `mark_complete()` + save + move to Completate. Swipe/drag left → delete from disk + remove row.

## Fixes Applied During Execution

- `class_name PersistenceManager` removed — conflicts with autoload singleton name
- `delta_x`/`delta_y` given explicit `float` types — Godot 4.6 type inference limitation
- `.tscn` instancing format fixed: removed `type="Control"` from instanced nodes
- Added `InputEventMouseButton`/`InputEventMouseMotion` fallback in TaskRow for desktop testing

## Key Files

### key-files.created
- src/ui/main_scene.gd
- src/ui/main_scene.tscn
- src/ui/task_list_view.gd
- src/ui/task_list_view.tscn

## User Verification

Checkpoint approved by user. Tabs visible, FAB works, tasks persist across restarts, swipe/drag complete and delete confirmed working on desktop.
