extends GraphNode
class_name TaskNode

var task: TaskResource: set = set_task

func set_task(value: TaskResource) -> void:
	task = value
	title = task.title
	position_offset = task.graph_position
	# Subscribe to TaskResource signals for updates later
	
func _on_position_offset_changed() -> void:
	if task:
		task.graph_position = position_offset
		# Trigger a save via the PersistenceManager directly or via signal
		# For now, we will handle saving in the TaskBox parent
