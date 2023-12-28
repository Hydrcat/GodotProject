extends Control


var _current_month :int = 0
@onready var event_container = $EventScene/EventContainer
@onready var event_scene = $EventScene

# 事件预制件
const event_obj := preload("res://Game/Scene/ui/EventDes.tscn")

# 申请新的事件
func _ready():
	pass

# 向事件槽增加新的事件场景
func add_event(month:int,event_des:String)->void:
	var obj := event_obj.instantiate()
	event_container.add_child(obj)
	obj.set_property(month,event_des)
	event_scene.ensure_control_visible(obj)
	
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		flow()

##### 逻辑实现部分 ########

# 显式的将整个流程暴露出来。
func flow():
	var event :int
	
	## 事件选择阶段
	if Game.branchEvent.postEvent!="":
		add_event(Game.current_month,Game.branchEvent.postEvent)
		Game.advance_time()
		Game.branchEvent.postEvent= ""
		return
	elif Game.branchEvent.branch>0:
		event = Game.branchEvent.branch
		Game.branchEvent.branch = -1
	else:
		event = Game.pick_random_event()
	
	var data := Game.get_event(event) as Dictionary

	## ui显示
	var des := data.event as String
	add_event(Game.current_month,des)
	Game.advance_time()
	
	var branch_override := data["branch_override"] as Array
	var branch :int = 0
	
	## 覆写分支
	if branch_override.size()>0:
		for _t in branch_override:
			branch = GlobalExpression.branch(_t) if GlobalExpression.branch(_t)>0 else 0
			if branch>0:
				Game.branchEvent.branch = branch
				return 
	## 效果结算
	for e in data.effects:
		GlobalExpression.effect(e)
	
	## 条件分支
	var branchs := data.branch as Array
	if branchs.size()>0:
		for _t in branchs:
			branch = GlobalExpression.branch(_t) if GlobalExpression.branch(_t)>0 else 0
			if branch>0:
				Game.branchEvent.branch = branch
				return
	## postEvent
	if data.postEvent != "":
		Game.branchEvent.postEvent = data.postEvent




