# Phase 2: Task List UI — Research

**Phase:** 02-taskbox
**Date:** 2026-05-09
**Stack:** Godot 4.6, GDScript, Mobile renderer (already configured in project.godot)

---

## Standard Stack

### Core Godot 4.6 UI nodes for this phase

| Node | Use |
|------|-----|
| `TabContainer` | Tab bar shell (Tasks / Notes / Stats). Built-in tab switching, each child = one tab. |
| `VBoxContainer` | Vertical stack for task rows and group sections. |
| `ScrollContainer` | Makes the task list scrollable; wraps the VBoxContainer. |
| `PanelContainer` | Group header rows — provides a background rect for accent styling. |
| `HBoxContainer` | Single task row layout (title+deadline stacked on left, action area right). |
| `Label` | Title text, deadline text, group header labels. |
| `Button` | FAB, confirm/cancel in dialogs, collapse chevrons. |
| `AcceptDialog` / `Window` | New-task modal. `AcceptDialog` is simplest; `Window` gives more layout control. |
| `StyleBoxFlat` | Programmatic accent bar on group headers (left border color). |
| `MarginContainer` | Consistent padding inside rows (48dp+ touch targets). |

### Touch & Mobile in Godot 4.6
- **Touch targets:** Minimum size set via `custom_minimum_size = Vector2(0, 48)` on row containers. Godot uses logical pixels matching device dp.
- **Scrolling:** `ScrollContainer` handles touch scrolling natively — no extra code needed. Set `scroll_vertical_enabled = true`.
- **Swipe detection:** Godot 4.6 has no built-in swipe-on-row gesture. Must use `_gui_input(event: InputEvent)` on each row, track `InputEventScreenTouch` (start) and `InputEventScreenDrag` (delta). Threshold ~80px horizontal drag = swipe. This is ~30 lines per row — manageable but requires care.
- **FAB:** Not a native node. Implement as a `Button` with `layout_mode = LAYOUT_MODE_ANCHORS`, `anchors_preset = PRESET_BOTTOM_RIGHT`, offset inward 20px. Sits as a sibling of ScrollContainer inside a `Control` root, not inside the scroll.

### TabContainer vs custom tab bar
`TabContainer` is the correct choice for Godot 4.6:
- Built-in: renders tabs at top or bottom (`tab_alignment`, `tabs_position`)
- `set_tab_title(idx, "Tasks")` for labels
- `tab_changed` signal for switching views
- No third-party dependency
- **Gotcha:** `TabContainer` clips children — each tab child must be a full `Control` with `anchors_preset = PRESET_FULL_RECT`.

### Group header with left accent bar
`StyleBoxFlat` supports `border_width_left` — set only left border to create the Todoist-style accent:
```gdscript
var style := StyleBoxFlat.new()
style.bg_color = Color(0.12, 0.12, 0.14)   # dark row bg
style.border_color = Color(0.9, 0.3, 0.2)  # red for Expired
style.border_width_left = 4
style.set_corner_radius_all(4)
panel_container.add_theme_stylebox_override("panel", style)
```

### Collapsible sections
No built-in collapsible widget in Godot 4.6. Pattern:
- Group header `Button` emits `pressed` → toggle `visible` on the child `VBoxContainer` of items
- Chevron icon rotates 90° using `pivot_offset` + `rotation_degrees` tween
- Store collapse state in a `Dictionary` keyed by group name for persistence across reloads

### New-task modal (AcceptDialog approach)
```gdscript
var dialog := AcceptDialog.new()
dialog.title = "New Task"
var vbox := VBoxContainer.new()
var line_edit := LineEdit.new()
line_edit.placeholder_text = "Task title..."
vbox.add_child(line_edit)
dialog.add_child(vbox)
add_child(dialog)
dialog.popup_centered(Vector2(300, 160))
dialog.confirmed.connect(_on_task_confirmed.bind(line_edit))
```
`AcceptDialog` provides OK/Cancel automatically. Works on mobile — renders as a centered popup.

### Persistence wiring pattern
`PersistenceManager` must be a **singleton autoload** or instantiated once and passed down — not `PersistenceManager.new()` on every call (current task_box.gd bug). 

Recommended: add to Project → Autoload as `PersistenceManager`. Then access via `PersistenceManager.save_task(task)` globally. This avoids repeated instantiation and keeps the `user://tasks/` dir check to once at startup.

### Task grouping logic
```gdscript
func _categorize_tasks(tasks: Array[TaskResource]) -> Dictionary:
    var now := int(Time.get_unix_time_from_system())
    var groups := { "expired": [], "todo": [], "completed": [] }
    for task in tasks:
        if task.completed_at > 0:
            groups["completed"].append(task)
        elif task.deadline > 0 and task.deadline < now:
            groups["expired"].append(task)
        else:
            groups["todo"].append(task)  # no deadline → todo
    return groups
```

### Swipe gesture implementation (per D-03)
```gdscript
# In task row script:
var _swipe_start: Vector2 = Vector2.ZERO
const SWIPE_THRESHOLD := 80.0

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _swipe_start = event.position
    elif event is InputEventScreenDrag:
        var delta := event.position.x - _swipe_start.x
        if abs(delta) > SWIPE_THRESHOLD:
            if delta > 0:
                complete_task()   # swipe right
            else:
                delete_task()     # swipe left
            _swipe_start = Vector2.ZERO
```
Risk: `ScrollContainer` and row swipe can conflict — horizontal swipe triggers row action, vertical swipe scrolls. Godot 4.6 does not auto-resolve this. Mitigation: only trigger swipe action if `abs(delta.x) > abs(delta.y) * 1.5` (more horizontal than vertical).

If conflict is unresolvable in testing → fall back to action sheet per D-03.

### Scene structure (recommended)
```
MainScene (Control, fullscreen)
└── TabContainer
    ├── TasksTab (Control) [tab title: "Da fare"]
    │   ├── ScrollContainer (full rect)
    │   │   └── TaskListVBox (VBoxContainer)
    │   │       ├── GroupHeader_Expired (PanelContainer + HBox)
    │   │       ├── GroupItems_Expired (VBoxContainer, visible=false default)
    │   │       ├── GroupHeader_Todo (PanelContainer + HBox)
    │   │       ├── GroupItems_Todo (VBoxContainer, visible=true default)
    │   │       ├── GroupHeader_Completed (PanelContainer + HBox)
    │   │       └── GroupItems_Completed (VBoxContainer, visible=false default)
    │   └── FABButton (Button, anchored bottom-right, z_index=1)
    ├── NotesTab (Control) [tab title: "Note"] — placeholder
    └── StatsTab (Control) [tab title: "Stats"] — placeholder
```

### Don't hand-roll
- Scrolling — use `ScrollContainer`, don't implement manually
- Tab switching — use `TabContainer`, don't build custom signals
- Dialog — use `AcceptDialog`, don't build a Panel from scratch
- File paths — use existing `PersistenceManager` methods, don't open files directly

### Common pitfalls
1. **PersistenceManager instantiated repeatedly** — make it an autoload (current bug in codebase)
2. **Touch events eaten by ScrollContainer** — swipe rows must be direct children of the VBox, not inside another ScrollContainer
3. **TabContainer child sizing** — each tab child needs `anchors_preset = PRESET_FULL_RECT` or it won't fill the tab
4. **FAB z-layering** — FAB must have `z_index` > 0 or it renders behind the scroll area
5. **Filename collision** — `PersistenceManager.save_task` uses `task.title.validate_filename()` as key; two tasks with same title overwrite each other. Phase 2 should use a UUID or timestamp-based filename instead.

---

## Validation Architecture

### Validation Strategy
- GdUnit4 SceneRunner for UI component tests
- Headless Godot for logic unit tests (grouping, categorization)
- Manual Android export smoke test at end of phase

### Key behaviors to validate
1. Tasks load into correct groups on startup
2. FAB opens new-task dialog
3. New task appears in Todo group after confirm
4. Group headers collapse/expand their item list
5. Completed group starts collapsed
6. Swipe right → task moves to Completed group
7. Swipe left → task deleted
8. Tab switching shows correct content

---

## Security Notes
- All data is local `user://` — no network, no authentication surface
- `validate_filename()` on task title prevents path traversal in `.tres` filenames
- Recommend switching to UUID-based filenames to prevent title-collision overwrite (see pitfall #5)
