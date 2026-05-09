extends Control

@onready var group_expired: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Expired
@onready var group_todo: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Todo
@onready var group_completed: GroupSection = $ScrollContainer/TaskListVBox/GroupSection_Completed
@onready var fab: Button = $FABButton
@onready var _edit_dialog: AcceptDialog = $TaskEditDialog

var _editing_task_id: String = ""
var _is_new_task: bool = false

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

	group_expired.task_edit_requested.connect(_on_task_edit_requested)
	group_todo.task_edit_requested.connect(_on_task_edit_requested)
	group_completed.task_edit_requested.connect(_on_task_edit_requested)

	_edit_dialog.task_saved.connect(_on_task_saved)
	_edit_dialog.canceled.connect(func(): _is_new_task = false)

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
	_is_new_task = true
	var task := TaskResource.new()
	_edit_dialog.show_for_task(task, "Nuovo task")

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

func _on_task_edit_requested(task: TaskResource) -> void:
	_editing_task_id = task.task_id
	_edit_dialog.show_for_task(task)

func _on_task_saved(task: TaskResource) -> void:
	PersistenceManager.save_task(task)
	if _is_new_task:
		_is_new_task = false
		var now := int(Time.get_unix_time_from_system())
		_add_to_group(categorize(task, now), task)
	else:
		_refresh_or_move_row(task)

func _refresh_or_move_row(task: TaskResource) -> void:
	var now: int = int(Time.get_unix_time_from_system())
	var new_category: String = categorize(task, now)
	for group in [group_expired, group_todo, group_completed]:
		var row: TaskRow = group.find_row(task.task_id)
		if row != null:
			var old_category: String = _group_name(group)
			if old_category == new_category:
				row.set_task(task)
			else:
				group.remove_task(task)
				_add_to_group(new_category, task)
			return

func _group_name(group: GroupSection) -> String:
	if group == group_expired:
		return "expired"
	elif group == group_completed:
		return "completed"
	return "todo"

func _add_to_group(category: String, task: TaskResource) -> void:
	match category:
		"expired":
			group_expired.add_task(task)
		"completed":
			group_completed.add_task(task)
		_:
			group_todo.add_task(task)
