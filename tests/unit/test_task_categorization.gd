extends GdUnitTestSuite

const TaskListViewScript = preload("res://src/ui/task_list_view.gd")

func test_completed_task_goes_to_completed() -> void:
	var task := TaskResource.new()
	task.completed_at = 1000
	assert_str(TaskListViewScript.categorize(task, 2000)).is_equal("completed")

func test_expired_task_goes_to_expired() -> void:
	var task := TaskResource.new()
	task.deadline = 1000
	assert_str(TaskListViewScript.categorize(task, 2000)).is_equal("expired")

func test_no_deadline_task_goes_to_todo() -> void:
	var task := TaskResource.new()
	task.deadline = 0
	assert_str(TaskListViewScript.categorize(task, 2000)).is_equal("todo")

func test_future_deadline_goes_to_todo() -> void:
	var task := TaskResource.new()
	task.deadline = 9999999999
	assert_str(TaskListViewScript.categorize(task, 2000)).is_equal("todo")
