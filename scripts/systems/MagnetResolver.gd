class_name MagnetResolver
extends RefCounted

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")

const INTERACTION_ATTRACT := "attract"
const INTERACTION_REPEL := "repel"


func apply_after_push(state: GameState, source_id: int, dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return

	var processed_sources := {}
	var pending_sources: Array[Dictionary] = []
	pending_sources.append({
		"source_id": source_id,
		"direction": dir,
	})

	while not pending_sources.is_empty():
		var current: Dictionary = pending_sources.pop_front()
		var current_source_id := current["source_id"] as int
		var current_direction := current["direction"] as Vector2i

		if processed_sources.has(current_source_id):
			continue

		var source := state.get_body_by_id(current_source_id)
		if source == null:
			continue

		processed_sources[current_source_id] = true
		var moved_target_id := _process_source(state, source, current_direction)

		if moved_target_id == -1:
			continue

		# TODO: PHASE_04 以降で、連鎖時の起点ごとの処理方向を正式化する。
		# PHASE_03 では、最初に押した方向を連鎖中も引き継ぐ。
		pending_sources.append({
			"source_id": moved_target_id,
			"direction": current_direction,
		})


func _process_source(
	state: GameState,
	source: MagneticBodyStateScript,
	direction: Vector2i
) -> int:
	var target_info := find_first_target_in_line(state, source, direction)
	if target_info.is_empty():
		return -1

	var target := target_info["target"] as MagneticBodyStateScript
	var distance := target_info["distance"] as int

	if not can_magnetic_interaction_happen(source, target, distance):
		return -1

	var interaction_type := resolve_interaction_type(source, target, direction)
	if interaction_type == "":
		return -1

	var move_direction := _get_target_move_direction(interaction_type, direction)
	if not _try_move_body_one_step(state, target, move_direction):
		return -1

	return target.id


func find_first_target_in_line(
	state: GameState,
	source: MagneticBodyStateScript,
	direction: Vector2i
) -> Dictionary:
	var cursor := source.pos + direction
	var distance := 1

	while state.is_inside_board(cursor):
		if state.is_wall(cursor):
			return {}

		var target := state.get_body_at(cursor)
		if target != null:
			return {
				"target": target,
				"distance": distance,
			}

		cursor += direction
		distance += 1

	return {}


func can_magnetic_interaction_happen(
	source: MagneticBodyStateScript,
	target: MagneticBodyStateScript,
	distance: int
) -> bool:
	return source.strength + target.strength >= distance


func resolve_interaction_type(
	source: MagneticBodyStateScript,
	target: MagneticBodyStateScript,
	direction: Vector2i
) -> String:
	var source_pole := source.get_pole_on_face(direction)
	var target_pole := target.get_pole_on_face(-direction)

	if source_pole == "" or target_pole == "":
		return ""

	if source_pole == target_pole:
		return INTERACTION_REPEL

	return INTERACTION_ATTRACT


func _get_target_move_direction(interaction_type: String, direction: Vector2i) -> Vector2i:
	if interaction_type == INTERACTION_REPEL:
		return direction

	if interaction_type == INTERACTION_ATTRACT:
		return -direction

	return Vector2i.ZERO


func _try_move_body_one_step(
	state: GameState,
	body: MagneticBodyStateScript,
	move_direction: Vector2i
) -> bool:
	if move_direction == Vector2i.ZERO:
		return false

	if not body.movable:
		return false

	var next_pos := body.pos + move_direction
	if not state.is_cell_free(next_pos):
		return false

	body.pos = next_pos
	return true
