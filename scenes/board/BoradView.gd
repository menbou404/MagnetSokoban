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

const POLE_N_COLOR := Color(0.95, 0.35, 0.35, 0.95)
const POLE_S_COLOR := Color(0.35, 0.55, 1.0, 0.95)
const FACING_ARROW_COLOR := Color(1.0, 1.0, 1.0, 0.9)
const STRENGTH_DOT_COLOR := Color(0.1, 0.12, 0.16, 0.9)
const STRENGTH_DOT_OUTLINE_COLOR := Color(1.0, 1.0, 1.0, 0.75)

@export var cell_size := 64

@export var tex_floor: Texture2D
@export var tex_wall: Texture2D
@export var tex_goal: Texture2D
@export var tex_box: Texture2D
@export var tex_box_on_goal: Texture2D
@export var tex_player: Texture2D

var state: GameState


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func set_state(value: GameState) -> void:
	state = value
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

			if state.goals.has(pos):
				_draw_goal_cell(rect)

			if state.walls.has(pos):
				_draw_wall_cell(rect)

	for body in state.bodies:
		var box_pos := body.pos
		var box_rect := Rect2(
			Vector2(box_pos.x * cell_size, box_pos.y * cell_size),
			Vector2(cell_size, cell_size)
		)

		if state.goals.has(box_pos):
			_draw_box_on_goal(box_rect, body)
		else:
			_draw_box(box_rect, body)

	var player_rect := Rect2(
		Vector2(state.player_pos.x * cell_size, state.player_pos.y * cell_size),
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
