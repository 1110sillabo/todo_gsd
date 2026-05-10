## STATE.md

- Project Initialized: 2026-04-06
- Phase 1 complete (persistence + data layer)
- Phase 2 complete (TaskList UI, GroupSection, TaskRow, swipe gestures)
- Phase 3 complete (EditTaskDialog, tap-to-edit, SpinBox date picker, GdUnit4 tests)
- Phase 4 complete (Notes UI — scrollable list + modal editor + FAB, verified on device)
- Phase 5 in progress — Android export + mobile polish done ad-hoc (see 05-app-shell-export/05-00-ADHOC.md)

## Current Blockers
- None.

## Pending Verification
- None outstanding. FAB position verified on Galaxy A13 for both Tasks and Notes tabs.

## Decisions (locked)
- Deadline always required; SpinBox DD/MM/YYYY picker (no text field, no checkbox)
- New tasks prefill deadline with tomorrow's date
- FAB reuses EditTaskDialog (no separate inline dialog)
- Exit button: flat ✕ Button anchored top-right, last child of MainScene root (receives input after TabContainer)
- Viewport: 400×860, canvas_items stretch, portrait-only (`window/handheld/orientation=1` in project.godot + `screen/orientation=1` in export preset)
- Android architectures: armeabi-v7a + arm64-v8a (Galaxy A13 is 32-bit)
- FAB position: anchor 0.5/0.667 (center-x, 2/3 height) — responsive, works on any screen resolution
- ScrollContainer: anchor_bottom = 1.0, offset_bottom = -140 (ends before FAB)

## Known Pitfalls (lessons learned)

### FAB position broken on TaskListView after adding layout preset (2026-05-10)
**Symptom:** FAB appeared at top-left corner on Tasks tab but was correctly centered on Notes tab.
**Root cause:** Godot 4 uses the *parent scene's instance entry* for a node's layout, not the sub-scene's root node properties. When `TaskListView` was first instanced in Phase 2, no fill anchors existed. The stale values were baked into `main_scene.tscn`. Adding `layout_mode = 3` / `anchors_preset = 15` to the sub-scene root alone has no effect on an already-instanced node.
**Fix:** Two-layer approach:
  1. Explicitly add `layout_mode = 1`, `anchors_preset = 15`, `anchor_right = 1.0`, `anchor_bottom = 1.0` on the instance entry in `main_scene.tscn`.
  2. Call `set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)` at the top of `_ready()` in `task_list_view.gd` as a runtime guarantee.
**Pattern:** Any time a scene is re-anchored after already being instanced in a parent, the parent scene file must be updated too.

## Next Session
1. Export APK and run full smoke-test on device (Tasks + Notes tabs, FAB, edit dialogs)
2. Plan Phase 5: 3-dot menu + stats + JSON export stub

