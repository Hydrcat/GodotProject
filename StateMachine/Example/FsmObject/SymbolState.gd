extends State

@export var symbols :string
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
