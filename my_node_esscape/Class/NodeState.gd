extends State
class_name NodeState


#--------------------------------------#
# 自定义 区域
#--------------------------------------#

@export var node_name := ""
@export var node_description := ""


## 1.进入动作
func _enter(data:Dictionary = {}):
	pass

## 2.离开动作	
func _exit():
	pass	

## 3.输入动作
func state_process(delta):
	pass

## 4.转移动作
func switch_to(next_state,data:Dictionary={}):
	return state_machine.switch_to(next_state,data)
	
## 5.节点被高亮时
func on_focus():
	pass

## 6.节点被单击时
func on_clicked():
	pass

## 7.节点被拖动到另一个节点上时。
func on_drag_in(game_node:GameNode):
	pass		
	
## 8.节点被进入时	
func on_be_enter_in(game_node:GameNode):
	pass		
