@tool
extends Interactable
class_name Stone

var target_slot : int :
	set(v):
		target_slot = v
		_update_texture()

var current_slot : int :
	set(v):
		current_slot = v
		_update_texture()

func _update_texture():
	var index := target_slot
	if target_slot != current_slot :
		index += H2AConfig.SLOT.size() - 1
	#动态加载需要使用load，preload只能使用string常量。	
	self.texture =load("res://游戏素材/场景素材/H2A/游戏素材/SS_%02d.png" % index)
	
