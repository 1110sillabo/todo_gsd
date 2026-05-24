# Phase 05 — Context (App Shell & Export)

**Created:** 2026-05-24  
**Updated:** 2026-05-24 — simplified Send JSON to file-write only (no plugin)  
**Phase goal:** 3-dot menu (⋮) + export JSON to Downloads folder + Stats/Quit stubs

---

## Decisions

### 3-dot menu (⋮)
- Implemented as a **Godot `PopupMenu`** — standard dropdown, appears below the trigger button
- Trigger: top-right Button with text "⋮" (or MenuButton), placed in MainScene alongside the existing ✕ ExitButton
- Menu items:
  1. **Send JSON** — calls the share logic
  2. **Stats** — **disabled/grayed out** (no action, placeholder)
  3. **Quit** — calls `get_tree().quit()` (same as ✕ button, no confirm dialog)

### Send JSON — scope
- Exports **all app data**: tasks + notes + lists (ListResource + ListItemResource)
- Output: a single `todo_export.json` file
- Structure (agent's discretion for exact schema, but should be human-readable)

### Send JSON — method (SIMPLIFIED — no plugin)
- **Write file to Android Downloads folder**, then show a confirmation dialog
- Flow:
  1. Serialize all data → JSON string
  2. Resolve output path:
     - On Android: `OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/todo_export.json"`
     - On desktop (editor): `OS.get_user_data_dir() + "/todo_export.json"` (fallback for testing)
  3. Write the file via `FileAccess`
  4. Show an `AcceptDialog`: "Saved to Downloads/todo_export.json"
- **No plugin required.** No custom build required.
- **WRITE_EXTERNAL_STORAGE** permission must be enabled in export preset (for Android < 10 compatibility)
- User then opens Android file manager or any app to find and share the file manually
- **Future phase:** add native share sheet on top of this file-write foundation

### Stats
- Menu item present but **disabled** (`set_item_disabled(index, true)` on the PopupMenu)
- No dialog, no navigation — the item simply cannot be clicked

### Quit
- Calls `get_tree().quit()` directly
- No confirm dialog

---

## Prior context (locked)

- Exit button (✕) already in MainScene top-right — 3-dot menu must coexist without collision
- Viewport 400×860, canvas_items stretch, portrait-only
- PersistenceManager is an autoload singleton that manages all save/load
- Android architectures: armeabi-v7a + arm64-v8a (Galaxy A13 is 32-bit)

---

## Open questions for researcher

1. Does `OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)` work correctly on Android in Godot 4.6?
2. Is `WRITE_EXTERNAL_STORAGE` still needed for Android 10+ (API 29+) when writing to Downloads?
3. How does PersistenceManager currently serialize tasks/notes/lists — does it expose a method to dump all data, or must main_scene collect resources and serialize manually?

---

## Out of scope (deferred)

- GodotShare plugin / native share sheet — future phase on top of this foundation
- iOS
- Selective export (user chooses tasks/notes/all)
- Real Stats screen
