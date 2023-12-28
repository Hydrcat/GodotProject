extends Node

const AMBIENT_SOUND := "558840__kinoton__room-tone-corridor-howling-wind"
const RAIN_SOUND := "Rain Thunder So Far_MB 06"

var toolbox_counters: Array[int] = [0, 0, 0]
var vomit_wiped := false
var blood_wiped := false

var counter_checker := WeakRef.new()

@onready var game_node_manager: Node2D = %GameNodeManager


func _init() -> void:
	Game.counter_changed.connect(_on_game_counter_changed)
	Game.node_appeared.connect(_on_game_node_appeared)
	Game.trigger_activated.connect(_on_game_trigger_activated)


func _ready() -> void:
	AudioManager.play_sound(AMBIENT_SOUND, 1.0)
	
	# 这里我就写死在代码里了
	# 实际我做了一个表格，理论上可以做成直接导入外部编辑的结果
	game_node_manager.setup_nodes.call_deferred([
		{
			id=0,
			pid=-1,
			text="黑暗",
			description="周围黑到伸手不见五指",
			alt_trigger=&"lit",
			alt_text="废屋",
			alt_description="随时可能倒塌的房子",
		},
		{
			id=1,
			pid=0,
			text="墙壁",
			alt_trigger=&"lit",
			alt_text="很脏的墙壁",
		},
		{
			id=3,
			pid=0,
			text="脚下",
			description="感觉是坚硬的地板",
			sfx="wooden_floor",
			alt_trigger=&"lit",
			alt_text="地板",
			alt_description="腐烂的地板吱嘎作响",
		},
		{
			id=4,
			pid=0,
			text="窗户",
			description="外面一片漆黑",
		},
		{
			id=2,
			pid=0,
			text="墙壁",
			alt_trigger=&"lit",
			alt_text="很脏的墙壁",
		},
		{
			id=5,
			pid=0,
			text="天花板",
			alt_trigger=&"lit",
			alt_description="吊着什么东西",
		},
		{
			id=6,
			pid=1,
			text="油灯",
			description="还没有点着",
			scene="lantern_node",
			sfx="metal_hinge",
			activate_on_drop=7,
			activate_trigger=&"lit",
			alt_trigger=&"lit",
			alt_description="玻璃上写着“44”",
		},
		{
			id=7,
			pid=3,
			text="打火机",
			description="应该还能用",
			sfx="lighter",
			activate_on_drop=6,
			activate_trigger=&"lit",
			alt_trigger=&"lit",
			alt_description="没法用了",
		},
		{
			id=8,
			pid=4,
			text="抹布",
			description="稍微有点脏",
			alt_trigger=&"dirty_cloth",
			alt_description="太脏了不想碰",
		},
		{
			id=9,
			pid=1,
			text="血迹",
			description="血溅得到处都是",
			unlock_when=&"lit",
			activate_on_drop=8,
			activate_trigger=&"blood_wiped",
			alt_text="字迹",
			alt_description="“屋中母子皆来食”",
		},
		{
			id=10,
			pid=3,
			text="呕吐物",
			description="散发着刺鼻的气味",
			unlock_when=&"lit",
			activate_on_drop=8,
			activate_trigger=&"vomit_wiped",
			alt_text="刻痕",
			alt_description="地板上刻着“7777”",
		},
		{
			id=11,
			pid=2,
			text="工具箱",
			description="被密码锁锁上了",
			unlock_when=&"lit",
			sfx="metal_hinge",
			alt_trigger=&"toolbox",
			alt_description="锁打开了",
		},
		{
			id=12,
			pid=2,
			text="门",
			description="打不开",
			scene="exit_node",
			unlock_when=&"lit",
			alt_trigger=&"unlock",
			alt_description="打开了",
		},
		{
			id=13,
			pid=11,
			text="0",
			description="上面写着“2”",
			label="2",
			scene="counter_node",
		},
		{
			id=14,
			pid=11,
			text="0",
			description="上面写着“3”",
			label="3",
			scene="counter_node",
		},
		{
			id=15,
			pid=11,
			text="0",
			description="上面写着“4”",
			label="4",
			scene="counter_node",
		},
		{
			id=16,
			pid=12,
			text="指纹认证",
			description="用自己的手指没有反应",
			scene="fingerprint_node",
			alt_trigger=&"unlock",
			alt_description="已经没有反应了",
		},
		{
			id=17,
			pid=5,
			text="尸体",
			description="倒吊着已经没气了",
			unlock_when=&"lit",
		},
		{
			id=18,
			pid=17,
			text="脸",
			description="额头上刻着“999”",
		},
		{
			id=19,
			pid=17,
			text="左手",
			description="还是很漂亮的手",
			alt_trigger=&"cut",
			alt_description="手指都被切了下来",
			activate_on_drop=21,
			activate_trigger=&"cut",
		},
		{
			id=20,
			pid=17,
			text="右手",
			description="手指都被切了下来",
		},
		{
			id=21,
			pid=11,
			text="锯子",
			description="很锋利应该还能用",
			unlock_when=&"toolbox",
			alt_trigger=&"cut",
			alt_description="锯齿断了",
		},
		{
			id=22,
			pid=19,
			text="拇指",
			unlock_when=&"cut",
			scene="finger_node",
		},
		{
			id=23,
			pid=19,
			text="食指",
			unlock_when=&"cut",
			scene="finger_node",
		},
		{
			id=24,
			pid=19,
			text="中指",
			unlock_when=&"cut",
			scene="finger_node",
		},
		{
			id=25,
			pid=19,
			text="无名指",
			unlock_when=&"cut",
			scene="finger_node",
		},
		{
			id=26,
			pid=19,
			text="小指",
			unlock_when=&"cut",
			scene="finger_node",
		},
	])


func _exit_tree() -> void:
	AudioManager.stop_sound(AMBIENT_SOUND, 1.0)
	AudioManager.stop_sound(RAIN_SOUND, 1.0)


func _on_game_counter_changed(id: int, count: int) -> void:
	var tween := counter_checker.get_ref() as Tween
	if tween:
		tween.kill()
	
	match id:
		13:
			toolbox_counters[0] = count
		14:
			toolbox_counters[1] = count
		15:
			toolbox_counters[2] = count
	
	# 延迟一小段时间，没有后续更改就提交检查
	tween = create_tween()
	tween.tween_callback(func():
		if toolbox_counters == [4, 6, 7]:
			Game.trigger_activated.emit(&"toolbox")
	).set_delay(0.5)
	counter_checker = weakref(tween)


func _on_game_node_appeared(node: GameNode) -> void:
	if node.id == 21:
		%Rain.emitting = true
		AudioManager.play_sound(RAIN_SOUND, 2.0)


func _on_game_trigger_activated(trigger: StringName) -> void:
	match trigger:
		&"lit":
			AudioManager.play_sound("lit")
		&"vomit_wiped":
			vomit_wiped = true
			if vomit_wiped and blood_wiped:
				Game.trigger_activated.emit(&"dirty_cloth")
		&"blood_wiped":
			blood_wiped = true
			if vomit_wiped and blood_wiped:
				Game.trigger_activated.emit(&"dirty_cloth")
		&"toolbox":
			AudioManager.play_sound("toolbox")
		&"cut":
			AudioManager.play_sound("saw", 0.0, game_node_manager.expand_node.bind(19))
