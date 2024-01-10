extends Node

signal clicked
signal clicker_property_changed(p:Clicker_Property,_arg)

# 一级属性
var fans : int = 0:
	set(v):
		if v!= fans:
			clicker_property_changed.emit(Clicker_Property.FANS)
		fans = v

# 二级属性
var fans_adds_on_click :int = 1 
var fans_adds_on_timeout :int = 0

var _timer: Timer


enum Clicker_Property{
	FANS, # 粉丝
	FANS_PER_CLICK, #每次点击获取的粉丝
	FANS_PER_SECOND, #每秒获取的粉丝
}

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

func on_fans_add_timeout() -> void:
	fans += fans_adds_on_timeout

# 帮助函数，获取各个属性
func get_clicker_property(clicker_property:Clicker_Property) -> int:
	match clicker_property:
		Clicker_Property.FANS:
			return fans
		Clicker_Property.FANS_PER_CLICK:
			return fans_adds_on_click
		Clicker_Property.FANS_PER_SECOND:
			return fans_adds_on_timeout
	return -1
