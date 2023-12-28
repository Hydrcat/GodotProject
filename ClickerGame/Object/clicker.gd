extends Area2D
class_name Clicker

var tween :Tween
const T_SIZE ={
	NORMAL = 1.0,
	ENTER = 1.2,
	CILICK = 1.4,
}

@export var sounds : SoundsGroup
@onready var effect_holder = $EffectHolder

# 检测交互触发
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		on_interact()
	pass
	
# 交互触发
func on_interact()->void:
	## 动画表现
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).chain()
	tween.tween_property(self,"scale",Vector2.ONE * T_SIZE.CILICK,0.2).from(Vector2.ONE *T_SIZE.ENTER)
	tween.tween_property(self,"scale",Vector2.ONE * T_SIZE.ENTER,0.1)
	
	## 飘字
	var pos := get_viewport().get_mouse_position()
	Utils.creat_float_text("+1000",self,pos)
	var sds := sounds.sounds
	SoundManager.play_sound(sds.pick_random())
	effect_holder.play_effect()
	
# 鼠标进入
func _mouse_enter() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self,"scale",Vector2.ONE *T_SIZE.ENTER,0.3)
	
# 鼠标离开
func _mouse_exit() -> void:
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE *T_SIZE.NORMAL,0.3)
	

