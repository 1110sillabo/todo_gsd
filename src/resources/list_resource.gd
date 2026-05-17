extends Resource
class_name ListResource

@export var list_id: String = ""
@export var title: String = ""
@export var created_at: int = 0
@export var items: Array[ListItemResource] = []

func _init() -> void:
	if list_id.is_empty():
		list_id = "%d_%d" % [Time.get_ticks_msec(), randi()]
	if created_at == 0:
		created_at = int(Time.get_unix_time_from_system())
