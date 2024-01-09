extends Area2D
class_name Clicker

const T_SIZE ={
	NORMAL = 1.0,
	ENTER = 1.2,
	CILICK = 1.4,
}
const SFX_CLICK :AudioStreamOggVorbis = preload("res://Asset/Audio/click.ogg")

static var instance:Clicker

signal clicked #点击时

@onready var effect_holder = $EffectHolder
@onready var visual = $Visual

@export var rotate_speed:float = 0.0

var tween :Tween

func  _enter_tree() -> void:
	if instance == null:
		instance = self
	else:
		printerr("instance have muti!")

func _ready() -> void:
	Game.clicked.connect(on_interact)

func _process(delta: float) -> void:
	rotate(delta * rotate_speed)

# 检测交互触发
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		Game.clicked.emit()
	
# 交互触发
func on_interact()->void:
	## 动画表现
	if tween:tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).chain()
	tween.tween_property(self,"scale",Vector2.ONE * T_SIZE.CILICK,0.2).from(Vector2.ONE *T_SIZE.ENTER)
	tween.tween_property(self,"scale",Vector2.ONE * T_SIZE.ENTER,0.1)
	
	effect_holder.play_effect()
	SoundManager.play_sound(SFX_CLICK)
	
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
	

