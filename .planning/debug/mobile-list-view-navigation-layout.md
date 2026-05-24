---
status: fixing
trigger: "On mobile, in the 'liste' (lists) section, tapping a list does not open the list item detail view. Elements are correctly recorded but the list of books cannot be seen. Additionally, the list name ('libri') and 'Aggiungi elemento' button are aligned top-left — possibly a fixed size/layout issue."
created: 2026-05-24T00:00:00Z
updated: 2026-05-24T00:01:00Z
---

## Current Focus
<!-- OVERWRITE on each update - reflects NOW -->

hypothesis: CONFIRMED — list_detail_view.gd and lists_list_view.gd do not call set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) in _ready(), unlike the working task_list_view.gd. The detail view starts with visible=false; its layout isn't fully computed until shown. When shown, it has size 0 or incorrect size, causing all VBoxContainer children to collapse to top-left. Items in ScrollContainer are invisible (zero height). Navigation signal chain is correct; the view IS shown but appears empty.
test: Applied fix — added set_anchors_and_offsets_preset(PRESET_FULL_RECT) to both _ready() functions
expecting: Detail view fills screen correctly; items list visible; title and FAB at correct positions
next_action: Verify fix

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: Tapping a list in the lists view should open the list detail view showing that list's items (e.g., books in "libri" list). The layout should fill the screen properly.
actual: Cannot enter the list view of items. The list item view does not open. Additionally, list name and "Aggiungi elemento" button are aligned top-left with possible fixed sizing issues.
errors: No specific error messages reported — visual/navigation failure on mobile.
reproduction: Open the app on mobile, go to the "liste" section, tap on a list (e.g. "libri"). The detail view does not open. On whatever view is shown, UI elements are top-left aligned.
started: Unknown — items are correctly saved/recorded.

## Eliminated
<!-- APPEND only - prevents re-investigating -->

- hypothesis: Signal chain broken (list_open_requested not emitted or connected)
  evidence: Signal connection is correct in _add_list_row(); emit is correct in list_row.gd _gui_input; _on_list_open_requested correctly shows _detail_view
  timestamp: 2026-05-24T00:01:00Z

- hypothesis: Touch events not reaching ListRow on mobile
  evidence: list_row.gd handles both InputEventScreenTouch and InputEventMouseButton; emulate_mouse_from_touch is enabled by default; PanelContainer has MOUSE_FILTER_STOP
  timestamp: 2026-05-24T00:01:00Z

- hypothesis: Anchor/size flags misconfigured in list_detail_view.tscn
  evidence: Checked .tscn — anchors_preset=15, anchor_right=1.0, anchor_bottom=1.0 are present; structure is correct
  timestamp: 2026-05-24T00:01:00Z

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-05-24T00:01:00Z
  checked: task_list_view.gd vs lists_list_view.gd and list_detail_view.gd
  found: task_list_view.gd._ready() calls set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); the other two do NOT
  implication: Without this runtime call, Controls that start with visible=false may not have their anchor-based size computed correctly when first shown

- timestamp: 2026-05-24T00:01:00Z
  checked: main_scene.tscn, lists_list_view.tscn, list_detail_view.tscn layout chain
  found: Navigation signal chain is correct. ListDetailView IS shown on tap. Issue is the view appears empty due to size collapse.
  implication: User perceives "nav not working" because detail view shows with size ~0 (no items visible, title/FAB at top-left with minimum sizes only)

- timestamp: 2026-05-24T00:01:00Z
  checked: list_detail_view.tscn VBoxContainer children
  found: HeaderPanel has custom_minimum_size=(0,56), FABButton has custom_minimum_size=(0,60) — both show at minimum sizes even when parent is 0-height. ScrollContainer has no minimum height → invisible when parent height=0
  implication: Confirms title "libri" and FAB "Aggiungi elemento" are visible at top (minimum sizes rendered), but items list is invisible (ScrollContainer collapses)

## Resolution

root_cause: lists_list_view.gd and list_detail_view.gd do not call set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) in _ready(), unlike the working task_list_view.gd. When detail view starts with visible=false, its layout may not be fully initialized when first shown (parent size might be 0 during initial tree entry). Without the runtime call, the VBoxContainer inside the detail view has zero height — items in ScrollContainer are invisible, only minimum-height controls (title, FAB) render at top-left.
fix: Added set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) to _ready() in both lists_list_view.gd and list_detail_view.gd
verification: Pending user test on mobile
files_changed: [src/ui/lists_list_view.gd, src/ui/list_detail_view.gd]
