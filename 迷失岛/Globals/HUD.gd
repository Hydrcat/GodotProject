extends CanvasLayer
@onready var menu = $Menu
@onready var inventory = $Inventory

func _ready():
	SceneChanger.isNotGameScene.connect(_on_change_scene)

func _on_menu_pressed():
	Game.save_game()
	Game.back_to_menu()

func _on_change_scene(isNotGameScene:bool):
	if isNotGameScene:
		self.hide()
	else:
		self.show()
