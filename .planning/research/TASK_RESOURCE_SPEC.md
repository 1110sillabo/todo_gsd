# TaskResource Specification

The `TaskResource` is a Godot `Resource` that serves as the primary data model for the application.

## Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | `String` | Brief summary of the task. |
| `description` | `String` | Detailed notes (markdown supported). |
| `creation_date` | `int` | Unix timestamp of creation. |
| `deadline` | `int` | Unix timestamp of the deadline (0 if none). |
| `completion_date` | `int` | Unix timestamp of completion (0 if incomplete). |
| `rescheduled_count` | `int` | How many times the deadline was moved. |
| `tags` | `PackedStringArray` | Categorization tags. |
| `spatial_data` | `Dictionary` | Stores `graph_position` and potentially size for `GraphEdit`. |

## Methods

### `serialize_to_markdown() -> String`
Converts the task data into a markdown-formatted string.

**Format:**
```markdown
# [ ] {title}
- **Created:** {creation_date}
- **Deadline:** {deadline}
- **Tags:** {tags}

{description}
```

### `mark_complete()`
- Sets `completion_date` to current time.
- Emits `task_completed` signal.

## Implementation Details

```gdscript
class_name TaskResource
extends Resource

signal task_completed

@export var title: String = ""
@export var description: String = ""
@export var creation_date: int = 0
@export var deadline: int = 0
@export var completion_date: int = 0
@export var rescheduled_count: int = 0
@export var tags: PackedStringArray = []
@export var spatial_data: Dictionary = {"position": Vector2.ZERO}

func serialize_to_markdown() -> String:
    var status = "[x]" if completion_date > 0 else "[ ]"
    var md = "# %s %s\n" % [status, title]
    md += "- **Created:** %s\n" % Time.get_datetime_string_from_unix_time(creation_date)
    # ... rest of serialization logic
    return md

func mark_complete() -> void:
    completion_date = Time.get_unix_time_from_system()
    task_completed.emit()
```
