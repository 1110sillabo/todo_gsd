extends VBoxContainer
class_name GroupSection

const TASK_ROW_SCENE = preload("res://src/ui/task_row.tscn")

signal task_completed(task: TaskResource)
signal task_deleted(task: TaskResource)
signal task_edit_requested(task: TaskResource)

var _expanded: bool = true
var _accent_color: Color = Color.WHITE
var _tasks: Array[TaskResource] = []

func _ready() -> void:
	$HeaderPanel.gui_input.connect(_on_header_gui_input)

func setup(label: String, accent_color: Color, starts_expanded: bool) -> void:
	$HeaderPanel/HeaderHBox/GroupLabel.text = label
	_accent_color = accent_color
	_expanded = starts_expanded
	$ItemsContainer.visible = starts_expanded
	_update_chevron()
	_apply_accent_style()

func _apply_accent_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.14)
	style.border_color = _accent_color
	style.border_width_left = 4
	style.set_corner_radius_all(2)
	$HeaderPanel.add_theme_stylebox_override("panel", style)

func _update_chevron() -> void:
	$HeaderPanel/HeaderHBox/ChevronLabel.text = "▾" if _expanded else "▸"

func _update_count() -> void:
	$HeaderPanel/HeaderHBox/CountLabel.text = "(%d)" % _tasks.size()

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_expanded()
	elif event is InputEventScreenTouch and event.pressed:
		_toggle_expanded()

func _toggle_expanded() -> void:
	_expanded = !_expanded
	$ItemsContainer.visible = _expanded
	_update_chevron()

func add_task(task: TaskResource) -> void:
	_tasks.append(task)
	var row: TaskRow = TASK_ROW_SCENE.instantiate()
	$ItemsContainer.add_child(row)
	row.task = task
	row.task_completed.connect(_on_task_completed)
	row.task_deleted.connect(_on_task_deleted)
	row.task_edit_requested.connect(func(t): task_edit_requested.emit(t))
	_update_count()

func remove_task(task: TaskResource) -> void:
	for child in $ItemsContainer.get_children():
		if child is TaskRow and child.task == task:
			child.queue_free()
			break
	_tasks.erase(task)
	_update_count()

func clear() -> void:
	for child in $ItemsContainer.get_children():
		child.queue_free()
	_tasks.clear()
	_update_count()

func get_task_count() -> int:
	return _tasks.size()

func find_row(task_id: String) -> TaskRow:
	for child in $ItemsContainer.get_children():
		if child is TaskRow and child.task.task_id == task_id:
			return child
	return null

func _on_task_completed(task: TaskResource) -> void:
	task_completed.emit(task)

func _on_task_deleted(task: TaskResource) -> void:
	task_deleted.emit(task)
