extends Node

const RunConfig := preload("res://addons/run-configs/models/run_config.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not OS.has_feature(&"editor"):
		return

	var config := get_current_config()
	if not config:
		return
	
	var env = config.environment_variables
	
	for key in env.keys():
		OS.set_environment(key, env[key])

	print_rich("[color=yellow][Run Config][/color] Current config: [b]%s[/b]." % config.name)


func _process(delta):
	pass


## API
static func get_current_config() -> RunConfig:
	var ind := get_current_config_index()
	var configs := load_configs()
	
	if ind < 0 or ind >= configs.size():
		return null

	return configs[ind]


const _CONFIGS_PATH := "run_configs/data/configs"
const _CURRENT_CONFIG_PATH := "run_configs/data/current"


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
	
	# Check for duplicate names
	var base_name := new_config.name
	var name := new_config.name
	var count := 2
	
	while true:
		for json in configs:
			var config: RunConfig = RunConfig.new().deserialize(json)
			if name == config.name:
				name = "%s (%d)" % [base_name, count]
				count += 1
				continue
			
		break
		
	new_config.name = name
	

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

	if ind:
		return ind

	return 0