extends Node

const AMBIENT_SOUND := "Amb_Countryside_Night_Birds_Cow_Cricket"

@onready var game_node_manager: GameNodeManager = %GameNodeManager


func _ready() -> void:
	AudioManager.play_sound(AMBIENT_SOUND, 2.0)
	
	game_node_manager.setup_nodes.call_deferred([
		{
			id=0,
			pid=-1,
			text="T",
		},
		{
			id=1,
			pid=0,
			text="H",
		},
		{
			id=2,
			pid=1,
			text="E",
		},
		{
			id=3,
			pid=2,
			text="END",
		},
		{
			id=4,
			pid=3,
			text="FIN",
		},
		{
			id=5,
			pid=3,
			text="完",
		},
		{
			id=6,
			pid=3,
			text="终了",
		},
	])
