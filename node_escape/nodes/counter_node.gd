@tool
extends GameNode

var counter := 0:
	set(v):
		if counter == v:
			return
		counter = v
		if not is_inside_tree():
			await ready
		main_label.text = str(counter)
		
		Game.counter_changed.emit(id, counter)


func inspect() -> void:
	super.inspect()
	counter = (counter + 1) % 10
	AudioManager.play_sound("counter")
