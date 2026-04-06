extends GraphEdit
class_name TaskBox

@onready var add_button: Button = $AddButton

const TASK_NODE_SCENE = preload("res://src/ui/task_node.tscn")

func _ready() -> void:
	# Connect zoom/pan for touch support in Godot 4.6
	panning_scheme = 1 # 1 is GraphEdit.PanningScheme.PAN_PADDLE
	
	add_button.pressed.connect(_on_add_button_pressed)
	_load_existing_tasks()

func _on_add_button_pressed() -> void:
	var task := TaskResource.new()
	task.title = "Task %d" % Time.get_ticks_msec()
	_create_task_node(task)
	var pm := PersistenceManager.new()
	pm.save_task(task)

func _create_task_node(task: TaskResource) -> void:
	var node: TaskNode = TASK_NODE_SCENE.instantiate()
	add_child(node)
	node.task = task
	node.position_offset = task.graph_position
	node.position_offset_changed.connect(_on_node_moved.bind(node))

func _on_node_moved(node: TaskNode) -> void:
	if node.task:
		node.task.graph_position = node.position_offset
		var pm := PersistenceManager.new()
		pm.save_task(node.task)

func _load_existing_tasks() -> void:
	var pm := PersistenceManager.new()
	var task_files := pm.list_tasks()
	for file_name in task_files:
		var task := pm.load_task(file_name)
		if task:
			_create_task_node(task)
