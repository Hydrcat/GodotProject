extends Node2D

var tween : Tween
var target : Control
@onready var sprite_2d = $Sprite2D

func play(target:Control,img:CompressedTexture2D):
	if tween:tween.kill()
	
	sprite_2d.texture = img
	tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).chain()
	tween.tween_property(self,"global_position",target.global_position,0.5)
	var cb := func (node):
		node as Node2D
		node.queue_free()
	tween.tween_callback(cb.bind(self))
