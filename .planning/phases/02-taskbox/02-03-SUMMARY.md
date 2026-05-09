---
plan: 02-03
phase: 02-taskbox
status: complete
commit: eeb2cca
---

## Summary

Created the GroupSection collapsible scene with colored left-accent header.

## What Was Built

- `src/ui/group_section.tscn`: VBoxContainer → HeaderPanel (48px min) → HeaderHBox → GroupLabel + CountLabel + Spacer + ChevronLabel; + ItemsContainer (VBoxContainer).
- `src/ui/group_section.gd`: Extends VBoxContainer. `setup(label, accent_color, starts_expanded)` applies StyleBoxFlat with `border_width_left = 4` in the accent color. `add_task()` instantiates TaskRow, wires signals, updates count. `remove_task()` / `clear()` clean up children. Tap on HeaderPanel toggles `ItemsContainer.visible` and swaps chevron ▾/▸. Signals `task_completed` and `task_deleted` bubble up from TaskRow children.

## Key Files

### key-files.created
- src/ui/group_section.gd
- src/ui/group_section.tscn
