extends ScrollContainer
class_name MessageController

const Sender_Names = {
	"others" = 0,
	"me" = 1,
}

@onready var message_res := preload("res://UI/message.tscn") as PackedScene
@onready var messages: VBoxContainer = $Messages
@onready var text_edit: TextEdit = $"../Reply/VBoxContainer/TextEdit"



func _ready() -> void:
	Global.LineClear.connect(add_my_words)
	
func _on_add_message(message)->void:
	# 移动到最低下
	await get_tree().process_frame
	ensure_control_visible(message)
	

func add_message(sender:int,word:String) -> Message : 
	var message := message_res.instantiate() as Message
	message._sender = sender
	message._words = word
	messages.add_child(message)
	_on_add_message(message)
	return message

func enemy_message()->Message:
	var rand = randi_range(0,Global.enemyWords.size()-1)
	var word = Global.enemyWords[rand]
	return add_message(Sender_Names["others"],word)
	
func add_my_words()->void:
	var now_words = text_edit.text
	var rand = randi_range(0,Global.meWords.size()-1)
	var word = Global.meWords[rand]
	text_edit.text = now_words + word
	
func replay()->void:
	var word := text_edit.text
	if word == "":
		return
	add_message(Sender_Names["me"],word)
	text_edit.text = ""

#var test =[
#	{"me":"我只想杀了你"},
#	{"others":"你又没有点脑子？"},
#	{"me":"我都懒得说你"},
#		{"me":"我只想杀了你"},
#	{"others":"你又没有点脑子？"},
#	{"me":"我都懒得说你"},
#		{"me":"我只想杀了你"},
#	{"others":"你又没有点脑子？"},
#	{"me":"我都懒得说你"},
#		{"me":"我只想杀了你"},
#	{"others":"你又没有点脑子？"},
#	{"me":"我都懒得说你"},
#		{"me":"我只想杀了你"},
#	{"others":"你又没有点脑子？"},
#	{"me":"我都懒得说你"},
#]
#
#var now := 0
#
#func _on_timer_timeout() -> void:
#	var dic = test[now] as Dictionary
#	var sender = Sender_Names[dic.keys()[0]]
#	var word = dic.values()[0]	
#	add_message(sender,word)
#	now +=1


func _on_timer_timeout() -> void:
	enemy_message()


func _on_button_pressed() -> void:
	replay()
	
