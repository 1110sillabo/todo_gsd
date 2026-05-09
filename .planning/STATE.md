## STATE.md

- Project Initialized: 2026-04-06
- Phase 1 complete (persistence + data layer)
- Phase 2 complete (TaskList UI, GroupSection, TaskRow, swipe gestures)
- Phase 3 complete (EditTaskDialog, tap-to-edit, SpinBox date picker, GdUnit4 tests)
- Phase 4 not started (Notes UI)
- Phase 5 in progress — Android export + mobile polish done ad-hoc (see 05-app-shell-export/05-00-ADHOC.md)

## Current Blockers
- None blocking. All known issues resolved in session 2026-05-09. Needs re-export + on-device verification.

## Pending Verification (re-export APK and test)
- Portrait orientation now set via `screen/orientation=1` in export_presets.cfg (fixed root cause: manifest comes from preset, not project.godot)
- FAB visible at bottom-center, 140px above screen bottom
- Tab headings lowered 56px (status bar clearance)
- Font sizes increased (task title 22px, deadline 17px, group headers 20px)
- Scroll works through task rows (vertical drags no longer consumed by TaskRow swipe handler)
- ScrollContainer ends above FAB (no overlap)

## Decisions (locked)
- Deadline always required; SpinBox DD/MM/YYYY picker (no text field, no checkbox)
- New tasks prefill deadline with tomorrow's date
- FAB reuses EditTaskDialog (no separate inline dialog)
- Exit button: flat ✕ Button anchored top-right, last child of MainScene root (receives input after TabContainer)
- Viewport: 400×860, canvas_items stretch, portrait-only (`window/handheld/orientation=1` in project.godot + `screen/orientation=1` in export preset)
- Android architectures: armeabi-v7a + arm64-v8a (Galaxy A13 is 32-bit)
- FAB position: bottom-center, offset_bottom=-140 (above nav bar)
- ScrollContainer height: ends at offset_bottom=-140 (matches FAB top, prevents overlap)

## Next Session
1. Re-export APK and verify on device: portrait, FAB visible, scroll works
2. Fine-tune FAB/font sizes if needed
3. Start Phase 4: Notes UI

