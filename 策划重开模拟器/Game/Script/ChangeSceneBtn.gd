extends Button
class_name ChangeSceneButton

@export var next_scene : Node

func _pressed() -> void:
	if next_scene == null:
		return
		
	var uimanager := Game.get_ui_manager() as UIManager
	uimanager.change_to(next_scene)
