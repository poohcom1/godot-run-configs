@tool
extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var add_env_button: Button = $AddEnv

signal changed(envs: Dictionary)

var columns: Array[Array] = []

func _ready() -> void:
	add_env_button.pressed.connect(_add_column)


func render(envs: Dictionary):
	_delete_all_columns()
	
	for key in envs.keys():
		_add_column(key, envs[key])

	if columns.size() == 0:
		_add_column()

func _emit_changes():
	var envs := {}
	for column in columns:
		var key: LineEdit = column[0]
		var val: LineEdit = column[1]
		
		if not key.text.is_empty():
			envs[key.text] = val.text
			
	changed.emit(envs)


func _add_column(key_text: String = "", val_text: String = ""):
	var key := LineEdit.new()
	key.text = key_text
	key.placeholder_text = "Key"
	key.custom_minimum_size.x = 150
	key.text_changed.connect(func(txt): _emit_changes())
	
	var value := LineEdit.new()
	value.text = val_text
	value.placeholder_text = "Value"
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.text_changed.connect(func(txt): _emit_changes())
	
	var del := Button.new()
	del.icon = get_theme_icon(&"ImportFail", &"EditorIcons")
	del.pressed.connect(func(): _delete_column(del))
	
	grid_container.add_child(key)
	grid_container.add_child(value)
	grid_container.add_child(del)
	
	columns.append([key, value, del])
	_emit_changes()


func _delete_column(delete_button: Button):
	for i in range(len(columns)):
		if columns[i][2] == delete_button:
			for control: Control in columns[i]:
				control.queue_free()
			columns.remove_at(i)
			break
	_emit_changes()


func _delete_all_columns():
	for column in columns:
		for control in column:
			control.queue_free()
	columns = []
