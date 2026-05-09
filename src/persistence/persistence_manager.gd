extends Node

const TASKS_PATH: String = "user://tasks/"

func _init() -> void:
	if not DirAccess.dir_exists_absolute(TASKS_PATH):
		DirAccess.make_dir_recursive_absolute(TASKS_PATH)

## Saves a TaskResource to the specified path.
func save_task(task: TaskResource) -> Error:
	var path: String = TASKS_PATH + "%s.tres" % task.task_id
	return ResourceSaver.save(task, path)

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

# ---------- Notes ----------

const NOTES_PATH: String = "user://notes/"

## Saves a NoteResource to disk.
func save_note(note: NoteResource) -> Error:
	if not DirAccess.dir_exists_absolute(NOTES_PATH):
		DirAccess.make_dir_recursive_absolute(NOTES_PATH)
	var path: String = NOTES_PATH + "%s.tres" % note.title.validate_filename()
	return ResourceSaver.save(note, path)

## Loads a NoteResource from the specified filename.
func load_note(filename: String) -> NoteResource:
	var path: String = NOTES_PATH + filename
	if not FileAccess.file_exists(path):
		return null
	return load(path) as NoteResource

## Lists all note resource filenames.
func list_notes() -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(NOTES_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				files.append(file_name)
			file_name = dir.get_next()
	return files

## Deletes a note resource.
func delete_note(filename: String) -> Error:
	var path: String = NOTES_PATH + filename
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(path)
	return ERR_FILE_NOT_FOUND
