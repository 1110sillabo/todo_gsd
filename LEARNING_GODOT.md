# Learning Godot — Mobile UI Fixes & Lessons

A running log of real problems encountered building **GSD Todo** (a Godot 4 mobile app for Android) and how to fix them. Each entry covers the root cause, the code fix, and how to apply it through the Godot editor UI.

---

## 1. Vertical scroll doesn't work when gesture starts near the FAB button

**Symptom:** Dragging a finger upward from the bottom third of the screen does nothing — the list doesn't scroll.

**Root cause:** The FAB (`Button`) sits on top of the `ScrollContainer` as an overlay. Its default `mouse_filter` is `MOUSE_FILTER_STOP`, which means it intercepts all touch events that land on or near it — including drag gestures that would otherwise scroll the list.

**Fix:**

In the `.tscn` file, add `mouse_filter = 2` to the FAB node:

```
[node name="FABButton" type="Button" parent="."]
...
mouse_filter = 2
```

`2` = `MOUSE_FILTER_IGNORE` — the FAB becomes invisible to input routing; touches pass straight through to the `ScrollContainer` underneath.

**Also worth setting:** `scroll_deadzone = 30` on the `ScrollContainer`. Without a deadzone, the container tries to decide scroll vs. tap immediately — with 30px it waits until the finger has moved 30 pixels before committing, which eliminates accidental scroll triggers on taps.

**In the Godot editor:**
1. Open the scene → click the FAB node in the **Scene** panel
2. **Inspector → Mouse → Filter** → set to **Ignore**
3. Click the `ScrollContainer` node → **Inspector → Scroll → Deadzone** → set to `30`

---

## 2. Tab bar is too small to tap comfortably on mobile

**Symptom:** The tab strip at the top ("Da fare", "Note", "Stats") requires precise tapping — hard to hit reliably with a thumb.

**Root cause:** Godot's `TabContainer` tab bar inherits the project's default font size, which is typically 14–16px — fine for desktop, too small for mobile (minimum recommended touch target: 48dp).

**Fix:**

Add a font size theme override directly on the `TabContainer` node in the `.tscn`:

```
[node name="TabContainer" type="TabContainer" parent="."]
...
theme_override_font_sizes/font_size = 18
```

Increasing the font size makes Godot render larger tab labels, which in turn increases the automatic height of the tab bar — no manual sizing needed.

**In the Godot editor:**
1. Click `TabContainer` in the **Scene** panel
2. **Inspector → Theme Overrides → Font Sizes → Font Size** → set to `18`

---

## 3. Section headers (Scadute / Da fare / Completate) don't respond reliably to taps

**Symptom:** Tapping the section header to collapse/expand sometimes works, sometimes doesn't. It feels like you have to aim for the chevron (▾) specifically.

**Root cause — two parts:**

**Part 1 (touch target size):** The `HeaderPanel` had `custom_minimum_size = Vector2(0, 48)`. While 48px meets the minimum, it leaves no margin — a slightly-off tap misses.

**Part 2 (event not consumed):** The `gui_input` handler on `HeaderPanel` was toggling the section but not calling `accept_event()`. This means the `ScrollContainer` above it also received the same touch event and sometimes started scrolling instead of (or in addition to) toggling.

**Fix:**

Increase the header height in `group_section.tscn`:
```
[node name="HeaderPanel" type="PanelContainer" parent="."]
custom_minimum_size = Vector2(0, 56)
```

Add `accept_event()` in `group_section.gd` to consume the touch so nothing else processes it:

```gdscript
func _on_header_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        accept_event()
        _toggle_expanded()
    elif event is InputEventScreenTouch and event.pressed:
        accept_event()
        _toggle_expanded()
```

**In the Godot editor:**
1. Open `group_section.tscn` → click `HeaderPanel`
2. **Inspector → Custom Minimum Size → y** → set to `56`
3. The `accept_event()` change is code-only — edit `group_section.gd` directly

---

## 4. Text labels overflow horizontally instead of wrapping

**Symptom:** Long task titles and note titles extend beyond the right edge of the screen in a single line, making them unreadable.

**Root cause:** Godot `Label` nodes default to `autowrap_mode = 0` (no wrapping). Text just keeps going in one line indefinitely.

**Fix:**

Add `autowrap_mode = 3` to any `Label` that should wrap. `3` = `AUTOWRAP_WORD_SMART` — wraps at word boundaries, falls back to character boundaries only when a single word is too long.

In `task_row.tscn`:
```
[node name="TitleLabel" type="Label" parent="MarginContainer/VBoxContainer"]
...
autowrap_mode = 3
```

Same in `note_row.tscn`.

The parent `PanelContainer` automatically expands vertically to accommodate the taller wrapped label — no explicit height changes needed.

**In the Godot editor:**
1. Open the scene → click the `TitleLabel` node
2. **Inspector → Autowrap Mode** → set to **Word (Smart)**

---

## 5. Note editor covered by virtual keyboard — can't scroll content

**Symptom:** When editing a note on Android, the virtual keyboard slides up and covers the `TextEdit` area. The dialog was too tall and centered on screen, so the bottom portion ended up behind the keyboard.

**Root cause:** `popup_centered()` places the dialog at the vertical center of the 860px viewport. With the dialog at 560px tall, its bottom edge lands at y≈800. Android's virtual keyboard takes up ~350px from the bottom (starting at y≈510), so ~290px of the dialog is hidden.

**Fix — two parts:**

**Part 1:** Shrink the dialog to 380px tall and reduce `ContentEdit` minimum height to 180px:

```
[node name="NoteEditDialog" type="AcceptDialog"]
size = Vector2i(390, 380)

[node name="ContentEdit" type="TextEdit" parent="VBoxContainer"]
custom_minimum_size = Vector2(0, 180)
```

**Part 2:** Replace `popup_centered()` with a fixed position near the top of the screen:

```gdscript
# Before
popup_centered()

# After — opens at top of screen, above keyboard
popup(Rect2i(Vector2i(5, 40), Vector2i(390, 380)))
```

`Rect2i(position, size)` — placing the dialog at x=5, y=40 (just below the ✕ button) keeps it entirely in the upper portion of the screen, above the keyboard.

**In the Godot editor:**
1. Open `note_edit_dialog.tscn` → click root `NoteEditDialog`
2. **Inspector → Size** → set to `390 × 380`
3. Click `ContentEdit` → **Inspector → Custom Minimum Size → y** → set to `180`
4. The `popup()` position change is code-only — edit `note_edit_dialog.gd`

---

## 6. "Da fare" tasks appear in random order instead of by urgency

**Symptom:** Tasks in the "Da fare" section show up in whatever order their `.tres` files were read from disk — not by deadline.

**Root cause:** `PersistenceManager.list_tasks()` returns filenames in filesystem order (effectively random). Tasks were added to the group section directly as they were loaded, with no sorting step.

**Fix:**

In `task_list_view.gd`, collect todo tasks into an array first, sort, then add:

```gdscript
var todo_tasks: Array[TaskResource] = []

for filename in PersistenceManager.list_tasks():
    var task := PersistenceManager.load_task(filename)
    if task == null:
        continue
    match categorize(task, now):
        "completed":
            group_completed.add_task(task)
        "expired":
            group_expired.add_task(task)
        _:
            todo_tasks.append(task)   # collect instead of adding immediately

# Sort by closest deadline first; no-deadline tasks go to the bottom
todo_tasks.sort_custom(func(a: TaskResource, b: TaskResource) -> bool:
    if a.deadline == 0 and b.deadline == 0:
        return false
    if a.deadline == 0:
        return false   # no deadline → goes after everything
    if b.deadline == 0:
        return true
    return a.deadline < b.deadline
)

for task in todo_tasks:
    group_todo.add_task(task)
```

`sort_custom` takes a comparator lambda. Return `true` if `a` should come before `b`. The `deadline` field is a Unix timestamp (int) — smaller = earlier = more urgent.

---

## 7. Completed tasks show the original deadline, not when they were completed

**Symptom:** In the "Completate" section, every row still shows the original due date (e.g. "15/05/2026") — not the date the task was actually marked done.

**Root cause:** `set_task()` in `task_row.gd` only checked `task.deadline > 0` when deciding what to show in `DeadlineLabel`. The `completed_at` field (set by `mark_complete()`) was never displayed.

**Fix:**

Check `completed_at` first — if it's set, show the completion date in green:

```gdscript
if task.completed_at > 0:
    var dt := Time.get_datetime_dict_from_unix_time(task.completed_at)
    $MarginContainer/VBoxContainer/DeadlineLabel.text = "✓ %02d/%02d/%04d" % [dt.day, dt.month, dt.year]
    $MarginContainer/VBoxContainer/DeadlineLabel.visible = true
    $MarginContainer/VBoxContainer/DeadlineLabel.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4, 1.0))
elif task.deadline > 0:
    # ... existing deadline display logic
```

`add_theme_color_override("font_color", Color(...))` applies a per-instance color without affecting other rows or requiring a custom theme resource.

---

## General Patterns

### `mouse_filter` values
| Value | Constant | Meaning |
|-------|----------|---------|
| 0 | MOUSE_FILTER_STOP | Node receives and blocks input (default for most Controls) |
| 1 | MOUSE_FILTER_PASS | Node receives input but passes it on |
| 2 | MOUSE_FILTER_IGNORE | Node is invisible to input — events go straight to nodes below |

### Always call `accept_event()` in `gui_input` handlers
If you handle a tap in `_gui_input` or via the `gui_input` signal but don't call `accept_event()`, the event continues propagating up to parent nodes (like `ScrollContainer`). This causes double-handling — both your handler AND the scroll logic fire. Always `accept_event()` when the input is fully handled.

### Theme overrides in `.tscn` format
```
theme_override_font_sizes/font_size = 18    # font size
theme_override_constants/margin_left = 12   # spacing constant
theme_override_colors/font_color = Color(0.55, 0.55, 0.6, 1)  # color
```
These are per-node overrides that don't require a `Theme` resource — useful for one-off adjustments.

### `popup()` vs `popup_centered()` on mobile
`popup_centered()` is convenient but doesn't account for the soft keyboard. Use `popup(Rect2i(position, size))` to control exactly where a dialog appears — position it in the upper half of the screen so the keyboard never covers it.
