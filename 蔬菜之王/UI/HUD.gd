extends Control

var tween:Tween
@onready var score_contain = $score
@onready var header = $score/HEADER
@onready var score = $score/SCORE

var score_num :int = 0:
	set(v):
		score_num = v
		score.text =str(score_num)

func _ready():
	Game.collect_target = score
	Game.add_score.connect(_on_collect)
	score_num = 0
	
func _on_collect(add:int)->void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).chain()
	tween.tween_property(score_contain,"scale",Vector2.ONE*1.2,0.3)
	score_num += add
	tween.tween_property(score_contain,"scale",Vector2.ONE,0.3)
