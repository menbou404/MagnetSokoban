class_name MagnetResolver
extends RefCounted

const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")

const INTERACTION_ATTRACT := "attract"
const INTERACTION_REPEL := "repel"
const INVALID_BODY_ID := -1


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
		var moved_body_ids := _process_source(state, source, current_direction)

		if moved_body_ids.is_empty():
			continue

		for moved_body_id in moved_body_ids:
			# TODO: PHASE_05 以降で、連鎖時の起点ごとの処理方向を正式化する。
			# PHASE_04 では、最初に押した方向を連鎖中も引き継ぐ。
			pending_sources.append({
				"source_id": moved_body_id,
				"direction": current_direction,
			})


func _process_source(
	state: GameState,
	source: MagneticBodyStateScript,
	direction: Vector2i
) -> Array[int]:
	var candidate := build_interaction_candidate(state, source, direction)
	if candidate.is_empty():
		return _empty_body_id_list()

	return resolve_interaction_candidate(state, candidate)


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


func build_interaction_candidate(
	state: GameState,
	source: MagneticBodyStateScript,
	direction: Vector2i
) -> Dictionary:
	var target_info := find_first_target_in_line(state, source, direction)
	if target_info.is_empty():
		return {}

	var target := target_info["target"] as MagneticBodyStateScript
	var distance := target_info["distance"] as int

	if not can_magnetic_interaction_happen(source, target, distance):
		return {}

	var interaction_type := resolve_interaction_type(source, target, direction)
	if interaction_type == "":
		return {}

	return {
		"source_id": source.id,
		"target_id": target.id,
		"direction": direction,
		"distance": distance,
		"source_strength": source.strength,
		"target_strength": target.strength,
		"combined_strength": source.strength + target.strength,
		"interaction_type": interaction_type,
		# TODO: 強い磁力の厳密な比較式は未確定。
		# PHASE_04 では source/target の strength の大小を優先度として使う。
		"priority_score": max(source.strength, target.strength),
	}


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


func resolve_interaction_candidate(state: GameState, candidate: Dictionary) -> Array[int]:
	var source_strength := candidate["source_strength"] as int
	var target_strength := candidate["target_strength"] as int

	if source_strength == target_strength:
		return _resolve_equal_strength_interaction(state, candidate)

	return _resolve_stronger_interaction(state, candidate)


func _resolve_stronger_interaction(state: GameState, candidate: Dictionary) -> Array[int]:
	var source_strength := candidate["source_strength"] as int
	var target_strength := candidate["target_strength"] as int

	var planned_move := {}
	if source_strength > target_strength:
		planned_move = _plan_target_move(state, candidate)
	else:
		planned_move = _plan_source_move(state, candidate)

	if planned_move.is_empty():
		return _empty_body_id_list()

	var planned_moves: Array[Dictionary] = []
	planned_moves.append(planned_move)
	if not _are_planned_moves_valid(state, planned_moves):
		return _empty_body_id_list()

	apply_planned_moves(state, planned_moves)
	var moved_ids: Array[int] = []
	moved_ids.append(planned_move["body_id"] as int)
	return moved_ids


func _resolve_equal_strength_interaction(state: GameState, candidate: Dictionary) -> Array[int]:
	var moved_ids: Array[int] = []
	var source_id := candidate["source_id"] as int
	var target_id := candidate["target_id"] as int
	var direction := candidate["direction"] as Vector2i

	while true:
		var source := state.get_body_by_id(source_id)
		var target := state.get_body_by_id(target_id)
		if source == null or target == null:
			break

		var distance := _get_line_distance(source.pos, target.pos, direction)
		if distance <= 0:
			break

		if not can_magnetic_interaction_happen(source, target, distance):
			break

		var interaction_type := resolve_interaction_type(source, target, direction)
		if interaction_type == "":
			break

		var planned_moves: Array[Dictionary] = []
		var source_move := _plan_single_step_move(
			state,
			source,
			_get_source_move_direction(interaction_type, direction)
		)
		var target_move := _plan_single_step_move(
			state,
			target,
			_get_target_move_direction(interaction_type, direction)
		)

		if source_move.is_empty() or target_move.is_empty():
			break

		planned_moves.append(source_move)
		planned_moves.append(target_move)

		if not _are_planned_moves_valid(state, planned_moves):
			break

		apply_planned_moves(state, planned_moves)
		_append_unique_body_id(moved_ids, source_id)
		_append_unique_body_id(moved_ids, target_id)

	return moved_ids


func _plan_source_move(state: GameState, candidate: Dictionary) -> Dictionary:
	var source := state.get_body_by_id(candidate["source_id"] as int)
	if source == null:
		return {}

	var interaction_type := candidate["interaction_type"] as String
	var direction := candidate["direction"] as Vector2i
	return _plan_single_step_move(
		state,
		source,
		_get_source_move_direction(interaction_type, direction)
	)


func _plan_target_move(state: GameState, candidate: Dictionary) -> Dictionary:
	var target := state.get_body_by_id(candidate["target_id"] as int)
	if target == null:
		return {}

	var interaction_type := candidate["interaction_type"] as String
	var direction := candidate["direction"] as Vector2i
	return _plan_single_step_move(
		state,
		target,
		_get_target_move_direction(interaction_type, direction)
	)


func _get_source_move_direction(interaction_type: String, direction: Vector2i) -> Vector2i:
	if interaction_type == INTERACTION_REPEL:
		return -direction

	if interaction_type == INTERACTION_ATTRACT:
		return direction

	return Vector2i.ZERO


func _get_target_move_direction(interaction_type: String, direction: Vector2i) -> Vector2i:
	if interaction_type == INTERACTION_REPEL:
		return direction

	if interaction_type == INTERACTION_ATTRACT:
		return -direction

	return Vector2i.ZERO


func _plan_single_step_move(
	state: GameState,
	body: MagneticBodyStateScript,
	move_direction: Vector2i
) -> Dictionary:
	if move_direction == Vector2i.ZERO:
		return {}

	if not body.movable:
		return {}

	var next_pos := body.pos + move_direction
	if not state.is_inside_board(next_pos):
		return {}

	if state.is_wall(next_pos):
		return {}

	return {
		"body_id": body.id,
		"from": body.pos,
		"to": next_pos,
	}


func _are_planned_moves_valid(state: GameState, planned_moves: Array[Dictionary]) -> bool:
	if planned_moves.is_empty():
		return false

	var moving_body_ids := {}
	var destinations := {}

	for planned_move in planned_moves:
		var body_id := planned_move["body_id"] as int
		var from_pos := planned_move["from"] as Vector2i
		var to_pos := planned_move["to"] as Vector2i
		var body := state.get_body_by_id(body_id)

		if body == null:
			return false

		if moving_body_ids.has(body_id):
			return false

		if body.pos != from_pos:
			return false

		if not state.is_inside_board(to_pos) or state.is_wall(to_pos):
			return false

		if to_pos == state.player_pos:
			return false

		if destinations.has(to_pos):
			return false

		moving_body_ids[body_id] = true
		destinations[to_pos] = true

	for planned_move in planned_moves:
		var body_id := planned_move["body_id"] as int
		var to_pos := planned_move["to"] as Vector2i
		var occupying_body := state.get_body_at(to_pos)

		if occupying_body != null and not moving_body_ids.has(occupying_body.id):
			return false

		for other_move in planned_moves:
			var other_body_id := other_move["body_id"] as int
			if body_id == other_body_id:
				continue

			var from_pos := planned_move["from"] as Vector2i
			var other_from_pos := other_move["from"] as Vector2i
			var other_to_pos := other_move["to"] as Vector2i
			if from_pos == other_to_pos and to_pos == other_from_pos:
				return false

	return true


func apply_planned_moves(state: GameState, planned_moves: Array[Dictionary]) -> void:
	for planned_move in planned_moves:
		var body := state.get_body_by_id(planned_move["body_id"] as int)
		if body == null:
			continue

		body.pos = planned_move["to"] as Vector2i


func _get_line_distance(from_pos: Vector2i, to_pos: Vector2i, direction: Vector2i) -> int:
	var delta := to_pos - from_pos

	if direction.x != 0:
		if delta.y != 0:
			return INVALID_BODY_ID
		if sign(delta.x) != sign(direction.x):
			return INVALID_BODY_ID
		return abs(delta.x)

	if direction.y != 0:
		if delta.x != 0:
			return INVALID_BODY_ID
		if sign(delta.y) != sign(direction.y):
			return INVALID_BODY_ID
		return abs(delta.y)

	return INVALID_BODY_ID


func _append_unique_body_id(body_ids: Array[int], body_id: int) -> void:
	if body_ids.has(body_id):
		return

	body_ids.append(body_id)


func _empty_body_id_list() -> Array[int]:
	var body_ids: Array[int] = []
	return body_ids
