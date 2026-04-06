extends GraphEdit
class_name TaskBox

@onready var add_button: Button = $AddButton

func _ready() -> void:
	# Connect zoom/pan for touch support in Godot 4.6
	panning_scheme = PAN_PADDLE
	# Loading logic will be implemented in wave 2
