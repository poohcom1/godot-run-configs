@tool
extends Resource

enum PlayMode { MainScene, CurrentScene, CustomScene }

@export_category("Run Config")

## Name of config
@export var name: String = "Config"

## Play mode when launched
## See [enum PlayMode]
@export var play_mode: PlayMode:
	set(val):
		play_mode = val
		if play_mode != PlayMode.CustomScene:
			custom_scene = ""
		notify_property_list_changed()
## Custom scene to launch
@export_file("*.tscn", "*.scn") var custom_scene: String

## Environment variables
@export var environment_variables: Dictionary


# Serialization
func serialize() -> String:
	var dict := {
		"name": name,
		"play_mode": play_mode,
		"custom_scene": custom_scene,
		"environment_variables": environment_variables
	}
	
	return JSON.stringify(dict)


func deserialize(json: String) -> Resource:
	var dict := JSON.parse_string(json)
	
	name = dict.name
	play_mode = dict.play_mode
	custom_scene = dict.custom_scene
	environment_variables = dict.environment_variables
	
	return self


# Editor 
func _validate_property(property: Dictionary):
	if property.name == &"custom_scene" and play_mode != PlayMode.CustomScene:
		property.usage |= PROPERTY_USAGE_READ_ONLY
