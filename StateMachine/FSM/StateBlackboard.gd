class_name StateBlackboard
extends Node


var data : Dictionary = {}


func _enter_tree():
	# 状态机根节点的 blackboard 属性为自身
	get_parent().blackboard = self


