extends Node2D
class_name FloatText

const MOVE_DISTANCE := 80
var tween :Tween
@onready var label: Label = $Label

func play(_text:String="Test TEXT") -> void:
	label.text = _text
	if tween:tween.kill()
	var end_pos := position + Vector2.UP * MOVE_DISTANCE
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self,"position",end_pos,1.5)
	tween.tween_property(self,"modulate:a",0,1.5)
	tween.tween_callback(func():
		queue_free()
		).set_delay(1.5)
