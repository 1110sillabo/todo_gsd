---
phase: 04-notes-ui
plan: 01
type: execute
wave: 1
depends_on: []
files_modified: [src/ui/note_row.tscn, src/ui/note_row.gd]
autonomous: true
requirements: [R05, R07]
must_haves:
  truths:
    - "NoteRow displays the title of a NoteResource"
    - "NoteRow emits a signal when tapped"
  artifacts:
    - path: "src/ui/note_row.tscn"
      provides: "Visual structure for a note list item"
    - path: "src/ui/note_row.gd"
      provides: "Signal emission and data display logic"
  key_links:
    - from: "src/ui/note_row.gd"
      to: "NoteResource"
      via: "property setter"
---

<objective>
Create the NoteRow component for displaying individual notes in a compact list.
Output: A reusable NoteRow scene with a title label and tap detection.
</objective>

<execution_context>
@.github/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-notes-ui/04-CONTEXT.md

<interfaces>
From src/resources/note_resource.gd:
```gdscript
class_name NoteResource
@export var title: String = ""
@export var content: String = ""
```
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create NoteRow scene</name>
  <files>src/ui/note_row.tscn</files>
  <action>
    Create a PanelContainer-based scene similar to `src/ui/task_row.tscn`.
    Structure:
    - PanelContainer (NoteRow) - custom_minimum_size (0, 60)
      - MarginContainer (12px margins)
        - Label (TitleLabel) - font_size 20
  </action>
  <verify>Scene file exists with the specified structure</verify>
  <done>NoteRow scene created</done>
</task>

<task type="auto">
  <name>Task 2: Implement NoteRow script</name>
  <files>src/ui/note_row.gd</files>
  <action>
    Implement logic to set the title and detect taps.
    Signals: `note_edit_requested(note: NoteResource)`
    Methods: `set_note(value: NoteResource)`
    Use `_gui_input` to detect a simple tap (press + release within reasonable range) and emit `note_edit_requested`.
  </action>
  <verify>Script exists with set_note and signal emission</verify>
  <done>NoteRow logic implemented</done>
</task>

</tasks>

<threat_model>
## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-01-01 | Tampering | NoteRow | accept | Display-only component |
</threat_model>

<success_criteria>
NoteRow displays title and signals when tapped.
</success_criteria>
