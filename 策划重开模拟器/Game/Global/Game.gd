extends Node

signal scene_changed(target_scene)
signal on_event(month:int,event_content:String,_set_args:Array)

@export var uimanager : UIManager

signal EndGame
# 记录配置表的路径以及关键字。
const TABLE_SETS := {
	attribute = "res://Datas/attribute.json",
	events_pool = "res://Datas/timeline.json",
	events = "res://Datas/event.json",
	talents = "res://Datas/talents.json",
}

# 用这种class的做法合理吗
var attribute := Attribute.new()
var events_pool := MonthEvents.new()
var talents := Talents.new()
var events := Event.new()                     

var branchEvent := {
	branch = -1,
	postEvent = "",
}

var current_month := 0

# Game全局单例只负责初始化，反序列化配置。

# 属性类，存储原始数据，记录人物状态，并提供操作接口。
# 操作接口
class Attribute :
	var data := []
	var _record_table := {}
	
	func from_sets(sets:Array)->void:
		data = sets
		var obj = {}
		for attr in sets:
			obj[attr.key] =0
		_record_table = obj
	
	# 拿到所有的属性键
	func get_keys()-> Array:
		var keys := []
		for attr in data:
			keys.append(attr.key)
		return keys
		
	func get_value(key:String)->int:
		return _record_table[key]
	
	func add(key:String,add_value:int):
		_record_table[key]+= add_value 
	
	func set_attr(to_dict:Dictionary)->void:
		for attr_key in to_dict:
			if not get_keys().has(attr_key):
				print("Error Data:dont have right key")
				return
				
			_record_table[attr_key] = to_dict[attr_key]
	
	func reset()->void:
		for attr in _record_table.keys():
			_record_table[attr] = 0

# talents
class Talents:
	var data:= {}
	var record_table = []
	func from_sets(sets:Dictionary)->void:
		data = sets
	
	func take_it(id:int)->void:
		if has(id): record_table.append(id)
		
		print("don't have it"+str(id))
	
	func get_talent(id:int)->Dictionary:
		return data[float(id)]
	
	func has(id:int)-> bool:
		return record_table.keys().has(id)
	
	func filter(v_key:String)->Array:
		var _t := []
		for id in data :
			_t.append(get_talent(id)[v_key]) 
		return _t
	func get_weights()->Array:
		var raritys := filter("rarity")
		var _t := []
		for r in raritys :
			_t.append(float(r))
		return _t
		
	
# 事件的keys用month，并且分割字符串，将权重增减。
class MonthEvents:
	const defalut_weight := 1.0
	var current_month := 0
	var data := []
	var events := {}
	func from_sets(sets:Array)->void:
		data = sets 
		var obj = {}
		for v in sets:
			var temp := {
				events = PackedInt32Array(),
				weights = PackedFloat32Array(),
			}
			for value in v.events:
				var split_arry := value.split("*") as PackedStringArray
				var num = split_arry[0].to_int()
				var weight = split_arry[1].to_float() if split_arry.size()>1 else defalut_weight
				temp.events.append(num)
				temp.weights.append(weight)
			obj[v.month] = temp
		events = obj
		print(events)
	func get_pool(month:int)->Dictionary:
		return events[float(month)]

# 事件
class Event:
	var data = {}
	var _history_keys = []
	
	func from_sets(sets:Dictionary)->void:
		data = sets
		
	func take_it(id:int)->void:
		if has(id):_history_keys.append(id)
		
	func has(id:int)->bool:
		var ids := data.keys()
		return ids.has(id)
	
	func already_happend(id:int)->bool:
		if id in _history_keys:
			return true
		else:
			return false
			
	func get_history()->Array:
		return _history_keys
	
	func get_set(id:int)->Dictionary:
		return data[float(id)]
		
# 将luban序列化的数据，按数组的方式储存
func read_table(json_path:StringName):
	var file := FileAccess.open(json_path,FileAccess.READ)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		printerr("未能读取对应配置")
		return {}
	var data = json.data
	return data

# 根据luban序列化数据的特征，将读取的数据存储为key为id的表。
func require_sets(json_path:StringName)->Dictionary:
	var file := FileAccess.open(json_path,FileAccess.READ)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		printerr("未能读取对应配置")
		return {}
	var data = json.data
	var final = {}
	for value in data:
		var key = value[value.keys()[0]]
		final[key] = value
	return final

func _ready() -> void:
	events_pool.from_sets(read_table(TABLE_SETS.events_pool))
	attribute.from_sets(read_table(TABLE_SETS.attribute))
	talents.from_sets(require_sets(TABLE_SETS.talents))
	events.from_sets(require_sets(TABLE_SETS.events))
	

func get_ui_manager() -> UIManager:
	if uimanager:
		return uimanager
	else:
		printerr("not exist uimanager!")
		return null

#TODO:finish random_pick(origin:array,weights:array)->variants
func random_pick(pool:Array,weights:Array)-> int:
	assert(pool.size()==weights.size())
	
	var sum : float = 0.0
	for weight in weights :
		sum += weight
	var rand = randf_range(0.0,sum)
	var now : float = 0.0
	
	for p in pool.size():
		var weight := weights[p] as float
		now += weight
		if rand <= now:
			return pool[p]
	return pool[pool.size()-1]

func pick_random_event(_month:int = current_month) -> int:
	var _events_pool := events_pool.get_pool(_month) as Dictionary
	var _events_id := _events_pool["events"] as Array
	var _events_extra_weights := _events_pool["weights"] as Array
	
	assert(_events_id.size() == _events_extra_weights.size())
	var tmp := []
	var tmp_weights := []
	# 检查是否满足条件，如果不满足，则从池子里删除。
	for p in _events_id.size():
		var _id = _events_id[p]
		if check_event_condition(_id):
			if get_event(_id)["isNotRandom"] == true:
				continue
			tmp.append(_id)
			tmp_weights.append(_events_extra_weights[p] * get_event(_id)["grade"])
	var picked := random_pick(tmp,tmp_weights)
	return picked 

# 涉及到解析公式
func check_event_condition(event_id:int)->bool:
	var event_data := Game.events.get_set(event_id) as Dictionary
	var include := event_data.include as String
	var exclude := event_data.exclude as String
	
	var is_include :bool
	var is_exclude :bool
	
	if include != "":
		is_include = GlobalExpression.condition(include)
	else:
		is_include = true
	
	is_exclude = GlobalExpression.condition(exclude) if exclude!="" else false
	
	return is_include and not is_exclude

func get_event(id:int)->Dictionary:
	return Game.events.get_set(id)

func advance_time()->void:
	current_month+=1

func apply_talents(Count:int)->PackedInt64Array:
	# 一个一个的挑，
	var _temp : PackedInt64Array =[]
	var data := talents.data
	var ids := data.keys()
	var weights := talents.get_weights()
	
	while _temp.size() < Count:
		var _id := random_pick(ids,weights)
		var _talent := talents.get_talent(_id)
		var _exclude := _talent.exclude as PackedInt64Array
		_exclude.append(_id)
		
		var canAdd := not check_cross(_exclude,_temp)
		if canAdd :
			_temp.append(_id)
	
	return _temp

func check_cross(array1:Array,array2:Array)->bool:
	for v in array1:
		if array2.has(v):
			return true
	return false
	
func _on_end_game()->void:
	pass
