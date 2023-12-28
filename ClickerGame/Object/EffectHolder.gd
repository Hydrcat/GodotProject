extends Node2D

@export var effect : PackedScene
var _effect_pool :Array[GPUParticles2D] =[]

# 播放特效
func play_effect()->void:
	var ef : GPUParticles2D
	if _effect_pool.is_empty():
		effect_create()

	ef = _effect_pool.pop_back() as GPUParticles2D
	ef.restart()
	#ef.emitting = true

func effect_create()->void:
	var ef := effect.instantiate() as GPUParticles2D
	add_child(ef)
	ef.finished.connect(effect_end.bind(ef))
	_effect_pool.append(ef)

func effect_end(this:GPUParticles2D) -> void:
	_effect_pool.append(this)

