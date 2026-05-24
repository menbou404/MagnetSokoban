class_name MagnetResolver
extends RefCounted

const ActionEventScript := preload("res://scripts/core/ActionEvent.gd")
const MagneticBodyStateScript := preload("res://scripts/core/MagneticBodyState.gd")
const RotationResolverScript := preload("res://scripts/systems/RotationResolver.gd")
const TurnResultScript := preload("res://scripts/core/TurnResult.gd")

const INTERACTION_ATTRACT := "attract"
const INTERACTION_REPEL := "repel"
const INVALID_BODY_ID := -1
const MAX_FIELD_SETTLE_STEPS := 128

const FIELD_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

var _rotation_resolver: RefCounted


func _init(rotation_resolver: RefCounted = null) -> void:
	if rotation_resolver == null:
		_rotation_resolver = RotationResolverScript.new()
	else:
		_rotation_resolver = rotation_resolver


func settle_magnetic_field(
	state: GameState,
	turn_result: TurnResultScript
) -> void:
	var seen_state_keys := {}
	var reached_max_steps := true

	for step in range(MAX_FIELD_SETTLE_STEPS):
		var state_key := _make_field_state_key(state)
		if seen_state_keys.has(state_key):
			push_warning("Magnetic field settle loop detected: %s" % state_key)
			reached_max_steps = false
			break

		seen_state_keys[state_key] = true

		var candidates := build_field_interaction_candidates(state)
		if candidates.is_empty():
			reached_max_steps = false
			break

		var selected_candidates := _get_strongest_candidates(candidates)
		if selected_candidates.is_empty():
			reached_max_steps = false
			break

		_add_magnet_trigger_events(turn_result, selected_candidates)

		var moved_body_ids := resolve_interaction_candidates(
			state,
			selected_candidates,
			turn_result
		)

		if moved_body_ids.is_empty():
			reached_max_steps = false
			break

	if reached_max_steps:
		push_warning("Magnetic field settle reached max steps: %d" % MAX_FIELD_SETTLE_STEPS)


func build_field_interaction_candidates(state: GameState) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var seen_pairs := {}

	for source_body in state.bodies:
		var source := source_body as MagneticBodyStateScript
		if source == null:
			continue

		for direction in FIELD_DIRECTIONS:
			var candidate := build_interaction_candidate(state, source, direction)
			if candidate.is_empty():
				continue

			var pair_key := _make_pair_key(
				candidate["source_id"] as int,
				candidate["target_id"] as int
			)

			if seen_pairs.has(pair_key):
				var existing_index := seen_pairs[pair_key] as int
				if _should_replace_duplicate_candidate(state, candidates[existing_index], candidate):
					candidates[existing_index] = candidate
				continue

			seen_pairs[pair_key] = candidates.size()
			candidates.append(candidate)

	return candidates


func apply_after_push(
	state: GameState,
	source_id: int,
	dir: Vector2i,
	turn_result: TurnResultScript
) -> void:
	var source_ids: Array[int] = []
	source_ids.append(source_id)
	apply_after_push_sources(state, source_ids, dir, turn_result)


func apply_after_push_sources(
	state: GameState,
	source_ids: Array[int],
	dir: Vector2i,
	turn_result: TurnResultScript
) -> void:
	if dir == Vector2i.ZERO:
		return

	var processed_sources := {}
	var pending_sources: Array[Dictionary] = []
	var primary_source_ids := _collect_unique_source_ids(source_ids)
	var primary_moved_body_ids := _process_source_batch(
		state,
		primary_source_ids,
		dir,
		turn_result
	)

	for source_id in primary_source_ids:
		processed_sources[source_id] = true

	for moved_body_id in primary_moved_body_ids:
		var force_reprocess := moved_body_id < 0
		pending_sources.append({
			"source_id": abs(moved_body_id),
			"direction": dir,
			"force_reprocess": force_reprocess,
		})

	while not pending_sources.is_empty():
		var current: Dictionary = pending_sources.pop_front()
		var current_source_id := current["source_id"] as int
		var current_direction := current["direction"] as Vector2i
		var force_reprocess := current.get("force_reprocess", false) as bool

		if processed_sources.has(current_source_id) and not force_reprocess:
			continue

		var source := state.get_body_by_id(current_source_id)
		if source == null:
			continue

		processed_sources[current_source_id] = true
		var moved_body_ids := _process_source(state, source, current_direction, turn_result)

		if moved_body_ids.is_empty():
			continue

		for moved_body_id in moved_body_ids:
			var moved_force_reprocess := moved_body_id < 0
			# TODO: PHASE_05 以降で、連鎖時の起点ごとの処理方向を正式化する。
			# PHASE_04 では、最初に押した方向を連鎖中も引き継ぐ。
			pending_sources.append({
				"source_id": abs(moved_body_id),
				"direction": current_direction,
				"force_reprocess": moved_force_reprocess,
			})


func _process_source(
	state: GameState,
	source: MagneticBodyStateScript,
	direction: Vector2i,
	turn_result: TurnResultScript
) -> Array[int]:
	var source_ids: Array[int] = []
	source_ids.append(source.id)
	return _process_source_batch(state, source_ids, direction, turn_result)


func _process_source_batch(
	state: GameState,
	source_ids: Array[int],
	direction: Vector2i,
	turn_result: TurnResultScript
) -> Array[int]:
	var candidates: Array[Dictionary] = []

	for source_id in source_ids:
		var source := state.get_body_by_id(source_id)
		if source == null:
			continue

		if not source.movable:
			continue

		var candidate := build_interaction_candidate(state, source, direction)
		if candidate.is_empty():
			continue

		candidates.append(candidate)

	if candidates.is_empty():
		return _empty_body_id_list()

	_add_magnet_trigger_events(turn_result, candidates)

	return resolve_interaction_candidates(state, candidates, turn_result)


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


func resolve_interaction_candidate(
	state: GameState,
	candidate: Dictionary,
	turn_result: TurnResultScript
) -> Array[int]:
	var source := state.get_body_by_id(candidate["source_id"] as int)
	var target := state.get_body_by_id(candidate["target_id"] as int)
	if source == null or target == null:
		return _empty_body_id_list()

	if not source.movable and not target.movable:
		return _empty_body_id_list()

	if source.movable != target.movable:
		return _resolve_single_movable_interaction(state, candidate, turn_result)

	var source_strength := candidate["source_strength"] as int
	var target_strength := candidate["target_strength"] as int

	if source_strength == target_strength:
		return _resolve_equal_strength_interaction(state, candidate, turn_result)

	return _resolve_stronger_interaction(state, candidate, turn_result)


func resolve_interaction_candidates(
	state: GameState,
	candidates: Array[Dictionary],
	turn_result: TurnResultScript
) -> Array[int]:
	if candidates.is_empty():
		return _empty_body_id_list()

	if candidates.size() == 1:
		return resolve_interaction_candidate(state, candidates[0], turn_result)

	var strongest_priority := -1
	for candidate in candidates:
		strongest_priority = maxi(strongest_priority, candidate["priority_score"] as int)

	var strongest_candidates: Array[Dictionary] = []
	for candidate in candidates:
		if (candidate["priority_score"] as int) == strongest_priority:
			strongest_candidates.append(candidate)

	if strongest_candidates.size() == 1:
		return resolve_interaction_candidate(state, strongest_candidates[0], turn_result)

	var planned_moves: Array[Dictionary] = []
	for candidate in strongest_candidates:
		var candidate_moves := _plan_candidate_first_step(state, candidate)
		for candidate_move in candidate_moves:
			planned_moves.append(candidate_move)

	if planned_moves.is_empty():
		return _empty_body_id_list()

	if not _are_planned_moves_valid(state, planned_moves):
		return _empty_body_id_list()

	apply_planned_moves(state, planned_moves)
	_add_planned_moves_event(turn_result, planned_moves)

	var moved_ids: Array[int] = []
	for planned_move in planned_moves:
		_append_unique_body_id(moved_ids, planned_move["body_id"] as int)

	return moved_ids


func _resolve_stronger_interaction(
	state: GameState,
	candidate: Dictionary,
	turn_result: TurnResultScript
) -> Array[int]:
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
	_add_body_move_event(turn_result, planned_move, candidate)
	var moved_ids: Array[int] = []
	var moved_body_id := planned_move["body_id"] as int
	if moved_body_id == (candidate["source_id"] as int) and _candidate_has_fixed_magnet(state, candidate):
		moved_body_id = -moved_body_id
	moved_ids.append(moved_body_id)
	return moved_ids


func _resolve_single_movable_interaction(
	state: GameState,
	candidate: Dictionary,
	turn_result: TurnResultScript
) -> Array[int]:
	var source := state.get_body_by_id(candidate["source_id"] as int)
	var target := state.get_body_by_id(candidate["target_id"] as int)
	if source == null or target == null:
		return _empty_body_id_list()

	var planned_move := {}
	if source.movable:
		planned_move = _plan_source_move(state, candidate)
	elif target.movable:
		planned_move = _plan_target_move(state, candidate)

	if planned_move.is_empty():
		return _empty_body_id_list()

	var planned_moves: Array[Dictionary] = []
	planned_moves.append(planned_move)
	if not _are_planned_moves_valid(state, planned_moves):
		return _empty_body_id_list()

	apply_planned_moves(state, planned_moves)
	_add_body_move_event(turn_result, planned_move, candidate)
	var moved_ids: Array[int] = []
	var moved_body_id := planned_move["body_id"] as int
	if moved_body_id == (candidate["source_id"] as int) and _candidate_has_fixed_magnet(state, candidate):
		moved_body_id = -moved_body_id
	moved_ids.append(moved_body_id)
	return moved_ids


func _plan_candidate_first_step(state: GameState, candidate: Dictionary) -> Array[Dictionary]:
	var planned_moves: Array[Dictionary] = []
	var source := state.get_body_by_id(candidate["source_id"] as int)
	var target := state.get_body_by_id(candidate["target_id"] as int)
	if source == null or target == null:
		return planned_moves

	if not source.movable and not target.movable:
		return planned_moves

	if source.movable != target.movable:
		var single_move := {}
		if source.movable:
			single_move = _plan_source_move(state, candidate)
		else:
			single_move = _plan_target_move(state, candidate)

		if single_move.is_empty():
			return planned_moves

		single_move["reason"] = candidate["interaction_type"] as String
		planned_moves.append(single_move)
		return planned_moves

	var source_strength := candidate["source_strength"] as int
	var target_strength := candidate["target_strength"] as int

	if source_strength == target_strength:
		var interaction_type := candidate["interaction_type"] as String
		var direction := candidate["direction"] as Vector2i
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
			return _empty_planned_move_list()

		source_move["reason"] = interaction_type
		target_move["reason"] = interaction_type
		planned_moves.append(source_move)
		planned_moves.append(target_move)
		return planned_moves

	var planned_move := {}
	if source_strength > target_strength:
		planned_move = _plan_target_move(state, candidate)
	else:
		planned_move = _plan_source_move(state, candidate)

	if planned_move.is_empty():
		return planned_moves

	planned_move["reason"] = candidate["interaction_type"] as String
	planned_moves.append(planned_move)
	return planned_moves


func _resolve_equal_strength_interaction(
	state: GameState,
	candidate: Dictionary,
	turn_result: TurnResultScript
) -> Array[int]:
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
		_add_simultaneous_move_event(turn_result, planned_moves, candidate)
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
	var moved_bodies: Array = []

	for planned_move in planned_moves:
		var body := state.get_body_by_id(planned_move["body_id"] as int)
		if body == null:
			continue

		body.pos = planned_move["to"] as Vector2i
		moved_bodies.append(body)

	_rotation_resolver.apply_rotation_tiles(state, moved_bodies)


func _add_body_move_event(
	turn_result: TurnResultScript,
	planned_move: Dictionary,
	candidate: Dictionary
) -> void:
	if turn_result == null:
		return

	var from_pos := planned_move["from"] as Vector2i
	var to_pos := planned_move["to"] as Vector2i
	turn_result.add_event(ActionEventScript.body_move(
		turn_result.allocate_phase(),
		planned_move["body_id"] as int,
		from_pos,
		to_pos,
		to_pos - from_pos,
		candidate["interaction_type"] as String
	))


func _add_simultaneous_move_event(
	turn_result: TurnResultScript,
	planned_moves: Array[Dictionary],
	candidate: Dictionary
) -> void:
	if turn_result == null:
		return

	var event_moves: Array[Dictionary] = []
	for planned_move in planned_moves:
		var from_pos := planned_move["from"] as Vector2i
		var to_pos := planned_move["to"] as Vector2i
		event_moves.append({
			"body_id": planned_move["body_id"] as int,
			"from": from_pos,
			"to": to_pos,
			"direction": to_pos - from_pos,
			"reason": candidate["interaction_type"] as String,
		})

	turn_result.add_event(ActionEventScript.simultaneous_move(
		turn_result.allocate_phase(),
		event_moves
	))


func _add_planned_moves_event(
	turn_result: TurnResultScript,
	planned_moves: Array[Dictionary]
) -> void:
	if turn_result == null:
		return

	var event_moves: Array[Dictionary] = []
	for planned_move in planned_moves:
		var from_pos := planned_move["from"] as Vector2i
		var to_pos := planned_move["to"] as Vector2i
		event_moves.append({
			"body_id": planned_move["body_id"] as int,
			"from": from_pos,
			"to": to_pos,
			"direction": to_pos - from_pos,
			"reason": planned_move.get("reason", ""),
		})

	turn_result.add_event(ActionEventScript.simultaneous_move(
		turn_result.allocate_phase(),
		event_moves
	))


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


func _collect_unique_source_ids(source_ids: Array[int]) -> Array[int]:
	var unique_ids: Array[int] = []
	for source_id in source_ids:
		_append_unique_body_id(unique_ids, source_id)
	return unique_ids


func _candidate_has_fixed_magnet(state: GameState, candidate: Dictionary) -> bool:
	var source := state.get_body_by_id(candidate["source_id"] as int)
	var target := state.get_body_by_id(candidate["target_id"] as int)
	if source != null and source.is_fixed_magnet():
		return true
	if target != null and target.is_fixed_magnet():
		return true
	return false


func _get_strongest_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	if candidates.is_empty():
		return selected

	var strongest_priority := -1
	for candidate in candidates:
		strongest_priority = maxi(strongest_priority, candidate["priority_score"] as int)

	for candidate in candidates:
		if (candidate["priority_score"] as int) == strongest_priority:
			selected.append(candidate)

	return selected


func _add_magnet_trigger_events(
	turn_result: TurnResultScript,
	candidates: Array[Dictionary]
) -> void:
	if turn_result == null or candidates.is_empty():
		return

	var trigger_phase := turn_result.allocate_phase()
	for candidate in candidates:
		turn_result.add_event(ActionEventScript.magnet_trigger(
			trigger_phase,
			candidate["source_id"] as int,
			candidate["direction"] as Vector2i,
			candidate["target_id"] as int,
			candidate["interaction_type"] as String
		))


func _make_pair_key(a: int, b: int) -> String:
	var low := mini(a, b)
	var high := maxi(a, b)
	return "%d:%d" % [low, high]


func _should_replace_duplicate_candidate(
	state: GameState,
	current_candidate: Dictionary,
	next_candidate: Dictionary
) -> bool:
	var current_source := state.get_body_by_id(current_candidate["source_id"] as int)
	var next_source := state.get_body_by_id(next_candidate["source_id"] as int)

	if current_source == null or next_source == null:
		return false

	return next_source.is_fixed_magnet() and not current_source.is_fixed_magnet()


func _make_field_state_key(state: GameState) -> String:
	var parts: Array[String] = []

	for body in state.bodies:
		parts.append("%d:%s:%d,%d:%d,%d:%d:%s" % [
			body.id,
			body.kind,
			body.pos.x,
			body.pos.y,
			body.facing.x,
			body.facing.y,
			body.strength,
			str(body.movable),
		])

	parts.sort()
	return "|".join(parts)


func _empty_body_id_list() -> Array[int]:
	var body_ids: Array[int] = []
	return body_ids


func _empty_planned_move_list() -> Array[Dictionary]:
	var planned_moves: Array[Dictionary] = []
	return planned_moves
