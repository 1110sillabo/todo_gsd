---
phase: 05-app-shell-export
plan: 01
subsystem: ui/export
tags: [menu, export, json, android, permissions]
dependency_graph:
  requires: [PersistenceManager autoload, TaskResource, NoteResource, ListResource, ListItemResource]
  provides: [_export_json(), MenuButton PopupMenu, todo_export.json]
  affects: [src/ui/main_scene.tscn, src/ui/main_scene.gd, export_presets.cfg]
tech_stack:
  added: [MenuButton, PopupMenu, AcceptDialog, FileAccess, JSON.stringify, OS.get_system_dir]
  patterns: [id_pressed signal, match dispatch, OS.has_feature platform branch]
key_files:
  modified:
    - src/ui/main_scene.tscn
    - src/ui/main_scene.gd
    - export_presets.cfg
decisions:
  - "item.title → JSON key 'text' to match documented output schema (ListItemResource uses title, not text)"
  - "layout_mode=0 for MenuButton (absolute top-left) vs layout_mode=1 for ExitButton (right-anchor)"
  - "MenuButton placed before ExitButton in scene tree to preserve ExitButton input priority"
metrics:
  duration: ~10min
  completed: 2026-05-24
  tasks_completed: 4
  files_modified: 3
---

# Phase 05 Plan 01: App Shell & Export — Summary

**One-liner:** Three-dot MenuButton added to MainScene header with PopupMenu dispatching JSON export to Downloads (Android) or user_data (desktop), confirmed via Italian AcceptDialog.

---

## What Was Implemented

### Task 1 — ListItemResource field confirmation (read-only)
Confirmed: `ListItemResource` exposes `item_id` (String), `title` (String), `checked` (bool).
The JSON serialization maps `item.title → "text"` to match the plan's documented output schema.

### Task 2 — MenuButton node in `main_scene.tscn`
- Added `[node name="MenuButton" type="MenuButton" parent="."]` as a direct child of the root `Control`, inserted **before** `ExitButton` in the scene text.
- Properties set: `layout_mode=0`, all anchors 0.0 (top-left), `offset_left=4`, `offset_top=4`, `offset_right=52`, `offset_bottom=52`, `custom_minimum_size=Vector2(48,48)`, `focus_mode=0`, `flat=true`, `text="⋮"`.

### Task 3 — `main_scene.gd` rewrite
Replaced the 7-line stub with the full implementation:
- `@onready var menu_button: MenuButton = $MenuButton`
- Three constants: `MENU_SEND_JSON=0`, `MENU_STATS=1`, `MENU_QUIT=2`
- `_ready()` builds the PopupMenu, disables Stats item, connects `id_pressed`
- `_on_menu_id_pressed(id)` dispatches to `_export_json()` or `get_tree().quit()`
- `_export_json()` reads all data via PersistenceManager, builds JSON payload, writes to Downloads (Android) or user_data (desktop), shows AcceptDialog
- `_unix_to_iso(unix)` returns null for 0, ISO string otherwise
- `_show_dialog(msg)` creates AcceptDialog, connects confirmed/canceled to queue_free

### Task 4 — `export_presets.cfg`
Changed `permissions/write_external_storage=false` → `permissions/write_external_storage=true`.

---

## Deviations from Plan

None — plan executed exactly as written. The `item.title → "text"` mapping was pre-noted in the plan's Task 1 note and followed correctly.

---

## Commit

| Hash | Message |
|------|---------|
| `dde6e36` | `feat(05): add ⋮ menu with JSON export to Downloads` |

---

## UAT Checklist (Manual)

Test on a physical Android device or the Godot editor (desktop fallback):

- [ ] **1. MenuButton visible** — On app launch, a `⋮` button appears in the top-left corner (≈48×48 px). It does not overlap the tab bar or the ✕ button.
- [ ] **2. Popup opens** — Tapping `⋮` opens a popup with exactly 3 items: "Send JSON", "Stats", "Quit".
- [ ] **3. Stats is greyed out** — The "Stats" item is visually disabled and cannot be tapped.
- [ ] **4. Quit works** — Tapping "Quit" exits the app (same behavior as ✕ button).
- [ ] **5. Send JSON — Android** — Tapping "Send JSON" on an Android device writes `todo_export.json` to the Downloads folder and shows an Italian dialog: *"Salvato in Download/todo_export.json"*.
- [ ] **6. Send JSON — Desktop** — Tapping "Send JSON" in the Godot editor writes `todo_export.json` to `user://` (displayed as the full path) and shows the confirmation dialog.
- [ ] **7. JSON content** — Open `todo_export.json` and verify: `exported_at` is an ISO timestamp; `tasks`, `notes`, `lists` arrays are present; each task has `id`, `title`, `description`, `created_at`, `deadline`, `completed_at`, `reschedule_count`, `tags`; each note has `title`, `content`, `created_at`; each list has `id`, `title`, `created_at`, `items` (with `text` and `checked`); zero-value timestamps are `null`.
- [ ] **8. Empty data** — With no data saved, Send JSON writes a valid JSON file with empty arrays (no crash).

---

## Known Stubs

- **Stats menu item** — `MENU_STATS` is intentionally disabled. No implementation. Tracked for a future phase.

## Self-Check: PASSED

- `src/ui/main_scene.tscn` — MenuButton node present before ExitButton ✓
- `src/ui/main_scene.gd` — full script with all functions ✓
- `export_presets.cfg` — `write_external_storage=true` ✓
- Commit `dde6e36` exists ✓
