@tool
extends Node2D

const SLOT_TEXTURE := preload("res://游戏素材/场景素材/H2A/游戏素材/CIRCLE.png")
const LINE_TEXTURE := preload("res://游戏素材/场景素材/H2A/游戏素材/CIRCLELINE.png")

@export var _radius := 100.0 :
	set(v):
		_radius = v
		queue_redraw()

@export var _config : H2AConfig :
	set(v):
		if _config and _config.is_connected("changed",_update_board):
			_config.changed.disconnect(_update_board)
			
		_config = v	
		
		if _config and not _config.is_connected("changed",_update_board):
			_config.changed.connect(_update_board)
			
		_update_board()

var _slot_size = H2AConfig.SLOT.size()
var _stone_map = {}
var _stone_pool = []

func _update_board():
	for node in get_children():
		if node.owner == null:
			node.queue_free()
			
	if not _config :
		return

	# 放置线
	for src in _slot_size :
		for dst in range(src + 1, _slot_size):
			if not dst in _config.connections[src] :
				continue
			var line = Line2D.new()
			add_child(line)		
			line.texture = LINE_TEXTURE
			line.width = LINE_TEXTURE.get_height()
			line.add_point(_get_slot_pos(src))
			line.add_point(_get_slot_pos(dst)) 
			line.texture_mode =Line2D.LINE_TEXTURE_TILE
			line.default_color = Color.WHITE
			line.show_behind_parent = true
	queue_redraw()			
	
	# 放置棋子
	
	for slot in range(1,H2AConfig.SLOT.size()) :
		var stone = Stone.new()
		add_child(stone)
		stone.target_slot = slot
		stone.current_slot = _config.placements[slot]	
		stone.position = _get_slot_pos(stone.current_slot)
		#_stone_map[slot] = stone
		_stone_pool.append(stone)
		stone.interact.connect(_request_move.bind(stone))		
			



func _draw():
	for slot in _slot_size :
		draw_texture(SLOT_TEXTURE,_get_slot_pos(slot) - SLOT_TEXTURE.get_size()/2)
			
func _get_slot_pos(slot:int) -> Vector2:
	return Vector2.DOWN.rotated(TAU / _slot_size * slot) * _radius

func _request_move(stone:Stone):
	var available := H2AConfig.SLOT.values()
	
	#没有主动维护stone_map的原因，这里记录的是全部的stone,并通过删除stone的位置来确保空余位置。
#	for s in _stone_map.values():
#		available.erase(s.current_slot)
	
	for s in _stone_pool:
		available.erase(s.current_slot)
	
	assert(available.size() == 1)
	var available_slot := available.front() as int
	if available_slot in _config.connections[stone.current_slot]:
		_move_stone(stone,available_slot)
		
func _move_stone(stone:Stone,slot:int):
	stone.current_slot = slot
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(stone,"position",_get_slot_pos(slot),0.2)
	_check_end()
	
func _check_end():
	for s in _stone_pool :
		if s.current_slot != s.target_slot:
			return	
	_finish_H2A()
	
func _finish_H2A():
	SceneChanger.change_scene("res://Scenes/scene_h2.tscn")
	Game.flags.add("h2a_finished")
				
func reset():
	for s in _stone_pool :
		_move_stone(s,_config.placements[s.target_slot])
		
