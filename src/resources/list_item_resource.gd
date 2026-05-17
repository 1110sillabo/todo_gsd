extends Resource
class_name ListItemResource

@export var item_id: String = ""
@export var title: String = ""
@export var checked: bool = false

func _init() -> void:
	if item_id.is_empty():
		item_id = "%d_%d" % [Time.get_ticks_msec(), randi()]
