extends GdUnitTestSuite

func test_scene_loads() -> void:
	var runner := scene_runner("res://src/ui/task_list_view.tscn")
	assert_object(runner.scene()).is_not_null()

func test_completed_group_starts_collapsed() -> void:
	var runner := scene_runner("res://src/ui/task_list_view.tscn")
	await runner.simulate_frames(2)
	var view := runner.scene()
	var items := view.get_node("ScrollContainer/TaskListVBox/GroupSection_Completed/ItemsContainer")
	assert_bool(items.visible).is_false()

func test_todo_group_starts_expanded() -> void:
	var runner := scene_runner("res://src/ui/task_list_view.tscn")
	await runner.simulate_frames(2)
	var view := runner.scene()
	var items := view.get_node("ScrollContainer/TaskListVBox/GroupSection_Todo/ItemsContainer")
	assert_bool(items.visible).is_true()

func test_add_task_increases_todo_count() -> void:
	var runner := scene_runner("res://src/ui/task_list_view.tscn")
	await runner.simulate_frames(2)
	var view := runner.scene()
	var group_todo: GroupSection = view.get_node("ScrollContainer/TaskListVBox/GroupSection_Todo")
	var before := group_todo.get_task_count()
	var task := TaskResource.new()
	task.title = "Test task"
	group_todo.add_task(task)
	assert_int(group_todo.get_task_count()).is_equal(before + 1)
