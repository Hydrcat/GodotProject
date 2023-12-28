@tool
extends TileMap


const TetrisNanme = {
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



@export var tetrisSet : TetrisSet

@export var tetrisType :TETRIS:
	set(v):
		save_this()
		tetrisType = v
		read_this()
		
@export var roationsType :ROATIONS:
	set(v):
		save_this()
		roationsType = v
		read_this()
		
@export var save_Array = [TetrisNanme.size()]
@export var checks : Array[Vector2i]

@export var roate_checks : Array
@export var roate_checks_I : Array
@export var isSaved := false:
	set(v):
		save_all()
		isSaved = v
		
@export var isRead := false:
	set(v):
		read_all()
		isRead = v



func save_this()->void:
	print("success")
	var cell_coords = [] as Array[Vector2i]
	var cell_color :Vector2i = Vector2i.RIGHT * 99
	for cell in get_used_cells(0):
		cell_coords.append(cell)
		if cell_color.length()>10 :
			cell_color = get_cell_atlas_coords(0,cell)
	var names = ROATIONS_NAME.keys()[roationsType]
	var tables = save_Array[tetrisType]
#	tables = {
#		names : cell_coords,
#		"colors" : cell_color,
#	}
	if tables == null : 
		tables = {}
		tables[names] = cell_coords
		tables["colors"] = cell_color
		save_Array[tetrisType] = tables
	else:
		tables[names] = cell_coords
		tables["colors"] = cell_color
		save_Array[tetrisType] = tables
	
	if tetrisType == TETRIS.I :
		if roate_checks_I[roationsType] ==null:
			roate_checks_I.append(checks)
		else:
			roate_checks_I[roationsType]= checks
	else:
		if roate_checks[roationsType] ==null:
			roate_checks.append(checks)
		else:
			roate_checks[roationsType]= checks
	notify_property_list_changed()
	
	
func read_this()->void:
	var tables = save_Array[tetrisType]
	clear_layer(0)
	var names = ROATIONS_NAME.keys()[roationsType]
	var cells = tables[names]
	var this_color = tables["colors"]
	for cell in cells:
		set_cell(0,cell,0,this_color)
	if tetrisType == TETRIS.I :
		checks = roate_checks[roationsType]
	else:
		checks = roate_checks_I[roationsType]
		
	notify_property_list_changed()	

func save_all()->void:
	tetrisSet.tetrisSets = save_Array
	tetrisSet.kickChecks = roate_checks
	tetrisSet.kickChecks_I = roate_checks_I
	print(tetrisSet.kickChecks,roate_checks)

func read_all()->void:
	save_Array = tetrisSet.tetrisSets
	roate_checks = tetrisSet.kickChecks 
	roate_checks_I = tetrisSet.kickChecks_I
	pass
