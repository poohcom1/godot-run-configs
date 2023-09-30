@tool
extends ConfirmationDialog

const ConfigsManager := preload("res://addons/run-configs/run-config-manager.gd")
const RunConfig := preload("res://addons/run-configs/models/run_config.gd")
const EnvEditor := preload("res://addons/run-configs/editor/controls/configs_editor/env_editor.gd")

# Config List
@onready var add_config: Button = %AddConfig
@onready var remove_config: Button = %RemoveConfig

# Form
@onready var configs_list: ItemList = %ConfigsList
@onready var name_edit: LineEdit = %NameEdit
@onready var play_mode_edit: OptionButton = %PlayModeEdit
@onready var custom_scene_edit: Button = %CustomSceneEdit
@onready var env_edit: EnvEditor = %EnvEdit

var file_dialog := EditorFileDialog.new()
var configs: Array[RunConfig] = []
var selected := 0

func _ready():
	# File dialog
	file_dialog.title = "Choose a scene"
	file_dialog.add_filter("*.tscn, *.scn", "Scenes")
	file_dialog.min_size = Vector2(600, 400)
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	add_child(file_dialog)
	file_dialog.hide()
	
	# Main setup
	configs_list.item_selected.connect(_render_form)
	about_to_popup.connect(_on_popup)
	
	# Config List
	add_config.pressed.connect(_on_add_config)
	remove_config.pressed.connect(_on_remove_config)
	
	# Form
	name_edit.text_changed.connect(func(text): _update_value(&"name", text))
	play_mode_edit.item_selected.connect(func(ind): _update_value(&"play_mode", ind))
	custom_scene_edit.pressed.connect(func(): file_dialog.popup_centered_ratio())
	file_dialog.file_selected.connect(func(file): _update_value(&"custom_scene", file))
	env_edit.changed.connect(func(envs): _update_value(&"environment_variables", envs))

	confirmed.connect(func(): ConfigsManager.set_configs(configs))


# General
func _on_popup():
	configs = ConfigsManager.load_configs()
	selected = ConfigsManager.get_current_config_index()
	_render()


func _on_add_config():
	var new_config := RunConfig.new()
	
	# Check for duplicate names
	var base_name := new_config.name
	var name := new_config.name
	var count := 2
	
	while true:
		for config in configs:
			if name == config.name:
				name = "%s (%d)" % [base_name, count]
				count += 1
			
		break
	new_config.name = name
	
	configs.append(new_config)
	selected = configs.size() - 1
	_render()
	name_edit.grab_focus()
	name_edit.select_all()


func _on_remove_config():
	if configs.size() <= 0: return
	configs.remove_at(selected)
	selected = clamp(selected, 0, configs.size() - 1)
	_render()
	

func _render():
	# Configs list
	configs_list.clear()
	
	for config in configs:
		configs_list.add_item(config.name)
	
	if configs.size() > 0:
		configs_list.select(selected if selected >= 0 else 0)
	
	remove_config.disabled = configs.size() <= 0
	 
	# Form
	_render_form(selected)


# Form
func _render_form(ind: int):
	selected = ind
	
	if selected < 0 or selected >= configs.size():
		%Form.hide()
		%Hint.show()
		return
	%Form.show()
	%Hint.hide()
	
	var config := configs[selected]
	# Name
	name_edit.text = config.name
	# Play mode
	play_mode_edit.select(config.play_mode)
	# Custom scene
	custom_scene_edit.text = config.custom_scene
	if custom_scene_edit.text.is_empty():
		custom_scene_edit.text = "Choose a scene..."
	custom_scene_edit.visible = config.play_mode == RunConfig.PlayMode.CustomScene
	# Env
	env_edit.render(config.environment_variables)


func _update_value(property: StringName, value):
	if property == &"name":
		configs_list.set_item_text(selected, value)
	elif property == &"play_mode":
		custom_scene_edit.visible = value == int(RunConfig.PlayMode.CustomScene)
	elif property == &"custom_scene":
		custom_scene_edit.text = value
		
	var config := configs[selected]
	config.set(property, value)

