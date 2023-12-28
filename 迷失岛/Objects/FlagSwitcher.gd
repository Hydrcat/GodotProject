extends Node2D
class_name FlagSwitcher

@export var defaultNode : Node2D
@export var switchNode : Node2D

@export var flag : String

func _ready():
	defaultNode.show()
	switchNode.hide()
	Game.flags.flags_changed.connect(_upadate_nodes)
	_upadate_nodes()


func _upadate_nodes():
	var exist := Game.flags.has(flag)
	
	if defaultNode :
		defaultNode.visible = not exist
	if switchNode :
		switchNode.visible = exist	
	
	
	
