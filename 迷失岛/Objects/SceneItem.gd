@tool
extends "res://Objects/Interatable.gd"
class_name  SceneItem

@export var item : Item:
	set(v):
		item = v
		if item == null:
			return 
		self.texture = item.texture_scene
		notify_property_list_changed()

func _ready():
	if Engine.is_editor_hint():
		return
		
	
	var flag := _get_flag()
	if Game.flags.has(flag):
		queue_free()
	
	

		
func _interact():
	super._interact()
	Game.flags.add(_get_flag())
	Game.inventory.add(item)
	hide()
	var sprite := Sprite2D.new()
	sprite.texture = texture
	get_parent().add_child(sprite)
	sprite.global_position = global_position
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite,"scale",Vector2.ZERO,0.15).from(Vector2.ONE)
	tween.tween_callback(Callable(self,"clean_free").bind(sprite))
	
	
func clean_free(node:Node):
	if node:
		node.queue_free()
		queue_free()
		
	
func _get_flag() -> String : 
	return "picked:" + item.resource_path.get_file()
		

		
