extends Control

const LIST_ROW_SCENE = preload("res://src/ui/list_row.tscn")

@onready var _lists_vbox: VBoxContainer = $ListsContainer/VBoxContainer/ScrollContainer/ListsVBox
@onready var _fab: Button = $ListsContainer/VBoxContainer/FABButton
@onready var _add_dialog: AddTextDialog = $ListsContainer/AddListDialog
@onready var _lists_container: Control = $ListsContainer
@onready var _detail_view: ListDetailView = $ListDetailView

func _ready() -> void:
	$ListsContainer/VBoxContainer/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14
	_fab.pressed.connect(_on_fab_pressed)
	_add_dialog.text_confirmed.connect(_on_list_name_confirmed)
	_detail_view.back_pressed.connect(_on_back_pressed)
	_detail_view.visible = false
	_load_lists()

func _load_lists() -> void:
	for child in _lists_vbox.get_children():
		child.queue_free()
	for filename in PersistenceManager.list_lists():
		var list := PersistenceManager.load_list(filename)
		if list:
			_add_list_row(list)

func _add_list_row(list: ListResource) -> void:
	var row: ListRow = LIST_ROW_SCENE.instantiate()
	_lists_vbox.add_child(row)
	row.list = list
	row.list_open_requested.connect(_on_list_open_requested)
	row.list_deleted.connect(_on_list_deleted)

func _on_fab_pressed() -> void:
	_add_dialog.show_dialog("Nuova lista", "es. Libri da leggere...")

func _on_list_name_confirmed(text: String) -> void:
	var list := ListResource.new()
	list.title = text
	PersistenceManager.save_list(list)
	_load_lists()

func _on_list_open_requested(list: ListResource) -> void:
	_lists_container.visible = false
	_detail_view.visible = true
	_detail_view.show_list(list)

func _on_back_pressed() -> void:
	_detail_view.visible = false
	_lists_container.visible = true
	_load_lists()

func _on_list_deleted(list: ListResource) -> void:
	for filename in PersistenceManager.list_lists():
		if filename.begins_with(list.list_id):
			PersistenceManager.delete_list(filename)
			break
	_load_lists()
