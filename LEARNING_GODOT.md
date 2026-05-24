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

## 8. Controlling the scrollbar width

**Symptom:** The vertical scrollbar on the right is a thin sliver — hard to see and impossible to grab on a touchscreen.

**Root cause:** Godot's `ScrollContainer` creates a `VScrollBar` internally as an unnamed child node. Its width is not exposed as a direct property on `ScrollContainer` itself — you have to reach into the scrollbar node.

**Why you can't find it in the Inspector:** Selecting the `ScrollContainer` in the Scene panel shows its own properties, not the internal `VScrollBar` child. The scrollbar isn't listed in the scene tree either — Godot creates it at runtime.

**Fix — code (simplest, recommended):**

In the script attached to the scene that contains the `ScrollContainer`, call `get_v_scroll_bar()` in `_ready()`:

```gdscript
func _ready() -> void:
    $ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14
```

`14` is a good mobile value — visible without being intrusive. Default is ~8px. Try `20`+ if you want a thick grabbable bar.

`custom_minimum_size.x` sets the *minimum* width. Godot won't render it thinner than this value regardless of the theme.

**Fix — theme (global, applies to all ScrollContainers):**

If you want to set it once for the whole project instead of per-scene:

1. **Project → Project Settings → General → GUI → Theme → Custom** → create or assign a Theme resource
2. Or: select any node → **Inspector → Theme** → **New Theme** → save as `res://theme.tres`
3. In the **Theme editor** (bottom panel): click **Add Type** → search `VScrollBar` → Add
4. Under VScrollBar: **Add Theme Item → Constants → `minimum_width`** (Godot 4.3+) or set a custom `StyleBox` for the grabber area to be wider
5. Apply the theme to the root node of your main scene (it cascades down to all children)

**In the Godot editor (finding the VScrollBar at runtime):**

You can inspect the internal scrollbar while the game is running:
1. Run the project (F5 or the Play button)
2. **Scene → Remote** (top of Scene panel, switch from "Local" to "Remote")
3. Navigate the live tree — you'll see `VScrollBar` appear as a child of `ScrollContainer`
4. Click it → **Inspector → Custom Minimum Size → x** → adjust live

This remote inspector trick is useful any time you need to inspect nodes that are created at runtime and don't appear in the static scene tree.

---

## 9. Section header toggle: expand works but collapse doesn't

**Symptom:** Tapping a collapsible section header expands it fine, but tapping again to collapse does nothing (or is unreliable) on Android.

**Root cause:** The `gui_input` signal on a `PanelContainer` header is fragile when children are present. Godot routes touch events to the deepest child whose rect contains the touch point. When the section is *collapsed*, there are no child nodes in `ItemsContainer`, so the event propagates cleanly up to `HeaderPanel`. When *expanded*, `TaskRow` nodes (which extend `PanelContainer` with `mouse_filter = STOP`) are in the tree. Even though they're laid out *below* the header in a VBoxContainer, Godot's internal routing can sometimes eat the event before it bubbles back up to `HeaderPanel`, making the `gui_input` signal unreliable for collapsing.

**Why `gui_input` signal is fragile here:**
- `gui_input` on a node fires only when Godot's routing decides that node should receive the event
- Children inside `HeaderPanel` (like `HBoxContainer`) also have `mouse_filter = STOP` by default
- The routing path changes depending on which children are visible in the scene tree

**Fix — use `_input()` with a manual rect check:**

Instead of connecting to `$HeaderPanel.gui_input`, override `_input()` in the GroupSection script. `_input()` fires for **every** input event before any Control routing — you then manually check if the touch lands in the header's rect:

```gdscript
func _ready() -> void:
    set_process_input(true)

func _input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var pressed := false
    if event is InputEventScreenTouch and event.pressed:
        pressed = true
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        pressed = true
    if pressed and $HeaderPanel.get_global_rect().has_point(event.position):
        get_viewport().set_input_as_handled()
        _toggle_expanded()
```

Key points:
- `get_global_rect()` returns the header's actual screen rect — works correctly regardless of scroll position or what children are visible
- `get_viewport().set_input_as_handled()` is the `_input()` equivalent of `accept_event()` — prevents the event from reaching any Control's `_gui_input`
- `set_process_input(true)` is implicit once you define `_input()`, but explicit is clearer

**When all three GroupSection instances call `_input()`:** Each instance checks `$HeaderPanel.get_global_rect().has_point(event.position)`. Only the one whose header was actually tapped will match — the others return immediately. The rect check is cheap.

**General rule:** Prefer `_input()` + `get_global_rect().has_point()` over `gui_input` signal for tap targets whose children change dynamically. The signal approach is fine for static scenes but becomes unpredictable when the scene tree changes at runtime.

---

## 10. Section header collapse still unreliable on mobile — transparent Button overlay

**Symptom:** Even after switching from `gui_input` signal to `_input()` + `get_global_rect().has_point()` (Section 9), collapsing the section header is still unreliable on Android. Expanding seems to work; collapsing does not, or requires multiple taps.

**Why the `_input()` approach can still fail:**

`_input()` fires on all nodes that called `set_process_input(true)`, in **scene-tree order — children before parents**. All three `GroupSection` instances and every `TaskRow` inside them may all be processing the same `InputEventScreenTouch`. A TaskRow that internally calls `get_viewport().set_input_as_handled()` for swipe detection will prevent the parent GroupSection's `_input()` from ever firing.

Additionally, Godot's `_input()` ordering on Android can deviate from desktop behavior when the OS batches touch events, making the order of execution non-deterministic.

**Root issue:** Custom `_input()` with rect checks is inherently fragile on mobile because it races against child nodes and Android's batched event delivery. Godot's native `Button` widget avoids all of this — it uses internal, engine-level press detection that is guaranteed to fire before child `_gui_input` callbacks, and it correctly tracks touch-start + touch-end within the same button rect.

**Fix — transparent Button overlay:**

The approach: leave the visual structure (`HeaderPanel`, `HeaderHBox`, labels) exactly as-is, and add a `Button` as the **last child** of `HeaderPanel`. Being last = renders on top. With `flat = true` and full-rect anchors it is completely invisible, but it captures every tap on the header first.

**In `group_section.tscn`:**

Remove `ChevronLabel` (no longer needed — the whole header is the tap target):

```
# Remove this node entirely:
# [node name="ChevronLabel" type="Label" parent="HeaderPanel/HeaderHBox"]
```

Add a transparent tap-capture Button as the last child of `HeaderPanel`:

```
[node name="HeaderTapArea" type="Button" parent="HeaderPanel"]
layout_mode = 1
anchors_preset = 15
flat = true
focus_mode = 0
```

`anchors_preset = 15` = `PRESET_FULL_RECT` — fills the entire `HeaderPanel`. `flat = true` removes all visual styling. `focus_mode = 0` = `NONE` prevents an ugly focus border on Android.

**In `group_section.gd`:**

Remove `_input()`, `set_process_input(true)`, and `_on_header_gui_input`. Connect the overlay button in `_ready()`:

```gdscript
func _ready() -> void:
    $HeaderPanel/HeaderTapArea.pressed.connect(_toggle_expanded)

func _toggle_expanded() -> void:
    _expanded = !_expanded
    $ItemsContainer.visible = _expanded

func setup(label: String, accent_color: Color, starts_expanded: bool) -> void:
    $HeaderPanel/HeaderHBox/GroupLabel.text = label
    _accent_color = accent_color
    _expanded = starts_expanded
    $ItemsContainer.visible = starts_expanded
    _apply_accent_style()
```

No chevron, no `_update_chevron()`, no `_on_header_gui_input`. The UX remains clear: tap the section row anywhere → it toggles. Items count `(N)` still shows in `CountLabel`.

**Why this works where `_input()` didn't:**

| Mechanism | Priority | Blocked by children? |
|-----------|----------|----------------------|
| `_input()` + rect check | Low (processes after GUI routing) | Yes — any child's `set_input_as_handled()` stops it |
| `gui_input` signal on Panel | Medium | Yes — children with `mouse_filter = STOP` grab first |
| `Button.pressed` (last-child overlay) | High (Button is top visual element, handles its own input before siblings) | No — it's on top, nothing sits above it |

The `Button` as last child is the only approach that is truly position-guaranteed: it renders above all siblings and catches the tap at the GUI routing stage, before `_input()` is called on any node.

**In the Godot editor:**
1. Open `group_section.tscn` → select `HeaderPanel` → **Add Child Node** → `Button`
2. Rename it `HeaderTapArea`
3. **Inspector → Flat** → on, **Focus Mode** → None
4. **Inspector → Layout → Anchors Preset** → Full Rect
5. Move it to the bottom of `HeaderPanel`'s children (drag in Scene panel)
6. Delete `ChevronLabel` from `HeaderHBox`
7. In `group_section.gd` connect in `_ready()` as above, delete `_input()` and `_on_header_gui_input`

---

## 11. FAB "+" button doesn't work on mobile — mouse_filter set to Ignore

**Symptom:** The floating "+" add button renders correctly but does nothing when tapped on Android. No dialog opens.

**Root cause:** The FAB `Button` was given `mouse_filter = 2` (`MOUSE_FILTER_IGNORE`) to fix an earlier scrolling issue (see entry 1). This was a partial fix: `MOUSE_FILTER_IGNORE` makes the button completely invisible to input routing — scroll worked again, but the button itself became untappable.

**The trade-off that was missed:** `MOUSE_FILTER_IGNORE` solves the scroll problem by passing all events through the button, but that includes the tap that should trigger `pressed`. The button never fires.

**Fix — replace floating FAB with a full-width bottom button:**

The floating overlay approach is inherently in conflict with the `ScrollContainer` beneath it. The simpler and more reliable pattern is to give the add button its own dedicated space outside the scroll area by placing it below the `ScrollContainer` in a `VBoxContainer`.

Change the scene structure from:

```
Control (root)
  ScrollContainer  ← full rect, offset_bottom = -140
    TaskListVBox
  FABButton        ← floating overlay, mouse_filter = 2
```

To:

```
Control (root)
  VBoxContainer    ← full rect
    ScrollContainer  ← size_flags_vertical = 3 (expand + fill)
      TaskListVBox
    FABButton        ← size_flags_horizontal = 3, min height 60
```

In the `.tscn`:

```
[node name="VBoxContainer" type="VBoxContainer" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0

[node name="ScrollContainer" type="ScrollContainer" parent="VBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 3   # expand + fill — takes all remaining space
scroll_deadzone = 30

[node name="FABButton" type="Button" parent="VBoxContainer"]
layout_mode = 2
size_flags_horizontal = 3
custom_minimum_size = Vector2(0, 60)
text = "+ Nuova attività"
theme_override_font_sizes/font_size = 18
```

No `mouse_filter` override, no floating anchors, no `z_index`. The `VBoxContainer` naturally gives the button its own 60px row at the bottom and lets `ScrollContainer` fill everything above it.

**Update `.gd` node paths** when moving nodes into a `VBoxContainer`:

```gdscript
# Before
@onready var fab: Button = $FABButton
$ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14

# After
@onready var fab: Button = $VBoxContainer/FABButton
$VBoxContainer/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14
```

**In the Godot editor:**
1. Open the scene → select the root node → **Add Child** → `VBoxContainer` → set anchors to Full Rect
2. Drag `ScrollContainer` into `VBoxContainer` → set its **Size Flags → Vertical** to **Expand + Fill**
3. Delete the floating `FABButton` → **Add Child** to `VBoxContainer` → `Button` → set **Size Flags → Horizontal** to **Expand + Fill**, min height 60, text `"+ Nuova attività"`
4. Remove `offset_bottom = -140` from `ScrollContainer` (no longer needed)
5. Update `@onready` paths in the attached `.gd` script

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

---

## 12. Control hidden at startup doesn't fill parent when shown — anchors ignored

**Symptom:** A detail view (e.g. `ListDetailView`) is initially hidden (`visible = false`). When shown by tapping a list item, its content renders correctly but is constrained to the top-left corner at roughly half the screen width, instead of filling the full screen.

**Root cause:** Godot 4 skips anchor-based size notifications for Controls that are `visible = false` at startup, as an optimization. The Control never receives the parent's resize event and keeps whatever tiny initial size it had (near zero, or just its combined minimum size). All the correct `.tscn` anchor settings (`anchors_preset = 15`, `anchor_right = 1.0`, etc.) are present and correct, but they only take effect when the parent sends a resize notification — which never happened while the Control was hidden.

**Why the `.tscn` anchors alone don't fix it:** Even with `layout_mode = 1`, `anchors_preset = 15`, `anchor_right = 1.0`, `anchor_bottom = 1.0` all correctly set, if the initial resize notification was never delivered, the stored offset values reflect a parent size of 0 — making the Control render at minimum size.

**Fix — call `set_anchors_and_offsets_preset` just before showing:**

In the parent view's show handler, reset the anchors on the detail view *after* making it visible. At that point the parent already has its correct full-screen size, so offsets are computed to zero:

```gdscript
func _on_list_open_requested(list: ListResource) -> void:
    _lists_container.visible = false
    _detail_view.visible = true
    _detail_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _detail_view.show_list(list)
```

The key detail: call `set_anchors_and_offsets_preset` **after** `visible = true`, not before. If called while still hidden, the parent size may not yet be available.

**Also required — `layout_mode` on scene root and children:**

The scene file for the detail view (and its parent) must have the correct `layout_mode` values:

```
# Root node of a standalone scene
[node name="ListDetailView" type="Control"]
layout_mode = 3        ← standalone root
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

# Direct child (VBoxContainer) filling the root
[node name="VBoxContainer" type="VBoxContainer" parent="."]
layout_mode = 1        ← anchors mode
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
```

When the scene is instanced inside a parent `.tscn`, override the root's `layout_mode` to `1` (anchors) for the instance:

```
[node name="ListDetailView" parent="." instance=ExtResource("...")]
layout_mode = 1        ← anchors mode in parent context
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
visible = false
```

**Diagnostic trick:** Temporarily display the Control's runtime size in a Label to confirm what Godot actually computed:

```gdscript
func show_list(list: ListResource) -> void:
    _title_label.text = list.title + " [" + str(int(size.x)) + "x" + str(int(size.y)) + "]"
```

If the label shows `libri [400x801]` the size is correct. If it shows something small like `libri [56x116]`, the resize notification was never received and the programmatic fix above is needed.
