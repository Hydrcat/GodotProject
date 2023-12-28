extends Control
class_name UIAttrs

@onready var points_label: Label = $VBoxContainer/MarginContainer/VBoxContainer/Header2
@onready var v_box_container: VBoxContainer = $VBoxContainer/AtrrContainer/ScrollContainer/VBoxContainer
const attr_changer_scene := preload("res://Game/Scene/ui/AttributeChanger.tscn") as PackedScene
var point_max := 10
var points := 0:
	set(v):
		points = v
		points_label.text = "剩余点数:"+str(points)
		
var point_alloc = {}

# 初始化时，生成对应attr数量的组件，并链接信号
func _ready() -> void:
	points = point_max
	var _attrs = Game.attribute.data
	for attr in _attrs:
		point_alloc[attr.key] = 0
		# 检查这个属性是否能够分配
		var isAllocable = attr["isAllocable"]
		if not isAllocable:
			continue
		# 添加组件。
		add_obj(attr.key,attr.name)

func add_obj(key:String,attr_name:String)->Node:
		var obj = attr_changer_scene.instantiate()
		obj.attr = key
		obj.attr_name = attr_name
		obj.name = key
		obj.attr_change_to.connect(attr_change_to)
		v_box_container.add_child(obj)
		return obj

func attr_change_to(attr:String,num:int):
	var num_now = point_alloc[attr]
	var add = num - num_now
	if num < 0 :return
	if add > points or points-add<0 :return
	
	points -= add
	point_alloc[attr] = num
	get_attr_obj(attr).change_attr_num(num)
	
func get_attr_obj(attr_key:String)->AtrrbuteChanger:
	for child in v_box_container.get_children():
		if child is AtrrbuteChanger and  child.name == attr_key:
			return child
	return null

func on_scene_out()->void:
	Game.attribute.set_attr(point_alloc)
