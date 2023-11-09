extends Object

static var _cached_editor_run_bar: Control = null

## Search for the EditorRunBar by finding the parent of EditorRunNative
## We could just search for EditorRunBar, but finding the button's parent is less likely to break in the future
static func _get_editor_run_bar_container(root: Node = EditorInterface.get_base_control()) -> Node:
	if _cached_editor_run_bar:
		return _cached_editor_run_bar

	for child in root.get_children():
		if child.get_class() == &"EditorRunNative":
			var container = child.get_parent()
			_cached_editor_run_bar = container
			return container

		var res = _get_editor_run_bar_container(child)

		if res:
			return res

	return null


static func add_control_to_editor_run_bar(control: Control) -> void:
	var run_bar := _get_editor_run_bar_container()
	
	if not run_bar:
		printerr("[Run Configs] Could not find EditorRunBar. Please contact developer.")
		return
	
	run_bar.add_child(control)


static func remove_control_from_editor_run_bar(control: Control) -> void:
	var run_bar := _get_editor_run_bar_container()
	
	if not run_bar:
		printerr("[Run Configs] Could not find EditorRunBar. Please contact developer.")
		return
	
	run_bar.remove_child(control)
