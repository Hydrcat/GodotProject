extends Sprite2D

@export var BGM_Overrides := ""
# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE,0.3).from(Vector2.ONE * 1.05)
	
func play_override_bgm()->void:
	AudioManager.play(BGM_Overrides)
	
