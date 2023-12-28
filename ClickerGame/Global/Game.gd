extends Node

var points : int = 0 # 生成的开发点数
var cps :float = 0.0 # 每分钟生成的进度

var RatePerClick :int = 1 #点击倍率
var ExtraPerClick :int = 0 #每次交互额外获得

signal clicked
signal points_change

func _enter_tree() -> void:
    clicked.connect(on_clicked) 

# 点击的时候，进行增加
func on_clicked() -> void:
    ## 点数 = 鼠标点击 * 点击获取倍率 + 额外补正
    points += RatePerClick + ExtraPerClick

# 时间计时器
func on_time_end() -> void:
    pass

