---
created: 2026-05-10 10:32:07
title: Center task add button and ensure view scrolling
area: ui
files:
  - src/ui/task_box.gd
  - src/ui/task_list_view.tscn
---

## Problem

The user wants the task add button (FAB) to be centered and to ensure that the task list view is properly scrollable. Currently, the FAB position and scrolling behavior need verification or adjustments as per the latest requirements.

## Solution

1. Adjust the position of the `AddButton` in `src/ui/task_box.gd` (or its scene) to be centered horizontally.
2. Verify and ensure the `ScrollContainer` in `src/ui/task_list_view.tscn` allows full scrolling through all task rows without being obstructed by the FAB.
