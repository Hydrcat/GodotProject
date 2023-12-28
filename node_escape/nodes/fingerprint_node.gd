@tool
extends GameNode

var expect: Array[int] = [25, 24, 22, 26, 23]
var actual: Array[int] = [0, 0, 0, 0, 0]
var current_index := 0

var unlocked := false

@onready var indicators: HBoxContainer = $MainPanel/Margin/V/Indicators


func update_indicators() -> void:
	for i in actual.size():
		var c := indicators.get_child(i) as ColorRect
		c.color = Color.RED if i < current_index else Color.WHITE


func accept_drop(node: GameNode) -> bool:
	if unlocked:
		return false
	
	if not node.id in [22, 23, 24, 25, 26]:
		return false
	
	AudioManager.play_sound("meat")
	actual[current_index] = node.id
	current_index += 1
	
	update_indicators()
	
	if current_index == actual.size():
		unlocked = actual == expect
		
		if unlocked:
			AudioManager.play_sound("correct")
			Game.trigger_activated.emit(&"unlock")
		else:
			AudioManager.play_sound("wrong")
			shake_head(func():
				current_index = 0
				update_indicators()
			)
	
	return true
