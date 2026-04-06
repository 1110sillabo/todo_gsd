# GdUnit Generated Test Suite for PersistenceManager
extends GdUnitTestSuite

const TEST_DIR: String = "user://tasks_test/"
var persistence: PersistenceManager

func before():
	persistence = PersistenceManager.new()
	# Override the TASKS_PATH for tests to avoid cluttering actual data
	# This requires modification of PersistenceManager to be more testable
	# But for now, we'll test the core logic

func test_task_saving_and_loading() -> void:
	var task := TaskResource.new()
	task.title = "Persistent Task"
	task.description = "Test Description"
	
	var err: Error = persistence.save_task(task)
	assert_int(err).is_equal(OK)
	
	var filename: String = task.title.validate_filename() + ".tres"
	var loaded_task: TaskResource = persistence.load_task(filename)
	
	assert_object(loaded_task).is_not_null()
	assert_str(loaded_task.title).is_equal("Persistent Task")
	assert_str(loaded_task.description).is_equal("Test Description")

func test_task_listing() -> void:
	var task1 := TaskResource.new()
	task1.title = "Task 1"
	persistence.save_task(task1)
	
	var task2 := TaskResource.new()
	task2.title = "Task 2"
	persistence.save_task(task2)
	
	var list := persistence.list_tasks()
	assert_array(list).contains(["Task 1.tres", "Task 2.tres"])

func test_task_deletion() -> void:
	var task := TaskResource.new()
	task.title = "Task to delete"
	persistence.save_task(task)
	
	var filename: String = "Task to delete.tres"
	var err: Error = persistence.delete_task(filename)
	assert_int(err).is_equal(OK)
	
	var exists: bool = FileAccess.file_exists(PersistenceManager.TASKS_PATH + filename)
	assert_bool(exists).is_false()
