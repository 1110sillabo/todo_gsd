extends PanelContainer
class_name TaskRow

signal task_completed(task: TaskResource)
signal task_deleted(task: TaskResource)
signal task_edit_requested(task: TaskResource)

var task: TaskResource: set = set_task
var _swipe_start: Vector2 = Vector2.ZERO
var _is_drag: bool = false
const SWIPE_THRESHOLD := 80.0

func set_task(value: TaskResource) -> void:
	task = value
	if not is_inside_tree():
		await ready
	$MarginContainer/VBoxContainer/TitleLabel.text = task.title
	if task.deadline > 0:
		var now := int(Time.get_unix_time_from_system())
		var dt := Time.get_datetime_dict_from_unix_time(task.deadline)
		$MarginContainer/VBoxContainer/DeadlineLabel.text = "%02d/%02d/%04d" % [dt.day, dt.month, dt.year]
		if task.deadline < now:
			$MarginContainer/VBoxContainer/DeadlineLabel.add_theme_color_override("font_color", Color(0.85, 0.25, 0.18))
	else:
		$MarginContainer/VBoxContainer/DeadlineLabel.visible = false

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_swipe_start = event.position
		_is_drag = false
	elif (event is InputEventScreenTouch and not event.pressed) or \
	     (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if not _is_drag:
			task_edit_requested.emit(task)
		_swipe_start = Vector2.ZERO
		_is_drag = false
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and _swipe_start != Vector2.ZERO:
		var delta_x: float = event.position.x - _swipe_start.x
		var delta_y: float = event.position.y - _swipe_start.y
		if abs(delta_x) > SWIPE_THRESHOLD / 2:
			_is_drag = true
		if abs(delta_x) > SWIPE_THRESHOLD and abs(delta_x) > abs(delta_y) * 1.5:
			_swipe_start = Vector2.ZERO
			_is_drag = false
			if delta_x > 0:
				task_completed.emit(task)
			else:
				task_deleted.emit(task)
