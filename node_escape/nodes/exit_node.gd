@tool
extends GameNode


func inspect() -> void:
	super.inspect()
	
	if description == "打开了":
		AudioManager.play_sound("open_door")
		text = "出口"
		description = ""
	elif text == "出口":
		Game.game_over()
