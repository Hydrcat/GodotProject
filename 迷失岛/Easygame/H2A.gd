extends Sprite2D


@export var BGM_Overrides := "res://游戏素材/音乐/OpenRoad.mp3"
@onready var borad = $Borad
@onready var gear = $Interactable/Gear


	
func _on_interactable_interact():
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(gear,"rotation",360,0.2).as_relative()
	tween.tween_callback(borad.reset)
	
	
func play_override_bgm()->void:
	AudioManager.play(BGM_Overrides)
	
