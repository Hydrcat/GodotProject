extends Control

@onready var v_box_container = $VBoxContainer/Talents/ScrollContainer/VBoxContainer
@export var Rare_color := {
	"1":Color.WEB_GRAY,
	"2":Color.CHARTREUSE,
	"3":Color.BLUE,
	"4":Color.BLUE_VIOLET,
}

const talent_obj := preload("res://Game/Scene/ui/TalentButton.tscn") as PackedScene
const  MAX_TALENT := 8

func add_talent(id:int)->void:
	var talent_data := Game.talents.get_talent(id) as Dictionary
	var rarity := talent_data.rarity as int
	var desc_name := talent_data.name as String
	var desc := talent_data.desc as String
	
	var obj := talent_obj.instantiate() as TalentButton
	v_box_container.add_child(obj)
	var obj_color := Rare_color[str(rarity)] as Color
	var des_s := desc_name+":"+desc
	obj.set_property(obj_color,des_s,id)

func random_pick()->void:
	var pick_array := Game.apply_talents(MAX_TALENT)
	for talent_id in pick_array:
		add_talent(talent_id)

func clear()->void:
	for child in v_box_container.get_children():
		child.queue_free()
		
func on_scene_in()->void:
	random_pick()

func on_scene_out()->void:
	var _record_event := []
	for child in v_box_container.get_children():
		child as TalentButton
		var _p = child.is_active()
		if _p != -1 :
			_record_event.append(_p)
	print(_record_event)
		
