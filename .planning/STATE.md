## STATE.md

- Project Initialized: 2026-04-06
- Phase 1 complete (persistence + data layer)
- Phase 2 complete (TaskList UI, GroupSection, TaskRow, swipe gestures)
- Phase 3 complete (EditTaskDialog, tap-to-edit, SpinBox date picker, GdUnit4 tests)
- Phase 4 not started (Notes UI)
- Phase 5 in progress — Android export work done ad-hoc (see 05-app-shell-export/05-00-ADHOC.md)

## Current Blockers
- Android orientation is still landscape on device despite `project.godot` having `window/handheld/orientation=1`.
  Root cause: `export_presets.cfg` lacked `screen/orientation=1` key — Godot writes the AndroidManifest only from the export preset, not project.godot. Added in session on 2026-05-09. Needs re-export + test to confirm.

## Decisions (locked)
- Deadline always required; SpinBox DD/MM/YYYY picker (no text field, no checkbox)
- New tasks prefill deadline with tomorrow's date
- FAB reuses EditTaskDialog (no separate inline dialog)
- Exit button: flat ✕ Button anchored top-right, last child of MainScene root (receives input after TabContainer)
- Viewport: 400×860, canvas_items stretch, portrait-only (`window/handheld/orientation=1`)
- Android architectures: armeabi-v7a + arm64-v8a (Galaxy A13 is 32-bit)

