@tool
extends EditorPlugin


const ConfigManager := preload("../run-config-manager.gd")
const RunConfig := preload("../models/run_config.gd")

const InspectorPlugin := preload("./lib/inspector_plugin.gd")
const UIExtension := preload("./lib/ui_extension.gd")
const ConfigsDropdown := preload("./controls/configs_dropdown.gd")

const RunShortcut: Shortcut = preload("res://addons/run-configs/editor/res/run_shortcut.tres")

const SETTINGS_BASE_PATH := ConfigManager.CONFIGS_BASE_PATH
const SETTINGS_SUB_PATH := "/shortcuts"

const _RUN_SHORTCUT_PATH := SETTINGS_BASE_PATH + SETTINGS_SUB_PATH + "/run_config_scene"

var play_button := Button.new()
var separator := VSeparator.new()
var configs_button := ConfigsDropdown.new()

var inspector_plugin := InspectorPlugin.new()

const AUTOLOAD_PATH = &"RunConfigManager"
var confg_manager_autoload := ConfigManager.new()


func _enter_tree():
	var base_control := get_editor_interface().get_base_control()

	# Menu Bar
	UIExtension.add_control_to_editor_run_bar(separator)
	# - Play Button
	play_button.icon = preload("res://addons/run-configs/editor/assets/PlayConfig.svg")
	play_button.pressed.connect(_play_scene)
	play_button.tooltip_text = "Run Config Scene (Shift + F5)"
	UIExtension.add_control_to_editor_run_bar(play_button)
	# - Configs button
	UIExtension.add_control_to_editor_run_bar(configs_button)

	# Inspector plugin
	add_inspector_plugin(inspector_plugin)
	
	# Settings
	var editor_settings := EditorInterface.get_editor_settings()
	if not editor_settings.has_setting(_RUN_SHORTCUT_PATH):
		editor_settings.set_setting(_RUN_SHORTCUT_PATH, RunShortcut.duplicate())
	editor_settings.set_initial_value(_RUN_SHORTCUT_PATH, RunShortcut.duplicate(), false)

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_PATH, "res://addons/run-configs/run-config-manager.gd")


func _disable_plugin() -> void:
	UIExtension.remove_control_from_editor_run_bar(separator)
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



func _input(event: InputEvent):
	var editor_settings := EditorInterface.get_editor_settings()
	var shortcut: Shortcut
	
	if editor_settings.has_setting(_RUN_SHORTCUT_PATH):
		shortcut = editor_settings.get_setting(_RUN_SHORTCUT_PATH)
	else:
		shortcut = RunShortcut
		
	if event is InputEventKey:
		if shortcut.matches_event(event) and event.is_pressed() and not event.is_echo():
			_play_scene()
