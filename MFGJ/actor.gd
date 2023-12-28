extends Node2D

enum STATE{WALK,RUN,IDLE}
enum DIRECTION{LEFT,UP,RIGHT}

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

var _current_state : int :
	set(v):
		#if not v in STATE :
		#	return
		if v == _current_direction :
			return
		_current_direction = v	
		match _current_direction :
			STATE.WALK:
				animation_player.play("move")
				pass
			STATE.RUN:
				pass
			STATE.IDLE:
				animation_player.stop()
				pass		
		
		
var  _current_direction : int :
	set(v):
		#if not v in DIRECTION : 
		#	return
		_current_direction = v
		match _current_direction :
			DIRECTION.LEFT:
				sprite_2d.flip_h = true
				pass
			DIRECTION.UP:
				pass
			DIRECTION.RIGHT:
				sprite_2d.flip_h = false
				pass			

func _ready():
	_current_state = STATE.IDLE
	pass
	
func _process(delta):
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if direction:
		_current_state = STATE.WALK
		_current_direction = direction + 1
	pass
	
	
