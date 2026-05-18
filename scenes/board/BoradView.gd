class_name BoardView
extends Node2D

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")

const FALLBACK_BOX_COLOR := Color("d19a66")
const FALLBACK_BOX_ON_GOAL_COLOR := Color("98c379")
const FALLBACK_PLAYER_COLOR := Color("61afef")
const FALLBACK_WALL_COLOR := Color("5c6370")
const FALLBACK_FLOOR_COLOR := Color("2b3245")
const FALLBACK_FLOOR_BORDER_COLOR := Color("1f2430")
const FALLBACK_GOAL_COLOR := Color("f2c94c")
const ROTATE_RIGHT_TILE_COLOR := Color(0.35, 0.85, 0.75, 0.85)
const ROTATE_LEFT_TILE_COLOR := Color(0.85, 0.58, 0.35, 0.85)

const POLE_N_COLOR := Color(0.95, 0.35, 0.35, 0.95)
const POLE_S_COLOR := Color(0.35, 0.55, 1.0, 0.95)
const FACING_ARROW_COLOR := Color(1.0, 1.0, 1.0, 0.9)
const STRENGTH_DOT_COLOR := Color(0.1, 0.12, 0.16, 0.9)
const STRENGTH_DOT_OUTLINE_COLOR := Color(1.0, 1.0, 1.0, 0.75)
const MAGNET_SOURCE_HIGHLIGHT_COLOR := Color(1.0, 0.94, 0.35, 0.95)
const MAGNET_TARGET_HIGHLIGHT_COLOR := Color(0.45, 0.9, 1.0, 0.9)

@export var cell_size := 64

@export var tex_floor: Texture2D
@export var tex_wall: Texture2D
@export var tex_goal: Texture2D
@export var tex_box: Texture2D
@export var tex_box_on_goal: Texture2D
@export var tex_player: Texture2D

var state: GameState
var _player_display_pos := Vector2.ZERO
var _body_display_positions := {}
var _highlight_faces: Array[Dictionary] = []


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func set_state(value: GameState, sync_display_positions := true) -> void:
	state = value
	if sync_display_positions:
		sync_display_from_state()
	queue_redraw()


func sync_display_from_state() -> void:
	if state == null:
		return

	_player_display_pos = _to_display_pos(state.player_pos)
	_body_display_positions.clear()
	for body in state.bodies:
		_body_display_positions[body.id] = _to_display_pos(body.pos)


func animate_movement_batch(
	player_move: Dictionary,
	body_moves: Array[Dictionary],
	duration: float
) -> void:
	var safe_duration := maxf(duration, 0.01)
	var tween := create_tween()
	tween.set_parallel(true)

	if not player_move.is_empty():
		var player_from := player_move["from"] as Vector2i
		var player_to := player_move["to"] as Vector2i
		_player_display_pos = _to_display_pos(player_from)
		tween.tween_method(
			Callable(self, "_set_player_display_pos"),
			_to_display_pos(player_from),
			_to_display_pos(player_to),
			safe_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for body_move in body_moves:
		var body_id := body_move["body_id"] as int
		var from_pos := body_move["from"] as Vector2i
		var to_pos := body_move["to"] as Vector2i
		_body_display_positions[body_id] = _to_display_pos(from_pos)
		tween.tween_method(
			Callable(self, "_set_body_display_pos").bind(body_id),
			_to_display_pos(from_pos),
			_to_display_pos(to_pos),
			safe_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	queue_redraw()
	await tween.finished

	if not player_move.is_empty():
		_player_display_pos = _to_display_pos(player_move["to"] as Vector2i)

	for body_move in body_moves:
		_body_display_positions[body_move["body_id"] as int] = _to_display_pos(body_move["to"] as Vector2i)

	queue_redraw()


func show_magnet_triggers(triggers: Array[Dictionary], duration: float) -> void:
	_highlight_faces.clear()

	for trigger in triggers:
		var source_id := trigger["body_id"] as int
		var source_face := trigger.get("source_face", trigger["direction"]) as Vector2i
		var target_id := trigger.get("target_id", -1) as int
		var target_face := trigger.get("target_face", -source_face) as Vector2i

		_highlight_faces.append({
			"body_id": source_id,
			"face": source_face,
			"color": MAGNET_SOURCE_HIGHLIGHT_COLOR,
		})

		if target_id != -1:
			_highlight_faces.append({
				"body_id": target_id,
				"face": target_face,
				"color": MAGNET_TARGET_HIGHLIGHT_COLOR,
			})

	queue_redraw()
	await get_tree().create_timer(maxf(duration, 0.01)).timeout
	_highlight_faces.clear()
	queue_redraw()


func _draw() -> void:
	if state == null:
		return

	for y in range(state.board_size.y):
		for x in range(state.board_size.x):
			var pos := Vector2i(x, y)
			var rect := Rect2(
				Vector2(x * cell_size, y * cell_size),
				Vector2(cell_size, cell_size)
			)

			_draw_floor_cell(rect)

			if state.rotate_right_tiles.has(pos):
				_draw_rotation_tile(rect, true)
			elif state.rotate_left_tiles.has(pos):
				_draw_rotation_tile(rect, false)

			if state.goals.has(pos):
				_draw_goal_cell(rect)

			if state.walls.has(pos):
				_draw_wall_cell(rect)

	for body in state.bodies:
		var box_pos := _get_body_display_pos(body)
		var box_rect := Rect2(
			box_pos * cell_size,
			Vector2(cell_size, cell_size)
		)

		if state.goals.has(body.pos):
			_draw_box_on_goal(box_rect, body)
		else:
			_draw_box(box_rect, body)

	var player_rect := Rect2(
		_player_display_pos * cell_size,
		Vector2(cell_size, cell_size)
	)
	_draw_player(player_rect)


func _draw_floor_cell(rect: Rect2) -> void:
	if tex_floor:
		draw_texture_rect(tex_floor, rect, false)
	else:
		draw_rect(rect, FALLBACK_FLOOR_BORDER_COLOR)
		draw_rect(rect.grow(-2), FALLBACK_FLOOR_COLOR)


func _draw_goal_cell(rect: Rect2) -> void:
	if tex_goal:
		draw_texture_rect(tex_goal, rect, false)
	else:
		draw_rect(rect.grow(-18), FALLBACK_GOAL_COLOR)


func _draw_rotation_tile(rect: Rect2, rotate_right: bool) -> void:
	var color := ROTATE_RIGHT_TILE_COLOR
	if not rotate_right:
		color = ROTATE_LEFT_TILE_COLOR

	draw_rect(rect.grow(-12), Color(color.r, color.g, color.b, 0.14))

	var center := rect.get_center()
	var radius := rect.size.x * 0.24
	var start_angle := -PI * 0.65
	var end_angle := PI * 0.65

	if rotate_right:
		draw_arc(center, radius, end_angle, start_angle, 18, color, 3.0)
		var tip := center + Vector2(cos(start_angle), sin(start_angle)) * radius
		_draw_arrow_head(tip, -Vector2(cos(start_angle), sin(start_angle)), color)
	else:
		draw_arc(center, radius, start_angle, end_angle, 18, color, 3.0)
		var tip := center + Vector2(cos(end_angle), sin(end_angle)) * radius
		_draw_arrow_head(tip, Vector2(cos(end_angle), sin(end_angle)), color)


func _draw_arrow_head(tip: Vector2, direction: Vector2, color: Color) -> void:
	if direction == Vector2.ZERO:
		return

	var forward := direction.normalized()
	var side := Vector2(-forward.y, forward.x)
	var size := 7.0
	var p1 := tip
	var p2 := tip - forward * size + side * (size * 0.55)
	var p3 := tip - forward * size - side * (size * 0.55)
	draw_colored_polygon(PackedVector2Array([p1, p2, p3]), color)


func _draw_wall_cell(rect: Rect2) -> void:
	if tex_wall:
		draw_texture_rect(tex_wall, rect, false)
	else:
		draw_rect(rect.grow(-4), FALLBACK_WALL_COLOR)


func _draw_box(rect: Rect2, body: MagneticBodyStateScript) -> void:
	if tex_box:
		draw_texture_rect(tex_box, rect, false)
	else:
		draw_rect(rect.grow(-8), FALLBACK_BOX_COLOR)

	_draw_pole_marker(rect, body)


func _draw_box_on_goal(rect: Rect2, body: MagneticBodyStateScript) -> void:
	if tex_box_on_goal:
		draw_texture_rect(tex_box_on_goal, rect, false)
	elif tex_box:
		draw_texture_rect(tex_box, rect, false)
	else:
		draw_rect(rect.grow(-8), FALLBACK_BOX_ON_GOAL_COLOR)

	_draw_pole_marker(rect, body)


func _draw_player(rect: Rect2) -> void:
	if tex_player:
		draw_texture_rect(tex_player, rect, false)
	else:
		draw_rect(rect.grow(-12), FALLBACK_PLAYER_COLOR)


func _draw_pole_marker(rect: Rect2, body: MagneticBodyStateScript) -> void:
	for face_direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var pole := body.get_pole_on_face(face_direction)
		if pole == "":
			continue

		_draw_face_pole_marker(rect, face_direction, _get_pole_color(pole))

	_draw_facing_arrow(rect, body.facing)
	_draw_strength_marker(rect, body.strength)
	_draw_highlight_faces(rect, body.id)


func _draw_face_pole_marker(rect: Rect2, face_direction: Vector2i, color: Color) -> void:
	var marker_thickness: float = maxf(5.0, rect.size.x * 0.1)
	var inset: float = rect.size.x * 0.2
	var marker_rect := Rect2()

	if face_direction == Vector2i.LEFT:
		marker_rect = Rect2(
			rect.position + Vector2(6, inset),
			Vector2(marker_thickness, rect.size.y - inset * 2.0)
		)
	elif face_direction == Vector2i.RIGHT:
		marker_rect = Rect2(
			rect.position + Vector2(rect.size.x - marker_thickness - 6, inset),
			Vector2(marker_thickness, rect.size.y - inset * 2.0)
		)
	elif face_direction == Vector2i.UP:
		marker_rect = Rect2(
			rect.position + Vector2(inset, 6),
			Vector2(rect.size.x - inset * 2.0, marker_thickness)
		)
	elif face_direction == Vector2i.DOWN:
		marker_rect = Rect2(
			rect.position + Vector2(inset, rect.size.y - marker_thickness - 6),
			Vector2(rect.size.x - inset * 2.0, marker_thickness)
		)

	draw_rect(marker_rect, color)
	draw_rect(marker_rect.grow(-1), color.lightened(0.12))


func _draw_facing_arrow(rect: Rect2, facing: Vector2i) -> void:
	if facing == Vector2i.ZERO:
		return

	var center := rect.get_center()
	var facing_vector := Vector2(facing.x, facing.y)
	var tip := center + facing_vector * (rect.size.x * 0.28)
	var tail := center - facing_vector * (rect.size.x * 0.12)
	draw_line(tail, tip, FACING_ARROW_COLOR, 4.0)
	draw_circle(tip, 4.5, FACING_ARROW_COLOR)


func _draw_strength_marker(rect: Rect2, strength: int) -> void:
	var visible_count: int = clamp(strength, 1, 5)
	var radius: float = maxf(2.5, rect.size.x * 0.045)
	var spacing: float = radius * 2.5
	var start := rect.position + Vector2(12, rect.size.y - 11)

	for index in range(visible_count):
		var center := start + Vector2(index * spacing, 0)
		draw_circle(center, radius + 1.0, STRENGTH_DOT_OUTLINE_COLOR)
		draw_circle(center, radius, STRENGTH_DOT_COLOR)


func _get_pole_color(pole: String) -> Color:
	if pole == MagneticBodyStateScript.POLE_N:
		return POLE_N_COLOR
	return POLE_S_COLOR


func _draw_highlight_faces(rect: Rect2, body_id: int) -> void:
	for highlight in _highlight_faces:
		if (highlight["body_id"] as int) != body_id:
			continue

		_draw_face_highlight(
			rect,
			highlight["face"] as Vector2i,
			highlight["color"] as Color
		)


func _draw_face_highlight(rect: Rect2, face_direction: Vector2i, color: Color) -> void:
	var center := rect.get_center()
	var half_size := rect.size.x * 0.5
	var start := center
	var end := center

	if face_direction == Vector2i.LEFT:
		start = rect.position + Vector2(8, 8)
		end = rect.position + Vector2(8, rect.size.y - 8)
	elif face_direction == Vector2i.RIGHT:
		start = rect.position + Vector2(rect.size.x - 8, 8)
		end = rect.position + Vector2(rect.size.x - 8, rect.size.y - 8)
	elif face_direction == Vector2i.UP:
		start = rect.position + Vector2(8, 8)
		end = rect.position + Vector2(rect.size.x - 8, 8)
	elif face_direction == Vector2i.DOWN:
		start = rect.position + Vector2(8, rect.size.y - 8)
		end = rect.position + Vector2(rect.size.x - 8, rect.size.y - 8)
	else:
		return

	draw_line(start, end, color, maxf(5.0, half_size * 0.16))


func _set_player_display_pos(value: Vector2) -> void:
	_player_display_pos = value
	queue_redraw()


func _set_body_display_pos(value: Vector2, body_id: int) -> void:
	_body_display_positions[body_id] = value
	queue_redraw()


func _get_body_display_pos(body: MagneticBodyStateScript) -> Vector2:
	if _body_display_positions.has(body.id):
		return _body_display_positions[body.id] as Vector2

	return _to_display_pos(body.pos)


func _to_display_pos(cell_pos: Vector2i) -> Vector2:
	return Vector2(cell_pos.x, cell_pos.y)
