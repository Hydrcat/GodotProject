extends Area2D
class_name Card

@onready var holder: Marker2D = $holder
@onready var num_label: Label = $Card_back/NumLabel
@onready var sprite_2d: Sprite2D = $Card_back/Sprite2D

const card_scene := preload("res://Scene/Card.tscn")

var is_holding:bool = false# 是否抓住了卡牌
var is_snaped:bool = false # 是否被吸附
var is_settled:bool = false # 是否成为固定卡牌

signal release_holding(card:Card)
signal card_leave_hand(card:Card)

var card_type :String
var card_num:int = -1 :
	set(v):
		card_num = v
		num_label.text = str(card_num)
		if card_num == 0:
			disappear()

# 被吸附的卡槽
var snaping_slot:CardSlot = null # 被吸附的卡槽
var hold_offset:Vector2 = Vector2.ZERO # 抓住的位置

var tween:Tween #动画
@export var tween_scale := 1.2


func _process(delta: float) -> void:
	_process_holding_movement(delta)

func _ready() -> void:
	hold_offset = holder.position
	
func init_card(card_res:CardRes,num:int)->Card:
	await ready
	card_type = card_res.card_type
	sprite_2d.texture = card_res.image
	sprite_2d.self_modulate = card_res.color
	card_num = num
	
	return self

# 基础交互处理 拖拽卡牌
# 抓住卡牌
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	#if Game.holding_card != null and Game.holding_card != self:
		#return
	
	var mb := event as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		# 拿起卡牌
		if mb.is_pressed() and not is_settled:
			#_viewport.set_input_as_handled()
			is_holding = true
			on_hold_card()
		# 松开卡牌
		if mb.is_released() and is_holding and not is_settled:
			is_holding = false
			on_release_card()
#region 动画区
func _mouse_enter():
	if is_settled:return
	if tween:tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE*tween_scale,0.1)

func _mouse_exit():
	if tween:tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE,0.1)
#卡牌收获时
func _on_change():
	if tween:tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).chain()
	tween.tween_property(self,"scale",Vector2.ONE*tween_scale,0.1)
	tween.tween_property(self,"scale",Vector2.ONE,0.1)
#endregion

# 卡牌状态：
## 1.抓住 自由
## 2.抓住 被吸附
## 3.松开 检测鼠标进入并播放动画
func _process_holding_movement(_delta:float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	# 如果 成为固定卡牌
	if is_settled:return
	# 抓住 自由态
	if is_holding and not snaping_slot:
		global_position = mouse_pos - hold_offset
	# 抓住 被吸附
	if is_holding and snaping_slot:
		pass
	# 成为固定卡牌
	
# 抓住卡牌时
func on_hold_card() -> void:
	
	z_index += 1
	Game.holding_card = self
	# 补充tween动画
	pass

# 松开卡牌时
func on_release_card() -> void:
	
	z_index -= 1
	Game.holding_card = null
	# 如果当前存在吸附的卡槽
	if snaping_slot:
		settle_to(snaping_slot)
	else:
		release_holding.emit(self)

func snap_to(slot:CardSlot) -> void:
	is_holding = true
	snaping_slot = slot
	global_position = slot.global_position
	print("snaped")

func release() -> void:
	is_snaped = false
	snaping_slot = null
	print("release")

func settle_to(slot:CardSlot) -> void:
	card_leave_hand.emit(self)
	is_settled = true
	is_holding = false
	global_position =  slot.global_position
	slot.settle_down(self)

##reigion after_settled
func change()->void:
	_on_change()
	card_num -= 1

func disappear()->void:
	snaping_slot.snapping_card = null
	snaping_slot.settled_card = null
	
	queue_free()
##endreigion
