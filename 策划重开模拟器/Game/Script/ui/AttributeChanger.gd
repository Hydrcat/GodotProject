@tool
extends HBoxContainer
class_name AtrrbuteChanger

@onready var label: Label = $Label
@onready var mind: Button = $MarginContainer/AtrrChanger/mind
@onready var add: Button = $MarginContainer/AtrrChanger/add
@onready var num_label: Label = $MarginContainer/AtrrChanger/num


var attr : String:
	set(v):
		attr = v
		
var attr_name : String:
	set(v):
		attr_name = v
		
var atrr_num : int 

signal attr_change_to(attr:String,num:int)

func _ready() -> void:
	label.text = attr_name

func change_attr_num(to_num:int)->void:
	atrr_num = to_num
	num_label.text = str(atrr_num)

func _on_mind_pressed() -> void:
	var num_to := atrr_num -1
	attr_change_to.emit(attr,num_to)

func _on_add_pressed() -> void:
	var num_to := atrr_num + 1
	attr_change_to.emit(attr,num_to)
