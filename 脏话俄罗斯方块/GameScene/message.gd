extends MarginContainer
class_name Message

const MAX_LINE_CHAR = 18

enum SENDER_TYPE {
	Others,Me
}

@onready var others: HBoxContainer = $Others
@onready var me: HBoxContainer = $Me
@onready var label_others: Label = $Others/OthersWord/MarginContainer/Label
@onready var label_me: Label = $Me/MeWord/MarginContainer/Label

@onready var others_word: PanelContainer = $Others/OthersWord
@onready var me_word: PanelContainer = $Me/MeWord



var _sender : SENDER_TYPE
var _words :String

func _ready() -> void:
	if _sender == null or _words == null :
		printerr("非法的消息来源以及内容")
	if _sender == SENDER_TYPE.Others:
		others.show()
		me.hide()
		label_others.text = _words
	elif _sender == SENDER_TYPE.Me:
		me.show()
		others.hide()
		label_me.text = _words
		
	if _words.length() >= MAX_LINE_CHAR:
		label_me.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		others_word.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		label_others.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		me_word.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	queue_redraw()	

