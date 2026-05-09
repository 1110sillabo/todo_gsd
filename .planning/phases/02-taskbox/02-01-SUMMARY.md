---
plan: 02-01
phase: 02-taskbox
status: complete
commit: 0f37a59
---

## Summary

Registered PersistenceManager as a Godot autoload singleton and fixed the filename collision bug.

## What Was Built

- Added `task_id: String` export to `TaskResource`. `_init()` auto-generates a unique ID using `"%d_%d" % [Time.get_ticks_msec(), randi()]` when the field is empty.
- Changed `PersistenceManager.save_task()` filename from `task.title.validate_filename()` to `task.task_id`, so two tasks with the same title produce separate `.tres` files.
- Added `[autoload]` section to `project.godot` with `PersistenceManager="*res://src/persistence/persistence_manager.gd"`.
- Renamed app from "Todo App on Steroids" to "GSD Todo".

## Key Files

### key-files.created
- src/resources/task_resource.gd (modified — task_id field added)
- src/persistence/persistence_manager.gd (modified — UUID filename)
- project.godot (modified — autoload + app name)

## Decisions

- Used `ticks_msec + randi()` for UUID generation (no crypto dependency, sufficient uniqueness for local app)
- `extends Node` kept as-is on PersistenceManager (correct for autoload singletons)
