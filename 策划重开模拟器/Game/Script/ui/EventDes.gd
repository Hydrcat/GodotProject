extends HBoxContainer
class_name EventDes

@onready var month_label = $MonthLabel
@onready var event_content = $EventContent

func set_property(month:int,content:String):
	month_label.text = str(month)
	event_content.text = content

func _enter_tree():
	pass	
