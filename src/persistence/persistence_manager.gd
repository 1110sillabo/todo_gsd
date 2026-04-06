extends Node
class_name PersistenceManager

const TASKS_PATH: String = "user://tasks/"

func _init() -> void:
	if not DirAccess.dir_exists_absolute(TASKS_PATH):
		DirAccess.make_dir_recursive_absolute(TASKS_PATH)

## Saves a TaskResource to the specified path.
func save_task(task: TaskResource) -> Error:
	var path: String = TASKS_PATH + "%s.tres" % task.title.validate_filename()
	return ResourceSaver.save(task, path)

## Loads a TaskResource from the specified path.
func load_task(filename: String) -> TaskResource:

## Loads a TaskResource from the specified path.
func load_task(filename: String) -> TaskResource:
	var path: String = TASKS_PATH + filename
	if not FileAccess.file_exists(path):
		return null
	return load(path) as TaskResource

## Lists all task resources available in the tasks directory.
func list_tasks() -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(TASKS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				files.append(file_name)
			file_name = dir.get_next()
	return files

## Deletes a task resource.
func delete_task(filename: String) -> Error:
	var path: String = TASKS_PATH + filename
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(path)
	return ERR_FILE_NOT_FOUND
