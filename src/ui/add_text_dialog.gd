extends AcceptDialog
class_name AddTextDialog

signal text_confirmed(text: String)

@onready var _line_edit: LineEdit = $VBoxContainer/LineEdit

func _ready() -> void:
	confirmed.connect(_emit_if_valid)

func show_dialog(dialog_title: String = "Aggiungi", hint: String = "") -> void:
	title = dialog_title
	_line_edit.text = ""
	_line_edit.placeholder_text = hint
	popup(Rect2i(Vector2i(5, 40), Vector2i(390, 155)))
	_line_edit.grab_focus()

func _emit_if_valid() -> void:
	var t := _line_edit.text.strip_edges()
	if not t.is_empty():
		text_confirmed.emit(t)
