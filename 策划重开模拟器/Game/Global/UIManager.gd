extends Node
class_name UIManager

signal scene_changed

@export var defalut_layout :Node
var current_layout : Node

func _enter_tree() -> void:
	Game.uimanager = self

func _ready() -> void:
	if current_layout == null :
		change_to(defalut_layout)
		
func change_to(layout:Node)->void:
	scene_changed.emit()
	if layout.has_method("on_scene_in"):
		layout.on_scene_in()
		
	if current_layout != null and current_layout.has_method("hide"):
		if current_layout.has_method("on_scene_out"):
			current_layout.on_scene_out()
		current_layout.hide()

	layout.show()
	current_layout = layout
	
	

func get_current_layout()->Node:
	return current_layout
	
