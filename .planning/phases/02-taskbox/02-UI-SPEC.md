# Phase 2: Task List UI — UI Design Contract

**Phase:** 02-taskbox
**Date:** 2026-05-09
**Status:** Ready for planning

---

## 1. Screen Architecture

```
┌─────────────────────────────────────┐
│  [Tasks]   [Note]   [Stats]         │  ← TabContainer (top tabs)
├─────────────────────────────────────┤
│                                     │
│  ▌ Scadute  (3)              ▾      │  ← Group header: red accent
│    ┌───────────────────────────┐    │
│    │ Paga bollette             │    │  ← Task row (title)
│    │ 12 mag 2026               │    │  ← Deadline label
│    └───────────────────────────┘    │
│    ┌───────────────────────────┐    │
│    │ Chiamare dentista         │    │
│    │ 10 mag 2026               │    │
│    └───────────────────────────┘    │
│                                     │
│  ▌ Da fare  (5)              ▾      │  ← Group header: blue accent
│    ┌───────────────────────────┐    │
│    │ Comprare latte            │    │
│    │ (nessuna scadenza)        │    │
│    └───────────────────────────┘    │
│    ...                              │
│                                     │
│  ▌ Completate (2)            ▸      │  ← Collapsed by default
│                                     │
│                                     │
│                          [ + ]      │  ← FAB bottom-right
└─────────────────────────────────────┘
```

---

## 2. Components

### 2.1 Tab Bar
- **Node:** `TabContainer`, tabs at top
- **Tabs:** "Da fare" (Tasks), "Note" (Notes), "Stats" (placeholder, grayed out)
- **Active tab:** visual underline or highlight on selected tab
- **Touch target:** min height 48px per tab
- **Stats tab:** disabled (`set_tab_disabled(2, true)`) — visible but non-interactive

### 2.2 Group Header
- **Node:** `PanelContainer` + `HBoxContainer`
- **Left accent bar:** 4px `StyleBoxFlat` border_width_left
  - Scadute: `Color(0.85, 0.25, 0.18)` — red
  - Da fare: `Color(0.22, 0.50, 0.90)` — blue
  - Completate: `Color(0.25, 0.72, 0.45)` — green, muted alpha when collapsed
- **Content (left to right):**
  - Accent label: group name ("Scadute", "Da fare", "Completate")
  - Item count badge: `(N)` in muted color
  - Spacer (HBoxContainer expands)
  - Chevron icon: `▾` when expanded, `▸` when collapsed
- **Touch target:** min height 48px
- **Interaction:** tap anywhere on header → toggle collapse

### 2.3 Task Row
- **Node:** `PanelContainer` > `MarginContainer` > `VBoxContainer`
- **Margin:** 12px horizontal, 10px vertical (inside the row)
- **Line 1:** Task title — `Label`, bold, font size 16px
- **Line 2:** Deadline string — `Label`, font size 13px, muted color
  - Format: "12 mag 2026" (Italian short date)
  - If no deadline: hide line 2 (label invisible, row shrinks)
  - If expired: deadline text in red/orange color
- **Touch target:** min height 56px (taller than header — primary interaction)
- **Swipe interaction (D-03):**
  - Swipe right (→): mark complete → row moves to Completate group (with brief animation)
  - Swipe left (←): delete → row removed (with brief animation)
  - Threshold: 80px horizontal, only if horizontal delta > vertical delta × 1.5
  - Fallback if swipe is unreliable: tap row → `AcceptDialog` action sheet (Complete / Delete / Cancel)
- **Background:** subtle card bg, slight rounding (4px corner radius)
- **Spacing between rows:** 4px gap

### 2.4 FAB (Floating Action Button)
- **Node:** `Button`, anchored `PRESET_BOTTOM_RIGHT`
- **Offset:** 20px from right, 20px from bottom
- **Size:** 56×56px (standard mobile FAB)
- **Label:** `+` (large, centered)
- **z_index:** 1 (renders above scroll content)
- **Style:** filled circle, accent blue `Color(0.22, 0.50, 0.90)`, white `+`
- **Interaction:** tap → open new-task modal (D-05)

### 2.5 New Task Modal
- **Node:** `AcceptDialog` (or `Window` if layout needs more control)
- **Title bar:** "Nuovo task"
- **Content:**
  - `LineEdit` — placeholder "Titolo del task…", auto-focused on open
  - `HBoxContainer` — calendar icon button + date label ("Nessuna scadenza" by default)
    - Tapping calendar icon: opens `Popup` with Godot `Calendar` or a custom date-picker panel (Phase 3 will refine this — for Phase 2 a simple date input is acceptable)
- **Buttons:** "Aggiungi" (OK / confirm) + "Annulla" (Cancel) — provided by AcceptDialog
- **Behavior on confirm:** create `TaskResource`, save via `PersistenceManager`, insert row into Da fare group
- **Behavior on cancel:** dismiss, no change
- **Size:** popup_centered at `Vector2(320, 180)`

---

## 3. States

| State | Behavior |
|-------|----------|
| Empty list | Show "Nessun task" placeholder text in Da fare group |
| Group collapsed | Child VBoxContainer `visible = false`, chevron `▸` |
| Group expanded | Child VBoxContainer `visible = true`, chevron `▾` |
| Completate default | Starts collapsed |
| Scadute / Da fare default | Start expanded |
| Swipe in progress | Row shifts horizontally (visual feedback) |
| Task completing | Row slides out right, re-appears in Completate |
| Task deleted | Row slides out left, removed |

---

## 4. Typography & Spacing

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Tab label | 14px | medium | active: white, inactive: muted |
| Group name | 14px | semibold | white |
| Group count | 13px | normal | muted gray |
| Task title | 16px | bold | white |
| Deadline (normal) | 13px | normal | muted gray |
| Deadline (expired) | 13px | normal | red `Color(0.85, 0.25, 0.18)` |
| Empty state | 14px | normal | muted gray, centered |

Row padding: 12px H, 10px V
Group header height: min 48px
Task row height: min 56px
FAB size: 56×56px

---

## 5. Godot Node Tree (reference for planner)

```
MainScene (Control)
└── TabContainer
    ├── TasksTab (Control, full rect) [title: "Da fare"]
    │   ├── ScrollContainer (full rect)
    │   │   └── TaskListVBox (VBoxContainer)
    │   │       ├── GroupHeader_Expired (PanelContainer)
    │   │       ├── GroupItems_Expired (VBoxContainer, visible=true)
    │   │       │   └── [TaskRow instances]
    │   │       ├── GroupHeader_Todo (PanelContainer)
    │   │       ├── GroupItems_Todo (VBoxContainer, visible=true)
    │   │       │   └── [TaskRow instances]
    │   │       ├── GroupHeader_Completed (PanelContainer)
    │   │       └── GroupItems_Completed (VBoxContainer, visible=false)
    │   │           └── [TaskRow instances]
    │   └── FABButton (Button, anchored bottom-right, z_index=1)
    ├── NotesTab (Control, full rect) [title: "Note"]
    │   └── Label ("In arrivo…")
    └── StatsTab (Control, full rect) [title: "Stats", disabled]
        └── Label ("In arrivo…")
```

---

## 6. Out of Scope (Phase 2)

- Inline title editing (Phase 3)
- Full calendar date picker (Phase 3 — Phase 2 may use a simple text input for deadline)
- Drag-to-reorder (Phase 3)
- Notes tab content (Phase 4)
- 3-dot menu (Phase 5)
