---
phase: 04-notes-ui
plan: 02
type: execute
wave: 1
depends_on: []
files_modified: [src/ui/note_edit_dialog.tscn, src/ui/note_edit_dialog.gd]
autonomous: true
requirements: [R06]
must_haves:
  truths:
    - "NoteEditDialog allows editing title and content"
    - "NoteEditDialog emits task_saved when confirmed"
  artifacts:
    - path: "src/ui/note_edit_dialog.tscn"
      provides: "Editing interface for notes"
    - path: "src/ui/note_edit_dialog.gd"
      provides: "Validation and object updating"
---

<objective>
Create the NoteEditDialog to handle creating and editing NoteResource objects.
Output: A modal dialog with title and content input fields.
</objective>

<execution_context>
@.github/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-notes-ui/04-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create NoteEditDialog scene</name>
  <files>src/ui/note_edit_dialog.tscn</files>
  <action>
    Create an AcceptDialog-based scene similar to `src/ui/task_edit_dialog.tscn`.
    Structure:
    - AcceptDialog (NoteEditDialog)
      - VBoxContainer
        - Label ("Titolo")
        - LineEdit (TitleEdit)
        - Label ("Contenuto")
        - TextEdit (ContentEdit) - custom_minimum_size (0, 300)
  </action>
  <verify>Scene file exists with LineEdit and TextEdit</verify>
  <done>NoteEditDialog scene created</done>
</task>

<task type="auto">
  <name>Task 2: Implement NoteEditDialog logic</name>
  <files>src/ui/note_edit_dialog.gd</files>
  <action>
    Implement `show_for_note(note: NoteResource)` to populate fields.
    Connect `confirmed` signal to update the `note` object and emit `note_saved(note: NoteResource)`.
    Disable 'OK' button if title is empty.
  </action>
  <verify>Dialog populates from object and saves back correctly</verify>
  <done>NoteEditDialog logic implemented</done>
</task>

</tasks>

<threat_model>
## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-02-01 | Information Disclosure | TextEdit | accept | Local-only data storage |
</threat_model>

<success_criteria>
Dialog successfully edits and saves NoteResource data.
</success_criteria>
