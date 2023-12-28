extends CPUParticles2D

const REFERENCE_AMOUNT := 32
const REFERENCE_WIDTH := 640.0


func _ready() -> void:
	emitting = false
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()


func _on_viewport_size_changed() -> void:
	# 下面是一道平面几何题，感谢数学老师
	var vp_size := get_viewport_rect().size
	var angle := rotation
	
	var a := sin(angle) * vp_size.y
	var width := cos(angle) * vp_size.x + a
	var b := width / 2 - a - tan(angle) * emission_rect_extents.y
	position.x = vp_size.x - b / cos(angle)
	position.y = -(tan(angle) * (width / 2 - a) + emission_rect_extents.y * cos(angle))
	
	emission_rect_extents.x = width / 2
	amount = lerp(0, REFERENCE_AMOUNT, width / REFERENCE_WIDTH) as int
