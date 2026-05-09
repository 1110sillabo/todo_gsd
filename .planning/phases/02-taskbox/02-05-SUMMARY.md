---
plan: 02-05
phase: 02-taskbox
status: complete
commit: f8ecb31
---

## Summary

Added GdUnit4 tests for task categorization logic and TaskListView scene integration.

## What Was Built

- Extracted `categorize(task, now)` as a `static func` on `TaskListView` — makes the grouping logic unit-testable without a scene.
- `tests/unit/test_task_categorization.gd`: 4 tests covering completed/expired/no-deadline/future-deadline routing.
- `tests/unit/test_task_list_view.gd`: 4 SceneRunner tests — scene loads, completed group starts collapsed, todo group starts expanded, add_task increases count.

## Key Files

### key-files.created
- tests/unit/test_task_categorization.gd
- tests/unit/test_task_list_view.gd
