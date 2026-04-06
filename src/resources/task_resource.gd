extends Resource
class_name TaskResource

## Signal emitted when the task is completed
signal completed(task: TaskResource)

@export var title: String = ""
@export var description: String = ""
@export var created_at: int = 0
@export var deadline: int = 0: set = set_deadline
@export var completed_at: int = 0
@export var reschedule_count: int = 0
@export var tags: Array[String] = []
@export var graph_position: Vector2 = Vector2.ZERO

func _init() -> void:
	if created_at == 0:
		created_at = Time.get_unix_time_from_system()

func set_deadline(value: int) -> void:
	if deadline != 0 and value != deadline:
		reschedule_count += 1
	deadline = value

## Marks the task as complete at the current time.
func mark_complete() -> void:
	completed_at = Time.get_unix_time_from_system()
	completed.emit(self)

## Reschedules the task to a new Unix timestamp.
func reschedule(new_date: int) -> void:
	deadline = new_date

## Generates a Markdown representation of the task.
func to_markdown() -> String:
	var date_str: String = Time.get_datetime_string_from_unix_time(created_at, true)
	var md: String = "- [%s] %s" % ["x" if completed_at > 0 else " ", title]
	if not description.is_empty():
		md += "\n  - Description: %s" % description
	md += "\n  - Created: %s" % date_str
	if deadline > 0:
		var d_str: String = Time.get_datetime_string_from_unix_time(deadline, true)
		md += "\n  - Deadline: %s" % d_str
	if reschedule_count > 0:
		md += "\n  - Rescheduled: %d times" % reschedule_count
	if not tags.is_empty():
		md += "\n  - Tags: %s" % ", ".join(tags)
	return md
