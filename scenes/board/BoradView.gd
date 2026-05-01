class_name BoardView
extends Node2D

const FALLBACK_BOX_COLOR := Color("d19a66")
const FALLBACK_BOX_ON_GOAL_COLOR := Color("98c379")
const FALLBACK_PLAYER_COLOR := Color("61afef")
const FALLBACK_WALL_COLOR := Color("5c6370")
const FALLBACK_FLOOR_COLOR := Color("2b3245")
const FALLBACK_FLOOR_BORDER_COLOR := Color("1f2430")
const FALLBACK_GOAL_COLOR := Color("f2c94c")

const POLE_N_COLOR := Color(0.95, 0.35, 0.35, 0.95)
const POLE_S_COLOR := Color(0.35, 0.55, 1.0, 0.95)

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

	for i in range(state.boxes.size()):
		var box_pos := state.boxes[i]
		var pole := state.box_poles[i]
		var box_rect := Rect2(
			Vector2(box_pos.x * cell_size, box_pos.y * cell_size),
			Vector2(cell_size, cell_size)
		)

		if state.goals.has(box_pos):
			_draw_box_on_goal(box_rect, pole)
		else:
			_draw_box(box_rect, pole)

	var player_rect := Rect2(
		Vector2(state.player.x * cell_size, state.player.y * cell_size),
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


func _draw_box(rect: Rect2, pole: String) -> void:
	if tex_box:
		draw_texture_rect(tex_box, rect, false)
	else:
		draw_rect(rect.grow(-8), FALLBACK_BOX_COLOR)

	_draw_pole_marker(rect, pole)


func _draw_box_on_goal(rect: Rect2, pole: String) -> void:
	if tex_box_on_goal:
		draw_texture_rect(tex_box_on_goal, rect, false)
	elif tex_box:
		draw_texture_rect(tex_box, rect, false)
	else:
		draw_rect(rect.grow(-8), FALLBACK_BOX_ON_GOAL_COLOR)

	_draw_pole_marker(rect, pole)


func _draw_player(rect: Rect2) -> void:
	if tex_player:
		draw_texture_rect(tex_player, rect, false)
	else:
		draw_rect(rect.grow(-12), FALLBACK_PLAYER_COLOR)


func _draw_pole_marker(rect: Rect2, pole: String) -> void:
	var color := _get_pole_color(pole)

	var marker_rect := Rect2(
		rect.position + Vector2(10, 8),
		Vector2(rect.size.x - 20, 12)
	)
	draw_rect(marker_rect, color)

	var inner_rect := marker_rect.grow(-2)
	draw_rect(inner_rect, color.lightened(0.15))


func _get_pole_color(pole: String) -> Color:
	if pole == GameState.POLE_N:
		return POLE_N_COLOR
	return POLE_S_COLOR