extends TileMap

const WIDTH := 10
const HEIGHT := 20

@onready var wall: TileMap = $Wall
@onready var actor: TileMap = $Actor

var max_h := 99
var min_h := 0

var line_data : PackedInt32Array

func _ready() -> void:
	actor.block_settle_down.connect(settle_down)
	for line in range(0,HEIGHT):
		line_data.append(0)

func has_block_in(coords:Vector2i) -> bool:
	if get_cell_source_id(0,coords) == -1 and get_cell_source_id(1,coords) == -1:
		return false
	return true
	
func set_shadow_block(coords:Vector2i,atalas_coords:Vector2i)->void:
	set_cell(2,coords,0,atalas_coords)
	
func clear_shadow()->void:
	clear_layer(2)

func find_min_height(coords:Array[Vector2i])->int:
	var min_length := 99
	for block in coords:
		var length := 0
		while not has_block_in(block+Vector2i.DOWN*length):
			length += 1
		min_length = length if length < min_length else min_length
	min_length -= 1
	return min_length

func checkLine():
	var skip_lines := 0
	# 找到所有的满格行，并消除
	for lineAdd in range(0,HEIGHT):
		var line = HEIGHT - lineAdd -1
		if line_data[line] > WIDTH -1:
			earseLine(line)
			skip_lines += 1
		elif skip_lines > 0:	
			moveLine(line,line+skip_lines)	
	
	
func moveLine(thisLine:int,targetLine:int)->void:
	if line_data[targetLine] > 0 : return
	
	for v in range(0,WIDTH):
		var atalas_coords := get_cell_atlas_coords(0,Vector2i(v,thisLine))
		set_cell(0,Vector2i(v,targetLine),0,atalas_coords)
	line_data[targetLine] = line_data[thisLine]
	line_data[thisLine] = 0

func earseLine(line:int)->void:
	for v in range(0,WIDTH):
		set_cell(0,Vector2i(v,line),-1) 
	line_data[line] = 0
	
	Global.LineClear.emit()

func settle_down(coords:Array[Vector2i],color:Vector2i):
	for coord in coords:
		max_h = max_h if max_h > coord.y else coord.y 
		min_h = min_h if min_h < coord.y else coord.y 
		set_cell(0,coord,0,color)
		line_data[coord.y] = line_data[coord.y] + 1
	checkLine()
		
