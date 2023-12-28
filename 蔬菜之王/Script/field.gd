extends TileMap
class_name Field


@export var card_size :Vector2i = Vector2i(50,50)

@onready var cards = $Cards
@onready var card_slots = $CardSlots
@onready var harvest_timer = $HarvestTimer

# 卡槽obj
const card_slot := preload("res://Scene/CardSlot.tscn")
# 收集动画
const card_collect_fx := preload("res://Scene/FX_CardCollect.tscn")
# 层枚举
const LAYER = {
	SLOT = 0 ,
	PIC = 1,
}
# 方向枚举
const DIRECTION ={
	UP = Vector2i(0,-1),
	DOWN = Vector2i(0,1),
	RIGHT = Vector2i(1,0),
	LEFT = Vector2i(-1,0),
}
# 存储数据的map,坐标->CARD
var map = {}
var isAcessCard := true

# 初始化，从slot层中获取获取田的位置。
func _ready():
	## 获取所有的卡槽位置
	var croods := get_used_cells(LAYER.SLOT)
	## 在对应的位置生成slot
	var max_w:int = 0
	var max_h:int = 0
	
	for coord in croods:
		max_w = max_w if max_w>coord.x else coord.x
		max_h = max_h if max_h>coord.y else coord.y
		var pos := map_to_local(coord) #局部坐标
		var _obj := card_slot.instantiate() as CardSlot
		_obj.name = str(coord.x)+"_"+str(coord.y)
		_obj.init_card_slot(pos,coord,card_size)
		card_slots.add_child(_obj)
		_obj.settled.connect(_set_card)
		# map 的初始化
		map[coord] = WeakRef.new()

func _set_card(card:Card,coord:Vector2i)->void:
	map[coord] = weakref(card)
	on_coords_change(coord)

func get_card_in(coord:Vector2i)->Card:
	return map[coord].get_ref() as Card
	
func find_connect_similar(coord:Vector2i)->Array:
	# 找到所有存在的邻居
	var type_card := get_card_in(coord)
	var type := type_card.card_type
	var num := type_card.card_num
	var r_array := []
	var is_readout := false
	
	r_array.append(coord)
	while not is_readout:
		# 找到当前所有的待遍历列表
		# 不在r_array中，并且存在卡牌
		var to_array := []
		for crd in r_array:
			for drt in DIRECTION.values():
				var t_crd = drt + crd
				if t_crd in map.keys() and not t_crd in r_array:
					to_array.append(t_crd)
			#var _card := get_card_in(crd)
			#if crd in r_array or _card == null or _card.card_type != type or _card.card_num != num:
				#continue
			#r_array.append(crd)
		var correct := []
		for crd in to_array:
			var _card := get_card_in(crd)
			if _card != null and _card.card_type == type and _card.card_num == num:
				correct.append(crd)
		if correct == []:
			is_readout = true
		else:
			r_array.append_array(correct)
	return r_array

func on_coords_change(coord:Vector2i)->void:
	harvest_timer.start()
	var group := find_connect_similar(coord)
	if group.size() <= 1:
		return	
	for crd in group:
		var card := get_card_in(crd)
		play_harvest(card)
		card.change()
		Game.add_score.emit(1)
		
	var group_now := find_connect_similar(coord)
	
	var t := func(num,array):return true if num in array else false
	if group_now.all(t.bind(group)):
		return
	else:
		await harvest_timer.timeout
		on_coords_change(coord)

#region 动画区
# 收获动画
func play_harvest(card:Card)->void:
	var img := card.sprite_2d.texture
	var fx := card_collect_fx.instantiate()
	add_child(fx)
	fx.global_position = card.global_position
	var target := Game.collect_target
	fx.play(target,img)

#endregion
