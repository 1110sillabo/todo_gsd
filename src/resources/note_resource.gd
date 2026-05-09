extends Resource
class_name NoteResource

@export var title: String = ""
@export var content: String = ""
@export var created_at: int = 0

func _init() -> void:
	if created_at == 0:
		created_at = Time.get_unix_time_from_system()
