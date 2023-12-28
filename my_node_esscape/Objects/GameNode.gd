extends Node2D
class_name GameNode

@onready var panel := $PanelContainer
@onready var label := $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var focus_cover = $PanelContainer/Focus_cover

signal pressed
signal used
signal drag_begin
signal drag_end

const DRAG_THRESHOLD := 15

var is_pressed := false
var is_dragging := false
var is_foucsing := false
var is_uesed := false :
	set(v):
		if v == is_uesed:
			return
		is_uesed = v	
		request_attention()	

var drag_start : Vector2
var drag_offset : Vector2

var tween_tint:Tween
var tween_foucus:Tween
var tween_text:Tween
var tween_attention: Tween


# 更新透明度
func update_tint()->void:
	var color := Color(Color.WHITE,0.6) if is_dragging else Color.WHITE

	if tween_tint:tween_tint.kill()
	tween_tint = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_tint.tween_property(panel,^"modulate",color,0.5)

# 更新背景颜色
func update_background_color(override_color:String = "",ignore_attention_tween:bool = true)->void:
	var a = 1.0 if is_foucsing else 0
	
	if ignore_attention_tween and tween_attention :
		tween_attention.kill()

	if tween_foucus:tween_foucus.kill()
	tween_tint = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_tint.tween_property(focus_cover,^"self_modulate",Color(1,1,1,a),0.5)	

# 更新文字颜色	
func update_text_color()->void:
	var color := Color(Color.BLACK) if is_uesed else Color.WHITE
	if tween_text : tween_text.kill()
	tween_text = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_text.tween_property(label,"self_modulate",color,0.5)
	
# 节点高亮，并体型变大，让玩家关注此节点	
func request_attention()->void:	
	if tween_attention:tween_attention.kill()
	tween_attention = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_attention.set_parallel()
	tween_attention.tween_property(panel,^"self_modulate",Color.WHITE,0.5)
	tween_attention.tween_property(self,^"scale",Vector2.ONE * 1.2,0.4)

	tween_attention.chain()
	tween_attention.tween_property(self,^"scale",Vector2.ONE,0.3)
	tween_attention.tween_callback(update_background_color.bind("",false))
	#update_background_color()
	
# set/get
func get_rect()->Rect2:
	return panel.get_rect()
	

func _on_panel_gui_input(event:InputEvent):
	var mouse_pos := get_viewport().get_mouse_position()
	
	var mb := event as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = mb.is_pressed()
		if is_pressed:
			drag_start = mouse_pos
			drag_offset = global_position - drag_start
		else :	
			if is_dragging:
				is_dragging = false
				_on_drag_end()
			else :
				_on_pressed()		
	
	var mm := event as InputEventMouseMotion
	if mm and mm.button_mask & MOUSE_BUTTON_LEFT and is_pressed:
		if is_dragging:
			global_position = mouse_pos + drag_offset
		else :
			var distance = mouse_pos - drag_offset
			if distance.length() > DRAG_THRESHOLD:	
				is_dragging = true
				_on_drag_begin()


func _on_drag_begin():
	update_tint()
	drag_begin.emit()

func _on_drag_end():
	update_tint()
	drag_end.emit()

func _on_pressed():
	is_foucsing = !is_foucsing
	update_background_color()
	pressed.emit()

	
