# Phase 05 Research: App Shell & Export

**Researched:** 2026-05-24  
**Domain:** Godot 4.6 GDScript — PopupMenu, Android plugin, JSON serialization  
**Confidence:** HIGH (plugin API verified from GitHub releases; GDScript APIs from Godot docs patterns; codebase read directly)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- 3-dot menu implemented as `PopupMenu` — standard dropdown, appears below the trigger button
- Trigger: top-right Button with text "⋮" (or MenuButton) placed in MainScene alongside existing ✕ ExitButton
- Menu items: 1) Send JSON — calls share logic; 2) Stats — disabled/grayed out; 3) Quit — `get_tree().quit()`
- Send JSON exports all app data: tasks + notes + lists (ListResource + ListItemResource)
- Output: a single `.json` file
- Serialize via PersistenceManager → JSON string
- Save to `user://gsd_export.json` (temp file)
- Convert path via `ProjectSettings.globalize_path()`
- Call `share.shareFile(absolute_path, title, message)` on plugin singleton
- Fallback: `AcceptDialog` with "Sharing requires Android build." if singleton not found
- Stats: disabled (cannot be clicked)
- Quit: `get_tree().quit()` directly
- Platform: Android only

### Agent's Discretion
- MenuButton vs Button + PopupMenu child — which is simpler

### Deferred Ideas (OUT OF SCOPE)
- Stats functionality
- iOS share
- Any export format other than JSON
</user_constraints>

---

## GodotShare Plugin

### Version & Repository

**Canonical repo (as of 2026):** `godot-mobile-plugins/godot-share`  
https://github.com/godot-mobile-plugins/godot-share  
[VERIFIED: GitHub releases page, fetched 2026-05-24]

> ⚠️ Repo history: originally `Shin-NiL/Godot-Android-Share-Plugin` → `cengiz-pz/godot-android-share-plugin` (archived Feb 2026) → `godot-sdk-integrations/godot-share` → **current: `godot-mobile-plugins/godot-share`**

| Version | Release Date | Godot Tested Against | Notes |
|---------|-------------|----------------------|-------|
| **v5.2** | Feb 8, 2026 | **4.6** ✅ | Current latest — use this |
| v5.1.1 | Jan 15, 2026 | 4.5.1 | |
| v5.1 | Nov 19, 2025 | 4.5.1 | |
| v5.0 | Jul 26, 2025 | 4.5 | |

**Download for this project:** `SharePlugin-Android-v5.2.zip` (23.4 KB)  
Direct: https://github.com/godot-mobile-plugins/godot-share/releases/download/v5.2/SharePlugin-Android-v5.2.zip  
AssetLib: https://godotengine.org/asset-library/asset/2542

### ⚠️ API Breaking Change vs CONTEXT.md

The CONTEXT.md specifies the **old Shin-NiL API** (`Engine.get_singleton("GodotShare")` + `shareFile()`). **v5.x uses a different unified node-based interface.** Planner must adapt the locked decision to the real API.

| | Old API (Shin-NiL / v4 cengiz-pz) | **New API (v5.2)** |
|---|---|---|
| Access pattern | `Engine.get_singleton("GodotShare")` | `$Share` node (child of scene) |
| Share file | `share.shareFile(path, title, msg)` | `share_node.share_file(path, mime_type, title, subject, content)` |
| Singleton name | `"GodotShare"` | No singleton — node only |

**Recommendation:** Use the v5.2 node API. Update the fallback guard to check `ClassDB.class_exists("Share")` or simply `if share_node != null`. See File Sharing Flow section.

### Plugin File Structure

After unzipping `SharePlugin-Android-v5.2.zip` to the project root, expect:
```
addons/
  share/
    plugin.cfg           ← Godot plugin descriptor
    src/
      share.gd           ← The Share node GDScript class
      icon.png
    config/
      ...
android/
  plugins/
    share/
      SharePlugin.gdap   ← Android plugin manifest
      SharePlugin.aar    ← Compiled Java library
```
[ASSUMED — based on zip size and v5.x structure from repo tree; exact paths confirmed from repo directory listing showing `addon/` and `android/` at root]

### .gdap Structure (Android Plugin Manifest)

```ini
[config]
name="SharePlugin"
binary_type="local"
binary="SharePlugin.aar"

[dependencies]
custom_maven_deps=[]
```
[ASSUMED — based on standard Godot 4 Android plugin manifest format; specific contents may differ]

### Installation Steps

1. **Set up Custom Gradle Build** (required by all Android plugins):
   - Editor: Project → Export → Android preset → Options → Gradle Build
   - Check **Use Gradle Build**
   - Click "Install Android Build Template" if the `android/` directory doesn't exist yet
   - OR manually: set `gradle_build/use_gradle_build=true` in `export_presets.cfg`

2. **Download and extract plugin:**
   ```
   Download SharePlugin-Android-v5.2.zip
   Unzip contents into project root (not into a subdirectory)
   ```

3. **Enable plugin:**
   - Editor: Project → Project Settings → Plugins
   - Find "Share" → Enable

4. **Fix package name** (required — plugin breaks with `$genname`):
   - Editor: Project → Export → Android → Package → Unique Name
   - Change `com.example.$genname` to a real name, e.g. `com.yourname.gsdtodo`
   - Or in `export_presets.cfg`: `package/unique_name="com.yourname.gsdtodo"`

### Custom Build Requirement

**YES — Custom Build (Gradle) is mandatory.** The plugin ships a `.aar` file (compiled Java) that must be compiled into the APK. Regular export (without Gradle) cannot include `.aar` dependencies. [VERIFIED: Plugin README states "Create custom Android gradle build" as prerequisite]

---

## PopupMenu Implementation

### MenuButton vs Button + PopupMenu

**Recommendation: Use `MenuButton`** — it is purpose-built for this exact use case.

| | `MenuButton` | `Button` + `PopupMenu` child |
|---|---|---|
| Built-in popup | ✅ `get_popup()` returns its `PopupMenu` | Manual: add `PopupMenu` child, call `popup()` |
| Auto-positioning | ✅ Opens below the button automatically | Manual: calculate position from button rect |
| Signal | `MenuButton` has `about_to_popup` | `PopupMenu` has `id_pressed` |
| Simplicity | **Simpler** | More code needed |

`MenuButton` is the correct node type for a ⋮ button. It renders identically to a `Button` in the scene tree but adds a `PopupMenu` automatically.

### GDScript Pattern — MenuButton

```gdscript
# In main_scene.gd — @onready declarations
@onready var menu_button: MenuButton = $MenuButton
@onready var popup_menu: PopupMenu = $MenuButton.get_popup()

# IDs for menu items (use constants, not magic numbers)
const MENU_SEND_JSON = 0
const MENU_STATS = 1
const MENU_QUIT = 2

func _ready() -> void:
    # Existing code...
    tab_container.set_tab_disabled(3, true)
    exit_button.pressed.connect(func(): get_tree().quit())

    # Build the menu
    popup_menu.add_item("Send JSON", MENU_SEND_JSON)
    popup_menu.add_item("Stats", MENU_STATS)
    popup_menu.add_item("Quit", MENU_QUIT)

    # Disable Stats (index 1, not ID 1 — but they're equal here)
    popup_menu.set_item_disabled(1, true)

    # Wire signal — id_pressed fires with the ID passed to add_item()
    popup_menu.id_pressed.connect(_on_menu_item_pressed)

func _on_menu_item_pressed(id: int) -> void:
    match id:
        MENU_SEND_JSON:
            _send_json()
        MENU_QUIT:
            get_tree().quit()
        # MENU_STATS: disabled — will never fire
```
[ASSUMED — based on Godot 4 PopupMenu API from training knowledge; signal name `id_pressed` is standard Godot 4 PopupMenu API]

### ⚠️ Critical API Detail: `id_pressed` not `item_pressed`

In Godot 4, `PopupMenu` emits **`id_pressed(id: int)`** — not `item_pressed`. The `id` is the value passed as the second argument to `add_item(text, id)`. If you use `add_item("text")` without an id, Godot auto-assigns sequential IDs.

### Disabling a Menu Item

```gdscript
# By index (0-based position in menu)
popup_menu.set_item_disabled(1, true)   # disables index 1 (Stats)

# Verify it's grayed out:
# Disabled items show grayed text and do NOT emit id_pressed when clicked
```

### MenuButton Positioning in Scene

Place `MenuButton` in `MainScene` (sibling of `ExitButton`). In the `.tscn`, anchor it to top-right similar to `ExitButton` but offset to the left of it.

Looking at current `ExitButton` in `main_scene.tscn`:
```
offset_left = -52, offset_right = -4, offset_top = 4, offset_bottom = 40
```

For `MenuButton` (⋮), place it to the left of ExitButton:
```
anchor_left = 1.0, anchor_right = 1.0
offset_left = -100, offset_right = -56   # 4px gap from ExitButton
offset_top = 4, offset_bottom = 40
z_index = 10
text = "⋮"
flat = true
```

---

## JSON Serialization Strategy

### Current State of PersistenceManager

**PersistenceManager has NO existing JSON serialization.** It saves/loads `.tres` resource files only. Custom serialization logic is required. [VERIFIED: read `persistence_manager.gd` directly]

The existing API:
- `list_tasks()` → `Array[String]` of filenames
- `load_task(filename)` → `TaskResource`
- `list_notes()` → `Array[String]` of filenames
- `load_note(filename)` → `NoteResource`
- `list_lists()` → `Array[String]` of filenames
- `load_list(filename)` → `ListResource`

### Resource Properties to Serialize

**TaskResource** (`@export` fields):
```
task_id, title, description, created_at (int), deadline (int),
completed_at (int), reschedule_count (int), tags (Array[String])
```

**NoteResource** (`@export` fields):
```
title, content, created_at (int)
```

**ListResource** (`@export` fields):
```
list_id, title, created_at (int), items (Array[ListItemResource])
```

**ListItemResource** (`@export` fields):
```
item_id, title, checked (bool)
```

### Serialization Approach — Hand-rolled dictionaries

Since `ResourceSaver` writes binary/text `.tres` files (not JSON), use manual property-to-dict mapping:

```gdscript
# In main_scene.gd (or a dedicated helper)
func _serialize_all_data() -> Dictionary:
    var pm: PersistenceManager = PersistenceManager.new()

    # Tasks
    var tasks_array := []
    for fname in pm.list_tasks():
        var task: TaskResource = pm.load_task(fname)
        if task:
            tasks_array.append({
                "task_id": task.task_id,
                "title": task.title,
                "description": task.description,
                "created_at": task.created_at,
                "deadline": task.deadline,
                "completed_at": task.completed_at,
                "reschedule_count": task.reschedule_count,
                "tags": task.tags
            })

    # Notes
    var notes_array := []
    for fname in pm.list_notes():
        var note: NoteResource = pm.load_note(fname)
        if note:
            notes_array.append({
                "title": note.title,
                "content": note.content,
                "created_at": note.created_at
            })

    # Lists
    var lists_array := []
    for fname in pm.list_lists():
        var lst: ListResource = pm.load_list(fname)
        if lst:
            var items_array := []
            for item: ListItemResource in lst.items:
                items_array.append({
                    "item_id": item.item_id,
                    "title": item.title,
                    "checked": item.checked
                })
            lists_array.append({
                "list_id": lst.list_id,
                "title": lst.title,
                "created_at": lst.created_at,
                "items": items_array
            })

    return {
        "exported_at": Time.get_datetime_string_from_system(),
        "tasks": tasks_array,
        "notes": notes_array,
        "lists": lists_array
    }
```

### PersistenceManager Access Pattern

`PersistenceManager` is a plain `Node` (not an Autoload). It must be instantiated with `PersistenceManager.new()` or found in the scene tree. Prefer `PersistenceManager.new()` since main_scene.gd doesn't hold a reference to one. [VERIFIED: `persistence_manager.gd` uses `extends Node`; no autoload found in project]

---

## File Sharing Flow (Android)

### Complete GDScript — Write + Share

```gdscript
# Node reference — add Share node as child of MainScene
@onready var share_node = $Share   # type: Share (from addon)

func _send_json() -> void:
    # 1. Collect and serialize all data
    var data: Dictionary = _serialize_all_data()
    var json_string: String = JSON.stringify(data, "\t")

    # 2. Write to temp file in user:// (required for Android FileProvider access)
    const EXPORT_PATH: String = "user://gsd_export.json"
    var file := FileAccess.open(EXPORT_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open export file: %s" % FileAccess.get_open_error())
        return
    file.store_string(json_string)
    file.close()

    # 3. Globalize the path (user:// → absolute OS path)
    var absolute_path: String = ProjectSettings.globalize_path(EXPORT_PATH)

    # 4. Share via plugin (v5.2 node API)
    if share_node != null:
        share_node.share_file(
            absolute_path,
            "application/json",   # MIME type
            "GSD Todo Export",    # title (shown in Android share sheet)
            "GSD Export",         # subject (used by email clients)
            "Exported GSD Todo data"  # content (body text)
        )
    else:
        # Fallback: inform user sharing requires Android
        var dialog := AcceptDialog.new()
        add_child(dialog)
        dialog.title = "Sharing unavailable"
        dialog.dialog_text = "Sharing requires Android build."
        dialog.popup_centered()
```

### v5.2 API — `share_file` Signature

```gdscript
share_file(
    a_path: String,        # absolute path — use ProjectSettings.globalize_path()
    a_mime_type: String,   # "application/json" for .json files
    a_title: String,       # share sheet title
    a_subject: String,     # email subject (optional context)
    a_content: String      # message body
)
```
[VERIFIED: from godot-mobile-plugins/godot-share README, Methods section]

### Adding Share Node to Scene

In `main_scene.tscn`, add a `Share` node as a child of `MainScene`. In GDScript, add `@onready var share_node = $Share`.

Alternatively, create it at runtime:
```gdscript
var share_node = null

func _ready() -> void:
    # Try to instantiate Share node from the addon
    if ClassDB.class_exists("Share"):
        share_node = ClassDB.instantiate("Share")
        add_child(share_node)
```
This runtime approach avoids `.tscn` coupling but is less idiomatic. **Recommendation: add `Share` to scene tree in the `.tscn`** for clarity.

### Android Scoped Storage / FileProvider

The plugin handles `FileProvider` registration internally for Android API 24+. Writing to `user://` and passing the globalized path is sufficient — the plugin wraps the path in a `FileProvider` URI when constructing the Intent. [VERIFIED: godot-mobile-plugins/godot-share README, Scoped Storage note from prior GODOT_mobile_export.md research]

---

## Key Risks

### Risk 1: Custom Build not set up (BLOCKER)
**What:** Export preset has `gradle_build/use_gradle_build=false`. The Share plugin requires Gradle build. Without it, the plugin's `.aar` is ignored and `$Share` node won't exist at runtime.  
**Mitigation:** Wave 0 task: set `use_gradle_build=true` and run "Install Android Build Template."

### Risk 2: Package name still uses `$genname` (BLOCKER)
**What:** Current `export_presets.cfg` has `package/unique_name="com.example.$genname"`. This token is not replaced by the Godot exporter and breaks the Gradle build when a plugin is involved.  
**Mitigation:** Must change to a real reverse-domain package name before testing. Task: update `export_presets.cfg`.

### Risk 3: API mismatch — CONTEXT.md uses old Shin-NiL API
**What:** CONTEXT.md specifies `Engine.get_singleton("GodotShare")` and `share.shareFile(absolute_path, title, message)`. v5.2 uses a **Share node** with `share_file(path, mime_type, title, subject, content)`.  
**Mitigation:** Planner must implement the v5.2 node API. The fallback guard changes from `Engine.has_singleton("GodotShare")` to a null-check on the `$Share` node or `ClassDB.class_exists("Share")`.

### Risk 4: Share node not available at runtime on desktop/PC
**What:** On non-Android platforms, the `Share` class may not be registered, so `$Share` would cause an error loading the scene.  
**Mitigation:** Add `Share` node conditionally (runtime instantiation via `ClassDB.class_exists("Share")`) OR suppress the error with `@tool` and scene-level guards. The fallback dialog path already handles this gracefully.

### Risk 5: `id_pressed` vs `item_pressed` signal name
**What:** Connecting to wrong signal name silently fails in GDScript (error in output but no crash).  
**Mitigation:** Use `id_pressed` — the correct signal name in Godot 4 `PopupMenu`.

### Risk 6: PersistenceManager has no `load_all_*` method
**What:** Must iterate `list_*()` → `load_*(filename)` per resource. No bulk load. If files are corrupt, `load_task()` returns null.  
**Mitigation:** Add null checks in the serialization loop (shown in code above).

---

## Recommended Approach

### 1. Plugin: Use godot-mobile-plugins/godot-share v5.2

Download `SharePlugin-Android-v5.2.zip`. This is the only version tested with Godot 4.6.

### 2. MenuButton (not Button + PopupMenu)

Use `MenuButton` with `flat = true` and text `"⋮"`. It handles popup positioning automatically. Access its `PopupMenu` via `get_popup()`. Wire `id_pressed` signal.

### 3. Share node: add to scene tree in .tscn

Add a `Share` node as a child of `MainScene` in `main_scene.tscn`. Guard all share calls with a null check. On non-Android builds the node will be absent; show `AcceptDialog` fallback.

### 4. JSON serialization: hand-rolled dict in main_scene.gd

No changes to `PersistenceManager` needed. Build a `_serialize_all_data()` method in `main_scene.gd` that instantiates `PersistenceManager.new()`, iterates all three collections, and returns a `Dictionary` for `JSON.stringify()`.

### 5. Export preset changes (required before any Android test)

```ini
# In export_presets.cfg, under [preset.0.options]:
gradle_build/use_gradle_build=true
package/unique_name="com.yourname.gsdtodo"   # replace $genname
```

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | GdUnit4 (detected in `addons/gdUnit4/`) |
| Config file | `addons/gdUnit4/plugin.cfg` |
| Quick run | Run single test file in Godot Editor |
| Full suite | Run all tests via GdUnit4 test runner |

### Phase Requirements → Test Map

| Req | Behavior | Test Type | Automated? |
|-----|----------|-----------|------------|
| Menu opens | ⋮ button click → PopupMenu appears | Manual/integration | Manual — requires UI interaction |
| Stats disabled | Stats item grayed, `id_pressed` not emitted | Unit | `test_stats_item_disabled.gd` — check `popup_menu.is_item_disabled(1)` |
| Quit works | Menu Quit → `get_tree().quit()` | Manual | Manual — can't unit-test quit() |
| Serialize all data | `_serialize_all_data()` returns valid structure | Unit | `test_app_shell_serialization.gd` |
| JSON file written | `user://gsd_export.json` created with valid JSON | Integration | `test_app_shell_json_export.gd` |
| Fallback dialog | No Share node → AcceptDialog shown | Unit | `test_app_shell_share_fallback.gd` |

### Wave 0 Gaps (test files to create)

- [ ] `tests/unit/test_app_shell_serialization.gd` — covers JSON serialization logic
- [ ] `tests/unit/test_app_shell_share_fallback.gd` — covers no-plugin fallback path

---

## Open Questions

1. **Will `Share` node cause scene load error on desktop?**  
   - What we know: On Android the Share plugin registers the class. On desktop it likely doesn't.  
   - What's unclear: Does Godot 4.6 error on `[node type="Share"]` in `.tscn` when the class is unregistered, or does it degrade gracefully?  
   - Recommendation: Use runtime instantiation (`ClassDB.class_exists("Share")`) rather than baking into `.tscn` to avoid desktop editor errors.

2. **Does the Gradle build template need to be re-installed if it already existed?**  
   - What we know: The current project has no `android/` directory — Gradle template has never been installed.  
   - What's unclear: n/a — first install needed.  
   - Recommendation: Task "Install Android Build Template" via Editor is required.

3. **Plugin version compatibility with Godot 4.6 dev vs stable?**  
   - What we know: v5.2 says "tested against Godot 4.6."  
   - What's unclear: Whether 4.6 here means 4.6-stable or 4.6-dev. The project uses Godot 4.6 (confirmed by GODOT_mobile_export.md context).  
   - Recommendation: Use v5.2. If the project is on a pre-stable 4.6 build, test the plugin; fallback to `OS.shell_open("mailto:...")` if it fails.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Android SDK / Gradle | Plugin custom build | Unknown | — | Install via Android Studio |
| GodotShare plugin files | Share feature | Not yet | — | Download v5.2 zip |
| Android export templates | APK export | Present (existing APKs in repo) | — | — |

**Missing dependencies with no fallback:**
- GodotShare v5.2 zip — must be downloaded and installed before this phase executes
- Android Gradle build environment — must be set up before APK build testing

**Missing dependencies with fallback:**
- If Gradle build is unavailable for testing: the entire non-Android code path (PopupMenu, JSON serialization, fallback dialog) can be developed and tested without a device; only the actual share action requires Android.

---

## Sources

### Primary (HIGH confidence)
- `godot-mobile-plugins/godot-share` GitHub repository — verified current canonical location, v5.2 release notes, API methods
- `godot-mobile-plugins/godot-share` releases page — version compatibility table verified
- Direct codebase read: `main_scene.gd`, `main_scene.tscn`, `persistence_manager.gd`, all resource files, `export_presets.cfg`

### Secondary (MEDIUM confidence)
- `GODOT_mobile_export.md` in project `.planning/` — prior research doc on sharing patterns
- `cengiz-pz/godot-android-share-plugin` README — installation steps and $genname warning (archived but accurate)

### Tertiary (LOW confidence)
- `.gdap` file structure — based on standard Godot 4 Android plugin format; specific file contents not directly verified from v5.2 zip contents
- Godot 4 `PopupMenu`/`MenuButton` API details — from training knowledge; signal name `id_pressed` is standard but not verified against live Godot 4.6 docs in this session

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Plugin extracts to `addons/share/` and `android/plugins/share/` structure | GodotShare Plugin | Wrong paths → enable step fails; check zip contents on download |
| A2 | `.gdap` file uses standard format with `binary_type="local"` | GodotShare Plugin | Planner writes wrong Gradle build config; low impact — editor handles this |
| A3 | `Share` node causes scene load error on desktop if class not registered | Key Risks / Open Questions | If Godot degrades gracefully, the `.tscn` approach is fine; safer to use runtime instantiation |
| A4 | `id_pressed` is the correct signal name for `PopupMenu` in Godot 4.6 | PopupMenu Implementation | Wrong signal → menu items never fire; easy to fix if discovered in test |
| A5 | `PersistenceManager` is not an Autoload | JSON Serialization | If it IS an autoload, use `get_node("/root/PersistenceManager")` instead of `.new()` |
