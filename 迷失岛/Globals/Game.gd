extends Node

const SAVE_FILE = "user://data.sav"
const BEGIN_SCENE = "res://Scenes/scene_h1.tscn"

class Flags:
	signal flags_changed
	
	var _flags := []
	
	func has(flag:String) -> bool: 
		return flag in _flags
	
	
	func add(flag:String):
		if has(flag):
			return
		_flags.append(flag)
		
		emit_signal("flags_changed")
	
	#序列化
	func to_dict()-> Dictionary:
		return {
			flags = _flags,
		}
	
	#反序列化
	func from_dict(dict:Dictionary):
		_flags = dict.flags
		flags_changed.emit()
		
	func reset():
		_flags.clear()
		flags_changed.emit()	
		

class Inventory:
	signal inventory_changed
	
	var active_item : Item
	
	var _items := []
	var _current_item_index := -1
	
	func get_item_count() -> int:
		return _items.size()
	
	func get_current_item() -> Item:
		if _current_item_index == -1 :
			return null
		return _items[_current_item_index]
		
	func has(item:Item):
		return item in _items
	
	func add(item:Item):
		if has(item):
			return
		_items.append(item)
		# 将当前的物品栏激活为指定的物品。
		_current_item_index = get_item_count() -1 
		emit_signal("inventory_changed")
		
	func del(item:Item):
		if not has(item):
			print_debug("当前背包不存在该道具："+item.resource_name)
			return
		_items.erase(item)
		
		if _current_item_index > get_item_count() - 1:
			if get_item_count() == 0:
				_current_item_index = -1
			else:
				_current_item_index = get_item_count() - 1	
		
		emit_signal("inventory_changed")
	
	func select_next():
		if _current_item_index == -1 :
			return
		_current_item_index = (_current_item_index + 1 ) % _items.size()
		emit_signal("inventory_changed")
		
	func select_prev():
		if _current_item_index == -1 :
			return
		_current_item_index = (_current_item_index - 1 + _items.size()) % _items.size()
		emit_signal("inventory_changed")
	
	func to_dict() -> Dictionary:
		var _item_path := PackedStringArray()
		for item in _items :

			var name = item.resource_path as String
			_item_path.append(name.get_file().get_basename())
				
		return{
			item_path = _item_path,
			current_item_index = _current_item_index	
		}
		
		
	func from_dict(dict:Dictionary):
		_current_item_index = dict.current_item_index
			
		_items.clear()
		var item_path_group = dict.item_path
		for item_path in item_path_group :
			_items.append(load("res://Res/%s.tres" % item_path) )
			
		inventory_changed.emit()
			
	func reset():
		
		_current_item_index = -1
		_items.clear()
		inventory_changed.emit()
		
func save_game():
	var file := FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	if not file :
		return
	var _flags := flags.to_dict()
	var _inventory := inventory.to_dict()
	var _current_scene := get_tree().current_scene.scene_file_path.get_basename()
	var saves := {
		flags=_flags,
		inventory = _inventory,
		current_scene = _current_scene,
		}
	
	file.store_string(JSON.stringify(saves))
	
func load_game():
	if not check_sav():
		return
		
	var file := FileAccess.open(SAVE_FILE,FileAccess.READ)
	if not file:
		return
	var file_string := file.get_as_text()	
	
	var json := JSON.new()
	if not json.parse(file_string) == OK :
		return
	
	var saves = json.data 
	
	assert(saves != null)
	var _flag = saves.flags
	var _inventory = saves.inventory
	var _current_scene = saves.current_scene
	
	SceneChanger.change_scene(_current_scene + ".tscn")
	flags.from_dict(_flag)
	inventory.from_dict(_inventory)
	
func new_game():
	flags.reset()
	inventory.reset()
	SceneChanger.change_scene(BEGIN_SCENE)

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)
	
func check_sav() -> bool:
	
	var file := FileAccess.open(SAVE_FILE,FileAccess.READ)
	if not file:
		return false
	var file_string := file.get_as_text()	
	
	var json := JSON.new()
	if not json.parse(file_string) == OK :
		return false
	
	var saves = json.data as Dictionary
	
	if (not "flags" in saves.keys()) or (not "inventory" in saves.keys()) or (not "current_scene" in saves.keys()) :
		return false
	
	return true
		
	

## 实例
var flags := Flags.new()
var inventory := Inventory.new()

func back_to_menu():
	SceneChanger.change_scene("res://UI/TitleScreen.tscn",true)	
	
