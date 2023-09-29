@tool
extends OptionButton

func _ready():
	clear()
	add_icon_item(get_theme_icon(&"Play", &"EditorIcons"), "Main Scene")
	add_icon_item(get_theme_icon(&"PlayScene", &"EditorIcons"), "Current Scene")
	add_icon_item(get_theme_icon(&"PlayCustom", &"EditorIcons"), "Custom Scene")

	select(0)
