extends GdUnitTestSuite

const TaskEditScript = preload("res://src/ui/task_edit_dialog.gd")

func test_parse_valid_deadline() -> void:
	var ts: int = TaskEditScript.parse_deadline("15/06/2026")
	assert_int(ts).is_greater(0)

func test_parse_empty_deadline() -> void:
	var ts: int = TaskEditScript.parse_deadline("")
	assert_int(ts).is_equal(0)

func test_parse_invalid_deadline() -> void:
	var ts: int = TaskEditScript.parse_deadline("not-a-date")
	assert_int(ts).is_equal(0)

func test_parse_zero_parts() -> void:
	var ts: int = TaskEditScript.parse_deadline("0/0/0")
	assert_int(ts).is_equal(0)

func test_format_zero() -> void:
	var result: String = TaskEditScript.format_deadline(0)
	assert_str(result).is_equal("")

func test_format_roundtrip() -> void:
	var ts: int = TaskEditScript.parse_deadline("15/06/2026")
	var formatted: String = TaskEditScript.format_deadline(ts)
	assert_str(formatted).is_equal("15/06/2026")

func test_format_roundtrip_jan() -> void:
	var ts: int = TaskEditScript.parse_deadline("01/01/2025")
	var formatted: String = TaskEditScript.format_deadline(ts)
	assert_str(formatted).is_equal("01/01/2025")
