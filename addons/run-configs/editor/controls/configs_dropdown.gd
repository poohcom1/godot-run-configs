extends MenuButton

const ConfigManager := preload("res://addons/run-configs/run-config-manager.gd")
const RunConfig := preload("res://addons/run-configs/models/run_config.gd")

const ConfigsEditorScene := preload("res://addons/run-configs/editor/controls/configs_editor/configs_editor.tscn")
const ConfigsEditor := preload("res://addons/run-configs/editor/controls/configs_editor/configs_editor.gd")

var configs_editor: ConfigsEditor
var _add_config_index := 0
var _no_config_index := 0

const DEFAULT_CONFIGS_TEXT = "..."


func _ready():
	icon = EditorInterface.get_base_control().get_theme_icon(&"GuiTreeArrowDown", &"EditorIcons")
	icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	text = DEFAULT_CONFIGS_TEXT
	configs_editor = ConfigsEditorScene.instantiate()
	configs_editor.hide()

	EditorInterface.get_base_control().add_child(configs_editor)
	configs_editor.confirmed.connect(_update, CONNECT_DEFERRED)
	
	pressed.connect(_update)
	get_popup().id_pressed.connect(_on_id_pressed)
	_update() # Make sure size is properly set to fit in screen


func _exit_tree() -> void:
	configs_editor.queue_free()


func _update():
	var popup := get_popup()
	popup.clear()
	
	var configs := ConfigManager.load_configs()
	var id := 0
	
	if configs.size() > 0:
		for config in configs:
			popup.add_check_item(config.name, id)
			id += 1
		
		popup.add_separator()
		
		_no_config_index = id
		popup.add_check_item("No config", id)
		id += 1
	else:
		popup.add_item("No configs", id)
		popup.set_item_disabled(id, true)
		id += 1
	
	var config_count := ConfigManager.load_configs().size()
	var current := ConfigManager.get_current_config_index()
	
	if current >= 0 and current < config_count:
		popup.set_item_checked(popup.get_item_index(current), true)
		# Set main button text here as well
		text = configs[current].name
	else:
		popup.set_item_checked(popup.get_item_index(_no_config_index), true)
		text = DEFAULT_CONFIGS_TEXT

	popup.add_separator()
	popup.add_item("Edit configurations...", id)
	
	_add_config_index = id


func _on_id_pressed(id: int) -> void:
	if id == _add_config_index:
		configs_editor.popup_centered_ratio(0.5)
	elif id == _no_config_index:
		ConfigManager.set_current_config_index(-1)
	else:
		ConfigManager.set_current_config_index(id)
	_update()
