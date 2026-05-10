extends PanelContainer
class_name NoteRow

signal note_edit_requested(note: NoteResource)

var note: NoteResource: set = set_note

func set_note(value: NoteResource) -> void:
	note = value
	if not is_inside_tree():
		await ready
	$MarginContainer/TitleLabel.text = note.title

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and not event.pressed) or \
	   (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		note_edit_requested.emit(note)
