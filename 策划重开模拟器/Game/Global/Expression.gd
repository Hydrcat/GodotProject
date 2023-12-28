extends Node

# 需要实现的功能如下：
## 三目运算，并返回是否为true
## 检索数组中是否包含对象
## 计算Effect

var e := Expression.new()
var variable_names := []:
	get:
		var tmp := []
		## 属性值的获取
		var attr_keys := Game.attribute.get_keys()
		for key in attr_keys:
			var v = key
			tmp.append(v)
		## 当前天赋的获取
		tmp.append("TLT")
		
		## 当前经历事件的获取
		tmp.append("EVT")
		
		return tmp
var variable_value := []:
	get:
		var tmp := []
		## 属性值的获取
		var attr_keys := Game.attribute.get_keys()
		for key in attr_keys:
			var v = Game.attribute.get_value(key)
			tmp.append(v)
		## 当前天赋的获取
		tmp.append(Game.talents.record_table)
		
		## 当前经历事件的获取
		tmp.append(Game.events.get_history())
		
		return tmp

# 将速记符号替换为计算符号
func _preprocess(_expression:String,mode:String="condition")->String:
	## 输出所有符号以及关键字的组合，如果
	if mode == "condition":
		var keys = ["EVT","TLT"]
		var tmp := _expression
		for key in keys:
			tmp = tmp.replace(key+"?","is_include"+key)
			tmp = tmp.replace("[","([")
			tmp = tmp.replace("]","])")
			
		return tmp
	if mode == "effect":
		var tmp = _expression
		if tmp == "END":
			return "end_game()"
		for key in Game.attribute.get_keys():
			tmp=_expression.replace(key+":","add_attr("+key)
			tmp=tmp+")"
		return tmp
	return ""
	
	
## 条件判断 如果运算结果并非一个bool值，将报错。
func try_prase(_expression:String):
	_expression = _preprocess(_expression)
	
	var error = e.parse(_expression,variable_names)
	if error != OK:
		return null
	
	var result = e.execute(variable_value,self)
	return result

#region 运算符
func add_attr(attr_key:String,add:int)->void:
	Game.attribute.add(attr_key,add)
	
func is_include(_array:Array,t_array:Array)->bool:
	for t in t_array:
		if t in _array:
			return true
	return false
	
func end_game()->void:
	print("end_game!")
#endregion

#region 接口
## 条件表达式
func condition(e:String)->bool:
	var _e := _preprocess(e,"condition")
	var result = try_prase(_e)
	if not result is bool:
		printerr("condition result not boo:",result)
	
	return result

## 结算表达式
func effect(e:String)->void:
	var _e = _preprocess(e,"effect")
	try_prase(_e) 

func branch(e:String)->int:
	var tmp := e.split(":")
	var _condition := tmp[0]
	var _value := tmp[1]
	if condition(_condition) :
		return _value.to_int()
	else:
		return -1
#endregion
