@tool
extends Area2D
class_name Interactable

signal interact

@export var texture:Texture:
	set(v):
		texture = v
		if texture == null :
			return
			
		# add_child添加的节点，未设置owner，在编辑器中不可见，但在2d/3d视图中可见。
		for node in get_children():
			if node.owner == null:
				node.queue_free()
			
		var sprite = Sprite2D.new()
		sprite.texture = texture
		add_child(sprite)
		
		var shape := RectangleShape2D.new()
		shape.size = sprite.get_rect().size
		
		var collider := CollisionShape2D.new()
		collider.shape = shape
		add_child(collider)
		
@export var access_item := false


func _input_event(viewport, event, shape_idx):
	if not event.is_action_pressed("Interate"):
		return
	if not access_item and Game.inventory.active_item:
		return
	_interact()

func _interact():
					
	emit_signal("interact")
	
	
	


