@tool
extends  Resource
class_name H2AConfig

enum SLOT {NULL,TIME,SUN,FISH,MOUNTAIN,CROSS,ROCK}

var placements := PackedInt32Array() #32整数专用的数组
# 字典,存储的是一个数组，表示是否与其他单位相链接。
# 如果希望相链接的话，数组中会添加相应的连接对象的引索
var connections := {} 

func _init():
	placements.resize(SLOT.size())
	placements.fill(SLOT.NULL)
	
	for slot in SLOT.values():
		connections[slot] = [] 
		
		
func _get_property_list():
	#返回通知godot应该保存的属性
	var propertys := [
		{
			name = "placements",
			type = TYPE_PACKED_INT32_ARRAY,
			usage = PROPERTY_USAGE_STORAGE,
		},
		{
			name = "connections",
			type = TYPE_DICTIONARY,
			usage = PROPERTY_USAGE_STORAGE,
		},

	] 
	
	#在godot4.1中，join在string上实现。
	var options := ",".join(PackedStringArray(SLOT.keys()))

	for slot in range(1,SLOT.size()):
		propertys.append({
			name = "placements/" + SLOT.keys()[slot],
			type = TYPE_INT,
			usage = PROPERTY_USAGE_EDITOR,
			hint = PROPERTY_HINT_ENUM,
			hint_string = options,
		})
		
	for slot in SLOT.size()-1:
		
		# 只向后生成选项flag
		var available := PackedStringArray()
		for dst in SLOT.size():
			if dst <= slot:
				available.append("")
			else :
				available.append(SLOT.keys()[dst])
				
		propertys.append({
		name = "connections/" + SLOT.keys()[slot],
		type = TYPE_INT,
		usage = PROPERTY_USAGE_EDITOR,
		hint = PROPERTY_HINT_FLAGS,
		hint_string = ",".join(available),
	})
	

	
	return propertys
	
func _get(property):
	if property.begins_with("placements/"):
		property = property.trim_prefix("placements/")
		var index := SLOT[property] as int
		return placements[index]
		
	if property.begins_with("connections/"):
		property = property.trim_prefix("connections/")
		var index := SLOT[property] as int
		var value := 0
		for dst in range(index + 1,SLOT.size()):
			if dst in connections[index]:
				# 位运算，将与index相连的dst位置，加入到value中，将1左移dst代表了位置，而或运算相当于“求和”
				value |= (1 << dst) 
		return value 
	
		
		
	return null

func _set(property, value):
	if property.begins_with("placements/"):
		property = property.trim_prefix("placements/")
		var index := SLOT[property] as int
		placements[index] = value
		emit_changed()
		return true
		
	if property.begins_with("connections/"):
		property = property.trim_prefix("connections/")
		var index := SLOT[property] as int
		for dst in range(index+1,SLOT.size()):
			_set_connected(index,dst,value & (1 << dst))
		emit_changed()
		return true
		
		
	return false	

func _set_connected(src:int,dst:int,isConnect:bool):
	var src_arr := connections[src] as Array
	var dst_arr := connections[dst] as Array
	
	var src_idx := src_arr.find(dst)
	var dst_idx := dst_arr.find(src)
	
	if isConnect:
		if src_idx == -1 :
			src_arr.append(dst)
		if dst_idx == -1 :	
			dst_arr.append(src)
	else :
		if src_idx != -1 :
			src_arr.erase(dst)
			#src_arr.remove_at(src_idx)
		if dst_idx == -1 :	
			dst_arr.erase(src)
			#dst_arr.remove_at(dst_idx)
	

