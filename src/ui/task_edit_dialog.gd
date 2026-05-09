extends AcceptDialog

signal task_saved(task: TaskResource)

var _task: TaskResource = null

@onready var _title_edit: LineEdit = $MarginContainer/VBoxContainer/TitleEdit
@onready var _deadline_edit: LineEdit = $MarginContainer/VBoxContainer/DeadlineEdit
@onready var _desc_edit: TextEdit = $MarginContainer/VBoxContainer/DescEdit

func _ready() -> void:
	confirmed.connect(_on_confirmed)
	_title_edit.text_changed.connect(_on_title_changed)

func show_for_task(task: TaskResource) -> void:
	_task = task
	_title_edit.text = task.title
	_deadline_edit.text = format_deadline(task.deadline)
	_desc_edit.text = task.description
	get_ok_button().disabled = task.title.strip_edges().is_empty()
	popup_centered(Vector2i(340, 300))

func _on_title_changed(new_text: String) -> void:
	get_ok_button().disabled = new_text.strip_edges().is_empty()

func _on_confirmed() -> void:
	if _task == null:
		return
	var new_title: String = _title_edit.text.strip_edges()
	if new_title.is_empty():
		return
	_task.title = new_title
	_task.deadline = parse_deadline(_deadline_edit.text)
	_task.description = _desc_edit.text
	task_saved.emit(_task)

static func parse_deadline(text: String) -> int:
	var trimmed: String = text.strip_edges()
	if trimmed.is_empty():
		return 0
	var parts: PackedStringArray = trimmed.split("/")
	if parts.size() != 3:
		return 0
	var d: int = parts[0].to_int()
	var m: int = parts[1].to_int()
	var y: int = parts[2].to_int()
	if d <= 0 or m <= 0 or y <= 0:
		return 0
	return int(Time.get_unix_time_from_datetime_dict({
		"day": d, "month": m, "year": y,
		"hour": 0, "minute": 0, "second": 0
	}))

static func format_deadline(ts: int) -> String:
	if ts <= 0:
		return ""
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(ts)
	return "%02d/%02d/%04d" % [dt.day, dt.month, dt.year]
