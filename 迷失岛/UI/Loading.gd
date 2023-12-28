extends ColorRect


@onready var label = $Label
@onready var timer = $Timer
@onready var l_timer = $Label/l_timer

@export var LOADING_TEXT := "少女祈祷中"
var timer_tween = WeakRef.new()

func _on_timer_timeout():
	SceneChanger.change_scene("res://UI/TitleScreen.tscn",true)



func _on_l_timer_timeout():
	
	var tween := timer_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(label,"text",LOADING_TEXT,0.1)	
	LOADING_TEXT += "."
	
	
