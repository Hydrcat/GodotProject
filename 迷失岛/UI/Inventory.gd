extends VBoxContainer

@onready var label = $Label
@onready var prev = $ItemBar/Prev
@onready var next = $ItemBar/Next
@onready var use = $ItemBar/Use
@onready var prop = $ItemBar/Use/Prop
@onready var hand = $ItemBar/Use/Hand


# 动画变量
var hand_intro := WeakRef.new()
var hand_outro := WeakRef.new()

# Called when the node enters the scene tree for the first time.
func _ready():

	#Game.inventory.connect("inventory_changed",Callable(self,_updat_ui()))
	#GODOT4 推荐使用信号非字符串链接的方法
	Game.inventory.inventory_changed.connect(_updat_ui)
	_updat_ui()

## 这里其实写的有问题，玩家对场景的交互，应该通过场景处理，再通过信号告知UI。
## 如果在UI节点中处理，
func _input(event):
	if event.is_action_pressed("Interate") and Game.inventory.active_item:
		Game.inventory.set_deferred("active_item",null)
		
		var tween := hand_outro.get_ref() as Tween

		tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
		tween.tween_property(hand,"scale",Vector2.ONE,0.5).from(Vector2.ONE * 2.0)
		tween.tween_property(hand,"modulate:a",0.0,0.5).from(1.0)
		tween.chain().tween_callback(hand.hide)
		
		hand_outro = weakref(tween)

func _updat_ui():
	var count := Game.inventory.get_item_count()
	if count < 2 :
		prev.disabled = true
		next.disabled = true
	visible = count > 0
	
	var current_item := Game.inventory.get_current_item()
	if not current_item:
		return
	
	label.text = current_item.description
	prop.texture = current_item.texture_prop
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_property(prop,"scale",Vector2.ONE,0.5).from(Vector2.ONE * 0.5)
	tween.tween_property(prop,"modulate:a",1.0,0.5).from(0.0)
	tween.chain().tween_callback(prop.show)
	


func _on_prev_pressed():
	Game.inventory.select_prev()


func _on_use_pressed():
	
	if Game.inventory.active_item == Game.inventory.get_current_item():
		return
		
	Game.inventory.active_item = Game.inventory.get_current_item()
	
	var tween := hand_intro.get_ref() as Tween	
	if tween :
		tween.kill()
		
	if hand_outro.get_ref():
			hand_outro.get_ref().kill()
				
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).set_parallel()
	tween.tween_callback(hand.show)
	tween.tween_property(hand,"scale",Vector2.ONE,0.5).from(Vector2.ZERO)
	tween.tween_property(hand,"modulate:a",1.0,0.5).from(0.0)
	
	hand_intro = weakref(tween)

func _on_next_pressed():
	Game.inventory.select_next()



