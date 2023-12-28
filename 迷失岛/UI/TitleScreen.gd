extends TextureRect

@onready var load_game = $VBoxContainer/Load

func _ready():
	if Game.has_save_file() and Game.check_sav():
		
		load_game.disabled = false
	else:
		load_game.disabled = true
		
# 新游戏
func _on_new_pressed():
	Game.new_game()
	pass # Replace with function body.

# 载入
func _on_load_pressed():
	Game.load_game()
	pass # Replace with function body.

# 离开
func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
