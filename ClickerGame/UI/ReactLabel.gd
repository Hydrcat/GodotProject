extends HBoxContainer
class_name ReactLabel

@export var property_listen :Game.Clicker_Property
@export var label_name :String
@export var label_num :int 

@onready var text_label :Label = $TextLabel
@onready var num_label :Label = $NumLabel


func _ready() -> void:
    if label_name == null or label_num == null :
        printerr("不合法的标签配置:",self)
    init_label(label_name,label_num)
    Game.clicker_property_changed.connect(update_label)

func init_label(l_name:String,l_num:int)->void:
    text_label.text = l_name
    num_label.text = str(l_num)

func update_label(clicker_property:Game.Clicker_Property)->void:
    if clicker_property != property_listen:
        return
    var update_value = Game.get_clicker_property(clicker_property)
    num_label.text = str(update_value)