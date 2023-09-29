extends Object

static func _get_editor_run_bar_container() -> Node:
	return EditorInterface.get_base_control() \
			.get_child(0) \
			.get_child(0) \
			.get_child(4) \
			.get_child(0) \
			.get_child(0) 


static func add_control_to_editor_run_bar(control: Control) -> void:
	_get_editor_run_bar_container().add_child(control)


static func remove_control_from_editor_run_bar(control: Control) -> void:
	_get_editor_run_bar_container().remove_child(control)
