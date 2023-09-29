@tool
extends EditorInspectorPlugin

const RunConfig := preload("res://addons/run-configs/models/run_config.gd")

func _can_handle(object):
	return object is RunConfig


#func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	#if name in [&"resource_local_to_scene", &"resource_path", &"resource_name", &"script", &"metadata"]:
		#return true
#
	#if name == &"environment_variables":
		#var delete_button := Button.new()
		#delete_button.text = "Delete Config"
		#add_custom_control(delete_button)
#
	#return false


