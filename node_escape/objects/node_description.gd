extends Label

var text_tween := WeakRef.new()


func _ready() -> void:
	text = ""
	modulate.a = 0


func show_string(string: String) -> void:
	var tween := text_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if text:
		tween.tween_property(self, ^"modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): text = string)
	tween.tween_property(self, ^"modulate:a", 1.0, 0.2)
	
	text_tween = weakref(tween)


func hide_string() -> void:
	var tween := text_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): text = "")
	
	text_tween = weakref(tween)
