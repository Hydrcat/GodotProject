extends TileMap
class_name Actor

const MoveDuration := 1.0
const BlockSize := 32

const TETRIS_NAME = {
	"I" = 0,
	"J" = 1,
	"L" = 2,
	"O" = 3,
	"S" = 4,
	"T" = 5,
	"Z" = 6,
}

const ROATIONS_NAME ={
	"DEFAULT" = 0,
	"R" = 1,
	"DOUBLE" = 2,
	"L" = 3,
}

enum TETRIS {
	I,J,L,Q,S,T,z
}

enum ROATIONS {
	DEFAULT,R,DOUBLE,L
}

@onready var wall: TileMap = $"../Wall"
@onready var world: TileMap = $".."

@export var tetrisSet : TetrisSet

var _tetris = []
var _blocks_set = {}

var _current_set = {}
var _current_tetris : String
var _current_roation : String
var _current_color : Vector2i

## 踢墙检查表，通过tetris型以及来引索
var _current_kick_checks  = {}

signal block_settle_down(coords:Array[Vector2i],color:Vector2i)


func block_init()->void:
	_tetris = tetrisSet.tetrisSets
	var kickCheckArray = tetrisSet.kickChecks
	var kickCheckArrayI = tetrisSet.kickChecks_I
	
	for tetris in TETRIS_NAME.keys():
		for roation in ROATIONS_NAME.keys():
			var roation_next = get_roation(roation,1)
			var roation_prev = get_roation(roation,-1)
			var key_R := tetris+":"+ roation+"->"+roation_next as String
			var key_L := tetris+":"+ roation+"->"+roation_prev as String
			var value_R = []
			var value_L = []
			if tetris == "I":
				value_R = kickCheckArrayI[ROATIONS_NAME[roation]]
				value_L = kickCheckArrayI[ROATIONS_NAME[roation_prev]]
			else:
				value_R = kickCheckArray[ROATIONS_NAME[roation]]
				value_L = kickCheckArray[ROATIONS_NAME[roation_prev]]
			
			for value in value_L :
				value = value * -1
			_current_kick_checks[key_R] = value_R
			_current_kick_checks[key_L] = value_L

func _ready() -> void:
	block_init()
	reset_self()
	
func _handle_input(delta:float)->void:
	if Input.is_action_just_pressed("game_left"):
		move(Vector2i.LEFT)
	if Input.is_action_just_pressed("game_right"):
		move(Vector2i.RIGHT)
	if Input.is_action_just_pressed("game_Hasten"):
		hasten()
	if Input.is_action_just_pressed("game_TurnClockWise"):
		roate(1)
	if Input.is_action_just_pressed("game_TurnCounterClockWise"):
		roate(-1)

func _process(delta: float)->void:
	_handle_input(delta)

func move(direction:Vector2i)->bool:
	## 先忽略砖块的检查
	for block in get_used_cells(0):
		var block_global := coords_to_global(block)
		var block_moved := block_global + direction
		if _has_block_in(block_moved):return false
		print(block_global,block_moved)
	position += Vector2(direction * BlockSize)
	set_shadow()
	return true
	
func hasten()->void:
	var min_height := _find_min_height()
	move(Vector2i.DOWN * min_height)
	settle_down()
	
func settle_down() -> void:
#	for block in get_used_cells(0):
#		var block_global := coords_to_global(block)
#		var altas_coords := get_cell_atlas_coords(0,block)
#		world.set_cell(0,block_global,0,altas_coords)
	var coords = get_global_coords()
	block_settle_down.emit(coords,_current_color)
	reset_self()	
		
func reset_self()->void:
	## 位置记得重新重置。
	clear_layer(0)
	position = Vector2.ZERO
	
	var rand = randi_range(0,TETRIS_NAME.size()-1)
	born(rand)

func born(tetris_enum:int)->void:
	_current_set = _tetris[tetris_enum]
	_current_tetris = TETRIS_NAME.keys()[tetris_enum]
	_current_roation = "DEFAULT"
	_current_color = _current_set["colors"]
	reshape()
	

func get_roation(Current:String,Roation:int)->String:
	var index = ROATIONS_NAME[Current] as int
	index = (index + Roation+ROATIONS_NAME.size()) % ROATIONS_NAME.size()
	return ROATIONS_NAME.keys()[index]

func roate(direction:int)->bool:
	## 这里增加旋转判断和踢墙
	## 检查 是右旋还是左旋。
	
	if kick_wall_check(direction):
		_current_roation = get_roation(_current_roation,direction)
		reshape()
		return true
	return false	

func kick_wall_check(direction:int)->bool:
	var next_roation := get_roation(_current_roation,direction)
	var coords_try : Array[Vector2i]
	var coords_now := get_global_coords(_current_set[next_roation]) as Array[Vector2i]
	
	var check_key := _current_tetris+":"+_current_roation+"->"+next_roation
	var check_values = _current_kick_checks[check_key]
	
	for offset in check_values:
		coords_try = []
		for coord in coords_now:
			coords_try.append(coord+offset)
		if not is_collosion(coords_try):
			move(offset)
			return true
	return false

func reshape():
	clear_layer(0)
		
	var colors = _current_color
	for cell in _current_set[_current_roation] :
		set_cell(0,cell,0,colors)
	set_shadow()	

func set_shadow()->void:
	# 实际上就是找到凸边距离正下方最短的那一个block，并依据这个block的移动距离设置高度就好
	# 对每个砖块找到最后一个非空格，并存入表内
	world.clear_shadow()
	var coords_global := get_global_coords()
	var min_length := _find_min_height(coords_global)
	
	for block in get_used_cells(0):
		var block_global := coords_to_global(block)
		var block_atas_coord := get_cell_atlas_coords(0,block)
		world.set_shadow_block(block_global+Vector2i.DOWN*min_length,block_atas_coord)

func _on_drop_timer_timeout() -> void:
	if !move(Vector2.DOWN):settle_down()

func _has_block_in(global_coords_position)->bool:
	var world = get_parent() as TileMap
	return world.has_block_in(global_coords_position)

func is_collosion(coords:Array[Vector2i])->bool:
	for coord in coords:
		if _has_block_in(coord):
			return true
	return false		
	
func _find_min_height(_coords:Array[Vector2i] = [])->int:
	var coords = _coords if _coords else get_global_coords()
	return world.find_min_height(coords)

func get_global_coords(_coords_overrides:Array[Vector2i] = [])->Array[Vector2i]:
	var coords = [] as Array[Vector2i]
	var locals =[] as Array[Vector2i]
	if _coords_overrides != [] :
		locals = _coords_overrides
	else:
		locals = get_used_cells(0)	
	for block in locals:
		coords.append(coords_to_global(block))
	return coords	

func coords_to_global(local_grid_position:Vector2i)->Vector2i:
	var world = get_parent() as TileMap
	var location =  to_global(map_to_local(local_grid_position))
	var world_coord = world.local_to_map(location)
	return world_coord
