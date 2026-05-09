# Phase 3: Task Editing — Research

**Date:** 2026-05-09
**Phase:** 03-task-editing

## Standard Stack

- **Godot 4.6, GDScript** — same as all prior phases
- **Dialog pattern:** `AcceptDialog` (already used in Phase 2 FAB modal — proven working)
- **Text input:** `LineEdit` for single-line (title, deadline), `TextEdit` for multiline (description)
- **No new dependencies** — pure Godot built-ins

## Architecture Patterns

### Edit Modal Pattern
Phase 2 established: `AcceptDialog.new()` → add child VBoxContainer → `popup_centered()`. Works reliably.

For the edit modal, prefer a **pre-built scene** (`task_edit_dialog.tscn`) over programmatic construction:
- Easier to maintain layout
- Node references via `@onready` instead of `get_node()` chains
- Can be preloaded once on TaskListView `_ready()`

The modal is a `Window` subclass (`AcceptDialog extends Window`). Key behaviors:
- `popup_centered(size)` — centers on screen
- `confirmed` signal — user clicked OK
- `canceled` signal / `close_requested` signal — user dismissed
- `get_ok_button()` — reference to OK button for enabling/disabling

### Passing Data Into Modal
```gdscript
# Pattern: expose a show_for_task(task) method on the dialog
func show_for_task(task: TaskResource) -> void:
    _task = task
    _title_edit.text = task.title
    _desc_edit.text = task.description
    _deadline_edit.text = _format_deadline(task.deadline)
    popup_centered(Vector2(340, 280))
```

### Deadline Text Parsing
User types `dd/mm/yyyy`. Parse on confirm:
```gdscript
func _parse_deadline(text: String) -> int:
    var parts := text.strip_edges().split("/")
    if parts.size() != 3:
        return 0
    var d := parts[0].to_int()
    var m := parts[1].to_int()
    var y := parts[2].to_int()
    if d == 0 or m == 0 or y == 0:
        return 0
    return int(Time.get_unix_time_from_datetime_dict({
        "day": d, "month": m, "year": y,
        "hour": 0, "minute": 0, "second": 0
    }))
```

Format existing deadline for display:
```gdscript
func _format_deadline(ts: int) -> String:
    if ts == 0:
        return ""
    var dt := Time.get_datetime_dict_from_unix_time(ts)
    return "%02d/%02d/%04d" % [dt.day, dt.month, dt.year]
```

### Connecting Edit to TaskRow
TaskRow needs to emit a signal when tapped (not swiped). Add `task_edit_requested(task)` signal.

Tap detection in `_gui_input`: distinguish tap (touch up without drag) from swipe (drag > threshold).
```gdscript
var _touch_start: Vector2 = Vector2.ZERO
var _is_drag: bool = false

func _gui_input(event):
    if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
        if event.pressed:
            _touch_start = event.position
            _is_drag = false
        else:
            if not _is_drag:
                task_edit_requested.emit(task)  # tap = edit
    elif event is InputEventScreenDrag or event is InputEventMouseMotion:
        var dx = abs(event.position.x - _touch_start.x)
        if dx > SWIPE_THRESHOLD:
            _is_drag = true
            # existing swipe logic...
```

### Saving In-Place
After edit confirmed:
1. Update `task.title`, `task.description`, `task.deadline`
2. `PersistenceManager.save_task(task)` — overwrites existing file (task_id stays same)
3. Call `row.set_task(task)` on the existing TaskRow — refreshes display
4. If deadline change affects category: move row to correct group

## Pitfalls

- **`AcceptDialog` child layout**: children added to AcceptDialog go into its VBoxContainer, not directly into the dialog. Use `dialog.add_child(vbox)` — the vbox then fills the dialog area.
- **`popup_centered` before `add_child` to scene tree**: Dialog must be added to the scene tree (`add_child(dialog)`) BEFORE calling `popup_centered()`. Phase 2 does this correctly already.
- **`TextEdit` sizing**: needs `custom_minimum_size` set or it collapses to 0 height. Set `Vector2(0, 80)` minimum.
- **`LineEdit` placeholder**: use `placeholder_text` property, not `text`.
- **Deadline category change**: completing and moving tasks already works in Phase 2 via `_on_task_completed`. For deadline changes, recategorize inline: if new deadline < now → move to Scadute; if deadline cleared → move to Da fare.
- **Signal memory leak**: dialogs created with `.new()` and added temporarily must be `queue_free()`'d after use or connected with `one_shot=true`.

## Security

- All data is local, no network — no injection surface.
- Deadline parsing uses integer parsing (`to_int()`), not `eval` — no injection risk.
- Title/description are stored as strings in .tres files — no execution risk.

## Validation Architecture

Not applicable for this phase (local UI with no external boundaries).
