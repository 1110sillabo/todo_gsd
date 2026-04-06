extends GraphEdit
class_name TaskBox

@onready var add_button: Button = $AddButton

func _ready() -> void:
	# Connect zoom/pan for touch support in Godot 4.6
	# Fallback if constant is missing in some 4.x versions
	panning_scheme = 1 # 1 is GraphEdit.PanningScheme.PAN_PADDLE
	# Loading logic will be implemented in wave 2
