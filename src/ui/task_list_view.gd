extends Control

@onready var group_expired: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Expired
@onready var group_todo: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Todo
@onready var group_completed: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Completed
@onready var fab: Button = $FABButton

func _ready() -> void:
	group_expired.setup("Scadute", Color(0.85, 0.25, 0.18), true)
	group_todo.setup("Da fare", Color(0.22, 0.50, 0.90), true)
	group_completed.setup("Completate", Color(0.25, 0.72, 0.45), false)

	group_expired.task_completed.connect(_on_task_completed)
	group_expired.task_deleted.connect(_on_task_deleted)
	group_todo.task_completed.connect(_on_task_completed)
	group_todo.task_deleted.connect(_on_task_deleted)
	group_completed.task_completed.connect(_on_task_completed)
	group_completed.task_deleted.connect(_on_task_deleted)

	fab.pressed.connect(_on_fab_pressed)
	_load_tasks()

func _load_tasks() -> void:
	group_expired.clear()
	group_todo.clear()
	group_completed.clear()
	var now := int(Time.get_unix_time_from_system())
	for filename in PersistenceManager.list_tasks():
		var task := PersistenceManager.load_task(filename)
		if task == null:
			continue
		match categorize(task, now):
			"completed":
				group_completed.add_task(task)
			"expired":
				group_expired.add_task(task)
			_:
				group_todo.add_task(task)

static func categorize(task: TaskResource, now: int = 0) -> String:
	if now == 0:
		now = int(Time.get_unix_time_from_system())
	if task.completed_at > 0:
		return "completed"
	if task.deadline > 0 and task.deadline < now:
		return "expired"
	return "todo"

func _on_fab_pressed() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Nuovo task"
	var vbox := VBoxContainer.new()
	var line_edit := LineEdit.new()
	line_edit.placeholder_text = "Titolo del task…"
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(line_edit)
	dialog.add_child(vbox)
	add_child(dialog)
	dialog.confirmed.connect(func(): _create_task(line_edit.text, dialog))
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.popup_centered(Vector2(320, 160))
	line_edit.grab_focus()

func _create_task(title: String, dialog: AcceptDialog) -> void:
	dialog.queue_free()
	if title.strip_edges().is_empty():
		return
	var task := TaskResource.new()
	task.title = title.strip_edges()
	PersistenceManager.save_task(task)
	group_todo.add_task(task)

func _on_task_completed(task: TaskResource) -> void:
	task.mark_complete()
	PersistenceManager.save_task(task)
	group_expired.remove_task(task)
	group_todo.remove_task(task)
	group_completed.add_task(task)

func _on_task_deleted(task: TaskResource) -> void:
	group_expired.remove_task(task)
	group_todo.remove_task(task)
	group_completed.remove_task(task)
	for filename in PersistenceManager.list_tasks():
		if filename.begins_with(task.task_id):
			PersistenceManager.delete_task(filename)
			break
