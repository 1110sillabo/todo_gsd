extends Control

@onready var tab_container: TabContainer = $TabContainer

func _ready() -> void:
	tab_container.set_tab_disabled(2, true)
