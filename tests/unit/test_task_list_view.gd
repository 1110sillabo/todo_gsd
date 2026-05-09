extends GdUnitTestSuite

const TaskListViewScene = preload("res://src/ui/task_list_view.tscn")

func test_scene_loads() -> void:
	var view: Node = TaskListViewScene.instantiate()
	assert_object(view).is_not_null()
	view.queue_free()

func test_completed_group_starts_collapsed() -> void:
	var view: Node = TaskListViewScene.instantiate()
	add_child(view)
	await get_tree().process_frame
	await get_tree().process_frame
	var items: Node = view.get_node("ScrollContainer/TaskListVBox/GroupSection_Completed/ItemsContainer")
	assert_bool(items.visible).is_false()
	view.queue_free()

func test_todo_group_starts_expanded() -> void:
	var view: Node = TaskListViewScene.instantiate()
	add_child(view)
	await get_tree().process_frame
	await get_tree().process_frame
	var items: Node = view.get_node("ScrollContainer/TaskListVBox/GroupSection_Todo/ItemsContainer")
	assert_bool(items.visible).is_true()
	view.queue_free()

func test_add_task_increases_todo_count() -> void:
	var view: Node = TaskListViewScene.instantiate()
	add_child(view)
	await get_tree().process_frame
	await get_tree().process_frame
	var group_todo: GroupSection = view.get_node("ScrollContainer/TaskListVBox/GroupSection_Todo")
	var before: int = group_todo.get_task_count()
	var task: TaskResource = TaskResource.new()
	task.title = "Test task"
	group_todo.add_task(task)
	assert_int(group_todo.get_task_count()).is_equal(before + 1)
	view.queue_free()
