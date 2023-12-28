extends Node
class_name StateMachine

signal state_changed(last_state:State,current_state:State)


var current_state:String
var current_state_node:State
var blackboard:StateBlackboard
var states := {}



#-------------------------------------------------------
#	set/get
#-------------------------------------------------------
func get_state_node_list() -> Array:
	return states.values()

func get_blackboard():
	if blackboard == null:
		for child in self.get_children():
			if child is StateBlackboard:
				blackboard = child
	return blackboard

func get_state_node(state) -> State:
	return states[state]	



#-------------------------------------------------------
#	内置
#-------------------------------------------------------
func _ready():
	#初始化状态机
	## 找到所有的子状态
	for child in self.get_children():
		if child is State:
			states[child.name] = child
		if child is StateBlackboard:
			blackboard = child
	if states.size() > 0:
		current_state = states.keys()[0]
		current_state_node = states[current_state]
		current_state_node._enter()
	else:
		set_physics_process(false)
		printerr("当前状态机不存在子状态，请检查")

func _physics_process(delta):
	current_state_node.state_process(delta)



#-------------------------------------------------------
#	自定义
#-------------------------------------------------------
func switch_to(state,data:Dictionary={}):
	if state != current_state:
		current_state_node._exit()
		state_changed.emit(current_state,state)
		
		current_state = state
		current_state_node = states[current_state]
		current_state_node._enter()
		

