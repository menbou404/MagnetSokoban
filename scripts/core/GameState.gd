class_name GameState
extends RefCounted

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")

var board_size := Vector2i.ZERO
var walls := {}
var goals := {}

var player_pos := Vector2i.ZERO
var bodies: Array[MagneticBodyStateScript] = []
var move_count := 0
var cleared := false


func snapshot() -> Dictionary:
	var body_snapshots: Array[Dictionary] = []
	for body in bodies:
		body_snapshots.append(body.snapshot())

	return {
		"player_pos": player_pos,
		"bodies": body_snapshots,
		"move_count": move_count,
		"cleared": cleared,
	}


func restore_from_snapshot(state: Dictionary) -> void:
	player_pos = state["player_pos"] as Vector2i

	bodies.clear()
	var restored_bodies: Array = (state["bodies"] as Array).duplicate()
	for body_state in restored_bodies:
		bodies.append(MagneticBodyStateScript.from_snapshot(body_state as Dictionary))

	move_count = state["move_count"] as int
	cleared = state["cleared"] as bool


func get_body_at(pos: Vector2i) -> MagneticBodyStateScript:
	for body in bodies:
		if body.pos == pos:
			return body
	return null


func get_body_by_id(body_id: int) -> MagneticBodyStateScript:
	for body in bodies:
		if body.id == body_id:
			return body
	return null


func is_inside_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < board_size.x and pos.y >= 0 and pos.y < board_size.y


func is_wall(pos: Vector2i) -> bool:
	return walls.has(pos)


func is_cell_free(pos: Vector2i, ignore_body_id: int = -1) -> bool:
	if not is_inside_board(pos):
		return false

	if is_wall(pos):
		return false

	for body in bodies:
		if body.id == ignore_body_id:
			continue
		if body.pos == pos:
			return false

	return true
