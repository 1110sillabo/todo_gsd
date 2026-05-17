extends PanelContainer
class_name ListItemRow

signal item_toggled(item: ListItemResource)
signal item_deleted(item: ListItemResource)

var item: ListItemResource: set = set_item
var _swipe_start: Vector2 = Vector2.ZERO
var _is_drag: bool = false
const SWIPE_THRESHOLD := 80.0

func set_item(value: ListItemResource) -> void:
	item = value
	if not is_inside_tree():
		await ready
	_update_display()

func _update_display() -> void:
	var label: RichTextLabel = $MarginContainer/TitleLabel
	if item.checked:
		label.text = "[color=#808080][s]" + item.title + "[/s][/color]"
	else:
		label.text = item.title

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
			item_toggled.emit(item)
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
			item_deleted.emit(item)
