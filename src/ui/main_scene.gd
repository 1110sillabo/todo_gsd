extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var exit_button: Button = $ExitButton

func _ready() -> void:
	tab_container.set_tab_disabled(2, true)
	exit_button.pressed.connect(func(): get_tree().quit())
