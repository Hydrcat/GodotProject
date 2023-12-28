extends Button
class_name TalentButton

@onready var color_rect = $HBoxContainer/ColorRect
var id : int

func set_property(grad_color:Color,content:String,_id:int = 1000)->void:
	color_rect.color = grad_color
	self.text = content
	id = _id
	

func is_active()->int:
	if self.button_pressed == true:
		return id
	else:
		return -1
	
