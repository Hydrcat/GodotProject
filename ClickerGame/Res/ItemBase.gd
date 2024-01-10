extends Resource
class_name ItemBase

# GameItem Res类
## item_id 引索Item的唯一程序字
@export var id:int
## item的名称
@export var s_name:String
## item的描述
@export var des:String
## item的解锁条件
@export var unlock_check:PackedStringArray #解锁检查，通过字符串检查
