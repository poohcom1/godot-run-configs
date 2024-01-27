extends Node

const CONFIGS_BASE_PATH := "run_configs"

const _CONFIGS_DATA_PATH := "/data"
const _CONFIGS_PATH := CONFIGS_BASE_PATH + _CONFIGS_DATA_PATH + "/configs"
const _CURRENT_CONFIG_PATH := CONFIGS_BASE_PATH + _CONFIGS_DATA_PATH + "/current"

const RunConfig := preload("res://addons/run-configs/models/run_config.gd")

func _init():
	if not OS.has_feature(&"editor"):
		return
	
	if Engine.is_editor_hint():
		return

	var config := get_current_config()
	if not config:
		return
	
	var env = config.environment_variables
	
	for key in env.keys():
		OS.set_environment(key, env[key])

	print_rich("[color=gray][Run Config][/color] [color=white]Applied environment variables from the [b]%s[/b] config." % config.name)

func _ready():
	var config := get_current_config()
	if not config: return
	if config.custom_scene != "" and get_tree().current_scene.scene_file_path != config.custom_scene:
		print_rich("[color=gray][Run Config][/color] [color=yellow][Warn][/color] The [b]%s[/b] config has a custom scene set, but the game is ran from the regular Run button. Please use the config Run button to run the custom scene." % config.name)


## API
static func get_current_config() -> RunConfig:
	var ind := get_current_config_index()
	var configs := load_configs()
	
	if ind < 0 or ind >= configs.size():
		return null

	return configs[ind]


static func load_configs() -> Array[RunConfig]:
	var settings = ProjectSettings.get_setting(_CONFIGS_PATH)

	var configs: Array[RunConfig] = []

	if not settings:
		return configs

	for json in settings:
		var config := RunConfig.new()
		config.deserialize(json)
		configs.append(config)

	return configs


static func set_configs(configs: Array[RunConfig]) -> void:
	var config_jsons = []
	
	for config in configs:
		config_jsons.append(config.serialize())
	
	ProjectSettings.set_setting(_CONFIGS_PATH, config_jsons)
	ProjectSettings.set_as_internal(_CONFIGS_PATH, true)
	ProjectSettings.save()


static func add_config(new_config := RunConfig.new()) -> void:
	var configs = ProjectSettings.get_setting(_CONFIGS_PATH)

	if not configs:
		configs = []

	configs.append(new_config.serialize())

	ProjectSettings.set_setting(_CONFIGS_PATH, configs)
	ProjectSettings.set_as_internal(_CONFIGS_PATH, true)
	ProjectSettings.save()


static func remove_config_index(ind: int) -> void:
	var configs: Array = ProjectSettings.get_setting(_CONFIGS_PATH)

	if not configs:
		configs = []
		return

	configs.remove_at(ind)

	ProjectSettings.set_setting(_CONFIGS_PATH, configs)
	ProjectSettings.set_as_internal(_CONFIGS_PATH, true)
	ProjectSettings.save()


static func set_current_config_index(id: int) -> void:
	ProjectSettings.set_setting(_CURRENT_CONFIG_PATH, id)
	ProjectSettings.save()


static func get_current_config_index() -> int:
	var ind = ProjectSettings.get_setting(_CURRENT_CONFIG_PATH)

	if ind != null:
		return ind

	return -1
