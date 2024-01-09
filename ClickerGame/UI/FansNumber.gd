extends HBoxContainer

@onready var num_label :Label= $NumLabel

func _ready() -> void:
	Game.fans_changed.connect(on_fans_changed)

func on_fans_changed()->void:
	num_label.text = str(Game.fans)
	
