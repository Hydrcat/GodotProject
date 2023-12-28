extends Node

const float_text := preload("res://Object/FLoatText.tscn")

func creat_float_text(text:String,_father:Node,pos:Vector2) -> void:
	var ft := float_text.instantiate()
	_father.add_child(ft)
	ft.global_position = pos
	ft.play(text)
