extends Node

const float_text := preload("res://Object/FLoatText.tscn")

func creat_float_text(text:String,_father:Node,pos:Vector2) -> void:
	var ft := float_text.instantiate()
	_father.add_child(ft)
	ft.global_position = pos
	ft.play(text)


## 字符串处理
func descript_process(to_process_str:String,args:Dictionary = {}) -> String:
	#TODO:增加一些判断容错，替换字符串以$Temp$类似。
	var temp_str = to_process_str
	for check_arg in args.keys() :
		temp_str = temp_str.replace(check_arg,args[check_arg])
	
	return temp_str
	