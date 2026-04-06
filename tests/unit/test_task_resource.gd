# GdUnit Generated Test Suite
# Warning: Do not edit the generated boilerplate, but feel free to add tests.
extends GdUnitTestSuite

# Test the basic TaskResource fields and logic
func test_task_creation() -> void:
    var task := TaskResource.new()
    task.title = "Test Task"
    
    # Assert basics
    assert_str(task.title).is_equal("Test Task")
    assert_int(task.created_at).is_greater(0)
    assert_int(task.reschedule_count).is_equal(0)

# Test the reschedule logic increments the counter
func test_task_reschedule() -> void:
    var task := TaskResource.new()
    var initial_deadline: int = 1000
    var next_deadline: int = 2000
    
    task.deadline = initial_deadline
    assert_int(task.reschedule_count).is_equal(0)
    
    task.deadline = next_deadline
    assert_int(task.reschedule_count).is_equal(1)
    assert_int(task.deadline).is_equal(next_deadline)

# Test the mark_complete logic
func test_task_marking_complete() -> void:
    var task := TaskResource.new()
    assert_int(task.completed_at).is_equal(0)
    
    task.mark_complete()
    assert_int(task.completed_at).is_greater(0)

# Test serialization to markdown
func test_to_markdown_serialization() -> void:
    var task := TaskResource.new()
    task.title = "Task to serialize"
    var md_output: String = task.to_markdown()
    
    assert_str(md_output).contains("[ ] Task to serialize")
    
    task.mark_complete()
    md_output = task.to_markdown()
    assert_str(md_output).contains("[x] Task to serialize")
