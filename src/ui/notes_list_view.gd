extends Control

const NOTE_ROW_SCENE = preload("res://src/ui/note_row.tscn")

@onready var notes_vbox: VBoxContainer = $ScrollContainer/NotesVBox
@onready var fab: Button = $FABButton
@onready var edit_dialog: NoteEditDialog = $NoteEditDialog

func _ready() -> void:
	$ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14
	fab.pressed.connect(_on_fab_pressed)
	edit_dialog.note_saved.connect(_on_note_saved)
	_load_notes()

func _load_notes() -> void:
	for child in notes_vbox.get_children():
		child.queue_free()
	
	for filename in PersistenceManager.list_notes():
		var note := PersistenceManager.load_note(filename)
		if note:
			_add_note_row(note)

func _add_note_row(note: NoteResource) -> void:
	var row: NoteRow = NOTE_ROW_SCENE.instantiate()
	notes_vbox.add_child(row)
	row.note = note
	row.note_edit_requested.connect(_on_note_edit_requested)

func _on_fab_pressed() -> void:
	var new_note := NoteResource.new()
	edit_dialog.show_for_note(new_note, "Nuova Nota")

func _on_note_edit_requested(note: NoteResource) -> void:
	edit_dialog.show_for_note(note, "Modifica Nota")

func _on_note_saved(note: NoteResource) -> void:
	PersistenceManager.save_note(note)
	_load_notes()
