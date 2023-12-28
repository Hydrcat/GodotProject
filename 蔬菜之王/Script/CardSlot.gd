extends Area2D
class_name CardSlot

# 信号
signal settled(card:Card,coord:Vector2i)

var snapping_card :Card = null
var settled_card :Card = null
# -1，-1是非法坐标
var coord :Vector2i = Vector2i(-1,-1)

@export var _size:Vector2 = Vector2.ZERO
@export var _is_show_rect:bool = false 
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func init_card_slot(pos:Vector2,crd:Vector2i,size:Vector2) -> void:
	position = pos
	coord = crd
	_size = size

func _mouse_enter() -> void:
	if Game.holding_card and settled_card == null:
		snapping_card = Game.holding_card
		snapping_card.snap_to(self)

func _mouse_exit() -> void:
	if Game.holding_card and settled_card == null:
		Game.holding_card.release()
		snapping_card = null

func _draw() -> void:
	if not _is_show_rect:return
	
	var rect := collision_shape_2d.shape.get_rect()
	draw_rect(rect,Color.BLUE,false,5.0) 

func _ready() -> void:
	set_size(_size)
	
# 初始化

# 功能区
func settle_down(card:Card) -> void:
	settled_card = card
	settled.emit(card,coord)

func set_size(to_size:Vector2)->void:
	_size = to_size
	var _rect := collision_shape_2d.shape as RectangleShape2D
	_rect.size = _size
	queue_redraw()

