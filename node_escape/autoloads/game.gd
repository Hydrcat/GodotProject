extends CanvasLayer

signal node_active(node: GameNode)
signal node_appeared(node: GameNode)
signal trigger_activated(trigger: StringName)
signal counter_changed(id: int, count: int)

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	randomize()


func game_over() -> void:
	animation_player.play(&"fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/game_over_scene.tscn")
	animation_player.play(&"fade_in")
