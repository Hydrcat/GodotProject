extends Node

const SOUND_BUS := &"Sound"
const VOLUME_MIN := -60.0
const VOLUME_MAX := 0.0

var sounds := {}


func _init() -> void:
	load_sounds("res://assets/audio/voices")
	load_sounds("res://assets/audio/sfx")


func load_sounds(path: String) -> void:
	for file in DirAccess.get_files_at(path):
		if file.get_extension() != "import":
			continue
		
		var player := AudioStreamPlayer.new()
		add_child(player)
		player.stream = load(path.path_join(file.get_basename()))
		player.bus = SOUND_BUS
		
		sounds[file.get_basename().get_basename()] = player


func has_sound(sound: String) -> bool:
	return sound in sounds


func play_sound(sound: String, xfade := 0.0, callback := Callable()) -> void:
	var player := sounds.get(sound) as AudioStreamPlayer
	if not player:
		printerr("No sound named: %s" % sound)
		return
	
	player.play()
	
	if xfade > 0:
		set_volume(0.0, player)
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_method(set_volume.bind(player), 0.0, 1.0, xfade)
	else:
		set_volume(1.0, player)
	
	if callback:
		await player.finished
		callback.call()


func stop_sound(sound: String, xfade := 0.0) -> void:
	var player := sounds.get(sound) as AudioStreamPlayer
	if not player:
		printerr("No sound named: %s" % sound)
		return
	
	if xfade > 0:
		var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_method(set_volume.bind(player), 1.0, 0.0, xfade)
		tween.tween_callback(player.stop)
	else:
		player.stop()


func set_volume(volume: float, player: AudioStreamPlayer) -> void:
	player.volume_db = to_db(volume)


func to_db(normalized: float) -> float:
	var min_linear := db_to_linear(VOLUME_MIN)
	var max_linear := db_to_linear(VOLUME_MAX)
	return linear_to_db(lerp(min_linear, max_linear, normalized))
