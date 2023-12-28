extends Node
class_name State

@onready var state_machine := self.get_parent() as StateMachine
	
#--------------------------------------#
##set get 区域
#--------------------------------------#

func get_state_machine():
	return state_machine as StateMachine

func get_current_state() -> State:
	return state_machine.get_current_state()

func get_blackboard() -> StateBlackboard:
	return state_machine.get_blackboard() 


#--------------------------------------#
# 自定义 区域
#--------------------------------------#

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



