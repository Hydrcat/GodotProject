@tool
class_name GameNode
extends Node2D

signal drag_begin
signal drag_end
signal pressed
signal inspected

const DRAG_THRESHOLD := 6.0

@export var text: String:
	set(v):
		if text == v:
			return
		text = v
		
		var outside_tree := not is_inside_tree()
		if outside_tree:
			await ready
		main_label.text = text
		is_inspected = false

@export var label: String:
	set(v):
		if label == v:
			return
		label = v
		if not is_inside_tree():
			await ready
		corner_label.text = label
		corner_panel.visible = not label.is_empty()

@export var description: String:
	set(v):
		if description == v:
			return
		description = v
		is_inspected = false

# 拖动
var is_pressed := false
var is_dragging := false
var drag_start: Vector2
var drag_offset: Vector2

# 动画
## 透明度动画
var tint_tween := WeakRef.new()
## 背景颜色动画
var main_background_tween := WeakRef.new()
## foucus动画
var attention_tween := WeakRef.new()
## 文本颜色动画
var text_color_tween := WeakRef.new()

# 其他
var id: int
var is_active := false
var is_inspected := false:
	set(v):
		if is_inspected == v:
			return
		is_inspected = v
		if is_inside_tree():
			update_text_color()
			if not is_inspected:
				request_attention()

@onready var main_panel: PanelContainer = %MainPanel
@onready var main_label: Label = %MainLabel
@onready var corner_panel: PanelContainer = %CornerPanel
@onready var corner_label: Label = %CornerLabel


func _ready() -> void:
	Game.node_active.connect(_on_game_node_active)


func update_tint() -> void:
	var tween := tint_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	var color := Color(Color.WHITE, 0.6) if is_dragging else Color.WHITE
	if color == modulate:
		return
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"modulate", color, 0.2)
	
	tint_tween = weakref(tween)


func update_main_background(avoid_attention_tween := true) -> void:
	if avoid_attention_tween and attention_tween.get_ref():
		return
	
	var tween := main_background_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	var color := Color("#F50000") if is_active else Color("#7B7B7B")
	if color == main_panel.self_modulate:
		return
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(main_panel, ^"self_modulate", color, 0.5)
	
	main_background_tween = weakref(tween)


func update_text_color() -> void:
	var tween := text_color_tween.get_ref() as Tween
	if tween:
		tween.kill()
	
	var color := Color.BLACK if is_inspected else Color.WHITE
	if main_label.modulate == color:
		return
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(main_label, ^"modulate", color, 0.5)
	
	text_color_tween = weakref(tween)


func request_attention() -> void:
	if attention_tween.get_ref():
		return
	
	var background_tween := main_background_tween.get_ref() as Tween
	if background_tween:
		background_tween.kill()
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	
	tween.tween_property(main_panel, ^"self_modulate", Color.WHITE, 0.5)
	tween.tween_property(self, ^"scale", Vector2.ONE * 1.2, 0.5)
	tween.chain()
	tween.tween_property(self, ^"scale", Vector2.ONE, 0.5)
	tween.tween_callback(update_main_background.bind(false))
	
	attention_tween = weakref(tween)


func shake_head(callback: Callable = Callable()) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, ^"position", position + Vector2.LEFT * 6, 0.1)
	tween.tween_property(self, ^"position", position + Vector2.RIGHT * 5, 0.1)
	tween.tween_property(self, ^"position", position + Vector2.LEFT * 3, 0.1)
	tween.tween_property(self, ^"position", position + Vector2.RIGHT * 2, 0.1)
	tween.tween_property(self, ^"position", position, 0.1)
	
	if callback:
		tween.tween_callback(callback)


func get_rect() -> Rect2:
	return main_panel.get_global_rect()


func inspect() -> void:
	is_inspected = true
	inspected.emit()


func activate() -> void:
	pass


func _on_drag_begin() -> void:
	drag_begin.emit()
	update_tint()


func _on_drag_end() -> void:
	drag_end.emit()
	update_tint()


func _on_pressed() -> void:
	pressed.emit()


func _on_game_node_active(node: GameNode) -> void:
	is_active = node == self
	update_main_background()


func _on_panel_gui_input(event: InputEvent) -> void:
	# 这里不使用 InputEventMouse 的 global_position
	# 因为会受到窗口拉伸模式缩放的影响
	var mouse_pos := get_viewport().get_mouse_position()
	
	var mb := event as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = mb.is_pressed()
		if mb.is_pressed():
			drag_start = mouse_pos
			drag_offset = mouse_pos - global_position
		else:
			if is_dragging:
				is_dragging = false
				_on_drag_end()
			else:
				_on_pressed()
		main_panel.accept_event()
	
	var mm := event as InputEventMouseMotion
	if mm and mm.button_mask & MOUSE_BUTTON_MASK_LEFT and is_pressed:
		if is_dragging:
			global_position = mouse_pos - drag_offset
		else:
			var distance := (mouse_pos - drag_start).length()
			if distance > DRAG_THRESHOLD:
				is_dragging = true
				_on_drag_begin()
		main_panel.accept_event()
