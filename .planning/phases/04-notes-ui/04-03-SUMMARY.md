---
phase: 04-notes-ui
plan: 03
type: execute
wave: 2
depends_on: [04-01, 04-02]
files_modified: [src/ui/notes_list_view.tscn, src/ui/notes_list_view.gd, src/ui/main_scene.tscn]
autonomous: true
requirements: [R05, R10]
must_haves:
  truths:
    - "Notes tab displays a list of saved notes"
    - "Tapping a note opens the edit dialog"
    - "FAB in notes tab creates a new note"
  artifacts:
    - path: "src/ui/notes_list_view.tscn"
      provides: "The container for the notes tab"
  key_links:
    - from: "src/ui/notes_list_view.gd"
      to: "PersistenceManager"
      via: "list_notes() and save_note()"
---

<objective>
Assemble the Notes tab UI, wiring up the list view, FAB, and edit dialog.
Output: A functional Notes tab integrated into the main application shell.
</objective>

<execution_context>
@.github/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-notes-ui/04-CONTEXT.md

<interfaces>
From src/persistence/persistence_manager.gd:
```gdscript
func save_note(note: NoteResource) -> Error
func list_notes() -> Array[String]
func load_note(filename: String) -> NoteResource
```
</interfaces>
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create NotesListView scene and script</name>
  <files>src/ui/notes_list_view.tscn, src/ui/notes_list_view.gd</files>
  <action>
    Create a scene similar to `TaskListView` (ScrollContainer -> VBoxContainer).
    Add a FAB Button (anchored 0.5 center, 0.667 height as per recent refinement).
    Instantiate `NoteEditDialog` within the scene.
    Script logic:
    - `_load_notes()`: fetch from PersistenceManager and instantiate `NoteRow` for each.
    - Connect `NoteRow.note_edit_requested` to open dialog.
    - Connect FAB to open dialog with new `NoteResource`.
    - Connect `NoteEditDialog.note_saved` to save via PersistenceManager and refresh list.
  </action>
  <verify>Notes display in list and editing works</verify>
  <done>NotesListView functional</done>
</task>

<task type="auto">
  <name>Task 2: Integrate into MainScene</name>
  <files>src/ui/main_scene.tscn</files>
  <action>
    Replace the placeholder `PlaceholderNotes` label in the `NotesTab` with the newly created `NotesListView`.
  </action>
  <verify>Notes tab is visible and functional in the app</verify>
  <done>Notes UI integrated</done>
</task>

</tasks>

<threat_model>
## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-03-01 | Elevation of Privilege | Persistence | accept | File-system restricted access |
</threat_model>

<success_criteria>
Notes tab is fully functional with list, create, and edit capabilities.
</success_criteria>
