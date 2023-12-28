extends CanvasLayer

signal isNotGameScene(judge:bool)

@onready var color_rect = $ColorRect



func change_scene(path:String,isNotGameScene := false):

	if isNotGameScene :
		emit_signal("isNotGameScene",true)
	
	else:
		emit_signal("isNotGameScene",false)
		
	var tween := create_tween()
	tween.tween_callback(Callable(color_rect,"show"))
	tween.tween_property(color_rect,"color:a",1.0,0.2)
	tween.tween_callback(Callable(self,"call_change_scene").bind(path))
	tween.tween_property(color_rect,"color:a",0.0,0.3)
	tween.tween_callback(Callable(color_rect,"hide"))
	
	
func call_change_scene(path:String) -> void:
	
	var next_scene := load(path).instantiate() as Node
	get_tree().change_scene_to_file(path)
	
	if next_scene.has_method("play_override_bgm"):
		next_scene.play_override_bgm()

