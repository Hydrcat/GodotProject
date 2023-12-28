class_name GameNodeManager
extends Node2D
# 这个类里面主要是业务无关的代码
# 一切都由 setup_nodes 传入的配置数据控制

const DRAG_THRESHOLD := 6.0

@export var description_label: Label

var root_id: int = -1
var node_config_map := {}
var node_child_map := {}
var node_map := {}
var node_locked: Array[int] = []

var is_dragging := false
var is_pressed := false
var drag_offset: Vector2
var drag_start: Vector2

var active_node_id: int = -1:
	set(v):
		if active_node_id == v:
			return
		active_node_id = v
		
		var node := node_map.get(active_node_id) as GameNode
		Game.node_active.emit(node)
		
		if not description_label:
			return
		if active_node_id == -1 or node.description.is_empty():
			description_label.hide_string()
		else:
			description_label.show_string(node.description)


func _init() -> void:
	Game.trigger_activated.connect(_on_game_trigger_activated)


func _process(_delta: float) -> void:
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	# 见 GameNode 拖动的相关说明
	var mouse_pos := get_viewport().get_mouse_position()
	
	var mb := event as InputEventMouseButton
	if mb and mb.button_index == MOUSE_BUTTON_LEFT:
		is_pressed = mb.is_pressed()
		if mb.is_pressed():
			drag_start = mouse_pos
		else:
			if is_dragging:
				is_dragging = false
			else:
				active_node_id = -1
		get_viewport().set_input_as_handled()
	
	var mm := event as InputEventMouseMotion
	if mm and mm.button_mask & MOUSE_BUTTON_MASK_LEFT and is_pressed:
		if is_dragging:
			global_position = mouse_pos - drag_offset
		else:
			var distance := (mouse_pos - drag_start).length()
			if distance > DRAG_THRESHOLD:
				is_dragging = true
				drag_offset = mouse_pos - global_position
		get_viewport().set_input_as_handled()


func _draw() -> void:
	if root_id != -1:
		draw_child_relation(root_id)


func setup_nodes(scene_config: Array) -> void:
	for node_config in scene_config:
		var id := node_config.id as int
		var pid := node_config.pid as int
		
		node_config_map[id] = node_config
		
		if pid in node_child_map:
			node_child_map[pid].append(id)
		else:
			node_child_map[pid] = [id]
		
		if node_config.get("unlock_when"):
			node_locked.append(id)
		
		var scene_path: String = "res://nodes/%s.tscn" % node_config.get("scene", "game_node")
		var node := load(scene_path).instantiate() as GameNode
		node.id = id
		node.text = node_config.text
		node.description = node_config.get("description", "")
		node.label = node_config.get("label", "")
		
		node.pressed.connect(_on_game_node_pressed.bind(id))
		node.inspected.connect(_on_game_node_inspected.bind(id))
		node.drag_end.connect(_on_game_node_drag_end.bind(id))
		
		node.pressed.connect(bring_node_to_top.bind(node))
		node.drag_begin.connect(bring_node_to_top.bind(node))
		
		node_map[id] = node
		add_child(node)
		
		if pid == -1:
			if root_id != -1:
				push_error("Multiple roots not allowed")
				return
			root_id = id
		else:
			node.hide()


func draw_child_relation(parent_id: int) -> void:
	var parent := node_map[parent_id] as GameNode
	for child_id in node_child_map.get(parent_id, []):
		var child := node_map[child_id] as GameNode
		if not child.visible:
			continue
		var alpha := (child.modulate.a + parent.modulate.a) / 2
		draw_line(parent.position, child.position, Color(Color.WHITE, alpha), 1.0, true)
		draw_child_relation(child_id)


func bring_node_to_top(node: GameNode) -> void:
	move_child(node, get_child_count() - 1)


func get_game_node_at(pos: Vector2, exception: GameNode = null) -> GameNode:
	for i in range(get_child_count() - 1, -1, -1):
		var node := get_child(i) as GameNode
		if not node or not node.visible or node == exception:
			continue
		if node.get_rect().has_point(pos):
			return node
	return null


func can_spawn_game_node_at(pos: Vector2, size: Vector2) -> bool:
	var rect := Rect2(pos - size / 2, size)
	
	var viewport_size := get_viewport_rect().size
	var camera_position := get_viewport().get_camera_2d().position
	var camera_rect := Rect2(camera_position - viewport_size / 2, viewport_size)
	
	# 尽量在可视范围内放置节点
	if not camera_rect.encloses(rect):
		return false
	
	# 不与已有节点重叠
	for i in range(get_child_count() - 1, -1, -1):
		var node := get_child(i) as GameNode
		if not node or not node.visible:
			continue
		if node.get_rect().intersects(rect):
			return false
	
	return true


func expand_node(node_id: int) -> bool:
	var node := node_map[node_id] as GameNode
	var max_size := Vector2.ZERO
	var to_expand: Array[GameNode] = []
	for child_id in node_child_map.get(node_id, []):
		var child := node_map[child_id] as GameNode
		if child.visible or child_id in node_locked:
			continue
		
		to_expand.append(child)
		var child_size := child.get_rect().size
		if child_size > max_size:
			max_size = child_size
	
	if to_expand.is_empty():
		return false
	
	# 划分圆周，找到连续的空白区域
	var start_vector := (Vector2.DOWN * 128.0).rotated(randf_range(0.0, TAU))
	var divisions := 16
	var step := TAU / divisions
	var range_start := -1
	var ranges := PackedVector2Array()
	for i in divisions:
		var pos := node.global_position + start_vector.rotated(i * step)
		if can_spawn_game_node_at(pos, max_size):
			if range_start == -1:
				range_start = i
		else:
			if range_start != -1:
				ranges.append(Vector2(range_start, i))
				range_start = -1
	if range_start != -1:
		ranges.append(Vector2(range_start, divisions))
	
	# 选最长的一段圆弧
	var chosen := Vector2.ZERO
	for r in ranges:
		if (r.y - r.x) > (chosen.y - chosen.x):
			chosen = Vector2(r.x, r.y)
	if chosen == Vector2.ZERO:
		chosen = Vector2(0, divisions)
	
	# 在这段圆弧上平均放置节点
	var angle_range := chosen * step
	var expand_speed := 0.5
	
	var tween := create_tween()
	tween.set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	for i in to_expand.size():
		var child := to_expand[i] as GameNode
		var weight := 1.0 * i / to_expand.size()
		var angle := lerp(angle_range.x, angle_range.y, weight) as float
		var target_position := node.position + start_vector.rotated(angle)
		tween.tween_property(child, ^"position", target_position, expand_speed).from(node.position)
		tween.tween_property(child, ^"modulate:a", 1.0, expand_speed).from(0.0)
		child.position = node.position
		bring_node_to_top(child)
		child.show()
	
	tween.chain()
	for child in to_expand:
		tween.tween_callback(func():
			Game.node_appeared.emit(child)
		)
	
	return true


func _on_game_node_pressed(node_id: int) -> void:
	var node := node_map[node_id] as GameNode
	if active_node_id == node_id:
		node.inspect()
	else:
		active_node_id = node_id
		
		if AudioManager.has_sound(node.description):
			AudioManager.play_sound(node.description)


func _on_game_node_drag_end(node_id: int) -> void:
	var node := node_map[node_id] as GameNode
	var below := get_game_node_at(get_global_mouse_position(), node)
	if not below:
		return
	
	# 把 node 放到了 below 上
	var config := node_config_map[below.id] as Dictionary
	
	if config.get("activate_on_drop", -1) == node_id:
		below.activate()
		
		var activate_trigger := config.get("activate_trigger", &"") as StringName
		if activate_trigger:
			Game.trigger_activated.emit(activate_trigger)
		
		var alt_text := config.get("alt_text", "") as String
		if alt_text:
			below.text = alt_text
		
		var alt_description := config.get("alt_description", "") as String
		if alt_description:
			below.description = alt_description
		
		if below.id == active_node_id or node_id == active_node_id:
			active_node_id = -1
	else:
		if not below.has_method(&"accept_drop") or not below.accept_drop(node):
			below.shake_head()


func _on_game_node_inspected(node_id: int) -> void:
	var config := node_config_map[node_id] as Dictionary
	var sfx := config.get("sfx", "") as String
	if sfx:
		AudioManager.play_sound(sfx)
	
	if expand_node(node_id):
		node_map[node_id].request_attention()
		active_node_id = -1


func _on_game_trigger_activated(trigger: StringName) -> void:
	for node_id in node_config_map:
		var node := node_map[node_id] as GameNode
		if not node.visible:
			continue
		
		var config := node_config_map[node_id] as Dictionary
		
		if config.get("activate_trigger", &"") == trigger:
			node.activate()
		
		if config.get("alt_trigger", &"") != trigger:
			continue
		
		var changed := false
		
		var alt_text := config.get("alt_text", "") as String
		if not alt_text.is_empty() and node.text != alt_text:
			node.text = alt_text
			changed = true
		
		var alt_description := config.get("alt_description", "") as String
		if not alt_description.is_empty() and node.description != alt_description:
			node.description = alt_description
			changed = true
		
		if changed:
			node.request_attention()
	
	var unlocked: Array[int] = []
	for node_id in node_locked:
		var config := node_config_map[node_id] as Dictionary
		
		if config.unlock_when != trigger:
			continue
		
		var parent_node := node_map[config.pid] as GameNode
		parent_node.is_inspected = false
		parent_node.request_attention()
		
		unlocked.append(node_id)
	
	for node_id in unlocked:
		node_locked.erase(node_id)
