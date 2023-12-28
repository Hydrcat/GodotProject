extends "res://Objects/Interatable.gd"
class_name Teleporter

@export_file var target_path : String


func _interact():
	super._interact()
	SceneChanger.change_scene(target_path)
	
	

