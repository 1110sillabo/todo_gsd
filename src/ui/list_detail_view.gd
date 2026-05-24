extends Control
class_name ListDetailView

signal back_pressed()

const LIST_ITEM_ROW_SCENE = preload("res://src/ui/list_item_row.tscn")

@onready var _title_label: Label = $VBoxContainer/HeaderPanel/HeaderHBox/TitleLabel
@onready var _items_vbox: VBoxContainer = $VBoxContainer/ScrollContainer/ItemsVBox
@onready var _fab: Button = $VBoxContainer/FABButton
@onready var _add_dialog: AddTextDialog = $AddItemDialog

var _current_list: ListResource = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 14
	$VBoxContainer/HeaderPanel/HeaderHBox/BackButton.pressed.connect(func(): back_pressed.emit())
	_fab.pressed.connect(_on_fab_pressed)
	_add_dialog.text_confirmed.connect(_on_item_name_confirmed)

func show_list(list: ListResource) -> void:
	_current_list = list
	_title_label.text = list.title
	_refresh_items()

func _refresh_items() -> void:
	for child in _items_vbox.get_children():
		child.queue_free()
	for it in _current_list.items:
		_add_item_row(it)

func _add_item_row(it: ListItemResource) -> void:
	var row: ListItemRow = LIST_ITEM_ROW_SCENE.instantiate()
	_items_vbox.add_child(row)
	row.item = it
	row.item_toggled.connect(_on_item_toggled)
	row.item_deleted.connect(_on_item_deleted)

func _on_fab_pressed() -> void:
	_add_dialog.show_dialog("Nuovo elemento", "es. Infinite Jest...")

func _on_item_name_confirmed(text: String) -> void:
	var it := ListItemResource.new()
	it.title = text
	_current_list.items.append(it)
	PersistenceManager.save_list(_current_list)
	_refresh_items()

func _on_item_toggled(it: ListItemResource) -> void:
	it.checked = not it.checked
	PersistenceManager.save_list(_current_list)
	_refresh_items()

func _on_item_deleted(it: ListItemResource) -> void:
	_current_list.items.erase(it)
	PersistenceManager.save_list(_current_list)
	_refresh_items()
