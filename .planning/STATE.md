## STATE.md

- Project Initialized: 2026-04-06
- Phase 1 complete (persistence + data layer)
- Phase 2 complete (TaskList UI, GroupSection, TaskRow, swipe gestures)
- Phase 3 complete (EditTaskDialog, tap-to-edit, SpinBox date picker, GdUnit4 tests)
- Phase 4 complete (Notes UI — scrollable list + modal editor + FAB, verified on device)
- Phase 5 in progress — Android export + mobile polish done ad-hoc (see 05-app-shell-export/05-00-ADHOC.md)
- Phase 6 ad-hoc work complete (UI polish, sorting, section toggle, Liste tab) — needs APK test

## Current Blockers
- None.

## Pending Verification
- Liste tab: create list, add items, toggle strikethrough, swipe-delete items, back nav, swipe-delete list — needs device test
- Section header collapse/expand (transparent Button overlay) — needs device test
- Scadute/Completate sort order — needs device test

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
1. Build APK and smoke-test on Galaxy A13: Tasks (sort + collapse), Notes, Liste tab
2. Fix orientation in export_presets.cfg if not set: add `screen/orientation=1` after `screen/immersive_mode=true` in `[preset.0.options]`
3. Investigate FAB scroll issue — finger swipe starting from near FAB doesn't scroll (mouse_filter=IGNORE on FAB may block scroll; try mouse_filter=PASS instead)
4. Investigate note content vertical scroll in NoteEditDialog

## Roadmap Evolution
- Phase 6 added: UI Polish & Bug Fixes (2026-05-17)

## Session 2 Summary (2026-05-17)
- Scadute section: sorted ascending by deadline (oldest overdue first)
- Completate section: sorted descending by completed_at (most recent first)
- GroupSection header: replaced `_input()` rect-check with transparent Button overlay (`HeaderTapArea`); removed chevron icon
- Liste tab added: ListResource + ListItemResource data model, full CRUD UI (lists-of-lists + detail view), strikethrough toggle via RichTextLabel BBCode
- notes_list_view.gd: scrollbar width set to 14px
- LEARNING_GODOT.md: sections 8 (scrollbar width), 9 (section toggle _input), 10 (transparent Button overlay)

