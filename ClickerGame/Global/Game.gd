extends Node

signal clicked
signal fans_changed

var fans : int = 0:
	set(v):
		if v!= fans:
			fans_changed.emit()
		fans = v

# 二级属性
var fans_adds_on_click :int = 1 
var fans_adds_on_timeout :float = 0.0

var _timer: Timer
var _timer_fans_adds :float = 0.0

func _enter_tree() -> void:
	clicked.connect(on_clicked)
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = 1.0
	add_child(_timer)
	_timer.timeout.connect(on_fans_add_timeout)
	_timer.start()

func on_clicked() -> void:
	fans += fans_adds_on_click
	Utils.creat_float_text(str(fans_adds_on_click),
			Clicker.instance,get_viewport().get_mouse_position())

#统计，如果达到整数级别则进行增加。
func on_fans_add_timeout() -> void:
	_timer_fans_adds += fans_adds_on_timeout
	fans += floori(_timer_fans_adds)
	fans_adds_on_timeout -= floori(_timer_fans_adds)

func get_fans() -> int :
	return fans

func buy() -> void:

	pass

