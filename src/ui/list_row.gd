extends PanelContainer
class_name ListRow

signal list_open_requested(list: ListResource)
signal list_deleted(list: ListResource)

var list: ListResource: set = set_list
var _swipe_start: Vector2 = Vector2.ZERO
var _is_drag: bool = false
const SWIPE_THRESHOLD := 80.0

func set_list(value: ListResource) -> void:
	list = value
	if not is_inside_tree():
		await ready
	$MarginContainer/HBoxContainer/TitleLabel.text = list.title
	var n := list.items.size()
	$MarginContainer/HBoxContainer/CountLabel.text = "(%d)" % n

func _gui_input(event: InputEvent) -> void:
	var is_press: bool = (event is InputEventScreenTouch and event.pressed) or \
		(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	var is_release: bool = (event is InputEventScreenTouch and not event.pressed) or \
		(event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	var is_move: bool = (event is InputEventScreenDrag or event is InputEventMouseMotion)

	if is_press:
		_swipe_start = event.position
		_is_drag = false
	elif is_release:
		if not _is_drag:
			list_open_requested.emit(list)
		_swipe_start = Vector2.ZERO
		_is_drag = false
	elif is_move and _swipe_start != Vector2.ZERO:
		var dx: float = event.position.x - _swipe_start.x
		var dy: float = event.position.y - _swipe_start.y
		if abs(dy) > abs(dx):
			return
		if abs(dx) > SWIPE_THRESHOLD / 2:
			_is_drag = true
		if dx < -SWIPE_THRESHOLD and abs(dx) > abs(dy) * 1.5:
			_swipe_start = Vector2.ZERO
			_is_drag = false
			accept_event()
			list_deleted.emit(list)
