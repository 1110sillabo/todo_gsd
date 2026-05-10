extends AcceptDialog
class_name NoteEditDialog

signal note_saved(note: NoteResource)

@onready var title_edit: LineEdit = $VBoxContainer/TitleEdit
@onready var content_edit: TextEdit = $VBoxContainer/ContentEdit

var _current_note: NoteResource

func _ready() -> void:
	register_text_enter(title_edit)
	title_edit.text_changed.connect(_on_title_changed)
	confirmed.connect(_on_confirmed)

func show_for_note(note: NoteResource, window_title: String = "Modifica Nota") -> void:
	_current_note = note
	title = window_title
	title_edit.text = note.title
	content_edit.text = note.content
	_on_title_changed(note.title)
	popup_centered()

func _on_title_changed(new_text: String) -> void:
	get_ok_button().disabled = new_text.strip_edges().is_empty()

func _on_confirmed() -> void:
	_current_note.title = title_edit.text.strip_edges()
	_current_note.content = content_edit.text
	note_saved.emit(_current_note)
