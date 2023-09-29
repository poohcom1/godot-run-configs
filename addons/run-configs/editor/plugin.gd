@tool
extends EditorPlugin

const ConfigManager := preload("../run-config-manager.gd")
const RunConfig := preload("../models/run_config.gd")

const InspectorPlugin := preload("./lib/inspector_plugin.gd")
const UIExtension := preload("./lib/ui_extension.gd")
const ConfigsDropdown := preload("./controls/configs_dropdown.gd")

var play_button := Button.new()
var configs_button := ConfigsDropdown.new()

var inspector_plugin := InspectorPlugin.new()

const AUTOLOAD_PATH = &"ConfigManager"
var confg_manager_autoload := ConfigManager.new()


func _enter_tree():
	var base_control := get_editor_interface().get_base_control()
	
	# Play Button
	play_button.icon = preload("res://addons/run-configs/editor/assets/PlayConfig.svg")
	play_button.pressed.connect(_play_scene)
	play_button.tooltip_text = "Play config"
	UIExtension.add_control_to_editor_run_bar(play_button)

	# Configs button
	UIExtension.add_control_to_editor_run_bar(configs_button)
	
	# Inspector plugin
	add_inspector_plugin(inspector_plugin)
	
	# Autoload
	add_autoload_singleton(AUTOLOAD_PATH, "res://addons/run-configs/run-config-manager.gd")
	

func _exit_tree():
	# Clean-up of the plugin goes here.
	UIExtension.remove_control_from_editor_run_bar(play_button)
	UIExtension.remove_control_from_editor_run_bar(configs_button)
	
	remove_inspector_plugin(inspector_plugin)
	remove_autoload_singleton(AUTOLOAD_PATH)


func _play_scene():
	var config := ConfigManager.get_current_config()
	
	if not config:
		EditorInterface.play_main_scene()
		
	match config.play_mode:
		RunConfig.PlayMode.MainScene:
			EditorInterface.play_main_scene()
		RunConfig.PlayMode.CurrentScene:
			EditorInterface.play_current_scene()
		RunConfig.PlayMode.CustomScene:
			var scene := config.custom_scene
			EditorInterface.play_custom_scene(scene)
