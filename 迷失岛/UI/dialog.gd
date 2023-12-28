extends Control

var _dialogs := []
var _current_line := -1

@onready var content = $Content

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func show_dialog(dialogs:Array):
	
	if _dialogs == dialogs and _current_line > -1 :
		_advance()
		return 
	_dialogs = dialogs # 引用，避免修改
	_show_line(0)
	show()
	
func _show_line(line:int):
	_current_line = line
	content.text = _dialogs[line]
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE,0.2).from(Vector2.ONE * 0.2)

func _advance():
	if _current_line + 1 < _dialogs.size():
		_show_line(_current_line + 1)
	else:
		
		hide()
		_current_line = -1



func _on_content_gui_input(event):
	if not event.is_action_pressed("Interate"):
		return
	_advance()

