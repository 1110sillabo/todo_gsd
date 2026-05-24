extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var exit_button: Button = $ExitButton
@onready var menu_button: MenuButton = $MenuButton

const MENU_SEND_JSON := 0
const MENU_STATS := 1
const MENU_QUIT := 2

func _ready() -> void:
	tab_container.set_tab_disabled(3, true)
	exit_button.pressed.connect(func(): get_tree().quit())

	var popup: PopupMenu = menu_button.get_popup()
	popup.clear()
	popup.add_item("Send JSON", MENU_SEND_JSON)
	popup.add_item("Stats", MENU_STATS)
	popup.add_item("Quit", MENU_QUIT)
	popup.set_item_disabled(popup.get_item_index(MENU_STATS), true)
	popup.id_pressed.connect(_on_menu_id_pressed)


func _on_menu_id_pressed(id: int) -> void:
	match id:
		MENU_SEND_JSON:
			_export_json()
		MENU_QUIT:
			get_tree().quit()


func _export_json() -> void:
	# --- Collect tasks ---
	var tasks_arr: Array = []
	for filename in PersistenceManager.list_tasks():
		var t: TaskResource = PersistenceManager.load_task(filename)
		if t == null:
			push_warning("_export_json: skipping corrupt task file: " + filename)
			continue
		tasks_arr.append({
			"id":               t.task_id,
			"title":            t.title,
			"description":      t.description,
			"created_at":       _unix_to_iso(t.created_at),
			"deadline":         _unix_to_iso(t.deadline),
			"completed_at":     _unix_to_iso(t.completed_at),
			"reschedule_count": t.reschedule_count,
			"tags":             t.tags,
		})

	# --- Collect notes ---
	var notes_arr: Array = []
	for filename in PersistenceManager.list_notes():
		var n: NoteResource = PersistenceManager.load_note(filename)
		if n == null:
			push_warning("_export_json: skipping corrupt note file: " + filename)
			continue
		notes_arr.append({
			"title":      n.title,
			"content":    n.content,
			"created_at": _unix_to_iso(n.created_at),
		})

	# --- Collect lists ---
	var lists_arr: Array = []
	for filename in PersistenceManager.list_lists():
		var l: ListResource = PersistenceManager.load_list(filename)
		if l == null:
			push_warning("_export_json: skipping corrupt list file: " + filename)
			continue
		var items_arr: Array = []
		for item in l.items:
			items_arr.append({
				"text":    item.title,
				"checked": item.checked,
			})
		lists_arr.append({
			"id":         l.list_id,
			"title":      l.title,
			"created_at": _unix_to_iso(l.created_at),
			"items":      items_arr,
		})

	# --- Build payload ---
	var payload: Dictionary = {
		"exported_at": Time.get_datetime_string_from_unix_time(
				int(Time.get_unix_time_from_system()), true),
		"tasks":  tasks_arr,
		"notes":  notes_arr,
		"lists":  lists_arr,
	}

	# --- Determine output path ---
	var path: String
	var label: String
	if OS.has_feature("android"):
		path  = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/todo_export.json"
		label = "Download/todo_export.json"
	else:
		path  = OS.get_user_data_dir() + "/todo_export.json"
		label = path

	# --- Write file ---
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_show_dialog("Errore: impossibile scrivere il file.\n" + path)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

	# --- Open file with system chooser (Android: triggers "Open with / Share" dialog) ---
	if OS.has_feature("android"):
		OS.shell_open(path)

	# --- Confirm ---
	_show_dialog("Salvato in " + label)


func _unix_to_iso(unix: int) -> Variant:
	if unix == 0:
		return null
	return Time.get_datetime_string_from_unix_time(unix, true)


func _show_dialog(msg: String) -> void:
	var d := AcceptDialog.new()
	d.dialog_text = msg
	add_child(d)
	d.popup_centered()
	d.confirmed.connect(d.queue_free)
	d.canceled.connect(d.queue_free)
